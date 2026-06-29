# Dokan-ERP Project Analysis and API Documentation

Generated from the current repository source on 2026-06-29.

## Project Analysis

- Workspace layout: `backend/` Express + Prisma API, `frontend/` Next.js App Router web app, `mobile/` Flutter mobile app.
- Backend entrypoint: `backend/src/app.ts`, mounted under both `/web/api` and `/app/api` plus public `/health` and `/confirm-due/:token` endpoints.
- Frontend API layer: `frontend/src/app/api/**`, mostly thin proxies to backend `/web/api/*` through `frontend/src/lib/server/backend-proxy.ts`.
- Mobile API layer: callers are expected to use `/app/api/*`; mobile README requires `DOKAN_API_BASE_URL=http://YOUR_SERVER_IP:4000`.
- Current API surface found in code: 175 backend route handlers across 19 mounted route groups, plus 65 frontend API handlers.

## API Topology

- Web clients normally hit `http://localhost:4000/web/api/*` directly or `http://localhost:3000/api/*` through Next.js proxy routes.
- Mobile clients hit `http://localhost:4000/app/api/*`.
- Authentication is resolved from the access-token cookie or an `Authorization: Bearer <token>` header.
- The mobile `/app/api/*` scope has a subscription-access gate in `backend/src/app.ts`; `/auth` and `/subscriptions` are exempt from that global check.

## Public Backend Endpoints

- `GET /health` - Service health check.
- `GET /confirm-due/:token` - Public due confirmation page handler.
- `POST /confirm-due/:token` - Public due confirmation submit handler.

## Backend Route Groups

### Auth

Source file: `backend/src/routes/auth.ts`

Mounted as: `/auth`

- `POST /web/api/auth/check-mobile` and `POST /app/api/auth/check-mobile`
- `POST /web/api/auth/register-owner` and `POST /app/api/auth/register-owner`
- `POST /web/api/auth/register-salesman` and `POST /app/api/auth/register-salesman`
- `POST /web/api/auth/register-owner-draft` and `POST /app/api/auth/register-owner-draft`
- `POST /web/api/auth/send-otp` and `POST /app/api/auth/send-otp`
- `POST /web/api/auth/verify-otp` and `POST /app/api/auth/verify-otp`
- `POST /web/api/auth/setup-pin` and `POST /app/api/auth/setup-pin`
- `POST /web/api/auth/complete-registration` and `POST /app/api/auth/complete-registration`
- `POST /web/api/auth/pre-login` and `POST /app/api/auth/pre-login`
- `POST /web/api/auth/owners-login` and `POST /app/api/auth/owners-login`
- `POST /web/api/auth/salesmans-login` and `POST /app/api/auth/salesmans-login`
- `POST /web/api/auth/send-owner-login-otp` and `POST /app/api/auth/send-owner-login-otp`
- `POST /web/api/auth/owners-login-otp` and `POST /app/api/auth/owners-login-otp`
- `POST /web/api/auth/salesmans-login-otp` and `POST /app/api/auth/salesmans-login-otp`
- `POST /web/api/auth/send-login-otp` and `POST /app/api/auth/send-login-otp`
- `POST /web/api/auth/verify-login-otp` and `POST /app/api/auth/verify-login-otp`
- `POST /web/api/auth/owners-verify-otp` and `POST /app/api/auth/owners-verify-otp`
- `POST /web/api/auth/salesmans-verify-otp` and `POST /app/api/auth/salesmans-verify-otp`
- `POST /web/api/auth/login` and `POST /app/api/auth/login`
- `POST /web/api/auth/refresh` and `POST /app/api/auth/refresh`
- `POST /web/api/auth/logout` and `POST /app/api/auth/logout`
- `GET /web/api/auth/me` and `GET /app/api/auth/me`
- `PATCH /web/api/auth/me` and `PATCH /app/api/auth/me`
- `PATCH /web/api/auth/me/password` and `PATCH /app/api/auth/me/password`
- `PATCH /web/api/auth/me/avatar` and `PATCH /app/api/auth/me/avatar`

### Bank Accounts

Source file: `backend/src/routes/bank-accounts.ts`

Mounted as: `/bank-accounts`

- `GET /web/api/bank-accounts` and `GET /app/api/bank-accounts`
- `POST /web/api/bank-accounts` and `POST /app/api/bank-accounts`
- `PUT /web/api/bank-accounts/:id` and `PUT /app/api/bank-accounts/:id`

