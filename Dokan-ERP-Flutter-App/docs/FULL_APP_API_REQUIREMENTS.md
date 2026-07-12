# Dokan ERP Full App API Requirements

Base path: `/api/v1`

Unless marked public, every endpoint requires:

```http
Authorization: Bearer <access-token>
Accept: application/json
Content-Type: application/json
```

Sales, purchase, payment, stock, and expense creation should also accept an
`Idempotency-Key` header.

## 1. Authentication and account

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/auth/register` | Register owner using name, phone, and password/PIN |
| POST | `/auth/send-otp` | Send registration/login OTP |
| POST | `/auth/verify-otp` | Verify OTP and issue tokens |
| POST | `/auth/login` | Owner/staff login using phone and password/PIN |
| POST | `/auth/refresh` | Rotate access and refresh tokens |
| POST | `/auth/logout` | Revoke the current session |
| POST | `/auth/forgot-password` | Start password/PIN recovery |
| POST | `/auth/reset-password` | Complete password/PIN reset |
| GET | `/auth/me` | Current user, role, permissions, store, and subscription |
| PATCH | `/auth/me` | Update account profile |
| POST | `/auth/change-password` | Change owner password/PIN |
| GET | `/auth/sessions` | List active devices/sessions |
| DELETE | `/auth/sessions/{sessionId}` | Revoke a device/session |
| POST | `/devices` | Register FCM/APNs device token |
| DELETE | `/devices/{deviceId}` | Remove notification device token |

Public endpoints: register, send OTP, verify OTP, login, refresh, forgot
password, and reset password.

## 2. Store onboarding and dashboard

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/stores` | Create the owner's first store |
| GET | `/stores` | List stores accessible to the user |
| GET | `/stores/{storeId}` | Store details |
| PATCH | `/stores/{storeId}` | Update name, owner, phone, address, type, timezone |
| POST | `/stores/{storeId}/select` | Set active store/branch |
| GET | `/dashboard` | Main owner dashboard KPIs |
| GET | `/dashboard/salesman` | Salesman-specific dashboard |
| GET | `/dashboard/activity` | Recent sales, payments, stock, and staff activity |

Dashboard response should include today sales, purchase, expense, profit,
receivable, payable, low-stock count, top products, recent sales, and date
comparison.

## 3. Products and catalog

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/products` | Paginated search/filter/sort product list |
| POST | `/products` | Create a custom product |
| GET | `/products/{productId}` | Product details |
| PATCH | `/products/{productId}` | Update product information |
| DELETE | `/products/{productId}` | Archive/delete product |
| GET | `/products/barcode/{barcode}` | Find product by barcode/QR |
| GET | `/products/{productId}/history` | Price and stock history |
| PATCH | `/products/{productId}/prices` | Update purchase and sale prices |
| PATCH | `/products/{productId}/threshold` | Update product low-stock threshold |
| POST | `/products/import` | Bulk product import |
| GET | `/products/export` | Export product list |
| GET | `/master-products` | Search optional master product database |
| POST | `/master-products/{masterId}/copy` | Copy master product into store catalog |

Product fields include stable ID, barcode, name, brand, category, unit,
pack information, image, purchase price, sale price, stock, threshold, tax,
status, and timestamps.

## 4. Categories, units, taxes, and charges

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/categories` | List product categories |
| POST | `/categories` | Create category |
| PATCH | `/categories/{categoryId}` | Rename/update category |
| DELETE | `/categories/{categoryId}` | Delete/archive category |
| GET | `/units` | List units |
| POST | `/units` | Create unit |
| PATCH | `/units/{unitId}` | Update unit |
| DELETE | `/units/{unitId}` | Delete/archive unit |
| GET | `/taxes` | List configured taxes and charges |
| POST | `/taxes` | Create tax/charge |
| PATCH | `/taxes/{taxId}` | Update tax/charge |
| DELETE | `/taxes/{taxId}` | Delete tax/charge |

