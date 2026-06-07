"use client";

import { useState } from "react";

const salesStats = [
  { label: "Total Sales", value: "৳12,45,67,890", sublabel: "Gross revenue", accent: "green", icon: "wallet" },
  { label: "Total Orders", value: "45,231", sublabel: "Order count", accent: "indigo", icon: "receipt" },
  { label: "Active Shops", value: "1,254", sublabel: "Selling stores", accent: "red", icon: "shop" },
  { label: "Avg Order", value: "৳275", sublabel: "Average order", accent: "orange", icon: "chart" },
  { label: "Gross Profit", value: "৳2,45,00,000", sublabel: "Profit earned", accent: "green", icon: "profit" },
  { label: "Growth", value: "+12.4%", sublabel: "Vs previous period", accent: "green", icon: "trend" },
];

const salesTrendLabels = ["01 Jun", "05 Jun", "10 Jun", "15 Jun", "20 Jun", "25 Jun", "30 Jun"];

const salesCategories = [
  { label: "Rice", amount: "৳3.92M", value: "31%", accent: "green" },
  { label: "Oil", amount: "৳2.76M", value: "22%", accent: "blue" },
  { label: "Beverage", amount: "৳2.14M", value: "17%", accent: "amber" },
  { label: "Cosmetics", amount: "৳1.63M", value: "13%", accent: "violet" },
  { label: "Others", amount: "৳2.00M", value: "17%", accent: "red" },
];

const topSellingShops = [
  { shop: "Rahman Store", sales: "৳1,985,000", orders: "862", profit: "৳286,000" },
  { shop: "Janata Bazar", sales: "৳1,842,000", orders: "801", profit: "৳252,000" },
  { shop: "Bondhon Mart", sales: "৳1,568,000", orders: "694", profit: "৳214,000" },
  { shop: "Mother Store", sales: "৳1,412,000", orders: "641", profit: "৳198,000" },
  { shop: "Fresh Corner", sales: "৳1,305,000", orders: "603", profit: "৳184,000" },
];

const topSellingProducts = [
  { product: "Miniket Rice 25KG", qty: "4,280", revenue: "৳2,140,000" },
  { product: "Fresh Soybean Oil 5L", qty: "3,960", revenue: "৳1,782,000" },
  { product: "Pran Mango Juice 1L", qty: "3,420", revenue: "৳1,248,000" },
  { product: "Lux Soap Twin Pack", qty: "3,180", revenue: "৳1,176,000" },
  { product: "Wheel Detergent", qty: "2,940", revenue: "৳1,102,000" },
];

const paymentMethods = [
  { label: "Cash", amount: "৳4.85M", percent: "39%", count: "12,860", accent: "green" },
  { label: "Bkash", amount: "৳3.10M", percent: "25%", count: "8,945", accent: "blue" },
  { label: "Nagad", amount: "৳1.96M", percent: "16%", count: "6,118", accent: "amber" },
  { label: "Card", amount: "৳1.48M", percent: "12%", count: "4,022", accent: "violet" },
  { label: "Bank", amount: "৳1.06M", percent: "8%", count: "3,286", accent: "red" },
];

const salesByBrand = [
  { label: "Fresh", amount: "৳2.84M", share: "22%" },
  { label: "Pran", amount: "৳2.42M", share: "19%" },
  { label: "ACI", amount: "৳1.94M", share: "15%" },
  { label: "Square", amount: "৳1.61M", share: "13%" },
  { label: "Unilever", amount: "৳1.32M", share: "11%" },
];

