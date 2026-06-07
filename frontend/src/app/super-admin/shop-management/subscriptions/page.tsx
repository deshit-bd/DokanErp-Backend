"use client";

import { useState } from "react";

const subscriptionStats = [
  { label: "Active Subscriptions", value: "1,186", note: "Currently billable shops", accent: "green", icon: "check" },
  { label: "Expired", value: "42", note: "Needs immediate renewal", accent: "red", icon: "alert" },
  { label: "Grace Period", value: "26", note: "Shops still allowed temporarily", accent: "amber", icon: "clock" },
  { label: "Monthly Revenue", value: "৳62,360", note: "Account-based billing", accent: "violet", icon: "wallet" },
];

const subscriptionRows = [
  { id: "sub-rahman", shop: "Rahman Store", accounts: "5 Accounts", amount: "৳50", expiry: "30 Jun 2026", status: "Active" },
  { id: "sub-janata", shop: "Janata Bazar", accounts: "7 Accounts", amount: "৳70", expiry: "28 Jun 2026", status: "Grace Period" },
  { id: "sub-fresh", shop: "Fresh Corner", accounts: "4 Accounts", amount: "৳40", expiry: "15 Jun 2026", status: "Expired" },
  { id: "sub-city", shop: "City Point", accounts: "8 Accounts", amount: "৳80", expiry: "07 Jul 2026", status: "Active" },
];

const subscriptionShopDetails = {
  owner: "Rahim",
  phone: "01711-223344",
  address: "Mirpur, Dhaka",
  createdDate: "31 May 2024",
  overviewCards: [
    { label: "Sales This Month", value: "৳1.9M" },
    { label: "Purchases This Month", value: "৳1.2M" },
    { label: "Profit This Month", value: "৳324K" },
    { label: "Stock Value", value: "৳8.4M" },
    { label: "Accounts", value: "5" },
    { label: "Products", value: "842" },
  ],
  accountCards: [
    { label: "Total Accounts", value: "5" },
    { label: "Owners", value: "1" },
    { label: "Salesmen", value: "4" },
    { label: "Active Accounts", value: "4" },
  ],
  accountRows: [
    { name: "Rahim", role: "Owner", phone: "01711-223344", lastLogin: "30 Jun 2026, 10:42 AM", status: "Active" },
    { name: "Karim", role: "Salesman", phone: "01811-223344", lastLogin: "30 Jun 2026, 09:25 AM", status: "Active" },
    { name: "Mitu", role: "Salesman", phone: "01911-223344", lastLogin: "29 Jun 2026, 08:18 PM", status: "Active" },
  ],
  subscriptionCards: [
    { label: "Current Plan", value: "Standard" },
    { label: "Accounts Used", value: "5" },
    { label: "Monthly Bill", value: "৳50" },
    { label: "Days Remaining", value: "24" },
  ],
  activityRows: [
    { date: "30 Jun 2026", user: "Karim", action: "Salesman Added", details: "New salesman added to the shop." },
    { date: "29 Jun 2026", user: "System", action: "Subscription Renewed", details: "Billing cycle renewed successfully." },
    { date: "28 Jun 2026", user: "Rahim", action: "Password Reset", details: "Reset an account password." },
  ],
} as const;

function SubscriptionMetricIcon({ type }: { type: string }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (type) {
    case "check":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="8.5" />
          <path {...commonProps} d="m8.5 12 2.3 2.3 4.7-4.8" />
        </svg>
      );
    case "alert":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M12 3.5 19 8v8l-7 4.5L5 16V8l7-4.5Z" />
          <path {...commonProps} d="M12 8v5" />
          <path {...commonProps} d="M12 16h.01" />
        </svg>
      );
    case "clock":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="8.5" />
          <path {...commonProps} d="M12 8v4.5l3 2" />
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

function DownloadIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path d="M12 4v9" />
      <path d="m8.5 10.5 3.5 3.5 3.5-3.5" />
      <path d="M5 18h14" />
    </svg>
  );
}

function renderMetricCards(cards: readonly { label: string; value: string }[]) {
  return (
    <div className="shop-details-card-grid">
      {cards.map((card) => (
        <article className="shop-details-card" key={card.label}>
          <span>{card.label}</span>
          <strong>{card.value}</strong>
        </article>
      ))}
    </div>
  );
}

function renderTableSection<T extends readonly string[]>({
  columns,
  rows,
}: {
  columns: T;
  rows: Array<Record<T[number], string>>;
}) {
  return (
    <div className="shop-details-table">
      <div className="shop-details-table-head" style={{ gridTemplateColumns: `repeat(${columns.length}, minmax(0, 1fr))` }}>
        {columns.map((column) => (
          <span key={column}>{column}</span>
        ))}
      </div>
      {rows.map((row, index) => (
        <div className="shop-details-table-row" key={`row-${index}`} style={{ gridTemplateColumns: `repeat(${columns.length}, minmax(0, 1fr))` }}>
          {columns.map((column) => (
            <span key={column}>{row[column as T[number]]}</span>
          ))}
        </div>
      ))}
    </div>
  );
}