## 5. Inventory and stock

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/inventory` | Current inventory with stock filters |
| GET | `/inventory/summary` | Stock quantity/value and low-stock summary |
| GET | `/inventory/low-stock` | Low/out-of-stock products |
| GET | `/inventory/movements` | Paginated stock ledger |
| POST | `/inventory/movements` | Add, reduce, correct, return, or transfer stock |
| GET | `/inventory/movements/{movementId}` | Stock movement details |
| POST | `/inventory/stock-counts` | Start physical stock count |
| PATCH | `/inventory/stock-counts/{countId}` | Save counted quantities |
| POST | `/inventory/stock-counts/{countId}/complete` | Complete and reconcile count |
| GET | `/inventory/valuation` | Cost and retail stock valuation |
| GET | `/inventory/dead-stock` | Slow/dead stock list |
| GET | `/inventory/expiring` | Expiring/expired batch list |

Every stock mutation should record product, quantity, before/after stock,
type, unit cost, reference, note, actor, store location, and timestamp.

## 6. Store layout: zones, racks, shelves, and bins

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/inventory/locations` | Full zone/rack/shelf/bin tree |
| POST | `/inventory/zones` | Create zone |
| PATCH | `/inventory/zones/{zoneId}` | Update zone |
| DELETE | `/inventory/zones/{zoneId}` | Delete empty zone |
| POST | `/inventory/zones/{zoneId}/racks` | Create rack |
| PATCH | `/inventory/racks/{rackId}` | Update rack |
| DELETE | `/inventory/racks/{rackId}` | Delete empty rack |
| POST | `/inventory/racks/{rackId}/shelves` | Create shelf |
| PATCH | `/inventory/shelves/{shelfId}` | Update shelf |
| DELETE | `/inventory/shelves/{shelfId}` | Delete empty shelf |
| POST | `/inventory/shelves/{shelfId}/bins` | Create bin |
| PATCH | `/inventory/bins/{binId}` | Update bin |
| DELETE | `/inventory/bins/{binId}` | Delete empty bin |
| GET | `/inventory/bins/{binId}/stock` | Products assigned to a bin |
| POST | `/inventory/bin-assignments` | Assign/move product quantity to a bin |

## 7. Sales and POS

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/sales` | Paginated sales history and search |
| POST | `/sales` | Complete POS checkout |
| GET | `/sales/{saleId}` | Invoice, lines, payments, and cancellation details |
| POST | `/sales/{saleId}/payments` | Add due/partial payment |
| POST | `/sales/{saleId}/cancel` | Cancel sale and reverse stock/accounts |
| POST | `/sales/{saleId}/refunds` | Full or partial return/refund |
| GET | `/sales/{saleId}/invoice` | Invoice data |
| GET | `/sales/{saleId}/invoice.pdf` | Download invoice PDF |
| POST | `/sales/{saleId}/share` | Generate/share invoice link |
| GET | `/sales/summary` | Sales totals by date/status/payment method |
| GET | `/sales/daily-closing` | Current day's closing calculation |
| POST | `/sales/daily-closing` | Submit cashier/day closing |
| GET | `/sales/daily-closing/{closingId}` | Closing details |

Checkout payload should include customer, salesman, product lines, unit prices,
discount, tax, totals, payment method, paid/due amount, and method-specific
reference. Supported methods are cash, due, bKash, Nagad, Rocket, card, and
bank.

## 8. Customers and receivables

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/customers` | Search/filter customer list |
| POST | `/customers` | Create customer with optional opening due |
| GET | `/customers/{customerId}` | Profile, summary, due, and recent activity |
| PATCH | `/customers/{customerId}` | Update profile |
| DELETE | `/customers/{customerId}` | Archive customer |
| GET | `/customers/{customerId}/ledger` | Sales, payments, and adjustments |
| GET | `/customers/{customerId}/due` | Outstanding due breakdown |
| POST | `/customers/{customerId}/payments` | Collect due payment |
| POST | `/customers/{customerId}/due-adjustments` | Add/correct opening/manual due |
| GET | `/customers/due-summary` | Total receivable and due customer summary |

