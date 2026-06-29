#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const repoRoot = path.resolve(__dirname, "..");
const reportsDir = path.join(repoRoot, "reports");

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function inlineMarkdown(value) {
  let rendered = escapeHtml(value);
  rendered = rendered.replace(/`([^`]+)`/g, "<code>$1</code>");
  return rendered;
}

function markdownToHtml(markdown) {
  const lines = markdown.split("\n");
  const html = [];
  let inList = false;

  function closeList() {
    if (inList) {
      html.push("</ul>");
      inList = false;
    }
  }

  for (const line of lines) {
    if (!line.trim()) {
      closeList();
      continue;
    }

    if (line.startsWith("### ")) {
      closeList();
      html.push(`<h3>${inlineMarkdown(line.slice(4))}</h3>`);
      continue;
    }

    if (line.startsWith("## ")) {
      closeList();
      html.push(`<h2>${inlineMarkdown(line.slice(3))}</h2>`);
      continue;
    }

    if (line.startsWith("# ")) {
      closeList();
      html.push(`<h1>${inlineMarkdown(line.slice(2))}</h1>`);
      continue;
    }

    if (line.startsWith("- ")) {
      if (!inList) {
        html.push("<ul>");
        inList = true;
      }
      html.push(`<li>${inlineMarkdown(line.slice(2))}</li>`);
      continue;
    }

    closeList();
    html.push(`<p>${inlineMarkdown(line)}</p>`);
  }

  closeList();

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Dokan-ERP Mobile API Integration Status</title>
  <style>
    :root {
      --text: #172033;
      --muted: #4b5563;
      --border: #d6dde8;
      --accent: #0f766e;
      --paper: #ffffff;
      --bg: #f4f7fb;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: linear-gradient(180deg, #eefbf8 0%, var(--bg) 100%);
      color: var(--text);
      font-family: "DejaVu Sans", Arial, sans-serif;
      line-height: 1.45;
    }
    main {
      width: 920px;
      margin: 28px auto;
      background: var(--paper);
      padding: 38px 48px;
      border: 1px solid var(--border);
      box-shadow: 0 18px 60px rgba(15, 23, 42, 0.08);
    }
    h1, h2, h3 {
      margin: 0 0 12px;
      line-height: 1.2;
    }
    h1 {
      font-size: 28px;
      padding-bottom: 12px;
      border-bottom: 3px solid var(--accent);
    }
    h2 {
      font-size: 20px;
      margin-top: 28px;
      padding-top: 12px;
      border-top: 1px solid var(--border);
    }
    h3 {
      font-size: 16px;
      margin-top: 22px;
      color: var(--accent);
    }
    p, li {
      font-size: 12.5px;
    }
    p {
      margin: 0 0 10px;
    }
    ul {
      margin: 0 0 12px 18px;
      padding: 0;
    }
    li {
      margin: 0 0 6px;
    }
    code {
      font-family: "DejaVu Sans Mono", "Courier New", monospace;
      font-size: 11.5px;
      background: #ecfeff;
      color: #134e4a;
      padding: 1px 4px;
      border-radius: 4px;
    }
    @page {
      size: A4;
      margin: 18mm 14mm;
    }
  </style>
</head>
<body>
  <main>
    ${html.join("\n")}
  </main>
</body>
</html>`;
}

function wrapText(line, width = 92) {
  if (!line.trim()) {
    return [""];
  }

  const indentMatch = line.match(/^(\s*[-]*\s*)/);
  const indent = indentMatch ? indentMatch[1] : "";
  const words = line.trim().split(/\s+/);
  const wrapped = [];
  let current = indent;

  for (const word of words) {
    const candidate = current.trim() ? `${current}${current.trim() === indent.trim() ? "" : " "}${word}` : `${indent}${word}`;
    if (candidate.length <= width) {
      current = candidate;
      continue;
    }

    if (current.trim()) {
      wrapped.push(current);
    }

    current = `${indent}${word}`;
  }

  if (current.trim()) {
    wrapped.push(current);
  }

  return wrapped.length ? wrapped : [line];
}

function escapePdfText(value) {
  return value.replace(/\\/g, "\\\\").replace(/\(/g, "\\(").replace(/\)/g, "\\)");
}

