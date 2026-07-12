# Clean Architecture rules

Every feature follows this dependency direction:

```text
presentation -> application -> domain
data -----------------------> domain/application
app/di ---------------------> all implementations
```

Dependencies must always point inward. `domain` knows nothing about Flutter,
Riverpod, HTTP, storage, or JSON. `application` coordinates domain contracts
and contains no Flutter or data imports. `data` implements inner contracts.
`presentation` renders state and calls contracts through injected providers.
Only `app/di` chooses local versus remote implementations.

## Adding a new API

Use this structure:

```text
modules/<feature>/
  domain/
    entities/
    repositories/<feature>_repository.dart
  application/
    services/                         # optional use cases
  data/
    datasources/<feature>_remote_data_source.dart
    mappers/<feature>_api_mapper.dart
    repositories/<feature>_remote_repository.dart
  presentation/
    providers/
    screens/
```

The required flow is:

```text
Widget/Notifier
  -> domain repository interface
  -> data repository implementation
  -> remote data source
  -> ApiClient
```

Rules:

- Put endpoint paths and raw request/response handling only in a data source.
- Put JSON-to-domain conversion only in a mapper or data repository.
- Return domain entities from repositories; never return raw JSON to UI code.
- Expose repository interfaces from `domain/repositories`.
- Declare provider tokens in presentation using only domain/application types.
- Wire concrete implementations in `lib/app/di/app_dependency_overrides.dart`.
- Await mutations and propagate failures to presentation; never report success
  before the request completes.
- Do not swallow API errors in repositories. A deliberate offline repository
  may handle them, but it must make that behavior explicit.
- Do not hardcode server URLs, tenant IDs, credentials, OTPs, or payment
  references.
- Keep `shopId` and display names as separate values.
- Always obtain HTTP clients from `apiClientProvider` and file transfers from
  `apiFileTransferProvider`. Their shared activity tracker automatically drives
  the global animated API loader; constructing a transport elsewhere bypasses
  both authentication policy and loading feedback.

## Provider token example

```dart
final customerRepositoryProvider = Provider<CustomerRepository>(
  (_) => throw UnimplementedError('Override customerRepositoryProvider'),
);
```

Then add its concrete local/remote selection to the composition root.

## Enforcement

`test/architecture/dependency_rule_test.dart` rejects:

- data imports from presentation;
- HTTP clients/endpoints outside data sources;
- Flutter or persistence dependencies in domain/application;
- concrete repository or data-source construction in presentation;
- feature-presentation dependencies from core.

Run the architecture test with the project-supported Flutter SDK before
merging changes.

## Offline-first policy

- Successful GET responses are cached in SharedPreferences per authenticated
  session. Retryable network failures return the latest cached response.
- Feature repositories mirror products, product settings, expenses, purchases,
  business settings, suppliers, sales history, and notifications locally.
- Mutations marked with `X-Queue-If-Offline: true` are persisted in
  SharedPreferences and replayed when the API becomes reachable.
- Create/payment/accounting requests must include an `Idempotency-Key` or a
  stable `client_id`; otherwise they must not be queued.
- Authentication, validation, permission, and tenant failures must never be
  hidden behind cached data.
- Logout clears session-scoped API response caches and pending mutations so
  one user's offline work can never sync under another user's tenant session.
