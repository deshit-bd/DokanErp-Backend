# API Integration Guide

The app now has a reusable API transport, token refresh, normalized errors,
environment configuration, Riverpod wiring, and remote data sources for the
ERP modules. The existing local repositories remain active until a real API
contract is supplied.

## Configure an environment

Do not hard-code server URLs or secrets. Pass configuration at build time:

```bash
flutter run \
  --dart-define=DOKAN_API_ENABLED=true \
  --dart-define=DOKAN_API_BASE_URL=https://staging.example.com \
  --dart-define=DOKAN_ENV=staging
```

The same flags work with `flutter build apk`. Optional timeout flags are
`DOKAN_API_CONNECT_TIMEOUT_SECONDS` and
`DOKAN_API_RECEIVE_TIMEOUT_SECONDS`.

This project requires Flutter 3.27 or newer. It uses the wide-gamut Color API
introduced in Flutter 3.27 and dependencies that require Dart 3.4 or newer.

Optional catalog safety flags:

```bash
--dart-define=DOKAN_API_SYNC_DELETIONS=false
--dart-define=DOKAN_API_SEED_EMPTY_CATALOG=false
```

Remote deletion and automatic demo-product seeding are disabled by default so
a new or temporarily empty backend cannot accidentally lose or gain products.

## Expected response contract

Object:

```json
{
  "data": {"id": "123"},
  "message": "Success"
}
```

List:

```json
{
  "data": [{"id": "123"}],
  "meta": {
    "current_page": 1,
    "per_page": 50,
    "total": 1,
    "last_page": 1
  }
}
```

Validation error:

```json
{
  "message": "Validation failed",
  "errors": {"phone": ["Phone is required"]}
}
```

The client accepts both snake_case and camelCase token and pagination fields.
Authentication responses may contain tokens directly inside `data` or in a
`data.tokens` object. Token expiry may be an ISO `expires_at` value or numeric
`expires_in` seconds.

## Backend requirements

- HTTPS in staging and production.
- JSON requests and responses using UTF-8.
- Bearer access tokens and refresh-token rotation.
- HTTP status codes: 400/409/422 validation, 401 authentication, 403
  authorization, 404 missing resource, and 5xx server failure.
- `X-Request-Id` on responses for support and logging.
- `Idempotency-Key` support for sales, purchases, and payment mutations.
- Server-side pagination and stable resource IDs.
- Atomic stock updates when sales are completed or purchases are received.
- UTC ISO-8601 timestamps; send store timezone separately when needed.

## Integration workflow

1. Confirm the real endpoint paths in `ApiEndpoints`.
2. Match request fields in each feature's `*RemoteDataSource`.
3. Add DTO-to-domain mapping inside the data layer.
4. Implement API repository adapters against the existing domain repository
   contracts.
5. Switch Riverpod repository providers from local to remote, or compose a
   local-first sync repository.
6. Run contract tests against staging before enabling
   `DOKAN_API_ENABLED=true` in production.

Presentation, application, and domain layers must not parse JSON or reference
the network client.

## Current automatic API wiring

When `DOKAN_API_ENABLED=true` and the base URL is valid, Riverpod switches the
following features from local persistence to remote adapters:

- Owner/staff login, registration, OTP verification, token refresh, logout.
- Product catalogue synchronization, stock and price mutations.
- Product categories and low-stock threshold settings.
- Purchase create/update/receive.
- POS sale creation and cancellation.
- Expense create/update/delete.
- Inventory and store settings.

API mode remains disabled by default, so demo/local mode continues to work
without a backend.

## Offline mutation queue

Financial and inventory mutations opt into a persistent queue. Retryable
connection, timeout, rate-limit, and server failures are stored locally and
retried when the API client is used again. Idempotency keys are preserved.

The backend must treat `Idempotency-Key` as unique per store and operation.
Validation and authorization failures are never queued.

## Files

`apiFileTransferProvider` supports authenticated multipart upload and binary
download on mobile, desktop, and web. Use it for product images, receipts,
invoices, and report exports. Private files should be returned through
short-lived signed URLs.

## Security and platform notes

`ApiSessionStore` isolates token persistence from authentication code. Access
and refresh tokens use encrypted platform storage. Existing development
sessions previously stored in SharedPreferences are migrated once and removed.

The current `dart:io` transport supports Android, iOS, Windows, macOS, and
Linux. Web builds use the browser HTTP transport selected by
`api_client_factory.dart`.