### Brands

Source file: `backend/src/routes/brands.ts`

Mounted as: `/brands`

- `GET /web/api/brands` and `GET /app/api/brands`
- `POST /web/api/brands` and `POST /app/api/brands`
- `PUT /web/api/brands/:id` and `PUT /app/api/brands/:id`
- `DELETE /web/api/brands` and `DELETE /app/api/brands`
- `DELETE /web/api/brands/:id` and `DELETE /app/api/brands/:id`

### Categories

Source file: `backend/src/routes/categories.ts`

Mounted as: `/categories`

- `GET /web/api/categories` and `GET /app/api/categories`
- `POST /web/api/categories` and `POST /app/api/categories`
- `POST /web/api/categories/import` and `POST /app/api/categories/import`
- `PATCH /web/api/categories/:id` and `PATCH /app/api/categories/:id`
- `DELETE /web/api/categories/:id` and `DELETE /app/api/categories/:id`
- `POST /web/api/categories/:id/approve` and `POST /app/api/categories/:id/approve`

### Customers

Source file: `backend/src/routes/customers.ts`

Mounted as: `/customers`

- `GET /web/api/customers` and `GET /app/api/customers`
- `POST /web/api/customers` and `POST /app/api/customers`
- `GET /web/api/customers/sales` and `GET /app/api/customers/sales`
- `GET /web/api/customers/sales/closing-summary` and `GET /app/api/customers/sales/closing-summary`
- `GET /web/api/customers/sales/:saleId` and `GET /app/api/customers/sales/:saleId`
- `POST /web/api/customers/sales/:saleId/cancel` and `POST /app/api/customers/sales/:saleId/cancel`
- `POST /web/api/customers/send-due-otp` and `POST /app/api/customers/send-due-otp`
- `POST /web/api/customers/verify-due-otp` and `POST /app/api/customers/verify-due-otp`
- `POST /web/api/customers/sales` and `POST /app/api/customers/sales`
- `GET /web/api/customers/:id/sales` and `GET /app/api/customers/:id/sales`
- `POST /web/api/customers/:id/payments` and `POST /app/api/customers/:id/payments`
- `GET /web/api/customers/:id/ledger` and `GET /app/api/customers/:id/ledger`
- `GET /web/api/customers/:id` and `GET /app/api/customers/:id`

### Expenses

Source file: `backend/src/routes/expenses.ts`

Mounted as: `/expenses`

- `GET /web/api/expenses` and `GET /app/api/expenses`
- `POST /web/api/expenses` and `POST /app/api/expenses`

### Inventory

Source file: `backend/src/routes/inventory.ts`

Mounted as: `/inventory`

- `GET /web/api/inventory/mode` and `GET /app/api/inventory/mode`
- `POST /web/api/inventory/mode` and `POST /app/api/inventory/mode`
- `GET /web/api/inventory/dashboard` and `GET /app/api/inventory/dashboard`
- `GET /web/api/inventory/attention` and `GET /app/api/inventory/attention`
- `GET /web/api/inventory/general-store` and `GET /app/api/inventory/general-store`
- `GET /web/api/inventory/stock-movements` and `GET /app/api/inventory/stock-movements`
- `POST /web/api/inventory/stock-movements` and `POST /app/api/inventory/stock-movements`
- `GET /web/api/inventory/layout-tree` and `GET /app/api/inventory/layout-tree`
- `GET /web/api/inventory/zones` and `GET /app/api/inventory/zones`
- `POST /web/api/inventory/zones` and `POST /app/api/inventory/zones`
- `GET /web/api/inventory/racks` and `GET /app/api/inventory/racks`
- `POST /web/api/inventory/racks` and `POST /app/api/inventory/racks`
- `GET /web/api/inventory/shelves` and `GET /app/api/inventory/shelves`
- `GET /web/api/inventory/bins` and `GET /app/api/inventory/bins`
- `POST /web/api/inventory/bins` and `POST /app/api/inventory/bins`
- `POST /web/api/inventory/placements` and `POST /app/api/inventory/placements`
- `PATCH /web/api/inventory/zones/:id` and `PATCH /app/api/inventory/zones/:id`
- `DELETE /web/api/inventory/zones/:id` and `DELETE /app/api/inventory/zones/:id`
- `PATCH /web/api/inventory/racks/:id` and `PATCH /app/api/inventory/racks/:id`
- `DELETE /web/api/inventory/racks/:id` and `DELETE /app/api/inventory/racks/:id`
- `POST /web/api/inventory/shelves` and `POST /app/api/inventory/shelves`
- `PATCH /web/api/inventory/shelves/:id` and `PATCH /app/api/inventory/shelves/:id`
- `DELETE /web/api/inventory/shelves/:id` and `DELETE /app/api/inventory/shelves/:id`
- `PATCH /web/api/inventory/bins/:id` and `PATCH /app/api/inventory/bins/:id`
- `DELETE /web/api/inventory/bins/:id` and `DELETE /app/api/inventory/bins/:id`

