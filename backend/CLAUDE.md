# Backend Architecture Rules (Clean Architecture)

This backend is mid-migration to Uncle Bob Clean Architecture: 4 concentric
layers, dependencies only point inward. The dependency rule is enforced by
ESLint (`eslint.config.js`, `boundaries/element-types` + `no-restricted-imports`)
— a lint failure on a cross-layer import is a build-blocking error, not a
style nit. Run `npm run lint` before committing.

## Layers (inner to outer; each may only import itself or further inward)

1. **`src/domain/`** — Entities. Plain TypeScript types + pure functions only.
   Never import `express`, `PrismaClient`, `zod`, or any I/O library here.
   **One named exception**: Prisma-generated *enum* value types (e.g.
   `CategoryStatus`) may be imported — they're schema-level value types, not
   the ORM. Do not extend this to models, `PrismaClient`, or query builders.
2. **`src/application/`** — Use cases, one file per use case
   (`verb-noun.use-case.ts`). Depends only on `domain/` and on *ports*
   (interfaces) declared in `application/*/ports/`. Never imports a concrete
   Prisma repository or `express` types.
3. **`src/adapters/`** — Interface adapters: HTTP controllers/routers/DTOs/
   presenters (`adapters/http/`), Prisma repository implementations of
   application ports (`adapters/persistence/prisma/`), and other
   framework-touching adapters (`adapters/storage/`). This is the only layer
   allowed to import both `express` and `@prisma/client`'s query builders.
   **Narrow, deliberate exception**: `adapters/persistence/**` may import the
   Prisma client singleton from `infrastructure/prisma/client.ts` directly —
   this app has no DI container, so repositories reach for the shared client
   instead of receiving it injected. Don't use this to justify importing
   unrelated infrastructure (e.g. the Express app/server) from adapters.
4. **`src/infrastructure/`** — Frameworks & drivers: Express app assembly
   (`infrastructure/http/app.ts`), the process entrypoint
   (`infrastructure/http/server.ts`), the Prisma client singleton
   (`infrastructure/prisma/client.ts`), background jobs
   (`infrastructure/jobs/`), env config (`infrastructure/config/` /
   `src/config/env.ts`).

**`src/routes/*.ts`** is the pre-migration codebase (legacy). It is exempt
from the boundary rules (`eslint.config.js` turns them off for that folder)
and is deleted module-by-module as each route file migrates — see "Migration
status" below. **Never add new code to `src/routes/*`.**

## Hard rules — do not do these (all found as real anti-patterns pre-migration; do not reintroduce)

- **Do not import `prisma` (the client singleton)** anywhere outside
  `src/adapters/persistence/**` and `src/infrastructure/prisma/**`. A use case
  takes a repository/port interface as a constructor parameter — it never
  imports the client directly. (`src/config/prisma.ts` is a temporary
  re-export shim for not-yet-migrated `src/routes/*` files; don't add new
  imports of it — import `@infrastructure/prisma/client` directly instead.)
- **Do not put business logic in a router/controller.** Controllers only:
  (a) read `request.validated`/`request.context`, (b) call exactly one use
  case, (c) pass the result to a presenter, (d) respond. An `if` encoding a
  business rule inside a controller belongs in `domain/` or `application/`.