## 9. Suppliers and payables

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/suppliers` | Search/filter supplier list |
| POST | `/suppliers` | Create supplier |
| GET | `/suppliers/{supplierId}` | Profile, payable, purchase, and payment summary |
| PATCH | `/suppliers/{supplierId}` | Update supplier |
| DELETE | `/suppliers/{supplierId}` | Archive supplier |
| GET | `/suppliers/{supplierId}/ledger` | Purchase/payment ledger |
| POST | `/suppliers/{supplierId}/payments` | Record supplier payment |
| POST | `/suppliers/{supplierId}/adjustments` | Add/correct payable balance |
| GET | `/suppliers/payable-summary` | Total payable summary |

Supplier fields include name, phone, address, product type, credit limit, and
opening payable.

## 10. Purchases

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/purchases` | Purchase order/history list |
| POST | `/purchases` | Create purchase order |
| GET | `/purchases/{purchaseId}` | Purchase details |
| PATCH | `/purchases/{purchaseId}` | Update draft/submitted purchase |
| POST | `/purchases/{purchaseId}/submit` | Submit purchase order |
| POST | `/purchases/{purchaseId}/receive` | Fully/partially receive items |
| POST | `/purchases/{purchaseId}/returns` | Return received items |
| POST | `/purchases/{purchaseId}/cancel` | Cancel purchase |
| GET | `/purchases/summary` | Purchase totals and supplier payable summary |

Purchase lines need ordered, received, returned quantities, unit cost, batch,
expiry, location, and reference information.

## 11. Expenses

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/expenses` | Paginated/filterable expense list |
| POST | `/expenses` | Create expense |
| GET | `/expenses/{expenseId}` | Expense details |
| PATCH | `/expenses/{expenseId}` | Update expense |
| DELETE | `/expenses/{expenseId}` | Delete/archive expense |
| GET | `/expense-categories` | Expense category list |
| POST | `/expense-categories` | Create expense category |
| GET | `/expenses/summary` | KPI, category split, and trend |
| POST | `/uploads/receipts` | Upload expense receipt |

Expense fields include title, category, amount, date, note, receipt,
payment method, and paid/pending status.

## 12. Staff, roles, and permissions

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/staff` | Search/filter staff list |
| POST | `/staff` | Add staff/salesman |
| GET | `/staff/{staffId}` | Staff details and activity |
| PATCH | `/staff/{staffId}` | Update staff profile/status |
| DELETE | `/staff/{staffId}` | Archive/remove staff |
| PUT | `/staff/{staffId}/permissions` | Replace permission set |
| PUT | `/staff/{staffId}/pin` | Set/reset staff login PIN |
| POST | `/staff/{staffId}/activate` | Activate staff |
| POST | `/staff/{staffId}/deactivate` | Deactivate staff |
| GET | `/staff/{staffId}/sales` | Staff sales history and KPI |
| GET | `/staff/{staffId}/activity` | Staff audit activity |
| GET | `/permissions` | Available permission catalogue |

PIN must be hashed by the backend and must never be returned by any API.

## 13. Reports and exports

All report endpoints accept `from`, `to`, `store_id`, and optional filters.

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/reports/dashboard` | Sales, purchase, expense, profit KPI/trends |
| GET | `/reports/daily-sales` | Daily sales and payment breakdown |
| GET | `/reports/daily-purchases` | Daily purchase breakdown |
| GET | `/reports/profit-loss` | Revenue, COGS, expense, and net profit |
| GET | `/reports/stock-value` | Cost/retail stock valuation |
| GET | `/reports/stock` | Stock movement and availability report |
| GET | `/reports/expenses` | Expense summary, trend, and category breakdown |
| GET | `/reports/receivables` | Customer due ageing |
| GET | `/reports/payables` | Supplier payable ageing |
| GET | `/reports/top-products` | Ranked products by quantity/revenue/profit |
| POST | `/reports/exports` | Generate PDF/Excel report |
| GET | `/reports/exports/{exportId}` | Export status and download URL |

## 14. Notifications

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/notifications` | Paginated notifications with category/read filters |
| GET | `/notifications/unread-count` | Unread badge count |
| PATCH | `/notifications/{notificationId}/read` | Mark one as read |
| POST | `/notifications/read-all` | Mark all as read |
| DELETE | `/notifications/{notificationId}` | Delete notification |
| GET | `/notification-preferences` | Current notification settings |
| PUT | `/notification-preferences` | Save event/channel preferences |

