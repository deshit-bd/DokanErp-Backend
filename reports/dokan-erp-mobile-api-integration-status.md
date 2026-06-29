# Dokan-ERP Mobile API Integration Status

Generated from the current repository source on 2026-06-29.

## Scope

- Backend source checked: `backend/src/app.ts` and `backend/src/routes/*.ts`
- Mobile source checked: `mobile/lib/core/constants/api_endpoints.dart`, `mobile/lib/data/network/erp_remote_data_source.dart`, and all `mobile/lib/modules/**/data/datasources/*remote*.dart` files
- Base API scope for mobile: `'/app/api'`

## How To Read This

- `Integrated` means the mobile app has a real caller and the backend route exists with a matching path/method.
- `Needs Fix` means mobile code calls an API, but the backend path or method does not match the current backend implementation.
- `Need To Integrate` means the backend already exposes the route under `/app/api`, but the current mobile app has no direct caller for it.

## Integrated APIs

### Auth

Mobile source: `mobile/lib/modules/auth/data/datasources/auth_remote_data_source.dart` and `mobile/lib/data/network/api_providers.dart`

- `POST /app/api/auth/login`
- `POST /app/api/auth/register-owner`
- `POST /app/api/auth/check-mobile`
- `POST /app/api/auth/send-otp`
- `POST /app/api/auth/verify-otp`
- `POST /app/api/auth/refresh`
- `POST /app/api/auth/logout`
- `GET /app/api/auth/me`

### Customers And Sales

Mobile source: `mobile/lib/modules/customers/data/datasources/customer_remote_data_source.dart`, `mobile/lib/modules/sales/data/datasources/sales_remote_data_source.dart`, and `mobile/lib/modules/sales/presentation/screens/parts/sales_screens_pos_checkout.dart`

- `GET /app/api/customers`
- `POST /app/api/customers`
- `GET /app/api/customers/:id`
- `POST /app/api/customers/:id/payments`
- `GET /app/api/customers/sales`
- `POST /app/api/customers/sales`
- `POST /app/api/customers/sales/:saleId/cancel`
- `POST /app/api/customers/send-due-otp`
- `POST /app/api/customers/verify-due-otp`

### Products, Categories, Shop Catalog, And Stock Movement

Mobile source: `mobile/lib/modules/products/data/datasources/product_remote_data_source.dart` and `mobile/lib/modules/products/data/datasources/quick_setup_catalog_remote_data_source.dart`

- `GET /app/api/products`
- `POST /app/api/products`
- `GET /app/api/products/:id`
- `PATCH /app/api/products/:id`
- `DELETE /app/api/products/:id`
- `GET /app/api/categories`
- `POST /app/api/categories`
- `DELETE /app/api/categories/:id`
- `GET /app/api/shops/products`
- `GET /app/api/inventory/stock-movements`
- `POST /app/api/inventory/stock-movements`
- `GET /app/api/shops/quick-setup/catalog`
- `POST /app/api/shops/quick-setup/catalog/select`
- `PATCH /app/api/shops/quick-setup/catalog/pricing`

### Purchases

Mobile source: `mobile/lib/modules/purchases/data/datasources/purchase_remote_data_source.dart`

- `GET /app/api/purchases`
- `POST /app/api/purchases`
- `GET /app/api/purchases/:id`
- `PATCH /app/api/purchases/:id`
- `POST /app/api/purchases/:id/receive`
- `POST /app/api/purchases/:id/cancel`
- `POST /app/api/purchases/:id/returns`

### Suppliers

Mobile source: `mobile/lib/modules/suppliers/data/datasources/supplier_remote_data_source.dart`

- `GET /app/api/suppliers`
- `POST /app/api/suppliers`
- `DELETE /app/api/suppliers/:id`
- `GET /app/api/suppliers/:id/ledger`
- `POST /app/api/suppliers/:id/payments`

### Expenses