- **Do not write `response.status(code).json({ message })` directly** for an
  error case. Throw a subclass of `AppError` (`src/domain/shared/app-error.ts`)
  and let `error-handler.middleware.ts` map it to a status code. (History:
  622 ad hoc instances of this across `src/routes/*` — don't add a 623rd.)
- **Every controller method must be wrapped in `asyncHandler`**
  (`adapters/http/middleware/async-handler.ts`) when registered on a router.
  This is Express **4**, not 5 — it does not forward rejected promises from an
  async handler to `next(err)` automatically. An unwrapped async controller
  that throws will produce an unhandled rejection, not an HTTP error response.
- **Do not call `getAuthenticatedUser` manually inside a route handler.**
  Auth context comes from `request.context`, populated once by
  `adapters/http/middleware/auth.middleware.ts` (`authMiddleware` +
  `requireRole(...)`). If `request.context` is missing where you need it, fix
  the middleware chain — don't re-authenticate in the handler.
- **Do not duplicate a business rule across modules "for convenience."**
  (History: bin-status derivation — `qty < 10 = LOW` — existed independently
  in 3 places: `utils/reconciliation.ts` twice, `routes/purchases.ts` once.)
  A domain rule lives in exactly one `domain/**` function, imported everywhere
  it's needed.
- **Do not let one bounded context's util/service import another context's
  route/controller file.** (History: `utils/reconciliation.ts` imported
  `ensureGeneralInventoryBin` from `routes/purchases.ts` — a backwards,
  cross-context dependency, not yet fixed as of this writing.) If two
  contexts need the same helper, it belongs in `domain/shared/` or the owning
  context's `application/` layer.
- **Do not trigger writes/mutations from a GET endpoint's use case as a
  "self-healing" side effect.** (History: `GET /inventory/stock-movements`
  runs a `$transaction` write via `reconcileProductStockAndBins`, not yet
  fixed as of this writing.) Reads call read-only use cases. If
  reconciliation-on-read is a genuine requirement, it must be an explicit,
  separately reviewed decision — not a side effect discovered by reading the
  source.
- **Do not hand-roll body/query parsing with tolerant camelCase/snake_case
  field-name aliasing inline in a controller.** Declare accepted aliases
  explicitly in the zod DTO (`adapters/http/dto/*.dto.ts`), so the accepted
  input shape is documented in one place per resource.
- **Do not return inconsistent response shapes.** Every migrated resource has
  exactly one presenter (`adapters/http/presenters/*.presenter.ts`) per
  distinct response shape (see `category.presenter.ts`'s `toCategoryDto` vs
  `toCategoryUpdateDto` for a case where the *original* endpoint shapes
  genuinely differed and were preserved deliberately, not merged). Never
  duplicate a field in both camelCase and snake_case going forward. (History:
  `routes/purchases.ts` does this extensively — not yet fixed. When it
  migrates, add a time-boxed `legacyFieldsEnabled` presenter flag rather than
  silently dropping fields a client may depend on; do not carry the
  duplication forward into new code.)
- **Do not start background jobs (`setInterval`, cron-like loops) as a bare
  side effect of importing `infrastructure/http/app.ts`.** Jobs are started
  explicitly from `infrastructure/http/server.ts` (the process entrypoint),
  so `app.ts` stays a side-effect-free Express app definition.
- **Do not add new files directly under `src/` root.** Every file there today
  (`call_sales_api.ts`, `check_db.js`, `debug-stock.ts`, etc.) is a pre-existing
  one-off debug script, excluded from lint and the TS build (see
  `eslint.config.js` ignores and `tsconfig.json` exclude). Put new one-off
  scripts in `scripts/` instead.

## Naming conventions

- Use cases: `verb-noun.use-case.ts`, exporting a class with an `execute(...)`
  method (see `src/application/category/use-cases/*` for the pattern).
- Ports: `noun-repository.port.ts`, `interface XRepository`.
- Repository implementations: `noun.repository.ts` under
  `adapters/persistence/prisma/`, named `PrismaXRepository`.
- DTOs: `noun.dto.ts` under `adapters/http/dto/`, exporting zod schemas named
  `CreateXDto`, `UpdateXDto`, etc.
- Presenters: `noun.presenter.ts`, exporting `toXDto(entity)`.
- Domain errors: `noun.errors.ts`, classes extending a base `AppError`
  subclass from `domain/shared/app-error.ts` (`ValidationError` → 400,
  `UnauthorizedError` → 401, `ForbiddenError` → 403, `NotFoundError` → 404,
  `ConflictError` → 409).

## Validation convention

Request bodies are validated by a zod schema in `adapters/http/dto/`, applied
via `validate({ body, query, params })` middleware
(`adapters/http/middleware/validate-request.middleware.ts`) before the
controller runs. Note: DTOs in the migrated modules so far are intentionally
permissive (most fields `.optional()`) because the *real* required-field
validation (with the exact original error message, e.g. "Category name is
required.") lives in the use case, to preserve byte-identical API responses
during migration. Don't tighten a DTO beyond what the original endpoint
enforced without deliberately deciding to change the contract.

**Exception**: `auth`'s controller reads `request.body` directly with no zod
DTO layer at all — the original `routes/auth.ts` never validated with a
schema library, and a strict-enough-to-be-useful zod schema across 25
endpoints' worth of loosely-typed, alias-tolerant bodies risked rejecting
input the original accepted. Every field-presence/format check still happens
in the use case, exactly as before. Don't treat this as license to skip DTOs
elsewhere — it was a deliberate, scoped call for this one already-unvalidated
module.

## Tenant scoping

Every repository method touching a shop-owned table should take `shopId` as
an explicit parameter derived from `request.context.shopId` — never silently
defaulted or sourced from multiple possible body/query fields. This isn't
fully retrofitted onto legacy `src/routes/*` yet; don't add new instances of
`shopId ?? query.shopId ?? body.shopId`-style resolution when migrating a
module — resolve it once via the auth middleware / controller instead.

## Migration status

**Done**: scaffolding, ESLint boundary enforcement, `infrastructure/http`
(app/server), `infrastructure/prisma/client.ts`, `infrastructure/jobs/otp-renewal.job.ts`,
the shared adapters (`AppError` incl. `ServiceUnavailableError`/`InternalError`/
`PaymentRequiredError`, and `details` for extra response fields like
`subscription`/`salesmanTrial`/`clearAuthCookies` — see `error-handler.middleware.ts`,
`auth.middleware`, `validate-request.middleware`, `asyncHandler`,
`PrismaUnitOfWork`, `file-storage.adapter` — used by `brand-logo-storage.adapter.ts`,
not yet wired into `products`' equivalent upload path), and four modules
end-to-end: **`categories`**, **`units`**, **`brands`**, **`auth`**. All
verified via snapshot diff against the pre-migration baseline plus extensive
manual exercises (see below for `auth` specifically).

**`auth` migration notes** (the largest and highest-risk module migrated so
far — 2652 lines, 25 endpoints):
- `src/auth/{current-user,session,jwt,cookies,constants,password,authorization}.ts`
  were deliberately **not** moved or rewritten — they're already
  framework-agnostic-enough primitives (session/JWT/cookie helpers, role
  policy) that `application/auth/*` and `adapters/http/controllers/auth.controller.ts`
  bridge into directly, the same pattern `auth.middleware.ts` already used for
  `current-user.ts`. Don't move them speculatively; if a genuine need arises
  (e.g. rewriting the JWT implementation), migrate them into
  `domain/auth`/`application/auth` deliberately at that time.
- `application/auth/ports/auth-repository.port.ts` is **one coarse repository**
  covering users/shops/OTPs/registration-drafts/refresh-tokens, unlike the
  one-repository-per-aggregate pattern used for categories/units/brands. The
  19 auth use cases share heavily cross-entity transactional logic (a user,
  shop, shopUser, and subscription are created atomically in 3 different
  flows), so splitting into micro-repositories would have multiplied file
  count without improving clarity. Follow this coarse-repository pattern only
  for `auth`; keep the fine-grained one-per-aggregate pattern everywhere else.
- Verifying an OTP and issuing a session (refresh token + access token) are
  **3 separate repository calls**, not one DB transaction like the original
  route's `prisma.$transaction`. A documented, deliberate relaxation — low
  risk (session issuance, not financial/inventory data) given the scope.
- Some legacy failure paths (invalid login credentials, a blocked salesman
  subscription trial, a revoked/expired refresh token) clear the auth cookies
  before responding. Use cases can't touch an Express `Response`, so this is
  signaled via `AppError.details.clearAuthCookies = true`, and
  `error-handler.middleware.ts` acts on that flag centrally.
- Fixed while migrating (real bugs found in the legacy code, not
  behavior changes made incidentally): `auth.middleware.ts` collapsed
  `getAuthenticatedUser`'s 404 ("user no longer exists") into a generic 401 —
  now preserves the original status code. This also fixes `categories`/
  `units`/`brands`, which share the same middleware.

Also done, end-to-end, using the same rigor as `categories`/`auth` (domain
entity/errors, application use-cases/ports, Prisma repository, presenter,
controller, router, old `src/routes/*.ts` deleted, `tsc`/`eslint` clean, and
manual endpoint exercises against the dev server): **`bank-accounts`**,
**`money-boxes`**, **`expenses`**, **`notifications`**, **`product-templates`**,
**`shops`** (`shop-profile`), **`staff`**, **`subscriptions`**, **`inventory`**.

**`inventory` migration notes** (28 endpoints — zones/racks/shelves/bins CRUD,
stock-movement adjustments, purchase-item placement):
- Uses **one coarse `InventoryRepository`** (like `auth`/`shop-profile`, not
  the one-per-aggregate pattern), because zones/racks/shelves/bins/stock
  movements/placements are all one bounded context with heavy cross-aggregate
  transactional logic (e.g. creating a rack can cascade-create shelves and
  bins in the same transaction).
- **Fixed while migrating** (structural fixes, not behavior changes):
  `ensureGeneralInventoryBin` and `reconcileProductStockAndBins` moved from
  `routes/purchases.ts` / `utils/reconciliation.ts` into
  `adapters/persistence/prisma/inventory.repository.ts` — this resolves the
  backwards dependency (`utils/reconciliation.ts` importing from
  `routes/purchases.ts`) documented as a known issue. `routes/purchases.ts`,
  `routes/customers.ts`, and `shop-profile.repository.ts` now import the
  canonical version from the inventory module instead. Bin-status derivation
  (`qty < 10 = LOW`) also collapsed from 3 duplicated inline copies into one
  `domain/inventory/inventory.entity.ts` function
  (`deriveBinStatusFromQuantity`), used by the repository, presenter, and use
  cases alike.
- **Deliberately preserved, not fixed** (behavior-parity, not a fix): `GET
  /inventory/stock-movements` still runs `reconcileProductStockAndBins` as a
  mutating side effect inside a `$transaction` before responding — the
  "mutating GET" hazard called out in the hard-rules list above. Changing
  this would alter response timing/behavior clients may depend on; flagged
  here rather than fixed silently. Revisit as a deliberate, separately
  reviewed decision if it ever causes a real problem.
- **Preserved legacy quirk**: `POST /inventory/placements` wraps its whole
  transaction in a catch-all that responds **503** (not 404/400) with the
  raw thrown error's message for "bin not found"/"purchase item not found"
  failures inside the transaction — see `PlacementBinNotFoundError`/
  `PlacementPurchaseItemNotFoundError` in `inventory.errors.ts`, both
  `ServiceUnavailableError` subclasses for this reason, unlike every other
  domain error in this module.
- **Preserved legacy quirk**: the newer CRUD endpoints (`PATCH`/`DELETE` on
  `zones/:id`, `racks/:id`, `shelves/:id`, `bins/:id`, and `POST /shelves`)
  respond **500** with a terse `"Failed to X."` message on unexpected
  failure, while every other endpoint in this module responds **503** with a
  more descriptive `"X could not be Y right now."` message — two different
  code-generations' error-handling styles in the original file, both kept
  exactly as-is (see `InternalError` vs `ServiceUnavailableError` usage in
  `inventory.controller.ts`).

Also done: **`reports`** (7 read-only endpoints — dashboard, daily sales,
purchase summary, dues summary, expense summary, profit-loss, stock value).
Uses one coarse `ReportsRepository` (pure data-fetching) with all
calculation/shaping logic in the use cases, since every report is a bespoke
aggregation rather than a CRUD aggregate. `resolve-report-shop-scope.use-case.ts`
deliberately reproduces a legacy quirk: the original computed
`auth.shopId ?? (queryShopId ?? "") ?? (bodyShopId ?? "")`, and because the
query fallback is always a defined string, `bodyShopId` was effectively dead
code — preserved as-is rather than "fixed" into a more sensible fallback
chain.

Also done: **`purchases`** — the highest-risk module (11 endpoints,
`applyApprovedPurchaseEffects`, the return flow, receive-with-recount flow).

**`purchases` migration notes**:
- Uses **one coarse `PurchaseRepository`** (like `auth`/`inventory`), since
  every mutation (`create`, `update`, `approve`, `receive`, `payments`,
  `returns`, `cancel`) shares `applyApprovedPurchaseEffects` and the money
  box/bank account resolution helpers.
- `domain/purchase/purchase.errors.ts` has ~40 named error classes. Most map
  to sensible status codes, but a deliberately large subset are
  `ServiceUnavailableError` (503) subclasses for conditions that read like
  400/404/409 business-rule violations (e.g. `OnlyApprovedPurchasesCanBeReturnedError`,
  `ReturnQuantityExceedsAvailableError`, `RejectedPurchasesCannotBeApprovedError`).
  This is **not a mistake** — the original code threw plain `Error`s inside
  `$transaction` callbacks and the outer `catch` block for each endpoint
  funneled them into a 503 using the raw message. Preserved verbatim; do not
  "fix" these into 400/409 without a deliberate, separately reviewed decision.
- **`GET /:id` has no shop scoping at all** — it calls the auth check only,
  never resolves or checks a shop context, so any authenticated user (any
  role, any shop) can fetch any purchase by id. `GetPurchaseUseCase` /
  `findPurchaseByIdUnscoped` preserve this verbatim; every other endpoint
  does scope by shop.
- **`create` vs `update` alias handling genuinely differs** — `update`
  properly honors `invoice_no`/`reference`/`note`/`payment_method` snake_case
  aliases and falls back to the existing purchase's values; `create` computes
  the same alias-fallback locals but then never uses them at the point of
  insert (uses `body.invoiceNo`/`body.notes`/`body.paymentMethod`/`body.moneyBoxId`
  directly) — those aliases are silently dead code in the original `create`
  handler only. Reproduced exactly in `create-purchase.use-case.ts` (see its
  inline comments) rather than "fixed" into parity with `update`.
- **Approving a purchase does not wire in a money box/bank account** for the
  auto-generated supplier payment — `applyApprovedPurchaseEffects` is called
  from `approvePurchase` without `moneyBoxId`/`bankAccountId`, so a
  purchase's initial `paidAmount` (set at `create` time) generates a
  `supplierPayment` + ledger entry but never decrements any money
  box/bank-account balance. Only `/:id/receive` resolves and passes an
  effective money box/bank account into the same helper. Confirmed via
  manual test (money box balance unchanged after approving a purchase with
  `paidAmount > 0`) — this is the original's actual behavior, reproduced
  as-is, not a bug introduced by migration.
- **`/:id/receive`'s catch-all doesn't special-case money-box/bank-account
  resolution failures** the way `/` and `/:id/payments` do (both of which map
  the internal `MONEY_BOX_NOT_FOUND`/`BANK_ACCOUNT_NOT_FOUND` sentinels to a
  clean 400). In `receive`, those same failure paths surface as a **503**
  with the literal string `"MONEY_BOX_NOT_FOUND"` / `"BANK_ACCOUNT_NOT_FOUND"`
  as the user-facing message — see `ReceivePurchaseMoneyBoxNotFoundError` /
  `ReceivePurchaseBankAccountNotFoundError`. Preserved verbatim.
- Approving an already-`APPROVED` purchase, or a `DRAFT` purchase (neither of
  which is `PENDING_APPROVAL`), is a silent idempotent no-op that returns the
  purchase unchanged with a 200 — only `REJECTED` throws. Same for
  `/:id/receive` when already `APPROVED`. Preserved verbatim.
- `ensureGeneralInventoryBin`/`applyApprovedPurchaseEffects`'s bin-resolution
  now imports from `adapters/persistence/prisma/inventory.repository.ts`
  (see the `inventory` migration notes above) — no more backwards dependency.

Also done: **`suppliers`** (12 API endpoints + 2 standalone WhatsApp-confirmation
HTML handlers).

**`suppliers` migration notes**:
- **No router-wide `authMiddleware`.** Unlike every other migrated module,
  `supplier.router.ts` applies no shared auth middleware at all —
  `supplier.controller.ts` bridges directly to `auth/current-user.ts`
  per-endpoint (the same primitive `auth.middleware.ts` itself wraps),
  because this module's auth requirements are genuinely heterogeneous:
  `GET /`, `POST /`, and `GET /:id` are **dual-mode** (an explicit `shopId`
  routes to a shop-finance view; its absence falls back to a platform-admin
  view requiring `SUPER_ADMIN`/`ADMIN`), and `/send-due-otp` /
  `/verify-due-otp` require **no authentication at all** in the original —
  preserved verbatim, not "fixed" into requiring a session. (Note: under the
  `/app/api` **MOBILE** scope, `infrastructure/http/app.ts`'s subscription
  gate still authenticates every non-`/auth` request before it reaches this
  router — only the **WEB** scope's `/web/api/suppliers/send-due-otp` etc.
  are genuinely open.)
- In `POST /` (`create`), the "Supplier name is required." check happens
  **before** any auth/shop resolution in the original, so an unauthenticated
  request with a missing name gets 400 before a 401/403. Reproduced by
  validating `name` in the controller before calling `resolveFinanceShop`/
  `requirePlatformUser`.
- The in-memory `supplierDueOtps` `Map` (WhatsApp OTP-less confirmation
  tokens, never persisted to the database) moved to
  `adapters/storage/supplier-due-otp.store.ts` as `supplierDueOtpStore` — a
  single shared singleton instance used by both the `/send-due-otp`/
  `/verify-due-otp` API endpoints and the top-level `/confirm-supplier-due/:token`
  HTML handlers (`handleGetConfirmSupplierDue`/`handlePostConfirmSupplierDue`,
  now exported from `supplier.controller.ts`).
- The router is mounted at **two** prefixes in `infrastructure/http/app.ts`
  (`/suppliers` and `/add-suppliers`, both pointing at the same
  `supplier.router.ts`) — preserved from the original.

**Not yet migrated** (still `src/routes/*.ts`, unrestricted by boundary
rules): `customers`, `products`.

**Known, not-yet-fixed issues carried over from the legacy code** (do not
"fix" incidentally while touching unrelated code in these files — decompose
deliberately when that module's turn comes):
- `purchase.presenter.ts`'s `toPurchaseDto` deliberately keeps duplicating
  fields in both camelCase and snake_case (e.g. `supplierId`/`supplier_id`,
  `purchaseItemId`/`purchase_item_id`) — this was `routes/purchases.ts`'s
  original response shape, kept as-is (not consolidated to one casing)
  because at least one client is assumed to depend on one of the two forms.

## New feature checklist (for a migrated module)

1. Add/extend the domain entity + pure rule functions in `domain/<context>/`.
2. Add the port (if new data access needed) in `application/<context>/ports/`.
3. Implement the use case in `application/<context>/use-cases/`.
4. Implement/extend the Prisma repository in `adapters/persistence/prisma/`.
5. Add the zod DTO in `adapters/http/dto/`.
6. Add/extend the presenter in `adapters/http/presenters/`.
7. Wire the controller + router in `adapters/http/{controllers,routers}/`.
8. Run `npm run lint` and `npm run build`; manually exercise the endpoint(s)
   (there is no automated test suite — see `scripts/snapshot-endpoints.js`
   for a lightweight before/after response-diff tool used during migration).