### Money Boxes

Source file: `backend/src/routes/money-boxes.ts`

Mounted as: `/money-boxes`

- `GET /web/api/money-boxes` and `GET /app/api/money-boxes`
- `POST /web/api/money-boxes` and `POST /app/api/money-boxes`
- `PUT /web/api/money-boxes/:id` and `PUT /app/api/money-boxes/:id`

### Notifications

Source file: `backend/src/routes/notifications.ts`

Mounted as: `/notifications`

- `GET /web/api/notifications/settings` and `GET /app/api/notifications/settings`
- `PUT /web/api/notifications/settings` and `PUT /app/api/notifications/settings`
- `GET /web/api/notifications` and `GET /app/api/notifications`
- `POST /web/api/notifications` and `POST /app/api/notifications`
- `PUT /web/api/notifications/read` and `PUT /app/api/notifications/read`
- `DELETE /web/api/notifications` and `DELETE /app/api/notifications`

### Product Templates

Source file: `backend/src/routes/product-templates.ts`

Mounted as: `/product-templates`

- `GET /web/api/product-templates` and `GET /app/api/product-templates`
- `POST /web/api/product-templates` and `POST /app/api/product-templates`
- `PUT /web/api/product-templates/:id` and `PUT /app/api/product-templates/:id`
- `DELETE /web/api/product-templates/:id` and `DELETE /app/api/product-templates/:id`
- `PUT /web/api/product-templates/:id/products` and `PUT /app/api/product-templates/:id/products`
- `DELETE /web/api/product-templates/:id/products/:productId` and `DELETE /app/api/product-templates/:id/products/:productId`

### Products

Source file: `backend/src/routes/products.ts`

Mounted as: `/products`

- `GET /web/api/products` and `GET /app/api/products`
- `GET /web/api/products/:id/barcode.svg` and `GET /app/api/products/:id/barcode.svg`
- `POST /web/api/products` and `POST /app/api/products`
- `PUT /web/api/products/:id` and `PUT /app/api/products/:id`
- `PATCH /web/api/products/:id` and `PATCH /app/api/products/:id`
- `POST /web/api/products/:id/duplicate` and `POST /app/api/products/:id/duplicate`
- `GET /web/api/products/approval-requests` and `GET /app/api/products/approval-requests`
- `PATCH /web/api/products/approval-requests/:id/approve` and `PATCH /app/api/products/approval-requests/:id/approve`
- `PATCH /web/api/products/approval-requests/:id/reject` and `PATCH /app/api/products/approval-requests/:id/reject`
- `PATCH /web/api/products/:id/status` and `PATCH /app/api/products/:id/status`
- `DELETE /web/api/products/:id` and `DELETE /app/api/products/:id`

### Purchases

Source file: `backend/src/routes/purchases.ts`

Mounted as: `/purchases`

- `POST /web/api/purchases` and `POST /app/api/purchases`
- `GET /web/api/purchases` and `GET /app/api/purchases`
- `GET /web/api/purchases/:id` and `GET /app/api/purchases/:id`
- `POST /web/api/purchases/:id/payments` and `POST /app/api/purchases/:id/payments`
- `GET /web/api/purchases/:id/returns` and `GET /app/api/purchases/:id/returns`
- `POST /web/api/purchases/:id/returns` and `POST /app/api/purchases/:id/returns`
- `PATCH /web/api/purchases/:id/approve` and `PATCH /app/api/purchases/:id/approve`
- `PATCH /web/api/purchases/:id/reject` and `PATCH /app/api/purchases/:id/reject`
- `POST /web/api/purchases/:id/receive` and `POST /app/api/purchases/:id/receive`
- `POST /web/api/purchases/:id/cancel` and `POST /app/api/purchases/:id/cancel`