Preference events include low stock, new sale, new customer, payment received,
daily report, weekly report, staff activity, and system update. Channels
include push, email, and SMS, plus sound and vibration flags.

## 15. Business settings

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/settings/inventory` | Inventory mode and stock settings |
| PUT | `/settings/inventory` | Save thresholds, costing, expiry, bin rules |
| GET | `/settings/sales` | Sales, invoice, tax, and checkout settings |
| PUT | `/settings/sales` | Save sales settings |
| GET | `/settings/store` | Store profile settings |
| PUT | `/settings/store` | Save store profile settings |
| GET | `/settings/app` | Language, currency, timezone, and formatting |
| PUT | `/settings/app` | Save app preferences |

## 16. Subscription and billing

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/subscription/plans` | Available plans and features |
| GET | `/subscription` | Current plan, limits, and expiry |
| POST | `/subscription/checkout` | Start plan purchase/renewal |
| POST | `/subscription/verify-payment` | Verify payment transaction |
| GET | `/subscription/invoices` | Billing history |
| GET | `/subscription/usage` | Product, staff, store, and feature usage limits |
| POST | `/subscription/cancel` | Cancel auto-renewal |

Payment gateway webhooks are backend-only and should not trust success data
sent directly by the app.

## 17. Support, files, and system

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/uploads/images` | Upload product/store/profile image |
| DELETE | `/uploads/{fileId}` | Delete unused upload |
| GET | `/help/articles` | Help centre content |
| POST | `/support/tickets` | Create support request |
| GET | `/support/tickets` | User's support tickets |
| GET | `/support/tickets/{ticketId}` | Ticket conversation |
| POST | `/support/tickets/{ticketId}/messages` | Reply to ticket |
| GET | `/app/version` | Minimum/latest app version and update message |
| GET | `/system/health` | Public/basic service availability |

## 18. Recommended common query parameters

```text
page, per_page, search, sort, direction, status, category_id,
staff_id, customer_id, supplier_id, payment_method, from, to,
min_amount, max_amount, store_id
```

List responses should return pagination metadata:

```json
{
  "data": [],
  "meta": {
    "current_page": 1,
    "per_page": 50,
    "total": 0,
    "last_page": 1
  }
}
```

## 19. Backend rules required for safe integration

- Use UUID/ULID stable IDs; do not use names or phone numbers as resource IDs.
- Store money as integer minor units or a documented fixed decimal type.
- Perform sale, purchase receive, return, and payment accounting atomically.
- Prevent negative stock unless store settings explicitly allow it.
- Never accept calculated totals blindly; recalculate prices, tax, discount,
  stock, due, profit, and payable on the server.
- Use UTC ISO-8601 timestamps and return the store timezone.
- Return `X-Request-Id` for every request.
- Keep an immutable audit log for stock, payment, cancellation, permission,
  and settings changes.
- Apply store/tenant isolation to every query.
- Enforce permissions on the backend, not only in Flutter.
- Support soft deletion for financial and audit-sensitive records.
- Rate-limit login, OTP, PIN, and password-reset endpoints.

## 20. Delivery priority

### Phase 1: App operational

Authentication, store setup, dashboard, products, inventory movements, sales,
customers, customer payments, suppliers, purchases, expenses, staff, basic
settings, and notifications.

### Phase 2: Full ERP

Phase 2 turns the operational app into a complete ERP. It should include the
following work.

#### 2.1 Sales return and refund

- Support full and partial item returns against an original sale.
- Validate that returned quantity never exceeds sold quantity.
- Restore returned sellable stock automatically.
- Record damaged/non-sellable returns without restoring available stock.
- Support cash, mobile banking, card, bank, and store-credit refunds.
- Recalculate invoice totals, tax, discount, paid amount, due, and profit.
- Generate return receipt/credit-note data.
- Keep the original invoice immutable and link every return to it.
- Use `/sales/{saleId}/refunds` and expose refund history in sale details.

Completion criteria: duplicate refund prevention, atomic stock/account
reversal, permission checks, idempotency, and complete audit history.

#### 2.2 Advanced purchase receiving and returns

- Receive a purchase fully or partially.
- Receive different quantities, costs, batches, expiry dates, and locations
  for individual lines.
- Track ordered, received, pending, rejected, and returned quantities.
- Update stock and supplier payable only for accepted quantities.
- Support supplier returns with stock and payable reversal.
- Preserve receiving notes, invoice number, attachments, actor, and timestamp.
- Use purchase submit, receive, return, and cancel endpoints.

Completion criteria: purchase statuses move safely between draft, submitted,
partially received, received, and cancelled without quantity corruption.

#### 2.3 Supplier ledger and payable management

- Maintain purchase, payment, return, opening balance, and adjustment entries.
- Calculate current payable and supplier credit-limit usage.
- Support partial supplier payments through all configured payment methods.
- Prevent editing/deleting posted ledger entries; use reversal adjustments.
- Provide supplier statement, date filtering, and payable ageing.
- Add receipt/reference and actor information to every payment.

Completion criteria: ledger balance always matches purchase and payment
transactions, including cancellations and returns.

#### 2.4 Customer receivable and due ageing

- Maintain sale, payment, return, opening due, and adjustment entries.
- Support due collection, partial collection, and advance/store credit.
- Produce customer statements and ageing buckets.
- Recalculate receivable when a sale is cancelled or refunded.
- Add payment receipt and transaction-reference support.

Completion criteria: customer balance is server-calculated and cannot be
changed directly without an authorized ledger adjustment.

#### 2.5 Daily closing and cash reconciliation

- Calculate opening cash, cash sales, digital sales, due collections,
  supplier payments, expenses, refunds, and expected closing cash.
- Accept counted cash and calculate shortage/overage.
- Store cashier, store, business date, note, and denomination breakdown.
- Lock a submitted closing from normal edits.
- Allow owner-approved reopening or adjustment with audit logs.
- Provide closing history and printable closing report.

Completion criteria: one active closing per store/cashier/business date and
all totals reproduced from posted transactions.

#### 2.6 Complete reports and analytics

- Dashboard KPI and comparison report.
- Daily sales and payment-method report.
- Daily purchase and supplier report.
- Profit-and-loss report using revenue, COGS, returns, and expenses.
- Stock quantity, movement, valuation, low-stock, expiry, and dead-stock
  reports.
- Customer receivable and supplier payable ageing.
- Product, category, staff, and payment-method performance.
- Tax and discount summaries.
- Date, store, staff, category, customer, supplier, and status filters.
- Server-side totals and pagination for large data sets.

Completion criteria: report values reconcile with source transactions and
respect store timezone and user permissions.

#### 2.7 PDF, Excel, and shareable exports

- Generate reports asynchronously for large periods.
- Return export job ID, status, expiry time, and signed download URL.
- Support PDF and Excel/CSV formats.
- Add store branding and selected filter information.
- Generate invoice, purchase, ledger, closing, and financial report files.
- Allow WhatsApp/share flow through a secure temporary URL.
- Automatically delete expired export files.

Completion criteria: exports cannot leak data across stores and generated
files match the requested report filters.

#### 2.8 Store layout and bin-level inventory

- CRUD for zones, racks, shelves, and bins.
- Assign product quantity to one or multiple bins.
- Transfer stock between bins with an atomic movement record.
- Show bin stock, low-stock status, capacity, and location path.
- Prevent deletion of a location containing stock.
- Include location in purchase receiving, stock count, sale picking, and
  stock movement history.

Completion criteria: total bin quantity reconciles with the product's store
inventory or the system clearly records unassigned stock.

#### 2.9 Tax, charge, unit, and category management

- CRUD for tax rates, fixed charges, units, and categories.
- Support inclusive/exclusive tax and active date ranges.
- Configure tax applicability by product/category.
- Prevent deleting records used by posted transactions.
- Save historical names/rates on invoices for accurate old reports.
- Support sort order, activation, and archive status.

Completion criteria: server performs every tax and charge calculation using
the effective configuration at transaction time.

#### 2.10 Inventory controls

- Physical stock-count sessions with draft and completed states.
- Stock reconciliation with variance reason and approval.
- Batch, expiry, and optional serial tracking.
- FIFO, weighted-average, or configured costing support.
- Negative-stock policy enforcement.
- Low-stock, expiry, and dead-stock detection.
- Stock transfer between stores when multi-store is later enabled.

Completion criteria: every quantity change produces an immutable movement and
every cost change can be explained by a source transaction.

#### 2.11 Audit log and approval controls

- Record actor, role, device/session, request ID, IP, action, entity, old/new
  values, store, and timestamp.
- Cover login, permissions, PIN reset, stock, sale cancellation, refund,
  payment, purchase, expense, settings, and daily closing.
- Provide owner-only filtering and detail endpoints.
- Mark sensitive operations as pending approval when configured.
- Do not expose passwords, PINs, tokens, or full payment secrets in logs.

Recommended endpoints:

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/audit-logs` | Search authorized audit events |
| GET | `/audit-logs/{auditId}` | Audit-event details |
| GET | `/approvals` | Pending/processed approval list |
| POST | `/approvals/{approvalId}/approve` | Approve sensitive operation |
| POST | `/approvals/{approvalId}/reject` | Reject sensitive operation |