export default function ShopManagementSubscriptionsPage() {
  const [openActionMenu, setOpenActionMenu] = useState<string | null>(null);
  const [openExportMenu, setOpenExportMenu] = useState(false);
  const [selectedSubscriptionId, setSelectedSubscriptionId] = useState<string | null>(null);
  const selectedSubscription = subscriptionRows.find((row) => row.id === selectedSubscriptionId) ?? null;

  const openSubscriptionDetails = (subscriptionId: string) => {
    setSelectedSubscriptionId(subscriptionId);
    setOpenActionMenu(null);
  };

  const renderSubscriptionContent = () => {
    if (!selectedSubscription) return null;

    return (
      <div className="shop-details-content-grid">
        {renderMetricCards(subscriptionShopDetails.subscriptionCards)}
        <section className="shop-details-section">
          <h4>Subscription Details</h4>
          <div className="shop-details-info-grid">
            <article className="shop-details-info-item"><span>Shop Name</span><strong>{selectedSubscription.shop}</strong></article>
            <article className="shop-details-info-item"><span>Owner</span><strong>{subscriptionShopDetails.owner}</strong></article>
            <article className="shop-details-info-item"><span>Plan Name</span><strong>Standard</strong></article>
            <article className="shop-details-info-item"><span>Billing Cycle</span><strong>Monthly</strong></article>
            <article className="shop-details-info-item"><span>Price Per Account</span><strong>৳10</strong></article>
            <article className="shop-details-info-item"><span>Current Accounts</span><strong>5</strong></article>
            <article className="shop-details-info-item"><span>Monthly Charge</span><strong>{selectedSubscription.amount}</strong></article>
            <article className="shop-details-info-item"><span>Next Renewal</span><strong>{selectedSubscription.expiry}</strong></article>
            <article className="shop-details-info-item"><span>Grace Period Status</span><strong>{selectedSubscription.status === "Grace Period" ? "Active" : "Not Active"}</strong></article>
          </div>
        </section>
        <section className="shop-details-section">
          <h4>Billing Calculation</h4>
          <div className="profit-loss-formula-lines">
            <div className="profit-loss-formula-row"><span>Owner</span><strong>1 × ৳10</strong></div>
            <div className="profit-loss-formula-row"><span>Salesmen</span><strong>4 × ৳10</strong></div>
            <div className="profit-loss-formula-result"><span>Total Accounts</span><strong>5</strong></div>
            <div className="profit-loss-formula-result profit-loss-formula-result-margin"><span>Total Charge</span><strong>৳50</strong></div>
          </div>
        </section>
        <section className="shop-details-section">
          <h4>Activity Log</h4>
          {renderTableSection({
            columns: ["Date", "User", "Action", "Details"] as const,
            rows: subscriptionShopDetails.activityRows.map((row) => ({
              Date: row.date,
              User: row.user,
              Action: row.action,
              Details: row.details,
            })),
          })}
        </section>
      </div>
    );
  };

  return (
    <>
      <section className="master-category-page">
        <div className="purchase-report-layout sales-report-layout">
        <div className="admin-dashboard-stats shop-management-subscriptions-stats">
          {subscriptionStats.map((stat) => (
            <article className="admin-stat-card" key={stat.label}>
              <div className={`admin-stat-icon admin-stat-icon-${stat.accent}`}>
                <SubscriptionMetricIcon type={stat.icon} />
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

        <section className="admin-dashboard-panel purchase-report-panel sales-report-table-card">
          <div className="purchase-report-table-header">
            <div>
              <h3>Subscriptions</h3>
              <p>Track active, expired, and grace-period shops based on account-level billing.</p>
            </div>
          </div>

          <div className="shop-management-toolbar-grid shop-management-toolbar-grid-subscriptions">
            <label className="master-category-search">
              <input type="text" placeholder="Search shop" />
            </label>
            <select className="master-category-select" defaultValue="All Status">
              <option>All Status</option>
              <option>Active</option>
              <option>Grace Period</option>
              <option>Expired</option>
            </select>
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
          </div>

          <div className="shop-management-records-table">
            <div className="shop-management-records-head shop-management-records-head-subscriptions">
              <span>Shop</span>
              <span>Accounts</span>
              <span>Amount</span>
              <span>Expiry</span>
              <span>Status</span>
              <span>Action</span>
            </div>

            {subscriptionRows.map((row) => (
              <div className="shop-management-records-row shop-management-records-row-subscriptions" key={row.id}>
                <span>{row.shop}</span>
                <span>{row.accounts}</span>
                <span>{row.amount}</span>
                <span>{row.expiry}</span>
                <span>
                  <em
                    className={`shop-management-status-badge${
                      row.status === "Expired"
                        ? " shop-management-status-badge-suspended"
                        : row.status === "Grace Period"
                          ? " shop-management-status-badge-grace"
                          : ""
                    }`}
                  >
                    {row.status}
                  </em>
                </span>
                <span className="subscription-table-actions">
                  <button
                    type="button"
                    className="subscription-list-action-button subscription-list-action-button-view"
                    onClick={() => openSubscriptionDetails(row.id)}
                  >
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
                        <button type="button" className="subscription-table-action-dropdown-item" role="menuitem" onClick={() => openSubscriptionDetails(row.id)}>View Subscription</button>
                        <button type="button" className="subscription-table-action-dropdown-item" role="menuitem" onClick={() => openSubscriptionDetails(row.id)}>Manage Accounts</button>
                        <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">Renew</button>
                        <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">Suspend Shop</button>
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

      {selectedSubscription ? (
        <div className="payment-modal-backdrop" onClick={() => setSelectedSubscriptionId(null)}>
          <div
            className="payment-modal shop-management-details-modal"
            onClick={(event) => event.stopPropagation()}
            role="dialog"
            aria-modal="true"
            aria-labelledby="subscription-details-modal-title"
          >
            <div className="payment-modal-header shop-management-details-modal-header">
              <div>
                <h3 id="subscription-details-modal-title">Subscription Details</h3>
                <p>Review plan, billing, renewal, and account-based subscription charge details for this shop.</p>
              </div>
              <button
                type="button"
                className="payment-modal-close"
                onClick={() => setSelectedSubscriptionId(null)}
                aria-label="Close subscription details modal"
              >
                ×
              </button>
            </div>

            <div className="shop-management-details-modal-body">
              {renderSubscriptionContent()}
            </div>
          </div>
        </div>
      ) : null}
    </>
  );
}