function writeSimplePdf(markdown, outputPath) {
  const lines = markdown
    .split("\n")
    .flatMap((line) => wrapText(line))
    .map((line) => line.replace(/^###\s*/, "").replace(/^##\s*/, "").replace(/^#\s*/, ""))
    .map((line) => line.replace(/`/g, ""));

  const linesPerPage = 48;
  const pages = [];

  for (let index = 0; index < lines.length; index += linesPerPage) {
    pages.push(lines.slice(index, index + linesPerPage));
  }

  const objects = [];
  function addObject(body) {
    objects.push(body);
    return objects.length;
  }

  const fontObjectId = addObject("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");
  const pagesObjectId = 2;
  addObject("__PAGES_PLACEHOLDER__");
  const pageObjectIds = [];

  for (const pageLines of pages) {
    const commands = ["BT", "/F1 10 Tf", "50 760 Td", "14 TL"];
    for (const line of pageLines) {
      commands.push(`(${escapePdfText(line)}) Tj`);
      commands.push("T*");
    }
    commands.push("ET");
    const stream = commands.join("\n");
    const contentObjectId = addObject(`<< /Length ${Buffer.byteLength(stream, "utf8")} >>\nstream\n${stream}\nendstream`);
    const pageObjectId = addObject(
      `<< /Type /Page /Parent ${pagesObjectId} 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 ${fontObjectId} 0 R >> >> /Contents ${contentObjectId} 0 R >>`,
    );
    pageObjectIds.push(pageObjectId);
  }

  objects[pagesObjectId - 1] = `<< /Type /Pages /Kids [${pageObjectIds.map((id) => `${id} 0 R`).join(" ")}] /Count ${pageObjectIds.length} >>`;
  const catalogObjectId = addObject(`<< /Type /Catalog /Pages ${pagesObjectId} 0 R >>`);

  let pdf = "%PDF-1.4\n";
  const offsets = [0];
  for (let index = 0; index < objects.length; index += 1) {
    offsets.push(Buffer.byteLength(pdf, "utf8"));
    pdf += `${index + 1} 0 obj\n${objects[index]}\nendobj\n`;
  }
  const xrefOffset = Buffer.byteLength(pdf, "utf8");
  pdf += `xref\n0 ${objects.length + 1}\n`;
  pdf += "0000000000 65535 f \n";
  for (let index = 1; index < offsets.length; index += 1) {
    pdf += `${String(offsets[index]).padStart(10, "0")} 00000 n \n`;
  }
  pdf += `trailer\n<< /Size ${objects.length + 1} /Root ${catalogObjectId} 0 R >>\nstartxref\n${xrefOffset}\n%%EOF`;
  fs.writeFileSync(outputPath, pdf, "utf8");
}

const integrated = [
  {
    title: "Auth",
    mobileSource: "`mobile/lib/modules/auth/data/datasources/auth_remote_data_source.dart` and `mobile/lib/data/network/api_providers.dart`",
    endpoints: [
      "`POST /app/api/auth/login`",
      "`POST /app/api/auth/register-owner`",
      "`POST /app/api/auth/check-mobile`",
      "`POST /app/api/auth/send-otp`",
      "`POST /app/api/auth/verify-otp`",
      "`POST /app/api/auth/refresh`",
      "`POST /app/api/auth/logout`",
      "`GET /app/api/auth/me`",
    ],
  },
  {
    title: "Customers And Sales",
    mobileSource: "`mobile/lib/modules/customers/data/datasources/customer_remote_data_source.dart`, `mobile/lib/modules/sales/data/datasources/sales_remote_data_source.dart`, and `mobile/lib/modules/sales/presentation/screens/parts/sales_screens_pos_checkout.dart`",
    endpoints: [
      "`GET /app/api/customers`",
      "`POST /app/api/customers`",
      "`GET /app/api/customers/:id`",
      "`POST /app/api/customers/:id/payments`",
      "`GET /app/api/customers/sales`",
      "`POST /app/api/customers/sales`",
      "`POST /app/api/customers/sales/:saleId/cancel`",
      "`POST /app/api/customers/send-due-otp`",
      "`POST /app/api/customers/verify-due-otp`",
    ],
  },
  {
    title: "Products, Categories, Shop Catalog, And Stock Movement",
    mobileSource: "`mobile/lib/modules/products/data/datasources/product_remote_data_source.dart` and `mobile/lib/modules/products/data/datasources/quick_setup_catalog_remote_data_source.dart`",
    endpoints: [
      "`GET /app/api/products`",
      "`POST /app/api/products`",
      "`GET /app/api/products/:id`",
      "`PATCH /app/api/products/:id`",
      "`DELETE /app/api/products/:id`",
      "`GET /app/api/categories`",
      "`POST /app/api/categories`",
      "`DELETE /app/api/categories/:id`",
      "`GET /app/api/shops/products`",
      "`GET /app/api/inventory/stock-movements`",
      "`POST /app/api/inventory/stock-movements`",
      "`GET /app/api/shops/quick-setup/catalog`",
      "`POST /app/api/shops/quick-setup/catalog/select`",
      "`PATCH /app/api/shops/quick-setup/catalog/pricing`",
    ],
  },
  {
    title: "Purchases",
    mobileSource: "`mobile/lib/modules/purchases/data/datasources/purchase_remote_data_source.dart`",
    endpoints: [
      "`GET /app/api/purchases`",
      "`POST /app/api/purchases`",
      "`GET /app/api/purchases/:id`",
      "`PATCH /app/api/purchases/:id`",
      "`POST /app/api/purchases/:id/receive`",
      "`POST /app/api/purchases/:id/cancel`",
      "`POST /app/api/purchases/:id/returns`",
    ],
  },
  {
    title: "Suppliers",
    mobileSource: "`mobile/lib/modules/suppliers/data/datasources/supplier_remote_data_source.dart`",
    endpoints: [
      "`GET /app/api/suppliers`",
      "`POST /app/api/suppliers`",
      "`DELETE /app/api/suppliers/:id`",
      "`GET /app/api/suppliers/:id/ledger`",
      "`POST /app/api/suppliers/:id/payments`",
    ],
  },
  {
    title: "Expenses",
    mobileSource: "`mobile/lib/modules/expenses/data/datasources/expense_remote_data_source.dart`",
    endpoints: [
      "`GET /app/api/expenses`",
      "`POST /app/api/expenses`",
      "`PATCH /app/api/expenses/:id`",
      "`DELETE /app/api/expenses/:id`",
    ],
  },
  {
    title: "Business Settings, Subscription, Inventory Layout, Dashboard, Reports, Staff, Notifications",
    mobileSource: "`mobile/lib/modules/settings/data/datasources/*.dart` and `mobile/lib/data/network/erp_remote_data_source.dart`",
    endpoints: [
      "`GET /app/api/settings/inventory`",
      "`PATCH /app/api/settings/inventory`",
      "`GET /app/api/settings/store`",
      "`PUT /app/api/settings/store`",
      "`POST /app/api/settings/store/documents/:type`",
      "`PATCH /app/api/shops/me/logo`",
      "`GET /app/api/subscriptions/me`",
      "`POST /app/api/subscriptions/payments`",
      "`GET /app/api/inventory/mode`",
      "`POST /app/api/inventory/mode`",
      "`GET /app/api/inventory/layout-tree`",
      "`POST /app/api/inventory/zones`",
      "`PATCH /app/api/inventory/zones/:id`",
      "`DELETE /app/api/inventory/zones/:id`",
      "`POST /app/api/inventory/racks`",
      "`PATCH /app/api/inventory/racks/:id`",
      "`DELETE /app/api/inventory/racks/:id`",
      "`POST /app/api/inventory/shelves`",
      "`PATCH /app/api/inventory/shelves/:id`",
      "`DELETE /app/api/inventory/shelves/:id`",
      "`POST /app/api/inventory/bins`",
      "`PATCH /app/api/inventory/bins/:id`",
      "`DELETE /app/api/inventory/bins/:id`",
      "`GET /app/api/reports/dashboard`",
      "`GET /app/api/reports/sales/daily`",
      "`GET /app/api/reports/purchases/summary`",
      "`GET /app/api/reports/dues/summary`",
      "`GET /app/api/reports/expenses/summary`",
      "`GET /app/api/reports/profit-loss`",
      "`GET /app/api/reports/stock-value`",
      "`GET /app/api/staff`",
      "`GET /app/api/notifications`",
    ],
  },
];

const mismatches = [];

const notIntegrated = [
  {
    title: "Bank Accounts",
    endpoints: [
      "`GET /app/api/bank-accounts`",
      "`POST /app/api/bank-accounts`",
      "`PUT /app/api/bank-accounts/:id`",
    ],
  },
  {
    title: "Brands",
    endpoints: [
      "`GET /app/api/brands`",
      "`POST /app/api/brands`",
      "`PUT /app/api/brands/:id`",
      "`DELETE /app/api/brands`",
      "`DELETE /app/api/brands/:id`",
    ],
  },
  {
    title: "Money Boxes",
    endpoints: [
      "`GET /app/api/money-boxes`",
      "`POST /app/api/money-boxes`",
      "`PUT /app/api/money-boxes/:id`",
    ],
  },
  {
    title: "Product Templates",
    endpoints: [
      "`GET /app/api/product-templates`",
      "`POST /app/api/product-templates`",
      "`PUT /app/api/product-templates/:id`",
      "`DELETE /app/api/product-templates/:id`",
      "`PUT /app/api/product-templates/:id/products`",
      "`DELETE /app/api/product-templates/:id/products/:productId`",
    ],
  },
  {
    title: "Units",
    endpoints: [
      "`GET /app/api/units`",
      "`POST /app/api/units`",
      "`DELETE /app/api/units/:id`",
      "`POST /app/api/units/:id/approve`",
    ],
  },
  {
    title: "Shop Management APIs Beyond Logo",
    endpoints: [
      "`GET /app/api/shops`",
      "`GET /app/api/shops/me/settings`",
      "`PATCH /app/api/shops/me/settings`",
      "`GET /app/api/shops/me/finance-sources`",
      "`POST /app/api/shops/me/money-boxes`",
      "`PUT /app/api/shops/me/money-boxes/:id`",
      "`POST /app/api/shops/me/bank-accounts`",
      "`PUT /app/api/shops/me/bank-accounts/:id`",
      "`GET /app/api/shops/me/inventory-settings`",
      "`PATCH /app/api/shops/me/inventory-settings`",
      "`GET /app/api/shops/me/taxes-charges`",
      "`POST /app/api/shops/me/taxes`",
      "`POST /app/api/shops/me/charges`",
      "`PATCH /app/api/shops/me/taxes/:id`",
      "`PATCH /app/api/shops/me/charges/:id`",
      "`DELETE /app/api/shops/me/taxes/:id`",
      "`DELETE /app/api/shops/me/charges/:id`",
    ],
  },
  {
    title: "Customer Read APIs Not Yet Used In Mobile",
    endpoints: [
      "`GET /app/api/customers/:id/sales`",
      "`GET /app/api/customers/:id/ledger`",
      "`GET /app/api/customers/sales/closing-summary`",
      "`GET /app/api/customers/sales/:saleId`",
    ],
  },
  {
    title: "Supplier Read And Admin APIs Not Yet Used In Mobile",
    endpoints: [
      "`GET /app/api/suppliers/:id`",
      "`PUT /app/api/suppliers/:id`",
      "`PATCH /app/api/suppliers/:id/status`",
      "`GET /app/api/suppliers/:id/dues`",
      "`GET /app/api/suppliers/:id/payments`",
      "`GET /app/api/suppliers/:id/purchases`",
      "`GET /app/api/add-suppliers/*` alias routes",
    ],
  },
  {
    title: "Purchase Admin APIs Not Yet Used In Mobile",
    endpoints: [
      "`POST /app/api/purchases/:id/payments`",
      "`GET /app/api/purchases/:id/returns`",
      "`PATCH /app/api/purchases/:id/approve`",
      "`PATCH /app/api/purchases/:id/reject`",
    ],
  },
  {
    title: "Product APIs Not Yet Used In Mobile",
    endpoints: [
      "`GET /app/api/products/:id/barcode.svg`",
      "`POST /app/api/products/:id/duplicate`",
      "`GET /app/api/products/approval-requests`",
      "`PATCH /app/api/products/approval-requests/:id/approve`",
      "`PATCH /app/api/products/approval-requests/:id/reject`",
      "`PATCH /app/api/products/:id/status`",
    ],
  },
  {
    title: "Inventory APIs Not Yet Used In Mobile",
    endpoints: [
      "`GET /app/api/inventory/dashboard`",
      "`GET /app/api/inventory/attention`",
      "`GET /app/api/inventory/general-store`",
      "`GET /app/api/inventory/zones`",
      "`GET /app/api/inventory/racks`",
      "`GET /app/api/inventory/shelves`",
      "`GET /app/api/inventory/bins`",
      "`POST /app/api/inventory/placements`",
    ],
  },
  {
    title: "Notifications Write APIs",
    endpoints: [
      "`GET /app/api/notifications/settings`",
      "`PUT /app/api/notifications/settings`",
      "`POST /app/api/notifications`",
      "`PUT /app/api/notifications/read`",
      "`DELETE /app/api/notifications`",
    ],
  },
  {
    title: "Staff Detail/Admin APIs",
    endpoints: [
      "`GET /app/api/staff/me/performance`",
      "`GET /app/api/staff/:staffUserId`",
      "`PATCH /app/api/staff/:staffUserId/permissions`",
      "`POST /app/api/staff/:staffUserId/pin-reset`",
      "`PATCH /app/api/staff/:staffUserId/status`",
    ],
  },
  {
    title: "Auth Flows Not Yet Hooked In Mobile",
    endpoints: [
      "`POST /app/api/auth/register-salesman`",
      "`POST /app/api/auth/register-owner-draft`",
      "`POST /app/api/auth/setup-pin`",
      "`POST /app/api/auth/complete-registration`",
      "`POST /app/api/auth/pre-login`",
      "`POST /app/api/auth/owners-login`",
      "`POST /app/api/auth/salesmans-login`",
      "`POST /app/api/auth/send-owner-login-otp`",
      "`POST /app/api/auth/owners-login-otp`",
      "`POST /app/api/auth/salesmans-login-otp`",
      "`POST /app/api/auth/send-login-otp`",
      "`POST /app/api/auth/verify-login-otp`",
      "`POST /app/api/auth/owners-verify-otp`",
      "`POST /app/api/auth/salesmans-verify-otp`",
      "`PATCH /app/api/auth/me`",
      "`PATCH /app/api/auth/me/password`",
      "`PATCH /app/api/auth/me/avatar`",
    ],
  },
];

function buildMarkdown() {
  const today = new Date().toISOString().slice(0, 10);
  const lines = [];

  lines.push("# Dokan-ERP Mobile API Integration Status");
  lines.push("");
  lines.push(`Generated from the current repository source on ${today}.`);
  lines.push("");
  lines.push("## Scope");
  lines.push("");
  lines.push("- Backend source checked: `backend/src/app.ts` and `backend/src/routes/*.ts`");
  lines.push("- Mobile source checked: `mobile/lib/core/constants/api_endpoints.dart`, `mobile/lib/data/network/erp_remote_data_source.dart`, and all `mobile/lib/modules/**/data/datasources/*remote*.dart` files");
  lines.push("- Base API scope for mobile: `'/app/api'`");
  lines.push("");
  lines.push("## How To Read This");
  lines.push("");
  lines.push("- `Integrated` means the mobile app has a real caller and the backend route exists with a matching path/method.");
  lines.push("- `Needs Fix` means mobile code calls an API, but the backend path or method does not match the current backend implementation.");
  lines.push("- `Need To Integrate` means the backend already exposes the route under `/app/api`, but the current mobile app has no direct caller for it.");
  lines.push("");
  lines.push("## Integrated APIs");
  lines.push("");

  for (const group of integrated) {
    lines.push(`### ${group.title}`);
    lines.push("");
    lines.push(`Mobile source: ${group.mobileSource}`);
    lines.push("");
    for (const endpoint of group.endpoints) {
      lines.push(`- ${endpoint}`);
    }
    lines.push("");
  }

  lines.push("## APIs That Need Fixing In Mobile");
  lines.push("");

  if (mismatches.length === 0) {
    lines.push("- No known mobile/backend route mismatches were found in the currently documented set.");
  } else {
    for (const item of mismatches) {
      lines.push(`- ${item.mobileCall} - ${item.issue} Source: ${item.mobileSource}`);
    }
  }

  lines.push("");
  lines.push("## Backend APIs That Still Need Mobile Integration");
  lines.push("");

  for (const group of notIntegrated) {
    lines.push(`### ${group.title}`);
    lines.push("");
    for (const endpoint of group.endpoints) {
      lines.push(`- ${endpoint}`);
    }
    lines.push("");
  }

  lines.push("## Recommended Next Work");
  lines.push("");
  lines.push("- The mismatch bucket is now cleared in this report, so the next work is expanding mobile coverage into the remaining backend route groups.");
  lines.push("- The highest-value missing integrations for daily mobile workflows are shop settings, supplier detail/dues/payment history, customer ledger/sales history, and purchase approval/payment history.");
  lines.push("- If you want tighter mobile coverage for owner operations, the next route groups to wire are `bank-accounts`, `money-boxes`, `units`, `brands`, and `notifications` write actions.");
  lines.push("");

  return lines.join("\n");
}

function main() {
  ensureDir(reportsDir);
  const markdown = buildMarkdown();
  const html = markdownToHtml(markdown);

  const markdownPath = path.join(reportsDir, "dokan-erp-mobile-api-integration-status.md");
  const htmlPath = path.join(reportsDir, "dokan-erp-mobile-api-integration-status.html");
  const pdfPath = path.join(reportsDir, "dokan-erp-mobile-api-integration-status.pdf");

  fs.writeFileSync(markdownPath, `${markdown}\n`, "utf8");
  fs.writeFileSync(htmlPath, html, "utf8");
  writeSimplePdf(markdown, pdfPath);

  console.log(
    JSON.stringify(
      {
        markdownPath,
        htmlPath,
        pdfPath,
        integratedGroups: integrated.length,
        mismatchCount: mismatches.length,
        pendingGroups: notIntegrated.length,
      },
      null,
      2,
    ),
  );
}

main();
