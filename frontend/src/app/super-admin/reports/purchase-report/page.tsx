"use client";

import { useState } from "react";

const purchaseStats = [
  {
    label: "Total Purchase",
    value: "৳12.5M",
    sublabel: "This month total spend",
    accent: "green",
    icon: "wallet",
  },
  {
    label: "Purchase Orders",
    value: "45,231",
    sublabel: "Processed purchase invoices",
    accent: "indigo",
    icon: "receipt",
  },
  {
    label: "Purchasing Shops",
    value: "1,254",
    sublabel: "Shops with active buying",
    accent: "orange",
    icon: "shop",
  },
  {
    label: "Avg Purchase",
    value: "৳27,540",
    sublabel: "Average per purchase order",
    accent: "red",
    icon: "chart",
  },
  {
    label: "Suppliers Used",
    value: "4,328",
    sublabel: "Unique suppliers in range",
    accent: "indigo",
    icon: "users",
  },
  {
    label: "Growth %",
    value: "+12.4%",
    sublabel: "Compared with previous period",
    accent: "green",
    icon: "trend",
  },
];

const trendLabels = ["01 Jun", "05 Jun", "10 Jun", "15 Jun", "20 Jun", "25 Jun", "30 Jun"];

const categoryBreakdown = [
  { label: "Groceries", value: "34%", amount: "৳4.25M", accent: "green" },
  { label: "Beverages", value: "21%", amount: "৳2.63M", accent: "blue" },
  { label: "Snacks", value: "18%", amount: "৳2.25M", accent: "amber" },
  { label: "Household", value: "15%", amount: "৳1.88M", accent: "violet" },
  { label: "Personal Care", value: "12%", amount: "৳1.49M", accent: "red" },
];

const topPurchasingShops = [
  { name: "Rahman Store", location: "Mirpur, Dhaka", amount: "৳1,245,000", orders: 428 },
  { name: "Janata Bazar", location: "Uttara, Dhaka", amount: "৳1,180,000", orders: 396 },
  { name: "Bondhon Mart", location: "Cumilla", amount: "৳965,000", orders: 344 },
  { name: "Mother Store", location: "Chattogram", amount: "৳912,000", orders: 321 },
  { name: "Fresh Corner", location: "Rajshahi", amount: "৳874,000", orders: 308 },
];

const topSuppliers = [
  { name: "Fresh Wholesale Ltd.", category: "Groceries", amount: "৳1,580,000", invoices: 612 },
  { name: "Teer Distribution", category: "Cooking Oil", amount: "৳1,410,000", invoices: 544 },
  { name: "Pran Foods", category: "Beverages", amount: "৳1,265,000", invoices: 503 },
  { name: "ACI Consumer", category: "Household", amount: "৳1,022,000", invoices: 388 },
  { name: "Square Essentials", category: "Personal Care", amount: "৳945,000", invoices: 356 },
];

const purchaseRows = [
  {
    date: "30 Jun 2026",
    shop: "Rahman Store",
    supplier: "Fresh Wholesale Ltd.",
    invoice: "PUR-240630-001",
    items: 42,
    total: "৳68,450",
    status: "Paid",
  },
  {
    date: "30 Jun 2026",
    shop: "Janata Bazar",
    supplier: "Teer Distribution",
    invoice: "PUR-240630-002",
    items: 28,
    total: "৳54,220",
    status: "Partial",
  },
  {
    date: "29 Jun 2026",
    shop: "Bondhon Mart",
    supplier: "Pran Foods",
    invoice: "PUR-240629-014",
    items: 31,
    total: "৳49,880",
    status: "Paid",
  },
  {
    date: "29 Jun 2026",
    shop: "Mother Store",
    supplier: "ACI Consumer",
    invoice: "PUR-240629-009",
    items: 19,
    total: "৳36,700",
    status: "Pending",
  },
  {
    date: "28 Jun 2026",
    shop: "Fresh Corner",
    supplier: "Square Essentials",
    invoice: "PUR-240628-005",
    items: 24,
    total: "৳41,260",
    status: "Paid",
  },
  {
    date: "28 Jun 2026",
    shop: "City Point",
    supplier: "Fresh Wholesale Ltd.",
    invoice: "PUR-240628-002",
    items: 37,
    total: "৳57,940",
    status: "Cancelled",
  },
];