const salesRecords = [
  {
    dateTime: "30 Jun 2026, 10:42 AM",
    invoiceNo: "SAL-240630-001",
    shop: "Rahman Store",
    customer: "Mehedi Hasan",
    salesman: "Rakib",
    items: "12",
    subtotal: "৳8,450",
    discount: "৳250",
    netAmount: "৳8,200",
    profit: "৳1,180",
    paymentMethod: "Bkash",
    status: "Paid",
  },
  {
    dateTime: "30 Jun 2026, 09:55 AM",
    invoiceNo: "SAL-240630-002",
    shop: "Janata Bazar",
    customer: "Nusrat Jahan",
    salesman: "Sojib",
    items: "8",
    subtotal: "৳5,940",
    discount: "৳140",
    netAmount: "৳5,800",
    profit: "৳860",
    paymentMethod: "Cash",
    status: "Paid",
  },
  {
    dateTime: "29 Jun 2026, 07:15 PM",
    invoiceNo: "SAL-240629-014",
    shop: "Bondhon Mart",
    customer: "Retail Walk-in",
    salesman: "Milon",
    items: "15",
    subtotal: "৳9,280",
    discount: "৳380",
    netAmount: "৳8,900",
    profit: "৳1,320",
    paymentMethod: "Card",
    status: "Partial",
  },
  {
    dateTime: "29 Jun 2026, 03:22 PM",
    invoiceNo: "SAL-240629-009",
    shop: "Mother Store",
    customer: "Sharmin Akter",
    salesman: "Tuhin",
    items: "6",
    subtotal: "৳3,980",
    discount: "৳80",
    netAmount: "৳3,900",
    profit: "৳580",
    paymentMethod: "Nagad",
    status: "Pending",
  },
  {
    dateTime: "28 Jun 2026, 05:05 PM",
    invoiceNo: "SAL-240628-005",
    shop: "Fresh Corner",
    customer: "Sabbir Ahmed",
    salesman: "Nayeem",
    items: "10",
    subtotal: "৳6,240",
    discount: "৳240",
    netAmount: "৳6,000",
    profit: "৳910",
    paymentMethod: "Bank",
    status: "Refunded",
  },
];

function SalesReportStatIcon({ type }: { type: string }) {
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
    case "profit":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M4 18h16" />
          <path {...commonProps} d="M7 15V9" />
          <path {...commonProps} d="M12 15V6" />
          <path {...commonProps} d="M17 15v-3" />
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

function EditIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path d="m4 20 4.5-1 8.8-8.8a1.8 1.8 0 0 0 0-2.5l-1-1a1.8 1.8 0 0 0-2.5 0L5 15.5 4 20Z" />
      <path d="M12.5 8.5 15.5 11.5" />
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

function DownloadIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path d="M12 4v9" />
      <path d="m8.5 10.5 3.5 3.5 3.5-3.5" />
      <path d="M5 18h14" />
    </svg>
  );
}