### Reports

Source file: `backend/src/routes/reports.ts`

Mounted as: `/reports`

- `GET /web/api/reports/dashboard` and `GET /app/api/reports/dashboard`
- `GET /web/api/reports/sales/daily` and `GET /app/api/reports/sales/daily`
- `GET /web/api/reports/purchases/summary` and `GET /app/api/reports/purchases/summary`
- `GET /web/api/reports/dues/summary` and `GET /app/api/reports/dues/summary`
- `GET /web/api/reports/expenses/summary` and `GET /app/api/reports/expenses/summary`
- `GET /web/api/reports/profit-loss` and `GET /app/api/reports/profit-loss`
- `GET /web/api/reports/stock-value` and `GET /app/api/reports/stock-value`

### Settings

Source file: `backend/src/routes/settings.ts`

Mounted as: `/settings`

- `GET /web/api/settings/store` and `GET /app/api/settings/store`
- `PUT /web/api/settings/store` and `PUT /app/api/settings/store`
- `POST /web/api/settings/store/documents/:type` and `POST /app/api/settings/store/documents/:type`
- `GET /web/api/settings/inventory` and `GET /app/api/settings/inventory`
- `PATCH /web/api/settings/inventory` and `PATCH /app/api/settings/inventory`

### Shops

Source file: `backend/src/routes/shops.ts`

Mounted as: `/shops`

- `GET /web/api/shops` and `GET /app/api/shops`
- `GET /web/api/shops/me/settings` and `GET /app/api/shops/me/settings`
- `GET /web/api/shops/me/finance-sources` and `GET /app/api/shops/me/finance-sources`
- `POST /web/api/shops/me/money-boxes` and `POST /app/api/shops/me/money-boxes`
- `PUT /web/api/shops/me/money-boxes/:id` and `PUT /app/api/shops/me/money-boxes/:id`
- `POST /web/api/shops/me/bank-accounts` and `POST /app/api/shops/me/bank-accounts`
- `PUT /web/api/shops/me/bank-accounts/:id` and `PUT /app/api/shops/me/bank-accounts/:id`
- `PATCH /web/api/shops/me/settings` and `PATCH /app/api/shops/me/settings`
- `GET /web/api/shops/me/inventory-settings` and `GET /app/api/shops/me/inventory-settings`
- `PATCH /web/api/shops/me/inventory-settings` and `PATCH /app/api/shops/me/inventory-settings`
- `PATCH /web/api/shops/me/logo` and `PATCH /app/api/shops/me/logo`
- `GET /web/api/shops/quick-setup/catalog` and `GET /app/api/shops/quick-setup/catalog`
- `GET /web/api/shops/products` and `GET /app/api/shops/products`
- `POST /web/api/shops/products/local` and `POST /app/api/shops/products/local`
- `POST /web/api/shops/quick-setup/catalog/select` and `POST /app/api/shops/quick-setup/catalog/select`
- `PATCH /web/api/shops/quick-setup/catalog/pricing` and `PATCH /app/api/shops/quick-setup/catalog/pricing`
- `PATCH /web/api/shops/products/:shopProductId` and `PATCH /app/api/shops/products/:shopProductId`
- `GET /web/api/shops/me/taxes-charges` and `GET /app/api/shops/me/taxes-charges`
- `POST /web/api/shops/me/taxes` and `POST /app/api/shops/me/taxes`
- `POST /web/api/shops/me/charges` and `POST /app/api/shops/me/charges`
- `PATCH /web/api/shops/me/taxes/:id` and `PATCH /app/api/shops/me/taxes/:id`
- `PATCH /web/api/shops/me/charges/:id` and `PATCH /app/api/shops/me/charges/:id`
- `DELETE /web/api/shops/me/taxes/:id` and `DELETE /app/api/shops/me/taxes/:id`
- `DELETE /web/api/shops/me/charges/:id` and `DELETE /app/api/shops/me/charges/:id`

### Staff

Source file: `backend/src/routes/staff.ts`

Mounted as: `/staff`

