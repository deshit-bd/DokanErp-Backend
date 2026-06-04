"use client";

import { useState } from "react";
import { LuBadgeCheck, LuFileText, LuStore, LuWallet } from "react-icons/lu";

const subscriptionCards = [
  {
    title: "Total Plans",
    value: "3",
    subtitle: "All Available Plans",
    accent: "blue" as const,
    icon: LuFileText,
  },
  {
    title: "Active Plans",
    value: "3",
    subtitle: "Currently Available",
    accent: "green" as const,
    icon: LuBadgeCheck,
  },
  {
    title: "Active Subscriptions",
    value: "1,245",
    subtitle: "Subscribed Shops",
    accent: "amber" as const,
    icon: LuStore,
  },
  {
    title: "Monthly Revenue",
    value: "৳245,000",
    subtitle: "Current Month",
    accent: "violet" as const,
    icon: LuWallet,
  },
];

const subscriptionPlanCards = [
  {
    title: "Shop Owner",
    subtitle: "Shop Owner Account",
    price: "৳10 / Account",
    accent: "green" as const,
    features: [
      "Full Shop Access",
      "Inventory Management",
      "Sales & Purchase",
      "Reports",
      "User Management",
    ],
    activeShopText: "Active Accounts: 1,245",
  },
  {
    title: "Salesman",
    subtitle: "Salesman Account",
    price: "৳10 / Account",
    accent: "blue" as const,
    features: ["POS Sales", "Customer Management", "Limited Reports"],
    activeShopText: "Active Accounts: 8,450",
  },
];

const subscriptionFeatureRows = [
  { feature: "Product Management", shopOwner: "✅", salesman: "❌" },
  { feature: "Purchase", shopOwner: "✅", salesman: "❌" },
  { feature: "Sales", shopOwner: "✅", salesman: "✅" },
  { feature: "Expense", shopOwner: "✅", salesman: "❌" },
  { feature: "Reports", shopOwner: "✅", salesman: "Limited" },
  { feature: "User Management", shopOwner: "✅", salesman: "❌" },
];

const subscriptionTableRows = [
  {
    id: 1,
    shopName: "Rahman Store",
    shopCode: "SHOP-001",
    owner: "Abdul Rahman",
    totalAccounts: 12,
    monthlyCharge: "৳120",
    status: "Active",
    billingStatus: "Paid",
    expiryDate: "31 Jul 2026",
  },
  {
    id: 2,
    shopName: "Bondhon Mart",
    shopCode: "SHOP-002",
    owner: "Nusrat Jahan",
    totalAccounts: 8,
    monthlyCharge: "৳80",
    status: "Trial",
    billingStatus: "Pending",
    expiryDate: "18 Jul 2026",
  },
  {
    id: 3,
    shopName: "Tongi Bazaar",
    shopCode: "SHOP-003",
    owner: "Kamrul Hasan",
    totalAccounts: 5,
    monthlyCharge: "৳50",
    status: "Expired",
    billingStatus: "Overdue",
    expiryDate: "02 Jun 2026",
  },
];

function SubscriptionTableActions({
  isOpen,
  onToggle,
}: {
  isOpen: boolean;
  onToggle: () => void;
}) {
  return (
    <span className="subscription-table-actions">
      <button type="button" className="subscription-list-action-button subscription-list-action-button-view" aria-label="View subscription">
        <span aria-hidden="true">👁</span>
        <span>View</span>
      </button>

      <span className="subscription-table-action-menu">
        <button
          type="button"
          className="subscription-list-action-button subscription-list-action-button-more"
          aria-haspopup="menu"
          aria-expanded={isOpen}
          onClick={onToggle}
        >
          <span aria-hidden="true">⋮</span>
          <span>More</span>
        </button>

        {isOpen ? (
          <div className="subscription-table-action-dropdown" role="menu">
            <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">
              View Subscription
            </button>
            <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">
              View Billing History
            </button>
            <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">
              Manage Accounts
            </button>
            <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">
              Renew Subscription
            </button>
            <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">
              Suspend Shop
            </button>
            <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">
              Activate Shop
            </button>
            <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">
              Send Payment Reminder
            </button>
            <button type="button" className="subscription-table-action-dropdown-item subscription-table-action-dropdown-item-danger" role="menuitem">
              Delete Subscription
            </button>
          </div>
        ) : null}
      </span>
    </span>
  );
}