Mobile source: `mobile/lib/modules/expenses/data/datasources/expense_remote_data_source.dart`

- `GET /app/api/expenses`
- `POST /app/api/expenses`
- `PATCH /app/api/expenses/:id`
- `DELETE /app/api/expenses/:id`

### Business Settings, Subscription, Inventory Layout, Dashboard, Reports, Staff, Notifications

Mobile source: `mobile/lib/modules/settings/data/datasources/*.dart` and `mobile/lib/data/network/erp_remote_data_source.dart`

- `GET /app/api/settings/inventory`
- `PATCH /app/api/settings/inventory`
- `GET /app/api/settings/store`
- `PUT /app/api/settings/store`
- `POST /app/api/settings/store/documents/:type`
- `PATCH /app/api/shops/me/logo`
- `GET /app/api/subscriptions/me`
- `POST /app/api/subscriptions/payments`
- `GET /app/api/inventory/mode`
- `POST /app/api/inventory/mode`
- `GET /app/api/inventory/layout-tree`
- `POST /app/api/inventory/zones`
- `PATCH /app/api/inventory/zones/:id`
- `DELETE /app/api/inventory/zones/:id`
- `POST /app/api/inventory/racks`
- `PATCH /app/api/inventory/racks/:id`
- `DELETE /app/api/inventory/racks/:id`
- `POST /app/api/inventory/shelves`
- `PATCH /app/api/inventory/shelves/:id`
- `DELETE /app/api/inventory/shelves/:id`
- `POST /app/api/inventory/bins`
- `PATCH /app/api/inventory/bins/:id`
- `DELETE /app/api/inventory/bins/:id`
- `GET /app/api/reports/dashboard`
- `GET /app/api/reports/sales/daily`
- `GET /app/api/reports/purchases/summary`
- `GET /app/api/reports/dues/summary`
- `GET /app/api/reports/expenses/summary`
- `GET /app/api/reports/profit-loss`
- `GET /app/api/reports/stock-value`
- `GET /app/api/staff`
- `GET /app/api/notifications`

## APIs That Need Fixing In Mobile

- No known mobile/backend route mismatches were found in the currently documented set.

## Backend APIs That Still Need Mobile Integration

### Bank Accounts

- `GET /app/api/bank-accounts`
- `POST /app/api/bank-accounts`
- `PUT /app/api/bank-accounts/:id`

### Brands

- `GET /app/api/brands`
- `POST /app/api/brands`
- `PUT /app/api/brands/:id`
- `DELETE /app/api/brands`
- `DELETE /app/api/brands/:id`

### Money Boxes

- `GET /app/api/money-boxes`
- `POST /app/api/money-boxes`
- `PUT /app/api/money-boxes/:id`

### Product Templates

- `GET /app/api/product-templates`
- `POST /app/api/product-templates`
- `PUT /app/api/product-templates/:id`
- `DELETE /app/api/product-templates/:id`
- `PUT /app/api/product-templates/:id/products`
- `DELETE /app/api/product-templates/:id/products/:productId`

### Units

- `GET /app/api/units`
- `POST /app/api/units`
- `DELETE /app/api/units/:id`
- `POST /app/api/units/:id/approve`

### Shop Management APIs Beyond Logo

- `GET /app/api/shops`
- `GET /app/api/shops/me/settings`
- `PATCH /app/api/shops/me/settings`
- `GET /app/api/shops/me/finance-sources`
- `POST /app/api/shops/me/money-boxes`
- `PUT /app/api/shops/me/money-boxes/:id`
- `POST /app/api/shops/me/bank-accounts`
- `PUT /app/api/shops/me/bank-accounts/:id`
- `GET /app/api/shops/me/inventory-settings`
- `PATCH /app/api/shops/me/inventory-settings`
- `GET /app/api/shops/me/taxes-charges`
- `POST /app/api/shops/me/taxes`
- `POST /app/api/shops/me/charges`
- `PATCH /app/api/shops/me/taxes/:id`
- `PATCH /app/api/shops/me/charges/:id`
- `DELETE /app/api/shops/me/taxes/:id`
- `DELETE /app/api/shops/me/charges/:id`

