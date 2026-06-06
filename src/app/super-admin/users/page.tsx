"use client";

import { useState } from "react";

const userStats = [
  { label: "Total Users", value: "12,854", note: "All platform accounts", accent: "green", icon: "users" },
  { label: "Active Users", value: "11,624", note: "Currently active users", accent: "indigo", icon: "check" },
  { label: "Suspended", value: "124", note: "Restricted accounts", accent: "red", icon: "suspend" },
  { label: "New Users", value: "458", note: "Added this period", accent: "orange", icon: "userplus" },
  { label: "Billable", value: "12,430", note: "Revenue generating accounts", accent: "green", icon: "coin" },
  { label: "Revenue", value: "৳124,300", note: "User billing revenue", accent: "violet", icon: "wallet" },
];

const userGrowthLabels = ["01 Jun", "05 Jun", "10 Jun", "15 Jun", "20 Jun", "25 Jun", "30 Jun"];

const roleBreakdown = [
  { label: "Owner", value: "34%", amount: "4,370", accent: "green" },
  { label: "Manager", value: "22%", amount: "2,828", accent: "blue" },
  { label: "Salesman", value: "27%", amount: "3,470", accent: "amber" },
  { label: "Accountant", value: "17%", amount: "2,186", accent: "violet" },
];

const userRows = [
  {
    user: "Rahim Uddin",
    shop: "Rahim Store",
    role: "Owner",
    phone: "+8801712345678",
    email: "rahim@rahimstore.com",
    lastLogin: "30 Jun 2026, 10:42 AM",
    status: "Active",
    billing: "Billable",
  },
  {
    user: "Karim Mia",
    shop: "Rahim Store",
    role: "Salesman",
    phone: "+8801812345678",
    email: "karim@rahimstore.com",
    lastLogin: "30 Jun 2026, 09:11 AM",
    status: "Active",
    billing: "Billable",
  },
  {
    user: "Nusrat Jahan",
    shop: "Janata Bazar",
    role: "Manager",
    phone: "+8801912345678",
    email: "nusrat@janatabazar.com",
    lastLogin: "29 Jun 2026, 07:22 PM",
    status: "Inactive",
    billing: "Billable",
  },
  {
    user: "Farhan Ahmed",
    shop: "City Point",
    role: "Accountant",
    phone: "+8801612345678",
    email: "farhan@citypoint.com",
    lastLogin: "28 Jun 2026, 04:08 PM",
    status: "Suspended",
    billing: "Non-Billable",
  },
  {
    user: "Mitu Akter",
    shop: "Fresh Corner",
    role: "Salesman",
    phone: "+8801512345678",
    email: "mitu@freshcorner.com",
    lastLogin: "28 Jun 2026, 01:36 PM",
    status: "Active",
    billing: "Billable",
  },
];

function UserManagementIcon({ type }: { type: string }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (type) {
    case "users":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
          <path {...commonProps} d="M15.5 10a2.5 2.5 0 1 0 0-5" />
          <path {...commonProps} d="M4.5 19a4.5 4.5 0 0 1 9 0" />
          <path {...commonProps} d="M14 17a3.5 3.5 0 0 1 5.5-2.8" />
        </svg>
      );
    case "check":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="8.5" />
          <path {...commonProps} d="m8.5 12 2.3 2.3 4.7-4.8" />
        </svg>
      );
    case "suspend":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="8.5" />
          <path {...commonProps} d="M8.5 12h7" />
        </svg>
      );
    case "userplus":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M10 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
          <path {...commonProps} d="M4.5 19a5 5 0 0 1 10 0" />
          <path {...commonProps} d="M18 8v6" />
          <path {...commonProps} d="M15 11h6" />
        </svg>
      );
    case "coin":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="7.5" />
          <path {...commonProps} d="M10 9.5h3a1.5 1.5 0 1 1 0 3h-2a1.5 1.5 0 1 0 0 3h3" />
        </svg>
      );
    case "wallet":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M4.5 8.5A2.5 2.5 0 0 1 7 6h10.5v12H7A2.5 2.5 0 0 1 4.5 15.5v-7Z" />
          <path {...commonProps} d="M17.5 9.5h2v5h-2a2.5 2.5 0 1 1 0-5Z" />
          <path {...commonProps} d="M7 6V4.5h9" />
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