export default function SubscriptionsPage() {
  const [activeView, setActiveView] = useState<"plans" | "features">("plans");
  const [openActionMenuId, setOpenActionMenuId] = useState<number | null>(null);
  const [isPlanModalOpen, setIsPlanModalOpen] = useState(false);

  return (
    <section className="subscription-dashboard-page">
      <div className="subscription-dashboard-stats">
        {subscriptionCards.map((card) => {
          const Icon = card.icon;

          return (
            <article className="subscription-dashboard-stat-card" key={card.title}>
              <span className={`subscription-dashboard-stat-icon subscription-dashboard-stat-icon-${card.accent}`} aria-hidden="true">
                <Icon />
              </span>

              <div className="subscription-dashboard-stat-copy">
                <strong>{card.title}</strong>
                <span>{card.value}</span>
                <small>{card.subtitle}</small>
              </div>
            </article>
          );
        })}
      </div>

      <section className="subscription-dashboard-plans-card">
        <fieldset className="subscription-dashboard-toggle-group">
          <legend className="subscription-dashboard-toggle-legend">Subscription sections</legend>

          <div className="subscription-dashboard-toggle-options" role="radiogroup" aria-label="Subscription sections">
            {[
              { key: "plans" as const, label: "Plans" },
              { key: "features" as const, label: "Features" },
            ].map((item) => {
              const id = `subscription-dashboard-${item.key}`;

              return (
                <label className="subscription-dashboard-toggle-option" htmlFor={id} key={item.key}>
                  <input
                    checked={activeView === item.key}
                    id={id}
                    name="subscription-dashboard-view"
                    onChange={() => setActiveView(item.key)}
                    type="radio"
                  />
                  <span>{item.label}</span>
                </label>
              );
            })}
          </div>
        </fieldset>

        {activeView === "plans" ? (
          <>
            <div className="subscription-plan-toolbar">
              <button
                type="button"
                className="subscription-table-outline-button subscription-plan-add-button"
                onClick={() => setIsPlanModalOpen(true)}
              >
                Add New Plan
              </button>
            </div>

            <div className="subscription-pricing-grid">
              {subscriptionPlanCards.map((plan) => (
                <article
                  className={`subscription-pricing-card subscription-pricing-card-${plan.accent}`}
                  key={`${plan.title}-${plan.accent}`}
                >
                  <div className="subscription-pricing-card-header">
                    <strong>{plan.title}</strong>
                  </div>

                  <div className="subscription-pricing-card-copy">
                    <h3>{plan.price}</h3>
                    <p>{plan.subtitle}</p>
                  </div>

                  <ul className="subscription-pricing-offers">
                    {plan.features.map((feature, index) => (
                      <li key={`${plan.accent}-${index}`}>
                        <span aria-hidden="true">✓</span>
                        <span>{feature}</span>
                      </li>
                    ))}
                  </ul>

                  <div className={`subscription-pricing-card-footer subscription-pricing-card-footer-${plan.accent}`}>
                    {plan.activeShopText}
                  </div>
                </article>
              ))}
            </div>
          </>
        ) : (
          <div className="subscription-feature-panel">
            <div className="subscription-feature-panel-copy">
              <h3>Feature Access</h3>
              <p>Compare what each active account type can use inside the system.</p>
            </div>

            <div className="subscription-feature-table">
              <div className="subscription-feature-table-head">
                <span>Feature</span>
                <span>Shop Owner</span>
                <span>Salesman</span>
              </div>
              {subscriptionFeatureRows.map((feature) => (
                <div className="subscription-feature-table-row" key={feature.feature}>
                  <span>{feature.feature}</span>
                  <span>{feature.shopOwner}</span>
                  <span>{feature.salesman}</span>
                </div>
              ))}
            </div>
          </div>
        )}
      </section>

      {isPlanModalOpen ? (
        <div className="payment-modal-backdrop" onClick={() => setIsPlanModalOpen(false)}>
          <div
            className="payment-modal subscription-plan-modal"
            onClick={(event) => event.stopPropagation()}
            role="dialog"
            aria-modal="true"
            aria-labelledby="subscription-plan-modal-title"
          >
            <div className="payment-modal-header subscription-plan-modal-header">
              <div>
                <h3 id="subscription-plan-modal-title">Add New Plan</h3>
              </div>
              <button
                type="button"
                className="payment-modal-close"
                onClick={() => setIsPlanModalOpen(false)}
                aria-label="Close modal"
              >
                ×
              </button>
            </div>

            <form className="payment-modal-form subscription-plan-modal-form">
              <label className="payment-modal-field subscription-plan-modal-field">
                <span>Plan Name *</span>
                <input type="text" placeholder="Enter plan name" />
              </label>

              <label className="payment-modal-field subscription-plan-modal-field">
                <span>Plan Type *</span>
                <select defaultValue="Per Account">
                  <option>Per Account</option>
                </select>
              </label>

              <label className="payment-modal-field subscription-plan-modal-field">
                <span>Billing Cycle *</span>
                <select defaultValue="Per Day">
                  <option>Per Day</option>
                </select>
              </label>

              <label className="payment-modal-field subscription-plan-modal-field">
                <span>Price *</span>
                <input type="text" defaultValue="৳10" />
              </label>

              <div className="subscription-plan-modal-block payment-modal-field-full">
                <strong>Applicable Roles</strong>
                <div className="subscription-plan-modal-check-grid">
                  {["Shop Owner", "Salesman", "Manager", "Accountant"].map((role) => (
                    <label className="subscription-plan-modal-check" key={role}>
                      <input type="checkbox" defaultChecked />
                      <span>{role}</span>
                    </label>
                  ))}
                </div>
              </div>

              <div className="subscription-plan-modal-block payment-modal-field-full">
                <strong>Features</strong>
                <div className="subscription-plan-modal-check-grid">
                  {["Product Management", "Sales", "Purchase", "Reports", "Barcode"].map((feature) => (
                    <label className="subscription-plan-modal-check" key={feature}>
                      <input type="checkbox" defaultChecked />
                      <span>{feature}</span>
                    </label>
                  ))}
                </div>
              </div>

              <label className="payment-modal-field payment-modal-field-full subscription-plan-modal-field">
                <span>Status *</span>
                <select defaultValue="Active">
                  <option>Active</option>
                  <option>Inactive</option>
                </select>
              </label>

              <div className="payment-modal-actions subscription-plan-modal-actions">
                <button
                  type="button"
                  className="payment-modal-secondary-button"
                  onClick={() => setIsPlanModalOpen(false)}
                >
                  Cancel
                </button>
                <button type="button" className="payment-modal-primary-button">
                  Save Plan
                </button>
              </div>
            </form>
          </div>
        </div>
      ) : null}

      <section className="subscription-list-card">
        <div className="subscription-list-card-header">
          <h3>Subscriptions</h3>
        </div>

        <div className="subscription-table-toolbar">
          <label className="subscription-table-search">
            <input type="text" placeholder="Search Shop Name, Code..." />
          </label>

          <select className="subscription-table-select" defaultValue="All Plans">
            <option>All Plans</option>
            <option>Shop Owner</option>
            <option>Salesman</option>
          </select>

          <select className="subscription-table-select" defaultValue="All Status">
            <option>All Status</option>
            <option>Active</option>
            <option>Suspended</option>
            <option>Expired</option>
            <option>Trial</option>
          </select>

          <select className="subscription-table-select" defaultValue="Billing Status">
            <option>Billing Status</option>
            <option>Paid</option>
            <option>Pending</option>
            <option>Overdue</option>
          </select>

          <button type="button" className="subscription-table-outline-button">
            Clear Filters
          </button>

          <button type="button" className="subscription-table-outline-button">
            Export
          </button>
        </div>

        <div className="subscription-shop-table">
          <div className="subscription-shop-table-head">
            <span>#</span>
            <span>Shop Name</span>
            <span>Shop Code</span>
            <span>Owner</span>
            <span>Total Accounts</span>
            <span>Monthly Charge</span>
            <span>Status</span>
            <span>Expiry Date</span>
            <span>Actions</span>
          </div>

          {subscriptionTableRows.map((row) => (
            <div className="subscription-shop-table-row" key={row.id}>
              <span>{row.id}</span>
              <span>{row.shopName}</span>
              <span>{row.shopCode}</span>
              <span>{row.owner}</span>
              <span>{row.totalAccounts}</span>
              <span>{row.monthlyCharge}</span>
              <span>
                <em
                  className={`subscription-list-status-badge${
                    row.status === "Expired"
                      ? " subscription-list-status-badge-expired"
                      : row.status === "Trial"
                        ? " subscription-list-status-badge-trial"
                        : ""
                  }`}
                >
                  {row.status}
                </em>
              </span>
              <span>{row.expiryDate}</span>
              <SubscriptionTableActions
                isOpen={openActionMenuId === row.id}
                onToggle={() => setOpenActionMenuId((current) => (current === row.id ? null : row.id))}
              />
            </div>
          ))}
        </div>

        <div className="master-category-footer">
          <span className="master-category-footer-text">Showing 3 subscriptions total</span>

          <div className="master-category-pagination">
            <button type="button" className="master-category-page-button">{"<"} Preview</button>
            <button type="button" className="master-category-page-chip master-category-page-chip-active">1</button>
            <button type="button" className="master-category-page-chip">2</button>
            <button type="button" className="master-category-page-chip">...</button>
            <button type="button" className="master-category-page-chip">24</button>
            <button type="button" className="master-category-page-button">Next Page {">"}</button>
          </div>

          <select className="master-category-page-size" defaultValue="10">
            <option>10</option>
          </select>
        </div>
      </section>
    </section>
  );
}