Completion criteria: posted financial records are never silently overwritten;
corrections use reversals, adjustments, or approved workflows.

### Phase 3: Commercial features

Phase 3 adds monetization, scale, platform operations, and customer-support
features.

#### 3.1 Subscription plans and feature limits

- Define free, trial, monthly, yearly, and custom plans.
- Configure limits for stores, staff, products, invoices, exports, storage,
  reports, and premium features.
- Return current plan, trial/expiry date, grace period, renewal status, and
  usage.
- Enforce plan limits on the backend.
- Support upgrade, downgrade, renewal, cancellation, and coupon/promotion.
- Keep plan and price history for billing records.

Completion criteria: expired or over-limit accounts receive consistent API
errors without losing access to their existing business data.

#### 3.2 Subscription payment and billing

- Start checkout for supported Bangladesh payment gateways or manual payment.
- Verify payment only from trusted gateway callbacks/webhooks.
- Make webhook processing signed, idempotent, and retry-safe.
- Create payment, invoice, refund, and failed-payment records.
- Activate/renew subscription only after verified payment.
- Provide billing history and downloadable invoices.
- Notify users before trial/plan expiry and after payment events.

Backend-only endpoints should include gateway webhooks such as:

```text
POST /webhooks/payments/{provider}
```

Completion criteria: Flutter cannot activate a subscription by sending a
client-side success flag.

