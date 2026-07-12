# Clean Architecture

Each business feature follows this dependency direction:

`presentation -> application -> domain`

`data -> domain`

The application composition layer wires repository implementations to
Riverpod providers. Inner layers never import outer layers.

API flow:

`presentation -> application use case -> domain repository contract`

`data repository -> remote data source -> ApiClient -> backend`

The local repositories stay usable for offline/demo mode. API repository
adapters can replace or compose them without changing the UI or business
rules. See `API_INTEGRATION.md` for the backend contract and rollout steps.

## Layer responsibilities

- `domain`: entities and repository contracts; plain Dart only.
- `application`: use cases and business services; depends only on domain.
- `data`: persistence, platform services, DTO mapping, and repository
  implementations.
- `presentation`: widgets, navigation, Riverpod state, and UI formatting.
- `core`: feature-independent configuration and utilities. It must not
  re-export feature presentation code.

The dependency rules are enforced by
`test/architecture/dependency_rule_test.dart`.