- `GET /web/api/staff/me/performance` and `GET /app/api/staff/me/performance`
- `GET /web/api/staff` and `GET /app/api/staff`
- `GET /web/api/staff/:staffUserId` and `GET /app/api/staff/:staffUserId`
- `PATCH /web/api/staff/:staffUserId/permissions` and `PATCH /app/api/staff/:staffUserId/permissions`
- `POST /web/api/staff/:staffUserId/pin-reset` and `POST /app/api/staff/:staffUserId/pin-reset`
- `PATCH /web/api/staff/:staffUserId/status` and `PATCH /app/api/staff/:staffUserId/status`

### Subscriptions

Source file: `backend/src/routes/subscriptions.ts`

Mounted as: `/subscriptions`

- `GET /web/api/subscriptions` and `GET /app/api/subscriptions`
- `GET /web/api/subscriptions/me` and `GET /app/api/subscriptions/me`
- `POST /web/api/subscriptions/payments` and `POST /app/api/subscriptions/payments`

### Suppliers

Source file: `backend/src/routes/suppliers.ts`

Mounted as: `/suppliers`, `/add-suppliers`

- `GET /web/api/suppliers` and `GET /app/api/suppliers`; `GET /web/api/add-suppliers` and `GET /app/api/add-suppliers`
- `POST /web/api/suppliers` and `POST /app/api/suppliers`; `POST /web/api/add-suppliers` and `POST /app/api/add-suppliers`
- `GET /web/api/suppliers/:id` and `GET /app/api/suppliers/:id`; `GET /web/api/add-suppliers/:id` and `GET /app/api/add-suppliers/:id`
- `PUT /web/api/suppliers/:id` and `PUT /app/api/suppliers/:id`; `PUT /web/api/add-suppliers/:id` and `PUT /app/api/add-suppliers/:id`
- `DELETE /web/api/suppliers/:id` and `DELETE /app/api/suppliers/:id`; `DELETE /web/api/add-suppliers/:id` and `DELETE /app/api/add-suppliers/:id`
- `PATCH /web/api/suppliers/:id/status` and `PATCH /app/api/suppliers/:id/status`; `PATCH /web/api/add-suppliers/:id/status` and `PATCH /app/api/add-suppliers/:id/status`
- `GET /web/api/suppliers/:id/dues` and `GET /app/api/suppliers/:id/dues`; `GET /web/api/add-suppliers/:id/dues` and `GET /app/api/add-suppliers/:id/dues`
- `GET /web/api/suppliers/:id/ledger` and `GET /app/api/suppliers/:id/ledger`; `GET /web/api/add-suppliers/:id/ledger` and `GET /app/api/add-suppliers/:id/ledger`
- `POST /web/api/suppliers/:id/payments` and `POST /app/api/suppliers/:id/payments`; `POST /web/api/add-suppliers/:id/payments` and `POST /app/api/add-suppliers/:id/payments`
- `GET /web/api/suppliers/:id/payments` and `GET /app/api/suppliers/:id/payments`; `GET /web/api/add-suppliers/:id/payments` and `GET /app/api/add-suppliers/:id/payments`
- `GET /web/api/suppliers/:id/purchases` and `GET /app/api/suppliers/:id/purchases`; `GET /web/api/add-suppliers/:id/purchases` and `GET /app/api/add-suppliers/:id/purchases`

### Units

Source file: `backend/src/routes/units.ts`

Mounted as: `/units`

- `GET /web/api/units` and `GET /app/api/units`
- `POST /web/api/units` and `POST /app/api/units`
- `DELETE /web/api/units/:id` and `DELETE /app/api/units/:id`
- `POST /web/api/units/:id/approve` and `POST /app/api/units/:id/approve`

## Frontend API Routes

These are the active Next.js routes under `frontend/src/app/api/**`. Most forward to backend `/web/api/*`; custom handlers are called out explicitly.

