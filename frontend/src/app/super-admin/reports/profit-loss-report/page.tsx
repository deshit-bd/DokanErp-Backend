"use client";

import { useState } from "react";

const profitLossStats = [
  { label: "Total Sales", value: "৳12.5M", trend: "↑ 12.4%", note: "Compared to previous period", accent: "green", icon: "wallet" },
  { label: "Total COGS", value: "৳8.2M", trend: "↑ 8.1%", note: "Compared to previous period", accent: "indigo", icon: "receipt" },
  { label: "Gross Profit", value: "৳4.3M", trend: "↑ 15.2%", note: "Compared to previous period", accent: "green", icon: "profit" },
  { label: "Operating Cost", value: "৳1.1M", trend: "↓ 3.4%", note: "Compared to previous period", accent: "orange", icon: "chart" },
  { label: "Net Profit", value: "৳3.2M", trend: "↑ 18.5%", note: "Compared to previous period", accent: "green", icon: "trend" },
  { label: "Net Margin", value: "25.4%", trend: "↑ 2.3%", note: "Compared to previous period", accent: "red", icon: "margin" },
];

const profitTrendLabels = ["01 Jun", "05 Jun", "10 Jun", "15 Jun", "20 Jun", "25 Jun", "30 Jun"];

const costBreakdown = [
  { label: "COGS", amount: "৳8.2M", value: "57%", accent: "green" },
  { label: "Salary", amount: "৳420K", value: "12%", accent: "blue" },
  { label: "Rent", amount: "৳210K", value: "6%", accent: "amber" },
  { label: "Utilities", amount: "৳145K", value: "4%", accent: "violet" },
  { label: "Marketing", amount: "৳168K", value: "5%", accent: "red" },
  { label: "Transportation", amount: "৳94K", value: "3%", accent: "yellow" },
  { label: "Others", amount: "৳63K", value: "2%", accent: "gray" },
];

const topProfitableShops = [
  { shop: "Rahman Store", amount: "৳486,000" },
  { shop: "Janata Bazar", amount: "৳442,000" },
  { shop: "Bondhon Mart", amount: "৳396,000" },
  { shop: "Mother Store", amount: "৳361,000" },
  { shop: "Fresh Corner", amount: "৳338,000" },
];

const lossMakingShops = [
  { shop: "City Point", amount: "৳72,000" },
  { shop: "Modina Store", amount: "৳58,000" },
  { shop: "Green Basket", amount: "৳42,000" },
  { shop: "Daily Needs", amount: "৳34,000" },
  { shop: "Corner Depot", amount: "৳28,000" },
];

const profitByCategory = [
  { label: "Rice", amount: "৳820K", value: "21%" },
  { label: "Oil", amount: "৳690K", value: "18%" },
  { label: "Beverage", amount: "৳605K", value: "16%" },
  { label: "Cosmetics", amount: "৳512K", value: "13%" },
  { label: "Soap", amount: "৳388K", value: "10%" },
  { label: "Others", amount: "৳905K", value: "22%" },
];

const profitByPaymentMethod = [
  { label: "Cash", amount: "৳1.22M", value: "38%", accent: "green" },
  { label: "Bkash", amount: "৳820K", value: "26%", accent: "blue" },
  { label: "Nagad", amount: "৳545K", value: "17%", accent: "amber" },
  { label: "Card", amount: "৳392K", value: "12%", accent: "violet" },
  { label: "Bank", amount: "৳223K", value: "7%", accent: "red" },
];

const storeProfitRows = [
  { shop: "Rahman Store", sales: "৳1,985,000", orders: "862", cogs: "৳1,204,000", grossProfit: "৳781,000", operatingCost: "৳295,000", netProfit: "৳486,000", netMargin: "24.5%", status: "Profitable" },
  { shop: "Janata Bazar", sales: "৳1,842,000", orders: "801", cogs: "৳1,148,000", grossProfit: "৳694,000", operatingCost: "৳252,000", netProfit: "৳442,000", netMargin: "24.0%", status: "Profitable" },
  { shop: "Bondhon Mart", sales: "৳1,568,000", orders: "694", cogs: "৳1,014,000", grossProfit: "৳554,000", operatingCost: "৳158,000", netProfit: "৳396,000", netMargin: "25.3%", status: "Profitable" },
  { shop: "Daily Needs", sales: "৳420,000", orders: "205", cogs: "৳301,000", grossProfit: "৳119,000", operatingCost: "৳121,000", netProfit: "৳2,000", netMargin: "0.5%", status: "Break-even" },
  { shop: "City Point", sales: "৳388,000", orders: "188", cogs: "৳294,000", grossProfit: "৳94,000", operatingCost: "৳166,000", netProfit: "৳72,000", netMargin: "-18.6%", status: "Loss" },
];