export default function SalesReportPage() {
  const [openActionMenu, setOpenActionMenu] = useState<string | null>(null);
  const [openExportMenu, setOpenExportMenu] = useState(false);

  return (
    <section className="master-category-page">
      <div className="purchase-report-layout sales-report-layout">
        <section className="master-category-table-card purchase-report-header-card sales-report-header-card">
          <div>
            <h2>Sales Report</h2>
            <p>Revenue, orders, shops, profit, growth, and deep sales intelligence for super admin.</p>
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

        <div className="admin-dashboard-stats sales-report-stats">
          {salesStats.map((stat) => (
            <article className="admin-stat-card" key={stat.label}>
              <div className={`admin-stat-icon admin-stat-icon-${stat.accent}`}>
                <SalesReportStatIcon type={stat.icon} />
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
              <div className="sales-report-trend-header">
                <h3>Sales Trend</h3>
                <p>Track sales, orders and profit over time</p>
                <div className="admin-analytics-legend">
                  <span className="admin-legend-item">
                    <i className="admin-legend-dot admin-legend-dot-green" />
                    Sales
                  </span>
                  <span className="admin-legend-item">
                    <i className="admin-legend-dot admin-legend-dot-blue" />
                    Orders
                  </span>
                  <span className="admin-legend-item">
                    <i className="admin-legend-dot admin-legend-dot-violet" />
                    Profit
                  </span>
                </div>
              </div>
              <select className="sales-report-period-select" defaultValue="Daily" aria-label="Sales trend period">
                <option>Daily</option>
                <option>Weekly</option>
                <option>Monthly</option>
              </select>
            </div>

            <div className="admin-chart-shell">
              <div className="admin-chart-axis">
                <span>৳24L</span>
                <span>৳18L</span>
                <span>৳12L</span>
                <span>৳8L</span>
                <span>৳4L</span>
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
                    <linearGradient id="sales-amount-fill" x1="0" x2="0" y1="0" y2="1">
                      <stop offset="0%" stopColor="rgba(16, 185, 129, 0.26)" />
                      <stop offset="100%" stopColor="rgba(16, 185, 129, 0)" />
                    </linearGradient>
                    <linearGradient id="sales-orders-fill" x1="0" x2="0" y1="0" y2="1">
                      <stop offset="0%" stopColor="rgba(67, 97, 255, 0.22)" />
                      <stop offset="100%" stopColor="rgba(67, 97, 255, 0)" />
                    </linearGradient>
                  </defs>
                  <path
                    className="admin-chart-fill-green"
                    d="M0 194 C34 156, 58 126, 92 128 S146 84, 182 72 S238 142, 274 136 S330 94, 366 88 S422 128, 458 114 S514 52, 550 66 S604 120, 640 78 L640 240 L0 240 Z"
                    fill="url(#sales-amount-fill)"
                  />
                  <path
                    className="admin-chart-fill-blue"
                    d="M0 216 C34 205, 58 190, 92 176 S146 158, 182 144 S238 186, 274 178 S330 134, 366 144 S422 164, 458 152 S514 120, 550 130 S604 144, 640 138 L640 240 L0 240 Z"
                    fill="url(#sales-orders-fill)"
                  />
                  <path
                    className="admin-chart-line-green"
                    d="M0 194 C34 156, 58 126, 92 128 S146 84, 182 72 S238 142, 274 136 S330 94, 366 88 S422 128, 458 114 S514 52, 550 66 S604 120, 640 78"
                  />
                  <path
                    className="admin-chart-line-blue"
                    d="M0 216 C34 205, 58 190, 92 176 S146 158, 182 144 S238 186, 274 178 S330 134, 366 144 S422 164, 458 152 S514 120, 550 130 S604 144, 640 138"
                  />
                  <path
                    className="sales-report-profit-line"
                    d="M0 224 C34 214, 58 206, 92 196 S146 186, 182 174 S238 208, 274 198 S330 162, 366 170 S422 184, 458 176 S514 146, 550 152 S604 166, 640 160"
                  />
                </svg>

                <div className="admin-chart-labels">
                  {salesTrendLabels.map((label) => (
                    <span key={label}>{label}</span>
                  ))}
                </div>
              </div>
            </div>

          </section>

          <section className="admin-dashboard-panel purchase-report-panel purchase-report-category-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Sales by Category</h3>
                <p>Strong visibility into what product groups are driving your revenue.</p>
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
                  <strong>৳12.45Cr</strong>
                  <span>Total Sales</span>
                </div>
              </div>

              <div className="purchase-report-category-list">
                {salesCategories.map((item) => (
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
          <section className="admin-dashboard-panel purchase-report-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Top Selling Shops</h3>
                <p>Best performing shops by sales, orders, and profit.</p>
              </div>
            </div>
            <div className="sales-report-metric-table">
              <div className="sales-report-metric-head">
                <span>Shop</span>
                <span>Sales</span>
                <span>Orders</span>
                <span>Profit</span>
              </div>
              {topSellingShops.map((row) => (
                <div className="sales-report-metric-row" key={row.shop}>
                  <span>{row.shop}</span>
                  <span>{row.sales}</span>
                  <span>{row.orders}</span>
                  <span>{row.profit}</span>
                </div>
              ))}
            </div>
          </section>

          <section className="admin-dashboard-panel purchase-report-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Top Selling Products</h3>
                <p>Most successful products by quantity sold and generated revenue.</p>
              </div>
            </div>
            <div className="sales-report-metric-table">
              <div className="sales-report-metric-head sales-report-metric-head-products">
                <span>Product</span>
                <span>Qty Sold</span>
                <span>Revenue</span>
              </div>
              {topSellingProducts.map((row) => (
                <div className="sales-report-metric-row sales-report-metric-row-products" key={row.product}>
                  <span>{row.product}</span>
                  <span>{row.qty}</span>
                  <span>{row.revenue}</span>
                </div>
              ))}
            </div>
          </section>
        </div>

        <div className="purchase-report-grid-two">
          <section className="admin-dashboard-panel purchase-report-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Payment Methods</h3>
                <p>Amount, contribution percentage, and transaction count by payment type.</p>
              </div>
            </div>
            <div className="sales-report-payment-list">
              {paymentMethods.map((item) => (
                <article className="sales-report-payment-card" key={item.label}>
                  <div className="purchase-report-rank-main">
                    <i className={`admin-legend-dot admin-legend-dot-${item.accent}`} />
                    <div>
                      <strong>{item.label}</strong>
                      <span>{item.count} transactions</span>
                    </div>
                  </div>
                  <div className="purchase-report-rank-meta">
                    <strong>{item.amount}</strong>
                    <span>{item.percent}</span>
                  </div>
                </article>
              ))}
            </div>
          </section>

          <section className="admin-dashboard-panel purchase-report-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Sales by Brand</h3>
                <p>Brand-level sales distribution across the selected date range.</p>
              </div>
            </div>
            <div className="sales-report-brand-list">
              {salesByBrand.map((item) => (
                <article className="sales-report-brand-card" key={item.label}>
                  <div>
                    <strong>{item.label}</strong>
                    <span>{item.share}</span>
                  </div>
                  <strong>{item.amount}</strong>
                </article>
              ))}
            </div>
          </section>
        </div>

        <section className="master-category-table-card purchase-report-filters-card">
          <div className="sales-report-toolbar-grid">
            <label className="purchase-report-field purchase-report-field-search">
              <span>Search Invoice</span>
              <input type="search" placeholder="Search invoice no..." />
            </label>
            <label className="purchase-report-field">
              <span>Shop</span>
              <select defaultValue="All Shops">
                <option>All Shops</option>
                <option>Rahman Store</option>
                <option>Janata Bazar</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Branch</span>
              <select defaultValue="All Branches">
                <option>All Branches</option>
                <option>Main Branch</option>
                <option>North Branch</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Salesman</span>
              <select defaultValue="All Salesmen">
                <option>All Salesmen</option>
                <option>Rakib</option>
                <option>Sojib</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Customer</span>
              <select defaultValue="All Customers">
                <option>All Customers</option>
                <option>Walk-in</option>
                <option>Mehedi Hasan</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Payment Method</span>
              <select defaultValue="All Methods">
                <option>All Methods</option>
                <option>Cash</option>
                <option>Bkash</option>
                <option>Nagad</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Status</span>
              <select defaultValue="All Status">
                <option>All Status</option>
                <option>Paid</option>
                <option>Partial</option>
                <option>Pending</option>
                <option>Refunded</option>
              </select>
            </label>
          </div>

          <div className="purchase-report-filter-actions sales-report-filter-actions">
            <button type="button" className="master-category-outline-button">Clear</button>
            <span className="master-category-action-menu sales-report-export-menu">
              <button
                type="button"
                className="master-category-outline-button sales-report-export-button"
                aria-haspopup="menu"
                aria-expanded={openExportMenu}
                onClick={() => setOpenExportMenu((current) => !current)}
              >
                <DownloadIcon />
                <span>Export</span>
              </button>
              {openExportMenu ? (
                <div className="master-category-action-dropdown" role="menu">
                  <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                    Export Excel
                  </button>
                  <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                    Export PDF
                  </button>
                  <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                    Export CSV
                  </button>
                </div>
              ) : null}
            </span>
            <button type="button" className="master-category-primary-button">Advanced Filters</button>
          </div>
        </section>

        <section className="master-category-table-card sales-report-table-card">
          <div className="purchase-report-table-header">
            <div>
              <h3>Sales Records</h3>
              <p>This is the primary transaction section for audit, operations, and follow-up actions.</p>
            </div>
          </div>

          <div className="sales-report-records-table">
            <div className="sales-report-records-head">
              <span>Date &amp; Time</span>
              <span>Invoice No</span>
              <span>Shop</span>
              <span>Customer</span>
              <span>Salesman</span>
              <span>Items</span>
              <span>Subtotal</span>
              <span>Discount</span>
              <span>Net Amount</span>
              <span>Profit</span>
              <span>Payment Method</span>
              <span>Status</span>
              <span>Action</span>
            </div>

            {salesRecords.map((row) => (
              <div className="sales-report-records-row" key={row.invoiceNo}>
                <span>{row.dateTime}</span>
                <span>{row.invoiceNo}</span>
                <span>{row.shop}</span>
                <span>{row.customer}</span>
                <span>{row.salesman}</span>
                <span>{row.items}</span>
                <span>{row.subtotal}</span>
                <span>{row.discount}</span>
                <span>{row.netAmount}</span>
                <span>{row.profit}</span>
                <span>{row.paymentMethod}</span>
                <span>
                  <em
                    className={`purchase-report-status-badge${
                      row.status === "Partial"
                        ? " purchase-report-status-badge-partial"
                        : row.status === "Pending"
                          ? " purchase-report-status-badge-pending"
                          : row.status === "Refunded"
                            ? " purchase-report-status-badge-cancelled"
                            : ""
                    }`}
                  >
                    {row.status}
                  </em>
                </span>
                <span className="purchase-report-row-actions">
                  <button type="button" className="purchase-report-view-button" aria-label={`Edit ${row.invoiceNo}`}>
                    <EditIcon />
                    <span>Edit</span>
                  </button>
                  <span className="master-category-action-menu">
                    <button
                      type="button"
                      className="purchase-report-more-button"
                      aria-label={`More actions for ${row.invoiceNo}`}
                      aria-haspopup="menu"
                      aria-expanded={openActionMenu === row.invoiceNo}
                      onClick={() => setOpenActionMenu((current) => (current === row.invoiceNo ? null : row.invoiceNo))}
                    >
                      <MoreIcon />
                      <span>More</span>
                    </button>
                    {openActionMenu === row.invoiceNo ? (
                      <div className="master-category-action-dropdown" role="menu">
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          View Invoice
                        </button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          Print Invoice
                        </button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          Download PDF
                        </button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          View Customer
                        </button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          View Shop
                        </button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          Refund Details
                        </button>
                      </div>
                    ) : null}
                  </span>
                </span>
              </div>
            ))}
          </div>

          <div className="master-category-footer purchase-report-pagination-wrap">
            <span className="master-category-footer-text">Showing 1-20 of 45,231 sales records</span>
            <div className="master-category-pagination">
              <button type="button" className="master-category-page-button">{"<"} Previous</button>
              <button type="button" className="master-category-page-chip master-category-page-chip-active">1</button>
              <button type="button" className="master-category-page-chip">2</button>
              <button type="button" className="master-category-page-chip">3</button>
              <button type="button" className="master-category-page-chip">4</button>
              <button type="button" className="master-category-page-button">Next {">"}</button>
            </div>
            <select className="master-category-page-size" defaultValue="20">
              <option value="20">20 / page</option>
              <option value="50">50 / page</option>
              <option value="100">100 / page</option>
            </select>
          </div>
        </section>
      </div>
    </section>
  );
}
