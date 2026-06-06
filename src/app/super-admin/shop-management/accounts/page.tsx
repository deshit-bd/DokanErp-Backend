"use client";

import { useState } from "react";

const accountStats = [
  { label: "Total Accounts", value: "6,236", note: "All shop-linked users", accent: "green", icon: "users" },
  { label: "Owners", value: "1,254", note: "One owner per shop", accent: "indigo", icon: "owner" },
  { label: "Salesmen", value: "4,982", note: "Billable operator accounts", accent: "amber", icon: "salesman" },
  { label: "Billable Revenue", value: "৳62,360", note: "Accounts × ৳10", accent: "violet", icon: "wallet" },
];

const roleBreakdown = [
  { label: "Owner", value: "20%", amount: "1,254", accent: "green" },
  { label: "Salesman", value: "80%", amount: "4,982", accent: "blue" },
];

const accountRows = [
  { id: "acc-rahim", user: "Rahim", shop: "Rahman Store", role: "Owner", phone: "01711-223344", status: "Active", billable: "Yes" },
  { id: "acc-karim", user: "Karim", shop: "Rahman Store", role: "Salesman", phone: "01811-223344", status: "Active", billable: "Yes" },
  { id: "acc-nusrat", user: "Nusrat", shop: "Janata Bazar", role: "Owner", phone: "01911-223344", status: "Active", billable: "Yes" },
  { id: "acc-farhan", user: "Farhan", shop: "City Point", role: "Salesman", phone: "01611-223344", status: "Disabled", billable: "No" },
  { id: "acc-mitu", user: "Mitu", shop: "Fresh Corner", role: "Salesman", phone: "01511-223344", status: "Active", billable: "Yes" },
];

function AccountsIcon({ type }: { type: string }) {
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
    case "owner":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M12 10.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7Z" />
          <path {...commonProps} d="M6 19a6 6 0 0 1 12 0" />
          <path {...commonProps} d="m16.5 6.5 1.5 1.5 2.5-2.5" />
        </svg>
      );
    case "salesman":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M10 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
          <path {...commonProps} d="M4.5 19a5 5 0 0 1 10 0" />
          <path {...commonProps} d="M16 9.5h4" />
          <path {...commonProps} d="M18 7.5v4" />
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

function MoreIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <circle cx="12" cy="5.5" r="1.5" />
      <circle cx="12" cy="12" r="1.5" />
      <circle cx="12" cy="18.5" r="1.5" />
    </svg>
  );
}

export default function ShopManagementAccountsPage() {
  const [openActionMenu, setOpenActionMenu] = useState<string | null>(null);
  const [openExportMenu, setOpenExportMenu] = useState(false);

  return (
    <section className="master-category-page">
      <div className="purchase-report-layout sales-report-layout">
        <div className="admin-dashboard-stats shop-management-accounts-stats">
          {accountStats.map((stat) => (
            <article className="admin-stat-card" key={stat.label}>
              <div className={`admin-stat-icon admin-stat-icon-${stat.accent}`}>
                <AccountsIcon type={stat.icon} />
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

        <section className="admin-dashboard-panel purchase-report-panel purchase-report-category-panel">
          <div className="purchase-report-panel-header">
            <div>
              <h3>Role Distribution</h3>
              <p>Billing is driven by owner and salesman account counts across all shops.</p>
            </div>
          </div>

          <div className="purchase-report-donut-layout">
            <div className="purchase-report-donut-wrap" aria-hidden="true">
              <svg viewBox="0 0 220 220" className="purchase-report-donut-svg">
                <circle cx="110" cy="110" r="66" className="purchase-report-donut-track" />
                <circle cx="110" cy="110" r="66" className="purchase-report-donut-segment purchase-report-donut-segment-green" />
                <circle cx="110" cy="110" r="66" className="purchase-report-donut-segment purchase-report-donut-segment-blue" />
              </svg>
              <div className="purchase-report-donut-center">
                <strong>6,236</strong>
                <span>Total Accounts</span>
              </div>
            </div>

            <div className="purchase-report-category-list">
              {roleBreakdown.map((item) => (
                <article className="purchase-report-category-card shop-management-role-card" key={item.label}>
                  <span className={`purchase-report-category-dot purchase-report-category-dot-${item.accent}`} />
                  <div className="shop-management-role-copy">
                    <strong>{item.label}</strong>
                    <span>{item.amount} accounts</span>
                  </div>
                  <em className="shop-management-role-share">{item.value}</em>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="admin-dashboard-panel purchase-report-panel sales-report-table-card">
          <div className="purchase-report-table-header">
            <div>
              <h3>Accounts</h3>
              <p>Track billable users, reset access, and manage ownership transfer at the shop level.</p>
            </div>
          </div>

          <div className="user-management-toolbar-grid">
            <label className="master-category-search">
              <input type="text" placeholder="Search user" />
            </label>
            <select className="master-category-select" defaultValue="Shop">
              <option>Shop</option>
            </select>
            <select className="master-category-select" defaultValue="Role">
              <option>Role</option>
              <option>Owner</option>
              <option>Salesman</option>
            </select>
            <select className="master-category-select" defaultValue="Status">
              <option>Status</option>
              <option>Active</option>
              <option>Disabled</option>
            </select>
            <div className="sales-report-export-menu">
              <button type="button" className="master-category-outline-button sales-report-export-button" onClick={() => setOpenExportMenu((current) => !current)}>
                Export
              </button>
              {openExportMenu ? (
                <div className="product-catalog-export-dropdown" role="menu">
                  <button type="button" className="product-catalog-export-item" role="menuitem">Export Excel</button>
                  <button type="button" className="product-catalog-export-item" role="menuitem">Export PDF</button>
                </div>
              ) : null}
            </div>
          </div>

          <div className="shop-management-records-table">
            <div className="shop-management-records-head shop-management-records-head-accounts">
              <span>User</span>
              <span>Shop</span>
              <span>Role</span>
              <span>Phone</span>
              <span>Status</span>
              <span>Billable</span>
              <span>Action</span>
            </div>

            {accountRows.map((row) => (
              <div className="shop-management-records-row shop-management-records-row-accounts" key={row.id}>
                <span>{row.user}</span>
                <span>{row.shop}</span>
                <span>{row.role}</span>
                <span>{row.phone}</span>
                <span>
                  <em className={`shop-management-status-badge${row.status === "Disabled" ? " shop-management-status-badge-suspended" : ""}`}>
                    {row.status}
                  </em>
                </span>
                <span>
                  <em className={`user-management-billing-badge${row.billable === "No" ? " user-management-billing-badge-off" : ""}`}>
                    {row.billable}
                  </em>
                </span>
                <span className="subscription-table-actions">
                  <button type="button" className="subscription-list-action-button subscription-list-action-button-view">
                    <span>View</span>
                  </button>
                  <span className="subscription-table-action-menu">
                    <button
                      type="button"
                      className="subscription-list-action-button subscription-list-action-button-more"
                      aria-haspopup="menu"
                      aria-expanded={openActionMenu === row.id}
                      onClick={() => setOpenActionMenu((current) => (current === row.id ? null : row.id))}
                    >
                      <MoreIcon />
                      <span>More</span>
                    </button>
                    {openActionMenu === row.id ? (
                      <div className="subscription-table-action-dropdown" role="menu">
                        <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">View</button>
                        <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">Reset Password</button>
                        <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">Disable</button>
                        <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">Transfer Ownership</button>
                      </div>
                    ) : null}
                  </span>
                </span>
              </div>
            ))}
          </div>
        </section>
      </div>
    </section>
  );
}