function ProfitLossIcon({ type }: { type: string }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (type) {
    case "wallet":
      return <svg aria-hidden="true" viewBox="0 0 24 24"><path {...commonProps} d="M4.5 8.5A2.5 2.5 0 0 1 7 6h10.5v12H7A2.5 2.5 0 0 1 4.5 15.5v-7Z" /><path {...commonProps} d="M17.5 9.5h2v5h-2a2.5 2.5 0 1 1 0-5Z" /><path {...commonProps} d="M7 6V4.5h9" /></svg>;
    case "receipt":
      return <svg aria-hidden="true" viewBox="0 0 24 24"><path {...commonProps} d="M8 4.5h8l3 3V19l-2-1.5L15 19l-2-1.5L11 19 9 17.5 7 19V4.5Z" /><path {...commonProps} d="M9 10h6" /><path {...commonProps} d="M9 13.5h6" /></svg>;
    case "profit":
      return <svg aria-hidden="true" viewBox="0 0 24 24"><path {...commonProps} d="M4 18h16" /><path {...commonProps} d="M7 15V9" /><path {...commonProps} d="M12 15V6" /><path {...commonProps} d="M17 15v-3" /></svg>;
    case "chart":
      return <svg aria-hidden="true" viewBox="0 0 24 24"><path {...commonProps} d="M5 18.5h14" /><path {...commonProps} d="M8 16v-4" /><path {...commonProps} d="M12 16V8" /><path {...commonProps} d="M16 16v-6" /></svg>;
    case "trend":
      return <svg aria-hidden="true" viewBox="0 0 24 24"><path {...commonProps} d="M5 17V7" /><path {...commonProps} d="M5 17h14" /><path {...commonProps} d="m8 14 3-3 3 2 4-5" /></svg>;
    case "margin":
      return <svg aria-hidden="true" viewBox="0 0 24 24"><path {...commonProps} d="M5 19V5" /><path {...commonProps} d="M5 19h14" /><path {...commonProps} d="M9 15 12 9l3 3 4-6" /></svg>;
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

export default function ProfitLossReportPage() {
  const [openActionMenu, setOpenActionMenu] = useState<string | null>(null);
  const [openExportMenu, setOpenExportMenu] = useState(false);

  return (
    <section className="master-category-page">
      <div className="purchase-report-layout sales-report-layout">
        <section className="master-category-table-card purchase-report-header-card sales-report-header-card">
          <div>
            <h2>Profit &amp; Loss Report</h2>
            <p>Executive profitability, cost, margin, and shop-wise performance in one place.</p>
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

        <div className="admin-dashboard-stats profit-loss-stats">
          {profitLossStats.map((stat) => (
            <article className="admin-stat-card profit-loss-kpi-card" key={stat.label}>
              <div className={`admin-stat-icon admin-stat-icon-${stat.accent}`}>
                <ProfitLossIcon type={stat.icon} />
              </div>
              <div className="admin-stat-content">
                <div className="admin-stat-heading">
                  <span>{stat.label}</span>
                </div>
                <strong>{stat.value}</strong>
                <div className={`profit-loss-kpi-trend${stat.trend.startsWith("↓") ? " profit-loss-kpi-trend-down" : ""}`}>{stat.trend}</div>
                <p>{stat.note}</p>
              </div>
            </article>
          ))}
        </div>

        <div className="purchase-report-grid-two">
          <section className="admin-dashboard-panel purchase-report-panel">
            <div className="purchase-report-panel-header">
              <div className="sales-report-trend-header">
                <h3>Profit Trend</h3>
                <p>Track sales, gross profit and net profit over time.</p>
                <div className="admin-analytics-legend">
                  <span className="admin-legend-item">
                    <i className="admin-legend-dot admin-legend-dot-green" />
                    Sales
                  </span>
                  <span className="admin-legend-item">
                    <i className="admin-legend-dot admin-legend-dot-blue" />
                    Gross Profit
                  </span>
                  <span className="admin-legend-item">
                    <i className="admin-legend-dot admin-legend-dot-violet" />
                    Net Profit
                  </span>
                </div>
              </div>
              <select className="sales-report-period-select" defaultValue="Daily" aria-label="Profit trend period">
                <option>Daily</option>
                <option>Weekly</option>
                <option>Monthly</option>
                <option>Quarterly</option>
                <option>Yearly</option>
              </select>
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
                <div className="admin-chart-grid"><span /><span /><span /><span /><span /><span /></div>
                <svg className="admin-chart-svg" viewBox="0 0 640 240" preserveAspectRatio="none" aria-hidden="true">
                  <path className="admin-chart-line-green" d="M0 196 C34 152, 62 124, 96 126 S154 86, 188 72 S246 144, 280 138 S336 96, 372 88 S430 128, 466 116 S524 58, 562 68 S610 118, 640 84" />
                  <path className="admin-chart-line-blue" d="M0 214 C34 188, 62 176, 96 176 S154 138, 188 130 S246 182, 280 174 S336 142, 372 136 S430 164, 466 156 S524 102, 562 112 S610 148, 640 136" />
                  <path className="sales-report-profit-line" d="M0 226 C34 214, 62 206, 96 202 S154 174, 188 168 S246 212, 280 204 S336 170, 372 166 S430 192, 466 184 S524 140, 562 146 S610 172, 640 160" />
                </svg>
                <div className="admin-chart-labels">
                  {profitTrendLabels.map((label) => <span key={label}>{label}</span>)}
                </div>
              </div>
            </div>
          </section>

          <section className="admin-dashboard-panel purchase-report-panel purchase-report-category-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Cost Breakdown</h3>
                <p>See where the cost stack is concentrated across the business.</p>
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
                  <strong>৳9.3M</strong>
                  <span>Total Cost</span>
                </div>
              </div>
              <div className="purchase-report-category-list">
                {costBreakdown.map((item) => (
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
                <h3>Top Profitable Shops</h3>
                <p>Top 5 shops ranked by net profit contribution.</p>
              </div>
            </div>
            <div className="sales-report-metric-table">
              <div className="sales-report-metric-head sales-report-metric-head-products">
                <span>Shop</span>
                <span>Net Profit</span>
              </div>
              {topProfitableShops.map((row) => (
                <div className="sales-report-metric-row sales-report-metric-row-products" key={row.shop}>
                  <span>{row.shop}</span>
                  <span>{row.amount}</span>
                </div>
              ))}
            </div>
          </section>

          <section className="admin-dashboard-panel purchase-report-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Loss-Making Shops</h3>
                <p>Bottom 5 shops currently generating negative net outcomes.</p>
              </div>
            </div>
            <div className="sales-report-metric-table">
              <div className="sales-report-metric-head sales-report-metric-head-products">
                <span>Shop</span>
                <span>Loss</span>
              </div>
              {lossMakingShops.map((row) => (
                <div className="sales-report-metric-row sales-report-metric-row-products" key={row.shop}>
                  <span>{row.shop}</span>
                  <span>{row.amount}</span>
                </div>
              ))}
            </div>
          </section>
        </div>

        <div className="purchase-report-grid-two">
          <section className="admin-dashboard-panel purchase-report-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Profit By Category</h3>
                <p>High sales does not always mean high profit. This view makes that obvious.</p>
              </div>
            </div>
            <div className="sales-report-brand-list">
              {profitByCategory.map((item) => (
                <article className="sales-report-brand-card" key={item.label}>
                  <div>
                    <strong>{item.label}</strong>
                    <span>{item.value}</span>
                  </div>
                  <strong>{item.amount}</strong>
                </article>
              ))}
            </div>
          </section>

          <section className="admin-dashboard-panel purchase-report-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Profit By Payment Method</h3>
                <p>Useful for super admin analysis across cash and digital payment channels.</p>
              </div>
            </div>
            <div className="sales-report-payment-list">
              {profitByPaymentMethod.map((item) => (
                <article className="sales-report-payment-card" key={item.label}>
                  <div className="purchase-report-rank-main">
                    <i className={`admin-legend-dot admin-legend-dot-${item.accent}`} />
                    <div>
                      <strong>{item.label}</strong>
                      <span>{item.value}</span>
                    </div>
                  </div>
                  <div className="purchase-report-rank-meta">
                    <strong>{item.amount}</strong>
                  </div>
                </article>
              ))}
            </div>
          </section>
        </div>

        <section className="admin-dashboard-panel profit-loss-formula-card">
          <div className="purchase-report-panel-header">
            <div>
              <h3>P&amp;L Formula Summary</h3>
              <p>An extremely useful quick-reference card for profit interpretation.</p>
            </div>
          </div>
          <div className="profit-loss-formula-lines">
            <div className="profit-loss-formula-row"><span>Sales</span><strong>৳12.5M</strong></div>
            <div className="profit-loss-formula-row"><span>(-) COGS</span><strong>৳8.2M</strong></div>
            <div className="profit-loss-formula-result"><span>= Gross Profit</span><strong>৳4.3M</strong></div>
            <div className="profit-loss-formula-row"><span>(-) Operating Cost</span><strong>৳1.1M</strong></div>
            <div className="profit-loss-formula-result"><span>= Net Profit</span><strong>৳3.2M</strong></div>
            <div className="profit-loss-formula-result profit-loss-formula-result-margin"><span>Net Profit Margin %</span><strong>25.4%</strong></div>
          </div>
        </section>

        <section className="master-category-table-card purchase-report-filters-card">
          <div className="sales-report-toolbar-grid profit-loss-toolbar-grid">
            <label className="purchase-report-field purchase-report-field-search">
              <span>Search Shop</span>
              <input type="search" placeholder="Search shop..." />
            </label>
            <label className="purchase-report-field">
              <span>Shop</span>
              <select defaultValue="All Shops"><option>All Shops</option><option>Rahman Store</option><option>Janata Bazar</option></select>
            </label>
            <label className="purchase-report-field">
              <span>Category</span>
              <select defaultValue="All Categories"><option>All Categories</option><option>Rice</option><option>Oil</option><option>Beverage</option></select>
            </label>
            <label className="purchase-report-field">
              <span>Region</span>
              <select defaultValue="All Regions"><option>All Regions</option><option>Dhaka</option><option>Chattogram</option><option>Rajshahi</option></select>
            </label>
            <label className="purchase-report-field">
              <span>Status</span>
              <select defaultValue="All Status"><option>All Status</option><option>Profitable</option><option>Break-even</option><option>Loss</option></select>
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
                  <button type="button" className="master-category-action-dropdown-item" role="menuitem">Export PDF</button>
                  <button type="button" className="master-category-action-dropdown-item" role="menuitem">Export Excel</button>
                </div>
              ) : null}
            </span>
            <button type="button" className="master-category-primary-button">Advanced Filters</button>
          </div>
        </section>

        <section className="master-category-table-card sales-report-table-card">
          <div className="purchase-report-table-header">
            <div>
              <h3>Store-wise Profit &amp; Loss Summary</h3>
              <p>Store-wise profitability snapshot with standard MUDI actions.</p>
            </div>
          </div>

          <div className="profit-loss-records-table">
            <div className="profit-loss-records-head">
              <span>Shop Name</span>
              <span>Total Sales</span>
              <span>Orders</span>
              <span>COGS</span>
              <span>Gross Profit</span>
              <span>Operating Cost</span>
              <span>Net Profit</span>
              <span>Net Margin %</span>
              <span>Status</span>
              <span>Action</span>
            </div>
            {storeProfitRows.map((row) => (
              <div className="profit-loss-records-row" key={row.shop}>
                <span>{row.shop}</span>
                <span>{row.sales}</span>
                <span>{row.orders}</span>
                <span>{row.cogs}</span>
                <span>{row.grossProfit}</span>
                <span>{row.operatingCost}</span>
                <span>{row.netProfit}</span>
                <span>{row.netMargin}</span>
                <span>
                  <em
                    className={`profit-loss-status-badge${
                      row.status === "Break-even"
                        ? " profit-loss-status-badge-breakeven"
                        : row.status === "Loss"
                          ? " profit-loss-status-badge-loss"
                          : ""
                    }`}
                  >
                    {row.status}
                  </em>
                </span>
                <span className="purchase-report-row-actions">
                  <button type="button" className="purchase-report-view-button" aria-label={`Edit ${row.shop}`}>
                    <EditIcon />
                    <span>Edit</span>
                  </button>
                  <span className="master-category-action-menu">
                    <button
                      type="button"
                      className="purchase-report-more-button"
                      aria-label={`More actions for ${row.shop}`}
                      aria-haspopup="menu"
                      aria-expanded={openActionMenu === row.shop}
                      onClick={() => setOpenActionMenu((current) => (current === row.shop ? null : row.shop))}
                    >
                      <MoreIcon />
                      <span>More</span>
                    </button>
                    {openActionMenu === row.shop ? (
                      <div className="master-category-action-dropdown" role="menu">
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">View Report</button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">View Shop</button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">Export PDF</button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">Export Excel</button>
                      </div>
                    ) : null}
                  </span>
                </span>
              </div>
            ))}
          </div>

          <div className="master-category-footer purchase-report-pagination-wrap">
            <span className="master-category-footer-text">Showing 1-20 of 1,254 shop profit reports</span>
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