#### 3.3 Master product database

- Maintain a central product catalogue with barcode, names, brand, category,
  unit, pack information, image, and suggested metadata.
- Search by barcode, text, brand, and category.
- Let a store copy a master item into its own catalogue.
- Keep store-specific price, cost, stock, threshold, and category independent.
- Support duplicate-barcode detection and moderated product submissions.
- Provide bulk import and catalogue version/update support.

Recommended additional endpoints:

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/master-products/submissions` | Submit missing product for review |
| GET | `/master-products/submissions/{submissionId}` | Review status |
| POST | `/admin/master-products/{masterId}/approve` | Platform approval |
| POST | `/admin/master-products/merge` | Merge duplicate catalogue records |

Completion criteria: changes to master data never overwrite a store's
financial or inventory values.

#### 3.4 Multi-store and branch management

- Create and manage multiple stores/branches under one business account.
- Assign staff to one or multiple stores with store-specific permissions.
- Select active store and restrict every request by tenant/store access.
- Provide combined owner dashboard and per-store reporting.
- Support inter-store stock-transfer request, dispatch, receive, and cancel.
- Maintain independent inventory, invoice sequence, settings, closing, and
  ledgers per store.
- Optionally share customer, supplier, category, and master product data.

Recommended endpoints:

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/stores/{storeId}/staff/{staffId}` | Assign staff to store |
| DELETE | `/stores/{storeId}/staff/{staffId}` | Remove store assignment |
| GET | `/stock-transfers` | Transfer list |
| POST | `/stock-transfers` | Create transfer |
| POST | `/stock-transfers/{transferId}/dispatch` | Dispatch stock |
| POST | `/stock-transfers/{transferId}/receive` | Receive stock |
| POST | `/stock-transfers/{transferId}/cancel` | Cancel transfer |
| GET | `/dashboard/consolidated` | Combined business dashboard |