function PurchaseReportStatIcon({ type }: { type: string }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (type) {
    case "wallet":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M4.5 8.5A2.5 2.5 0 0 1 7 6h10.5v12H7A2.5 2.5 0 0 1 4.5 15.5v-7Z" />
          <path {...commonProps} d="M17.5 9.5h2v5h-2a2.5 2.5 0 1 1 0-5Z" />
          <path {...commonProps} d="M7 6V4.5h9" />
        </svg>
      );
    case "receipt":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M8 4.5h8l3 3V19l-2-1.5L15 19l-2-1.5L11 19 9 17.5 7 19V4.5Z" />
          <path {...commonProps} d="M9 10h6" />
          <path {...commonProps} d="M9 13.5h6" />
        </svg>
      );
    case "shop":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M4.5 9h15" />
          <path {...commonProps} d="M6 9V19h12V9" />
          <path {...commonProps} d="M4 9 6 5h12l2 4" />
          <path {...commonProps} d="M9 19v-5h6v5" />
        </svg>
      );
    case "chart":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M5 18.5h14" />
          <path {...commonProps} d="M8 16v-4" />
          <path {...commonProps} d="M12 16V8" />
          <path {...commonProps} d="M16 16v-6" />
        </svg>
      );
    case "users":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
          <path {...commonProps} d="M4.5 18a4.5 4.5 0 0 1 9 0" />
          <path {...commonProps} d="M17 10a2.5 2.5 0 1 0 0-5" />
          <path {...commonProps} d="M17 13.5a4 4 0 0 1 3 3.5" />
        </svg>
      );
    case "trend":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M5 17V7" />
          <path {...commonProps} d="M5 17h14" />
          <path {...commonProps} d="m8 14 3-3 3 2 4-5" />
        </svg>
      );
    default:
      return null;
  }
}

function EyeIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path d="M2.5 12s3.5-6 9.5-6 9.5 6 9.5 6-3.5 6-9.5 6-9.5-6-9.5-6Z" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  );
}

function MoreIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <circle cx="12" cy="5.5" r="1.5" />
      <circle cx="12" cy="12" r="1.5" />
      <circle cx="12" cy="18.5" r="1.5" />
    </svg>
  );
}