export default function UserManagementPage() {
  const [openActionMenu, setOpenActionMenu] = useState<string | null>(null);
  const [openExportMenu, setOpenExportMenu] = useState(false);

  return (
    <section className="master-category-page">
      <div className="purchase-report-layout sales-report-layout">
        <div className="admin-dashboard-stats user-management-stats">
          {userStats.map((stat) => (
            <article className="admin-stat-card" key={stat.label}>
              <div className={`admin-stat-icon admin-stat-icon-${stat.accent}`}>
                <UserManagementIcon type={stat.icon} />
              </div>
              <div className="admin-stat-content">
                <div className="admin-stat-heading">
                  <span>{stat.label}</span>
                </div>
                <strong>{stat.value}</strong>
                <p>{stat.note}</p>
              </div>
            </article>
          ))}
        </div>

        <div className="purchase-report-grid-two">
          <section className="admin-dashboard-panel purchase-report-panel">
            <div className="purchase-report-panel-header">
              <div className="sales-report-trend-header">
                <h3>User Growth Trend</h3>
                <p>Created users, active users, and disabled users over time.</p>
                <div className="admin-analytics-legend">
                  <span className="admin-legend-item">
                    <i className="admin-legend-dot admin-legend-dot-green" />
                    Created Users
                  </span>
                  <span className="admin-legend-item">
                    <i className="admin-legend-dot admin-legend-dot-blue" />
                    Active Users
                  </span>
                  <span className="admin-legend-item">
                    <i className="admin-legend-dot admin-legend-dot-violet" />
                    Disabled Users
                  </span>
                </div>
              </div>
            </div>

            <div className="admin-chart-shell">
              <div className="admin-chart-axis">
                <span>600</span>
                <span>500</span>
                <span>400</span>
                <span>300</span>
                <span>200</span>
                <span>0</span>
              </div>
              <div className="admin-chart-area">
                <div className="admin-chart-grid"><span /><span /><span /><span /><span /><span /></div>
                <svg className="admin-chart-svg" viewBox="0 0 640 240" preserveAspectRatio="none" aria-hidden="true">
                  <path className="admin-chart-line-green" d="M0 204 C34 172, 62 144, 96 146 S154 96, 188 90 S246 162, 280 154 S336 116, 372 108 S430 144, 466 132 S524 82, 562 92 S610 124, 640 102" />
                  <path className="admin-chart-line-blue" d="M0 214 C34 194, 62 178, 96 176 S154 130, 188 124 S246 188, 280 180 S336 140, 372 136 S430 170, 466 162 S524 106, 562 116 S610 150, 640 132" />
                  <path className="sales-report-profit-line" d="M0 230 C34 224, 62 220, 96 216 S154 198, 188 194 S246 222, 280 216 S336 202, 372 198 S430 210, 466 206 S524 182, 562 188 S610 198, 640 192" />
                </svg>
                <div className="admin-chart-labels">
                  {userGrowthLabels.map((label) => <span key={label}>{label}</span>)}
                </div>
              </div>
            </div>
          </section>

          <section className="admin-dashboard-panel purchase-report-panel purchase-report-category-panel">
            <div className="purchase-report-panel-header">
              <div>
                <h3>Users By Role</h3>
                <p>Role-wise distribution of platform users across all shops.</p>
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
                </svg>
                <div className="purchase-report-donut-center">
                  <strong>12,854</strong>
                  <span>Total Users</span>
                </div>
              </div>

              <div className="purchase-report-category-list">
                {roleBreakdown.map((item) => (
                  <article className="purchase-report-rank-card" key={item.label}>
                    <div className="purchase-report-rank-main">
                      <i className={`admin-legend-dot admin-legend-dot-${item.accent}`} />
                      <div>
                        <strong>{item.label}</strong>
                        <span>{item.amount} users</span>
                      </div>
                    </div>
                    <em>{item.value}</em>
                  </article>
                ))}
              </div>
            </div>
          </section>
        </div>

        <section className="master-category-table-card purchase-report-filters-card">
          <div className="user-management-toolbar-grid">
            <label className="purchase-report-field purchase-report-field-search">
              <span>Search User</span>
              <input type="search" placeholder="Search user..." />
            </label>
            <label className="purchase-report-field">
              <span>Shop</span>
              <select defaultValue="All Shops">
                <option>All Shops</option>
                <option>Rahim Store</option>
                <option>Janata Bazar</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Role</span>
              <select defaultValue="All Roles">
                <option>All Roles</option>
                <option>Owner</option>
                <option>Manager</option>
                <option>Salesman</option>
                <option>Accountant</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Status</span>
              <select defaultValue="All Status">
                <option>All Status</option>
                <option>Active</option>
                <option>Inactive</option>
                <option>Suspended</option>
              </select>
            </label>
            <label className="purchase-report-field">
              <span>Subscription Plan</span>
              <select defaultValue="All Plans">
                <option>All Plans</option>
                <option>Basic</option>
                <option>Standard</option>
                <option>Enterprise</option>
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
                  <button type="button" className="master-category-action-dropdown-item" role="menuitem">Export Excel</button>
                  <button type="button" className="master-category-action-dropdown-item" role="menuitem">Export PDF</button>
                  <button type="button" className="master-category-action-dropdown-item" role="menuitem">Export CSV</button>
                </div>
              ) : null}
            </span>
            <button type="button" className="master-category-primary-button">Add User</button>
          </div>
        </section>

        <section className="master-category-table-card sales-report-table-card">
          <div className="purchase-report-table-header">
            <div>
              <h3>User Management</h3>
              <p>Manage billing relevance, role access, and account lifecycle from one table.</p>
            </div>
          </div>

          <div className="user-management-records-table">
            <div className="user-management-records-head">
              <span>User</span>
              <span>Shop</span>
              <span>Role</span>
              <span>Phone</span>
              <span>Email</span>
              <span>Last Login</span>
              <span>Status</span>
              <span>Billing</span>
              <span>Action</span>
            </div>

            {userRows.map((row) => (
              <div className="user-management-records-row" key={row.email}>
                <span>{row.user}</span>
                <span>{row.shop}</span>
                <span>{row.role}</span>
                <span>{row.phone}</span>
                <span>{row.email}</span>
                <span>{row.lastLogin}</span>
                <span>
                  <em
                    className={`user-management-status-badge${
                      row.status === "Inactive"
                        ? " user-management-status-badge-inactive"
                        : row.status === "Suspended"
                          ? " user-management-status-badge-suspended"
                          : ""
                    }`}
                  >
                    {row.status}
                  </em>
                </span>
                <span>
                  <em
                    className={`user-management-billing-badge${
                      row.billing === "Non-Billable" ? " user-management-billing-badge-off" : ""
                    }`}
                  >
                    {row.billing}
                  </em>
                </span>
                <span className="purchase-report-row-actions">
                  <button type="button" className="purchase-report-view-button" aria-label={`Edit ${row.user}`}>
                    <EditIcon />
                    <span>Edit</span>
                  </button>
                  <span className="master-category-action-menu">
                    <button
                      type="button"
                      className="purchase-report-more-button"
                      aria-label={`More actions for ${row.user}`}
                      aria-haspopup="menu"
                      aria-expanded={openActionMenu === row.email}
                      onClick={() => setOpenActionMenu((current) => (current === row.email ? null : row.email))}
                    >
                      <MoreIcon />
                      <span>More</span>
                    </button>
                    {openActionMenu === row.email ? (
                      <div className="master-category-action-dropdown" role="menu">
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">View</button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">Reset Password</button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">Disable User</button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">Transfer Ownership</button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">Login As User</button>
                        <button type="button" className="master-category-action-dropdown-item master-category-action-dropdown-item-danger" role="menuitem">Delete</button>
                      </div>
                    ) : null}
                  </span>
                </span>
              </div>
            ))}
          </div>

          <div className="master-category-footer purchase-report-pagination-wrap">
            <span className="master-category-footer-text">Showing 1-20 of 12,854 users</span>
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