### Customer Read APIs Not Yet Used In Mobile

- `GET /app/api/customers/:id/sales`
- `GET /app/api/customers/:id/ledger`
- `GET /app/api/customers/sales/closing-summary`
- `GET /app/api/customers/sales/:saleId`

### Supplier Read And Admin APIs Not Yet Used In Mobile

- `GET /app/api/suppliers/:id`
- `PUT /app/api/suppliers/:id`
- `PATCH /app/api/suppliers/:id/status`
- `GET /app/api/suppliers/:id/dues`
- `GET /app/api/suppliers/:id/payments`
- `GET /app/api/suppliers/:id/purchases`
- `GET /app/api/add-suppliers/*` alias routes

### Purchase Admin APIs Not Yet Used In Mobile

- `POST /app/api/purchases/:id/payments`
- `GET /app/api/purchases/:id/returns`
- `PATCH /app/api/purchases/:id/approve`
- `PATCH /app/api/purchases/:id/reject`

### Product APIs Not Yet Used In Mobile

- `GET /app/api/products/:id/barcode.svg`
- `POST /app/api/products/:id/duplicate`
- `GET /app/api/products/approval-requests`
- `PATCH /app/api/products/approval-requests/:id/approve`
- `PATCH /app/api/products/approval-requests/:id/reject`
- `PATCH /app/api/products/:id/status`

### Inventory APIs Not Yet Used In Mobile

- `GET /app/api/inventory/dashboard`
- `GET /app/api/inventory/attention`
- `GET /app/api/inventory/general-store`
- `GET /app/api/inventory/zones`
- `GET /app/api/inventory/racks`
- `GET /app/api/inventory/shelves`
- `GET /app/api/inventory/bins`
- `POST /app/api/inventory/placements`

### Notifications Write APIs

- `GET /app/api/notifications/settings`
- `PUT /app/api/notifications/settings`
- `POST /app/api/notifications`
- `PUT /app/api/notifications/read`
- `DELETE /app/api/notifications`

### Staff Detail/Admin APIs

- `GET /app/api/staff/me/performance`
- `GET /app/api/staff/:staffUserId`
- `PATCH /app/api/staff/:staffUserId/permissions`
- `POST /app/api/staff/:staffUserId/pin-reset`
- `PATCH /app/api/staff/:staffUserId/status`

### Auth Flows Not Yet Hooked In Mobile

- `POST /app/api/auth/register-salesman`
- `POST /app/api/auth/register-owner-draft`
- `POST /app/api/auth/setup-pin`
- `POST /app/api/auth/complete-registration`
- `POST /app/api/auth/pre-login`
- `POST /app/api/auth/owners-login`
- `POST /app/api/auth/salesmans-login`
- `POST /app/api/auth/send-owner-login-otp`
- `POST /app/api/auth/owners-login-otp`
- `POST /app/api/auth/salesmans-login-otp`
- `POST /app/api/auth/send-login-otp`
- `POST /app/api/auth/verify-login-otp`
- `POST /app/api/auth/owners-verify-otp`
- `POST /app/api/auth/salesmans-verify-otp`
- `PATCH /app/api/auth/me`
- `PATCH /app/api/auth/me/password`
- `PATCH /app/api/auth/me/avatar`

## Recommended Next Work

- The mismatch bucket is now cleared in this report, so the next work is expanding mobile coverage into the remaining backend route groups.
- The highest-value missing integrations for daily mobile workflows are shop settings, supplier detail/dues/payment history, customer ledger/sales history, and purchase approval/payment history.
- If you want tighter mobile coverage for owner operations, the next route groups to wire are `bank-accounts`, `money-boxes`, `units`, `brands`, and `notifications` write actions.