Completion criteria: no user can read or mutate an unauthorized store by
changing `store_id` in a request.

#### 3.5 Support ticket system

- Create support tickets with category, priority, subject, description, and
  attachments.
- Support threaded replies from customer and support agents.
- Track open, pending, resolved, and closed status.
- Record assignment, response time, resolution time, and satisfaction rating.
- Notify the user when support replies or status changes.
- Provide searchable help articles and FAQ content.

Completion criteria: ticket attachments use authorized signed URLs and users
can only access tickets belonging to their account.

#### 3.6 File and media management

- Upload product, store, profile, receipt, support, and report files.
- Validate MIME type, extension, size, and image dimensions.
- Use malware scanning where available.
- Generate thumbnails and optimized image variants.
- Store file owner, purpose, visibility, checksum, and reference count.
- Use short-lived signed URLs for private documents.
- Remove orphaned and expired files through scheduled cleanup.

Completion criteria: private invoices, receipts, exports, and support files
are never exposed through permanent public URLs.

#### 3.7 Remote app version and feature configuration

- Return minimum supported version, latest version, update URL, force-update
  flag, maintenance status, and localized messages.
- Target settings by platform, app version, environment, plan, or rollout
  percentage.
- Provide feature flags for gradual release and emergency disable.
- Cache configuration safely while respecting expiry.
- Never use feature flags as a replacement for backend permission checks.

Recommended endpoints:

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/app/config` | Version, maintenance, and feature configuration |
| GET | `/app/releases` | Release notes/history |
| GET | `/app/content` | Remote banners, notices, and help links |

Completion criteria: the app can show optional update, force update, and
maintenance screens without publishing a new build.

#### 3.8 Commercial notifications and campaigns

- Send plan-expiry, payment, feature, onboarding, and promotional messages.
- Target users by plan, store activity, language, platform, and consent.
- Support push, email, and SMS templates.
- Schedule campaigns and record delivered, opened, clicked, and failed states.
- Respect notification preferences and marketing opt-out.
- Separate operational notifications from promotional consent.

Completion criteria: campaigns are rate-limited, auditable, and compliant with
the user's channel preferences.

#### 3.9 Platform administration

- Manage businesses, users, subscriptions, payments, support, master products,
  app versions, feature flags, and system announcements.
- Suspend/reactivate abusive or unpaid accounts without deleting their data.
- View platform health, job failures, webhook failures, and aggregate usage.
- Provide secure admin roles with fine-grained permissions and audit logs.
- Support safe impersonation only when explicitly approved and fully audited.

Completion criteria: admin APIs use a separate authorization scope and are
never accessible with normal owner/staff tokens.

#### 3.10 Backup, retention, and data export

- Run encrypted automated database and file backups.
- Define retention policies for audit logs, exports, notifications, and
  deleted records.
- Allow an owner to request a portable business-data export.
- Support account closure with grace period, legal retention, and irreversible
  deletion workflow.
- Test backup restoration regularly.

Recommended endpoints:

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/account/data-exports` | Request full account export |
| GET | `/account/data-exports/{exportId}` | Export status/download |
| POST | `/account/closure-request` | Start account closure |
| DELETE | `/account/closure-request` | Cancel pending closure |

Completion criteria: backups are encrypted, restore-tested, tenant-safe, and
not directly downloadable through public storage paths.