- `POST /api/auth/login` - Thin proxy to backend /api/auth/login.
- `POST /api/auth/logout` - Thin proxy to backend /api/auth/logout.
- `POST /api/auth/me/avatar` - Uploads the image into the Next.js public folder, then patches the backend profile avatar.
- `GET, PATCH /api/auth/me` - Thin proxy to backend /api/auth/me.
- `POST /api/auth/refresh` - Thin proxy to backend /api/auth/refresh.
- `PUT /api/bank-accounts/:id` - Thin proxy to backend /api/bank-accounts/${id}.
- `GET, POST /api/bank-accounts` - Thin proxy to backend /api/bank-accounts.
- `PUT, DELETE /api/brands/:id` - Thin proxy to backend /api/brands/${id}.
- `GET, POST, DELETE /api/brands` - Thin proxy to backend /api/brands.
- `GET, POST /api/bulk-upload` - Custom Next.js import/export helper with local log storage and multiple upstream backend calls.
- `POST /api/categories/:id/approve` - Thin proxy to backend /api/categories/${id}/approve.
- `PATCH, DELETE /api/categories/:id` - Thin proxy to backend /api/categories/${id}.
- `POST /api/categories/import` - Custom Next.js route.
- `GET, POST /api/categories` - Thin proxy to backend /api/categories.
- `GET /api/customers/:id/ledger` - Thin proxy to backend /api/customers/${id}/ledger.
- `POST /api/customers/:id/payments` - Thin proxy to backend /api/customers/${id}/payments.
- `GET /api/customers/:id` - Thin proxy to backend /api/customers/${id}.
- `GET /api/customers/:id/sales` - Thin proxy to backend /api/customers/${id}/sales.
- `GET, POST /api/customers` - Thin proxy to backend /api/customers.
- `POST /api/customers/sales` - Thin proxy to backend /api/customers/sales.
- `PUT /api/money-boxes/:id` - Thin proxy to backend /api/money-boxes/${id}.
- `GET, POST /api/money-boxes` - Thin proxy to backend /api/money-boxes.
- `DELETE /api/product-templates/:id/products/:productId` - Thin proxy to backend /api/product-templates/${id}/products/${productId}.
- `PUT /api/product-templates/:id/products` - Thin proxy to backend /api/product-templates/${id}/products.
- `PUT, DELETE /api/product-templates/:id` - Thin proxy to backend /api/product-templates/${id}.
- `GET, POST /api/product-templates` - Thin proxy to backend /api/product-templates.
- `GET /api/products/:id/barcode` - Thin proxy to backend /api/products/${id}/barcode.svg${queryString}.
- `POST /api/products/:id/duplicate` - Thin proxy to backend /api/products/${id}/duplicate.
- `PUT, DELETE /api/products/:id` - Thin proxy to backend /api/products/${id}.
- `PATCH /api/products/:id/status` - Thin proxy to backend /api/products/${id}/status.
- `GET, POST /api/products` - Thin proxy to backend /api/products.
- `PATCH /api/purchases/:id/approve` - Thin proxy to backend /api/purchases/${id}/approve.
- `PATCH /api/purchases/:id/reject` - Thin proxy to backend /api/purchases/${id}/reject.
- `GET /api/purchases/:id` - Thin proxy to backend /api/purchases/${id}.
- `GET, POST /api/purchases` - Thin proxy to backend /api/purchases.
- `GET /api/shops` - Thin proxy to backend /api/shops.
- `GET /api/suppliers/:id/dues` - Thin proxy to backend /api/suppliers/${id}/dues.
- `GET /api/suppliers/:id/ledger` - Thin proxy to backend /api/suppliers/${id}/ledger.
- `GET, POST /api/suppliers/:id/payments` - Thin proxy to backend /api/suppliers/${id}/payments.
- `GET /api/suppliers/:id/purchases` - Thin proxy to backend /api/suppliers/${id}/purchases.
- `GET, PUT, DELETE /api/suppliers/:id` - Thin proxy to backend /api/suppliers/${id}.
- `PATCH /api/suppliers/:id/status` - Thin proxy to backend /api/suppliers/${id}/status.
- `GET, POST /api/suppliers` - Thin proxy to backend /api/suppliers.
- `POST /api/units/:id/approve` - Thin proxy to backend /api/units/${id}/approve.
- `GET, POST /api/units` - Thin proxy to backend /api/units.

## Notes

- `frontend/src/app/api/bulk-upload/route.ts` is not a single-pass proxy; it parses spreadsheets, keeps local import/export logs, and calls multiple backend routes.
- `frontend/src/app/api/auth/me/avatar/route.ts` stores the uploaded file in `frontend/public/uploads/profiles/` before updating the backend user profile.
- The older root file `dokan-erp-app api list.txt` exists, but this document is generated from the current codebase and should be treated as the fresher source of truth.