export default function PurchaseReportPage() {
  const [openActionMenu, setOpenActionMenu] = useState<string | null>(null);

  return (
    <section className="master-category-page">
      <div className="purchase-report-layout">
        <section className="master-category-table-card purchase-report-header-card">
          <div>
            <h2>Purchase Report</h2>
            <p>Track purchase volume, supplier usage, trend movement, and order-level activity.</p>
          </div>

          <div className="purchase-report-date-range">
            <div className="purchase-report-date-field">
              <span>From</span>
              <input type="date" defaultValue="2026-06-01" />
            </div>
            <div className="purchase-report-date-field">
              <span>To</span>
              <input type="date" defaultValue="2026-06-30" />
            </div>
            <button type="button" className="master-category-primary-button">Apply Range</button>
          </div>
        </section>

        <div className="admin-dashboard-stats purchase-report-stats">
          {purchaseStats.map((stat) => (
            <article className="admin-stat-card" key={stat.label}>
              <div className={`admin-stat-icon admin-stat-icon-${stat.accent}`}>
                <PurchaseReportStatIcon type={stat.icon} />
              </div>
              <div className="admin-stat-content">
                <div className="admin-stat-heading">
                  <span>{stat.label}</span>
                </div>
                <strong>{stat.value}</strong>
                <p>{stat.sublabel}</p>
              </div>
            </article>
          ))}
        </div>

        <div className="purchase-report-grid-two">
          <section className="admin-dashboard-panel purchase-report-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Purchase Trend</h3>
                <p>Daily purchase amount and order count over the selected date range.</p>
              </div>
              <button className="admin-filter-chip" type="button">
                Daily
                <span className="admin-filter-caret">⌄</span>
              </button>
            </div>

            <div className="admin-chart-shell">
              <div className="admin-chart-axis">
                <span>৳15L</span>
                <span>৳12L</span>
                <span>৳9L</span>
                <span>৳6L</span>
                <span>৳3L</span>
                <span>৳0</span>
              </div>

              <div className="admin-chart-area">
                <div className="admin-chart-grid">
                  <span />
                  <span />
                  <span />
                  <span />
                  <span />
                  <span />
                </div>
                <svg className="admin-chart-svg" viewBox="0 0 640 240" preserveAspectRatio="none" aria-hidden="true">
                  <defs>
                    <linearGradient id="purchase-fill" x1="0" x2="0" y1="0" y2="1">
                      <stop offset="0%" stopColor="rgba(16, 185, 129, 0.26)" />
                      <stop offset="100%" stopColor="rgba(16, 185, 129, 0)" />
                    </linearGradient>
                    <linearGradient id="orders-fill-purchase" x1="0" x2="0" y1="0" y2="1">
                      <stop offset="0%" stopColor="rgba(67, 97, 255, 0.24)" />
                      <stop offset="100%" stopColor="rgba(67, 97, 255, 0)" />
                    </linearGradient>
                  </defs>
                  <path
                    className="admin-chart-fill-green"
                    d="M0 190 C30 142, 58 114, 92 120 S146 72, 182 82 S238 164, 274 146 S330 92, 366 104 S422 148, 458 138 S514 58, 550 76 S602 126, 640 88 L640 240 L0 240 Z"
                    fill="url(#purchase-fill)"
                  />
                  <path
                    className="admin-chart-fill-blue"
                    d="M0 214 C30 202, 58 190, 92 176 S146 160, 182 150 S238 188, 274 178 S330 132, 366 142 S422 168, 458 154 S514 118, 550 134 S602 152, 640 146 L640 240 L0 240 Z"
                    fill="url(#orders-fill-purchase)"
                  />
                  <path
                    className="admin-chart-line-green"
                    d="M0 190 C30 142, 58 114, 92 120 S146 72, 182 82 S238 164, 274 146 S330 92, 366 104 S422 148, 458 138 S514 58, 550 76 S602 126, 640 88"
                  />
                  <path
                    className="admin-chart-line-blue"
                    d="M0 214 C30 202, 58 190, 92 176 S146 160, 182 150 S238 188, 274 178 S330 132, 366 142 S422 168, 458 154 S514 118, 550 134 S602 152, 640 146"
                  />
                </svg>

                <div className="admin-chart-labels">
                  {trendLabels.map((label) => (
                    <span key={label}>{label}</span>
                  ))}
                </div>
              </div>
            </div>

          </section>

          <section className="admin-dashboard-panel purchase-report-panel purchase-report-category-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Purchase by Category</h3>
                <p>Category contribution to the total purchase amount.</p>
              </div>
            </div>

            <div className="purchase-report-donut-layout">
              <div className="purchase-report-donut-wrap" aria-hidden="true">
                <svg viewBox="0 0 220 220" className="purchase-report-donut-svg">
                  <circle cx="110" cy="110" r="66" className="purchase-report-donut-track" />
                  <circle cx="110" cy="110" r="66" className="purchase-report-donut-segment purchase-report-donut-segment-green" />
                  <circle cx="110" cy="110" r="66" className="purchase-report-donut-segment purchase-report-donut-segment-blue" />
                  <circle cx="110" cy="110" r="66" className="purchase-report-donut-segment purchase-report-donut-segment-amber" />
                  <circle cx="110" cy="110" r="66" className="purchase-report-donut-segment purchase-report-donut-segment-violet" />
                  <circle cx="110" cy="110" r="66" className="purchase-report-donut-segment purchase-report-donut-segment-red" />
                </svg>
                <div className="purchase-report-donut-center">
                  <strong>৳12.5M</strong>
                  <span>Total Purchase</span>
                </div>
              </div>

              <div className="purchase-report-category-list">
                {categoryBreakdown.map((item) => (
                  <article className="purchase-report-rank-card" key={item.label}>
                    <div className="purchase-report-rank-main">
                      <i className={`admin-legend-dot admin-legend-dot-${item.accent}`} />
                      <div>
                        <strong>{item.label}</strong>
                        <span>{item.amount}</span>
                      </div>
                    </div>
                    <em>{item.value}</em>
                  </article>
                ))}
              </div>
            </div>
          </section>
        </div>

        <div className="purchase-report-grid-two">
          <section className="admin-dashboard-panel purchase-report-panel purchase-report-ranking-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Top Purchasing Shops</h3>
                <p>Highest-spending shops in the selected period.</p>
              </div>
            </div>

            <div className="purchase-report-rank-list purchase-report-rank-list-compact">
              {topPurchasingShops.map((item, index) => (
                <article className="purchase-report-rank-card purchase-report-rank-card-strong" key={item.name}>
                  <div className="purchase-report-rank-main purchase-report-rank-main-compact">
                    <span className="purchase-report-rank-index">{String(index + 1).padStart(2, "0")}</span>
                    <div>
                      <strong>{item.name}</strong>
                      <span>{item.location}</span>
                    </div>
                  </div>
                  <div className="purchase-report-rank-meta purchase-report-rank-meta-compact">
                    <strong>{item.amount}</strong>
                    <span>{item.orders} orders</span>
                  </div>
                </article>
              ))}
            </div>
          </section>

          <section className="admin-dashboard-panel purchase-report-panel purchase-report-ranking-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Top Suppliers</h3>
                <p>Suppliers contributing the highest purchase volume.</p>
              </div>
            </div>

            <div className="purchase-report-rank-list purchase-report-rank-list-compact">
              {topSuppliers.map((item, index) => (
                <article className="purchase-report-rank-card" key={item.name}>
                  <div className="purchase-report-rank-main purchase-report-rank-main-compact">
                    <span className="purchase-report-rank-index">{String(index + 1).padStart(2, "0")}</span>
                    <div>
                      <strong>{item.name}</strong>
                      <span>{item.category}</span>
                    </div>
                  </div>
                  <div className="purchase-report-rank-meta purchase-report-rank-meta-compact">
                    <strong>{item.amount}</strong>
                    <span>{item.invoices} invoices</span>
                  </div>
                </article>
              ))}
            </div>
          </section>
        </div>

        <section className="master-category-table-card purchase-report-filters-card">
          <div className="purchase-report-filter-grid">
            <label className="purchase-report-field purchase-report-field-search">
              <span>Search</span>
              <input type="search" placeholder="Search invoice, shop or supplier..." />
            </label>
            <label className="purchase-report-field">
              <span>Shop</span>
              <select defaultValue="All Shops">
                <option>All Shops</option>
                <option>Rahman Store</option>
                <option>Janata Bazar</option>
                <option>Bondhon Mart</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Supplier</span>
              <select defaultValue="All Suppliers">
                <option>All Suppliers</option>
                <option>Fresh Wholesale Ltd.</option>
                <option>Teer Distribution</option>
                <option>Pran Foods</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Category</span>
              <select defaultValue="All Categories">
                <option>All Categories</option>
                <option>Groceries</option>
                <option>Beverages</option>
                <option>Household</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Payment</span>
              <select defaultValue="All Payments">
                <option>All Payments</option>
                <option>Cash</option>
                <option>Bank</option>
                <option>Credit</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Status</span>
              <select defaultValue="All Status">
                <option>All Status</option>
                <option>Paid</option>
                <option>Partial</option>
                <option>Pending</option>
                <option>Cancelled</option>
              </select>
            </label>
          </div>

          <div className="purchase-report-filter-actions">
            <button type="button" className="master-category-outline-button">Clear Filters</button>
            <button type="button" className="master-category-outline-button">Export Excel</button>
            <button type="button" className="master-category-primary-button">Export PDF</button>
          </div>
        </section>

        <section className="master-category-table-card purchase-report-table-card">
          <div className="purchase-report-table-header">
            <div>
              <h3>Purchase Records Table</h3>
              <p>Showing recent purchase records for the selected filter set.</p>
            </div>
          </div>

          <div className="purchase-report-table">
            <div className="purchase-report-table-head">
              <span>Date</span>
              <span>Shop</span>
              <span>Supplier</span>
              <span>Invoice</span>
              <span>Items</span>
              <span>Total</span>
              <span>Status</span>
              <span>Actions</span>
            </div>

            {purchaseRows.map((row) => (
              <div className="purchase-report-table-row" key={row.invoice}>
                <span>{row.date}</span>
                <span>{row.shop}</span>
                <span>{row.supplier}</span>
                <span>{row.invoice}</span>
                <span>{row.items}</span>
                <span>{row.total}</span>
                <span>
                  <em
                    className={`purchase-report-status-badge${
                      row.status === "Partial"
                        ? " purchase-report-status-badge-partial"
                        : row.status === "Pending"
                          ? " purchase-report-status-badge-pending"
                          : row.status === "Cancelled"
                            ? " purchase-report-status-badge-cancelled"
                            : ""
                    }`}
                  >
                    {row.status}
                  </em>
                </span>
                <span className="purchase-report-row-actions">
                  <button type="button" className="purchase-report-view-button" aria-label={`View ${row.invoice}`}>
                    <EyeIcon />
                    <span>View</span>
                  </button>
                  <span className="master-category-action-menu">
                    <button
                      type="button"
                      className="purchase-report-more-button"
                      aria-label={`More actions for ${row.invoice}`}
                      aria-haspopup="menu"
                      aria-expanded={openActionMenu === row.invoice}
                      onClick={() => setOpenActionMenu((current) => (current === row.invoice ? null : row.invoice))}
                    >
                      <MoreIcon />
                      <span>More</span>
                    </button>
                    {openActionMenu === row.invoice ? (
                      <div className="master-category-action-dropdown" role="menu">
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          View Purchase
                        </button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          View Shop
                        </button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          View Supplier
                        </button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          Download Invoice
                        </button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          Print
                        </button>
                      </div>
                    ) : null}
                  </span>
                </span>
              </div>
            ))}
          </div>

          <div className="master-category-footer purchase-report-pagination-wrap">
            <span className="master-category-footer-text">Showing 1-6 of 45,231 purchase records</span>
            <div className="master-category-pagination">
              <button type="button" className="master-category-page-button">{"<"} Prev</button>
              <button type="button" className="master-category-page-chip master-category-page-chip-active">1</button>
              <button type="button" className="master-category-page-chip">2</button>
              <button type="button" className="master-category-page-chip">3</button>
              <button type="button" className="master-category-page-chip">...</button>
              <button type="button" className="master-category-page-chip">120</button>
              <button type="button" className="master-category-page-button">Next {">"}</button>
            </div>
            <select className="master-category-page-size" defaultValue="10">
              <option value="10">10 / page</option>
              <option value="20">20 / page</option>
              <option value="50">50 / page</option>
            </select>
          </div>
        </section>
      </div>
    </section>
  );
}
