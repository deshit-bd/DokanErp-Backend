"use client";

import { useState } from "react";

const shopStats = [
  { label: "Total Shops", value: "1,254", note: "Registered business entities", accent: "green", icon: "shop" },
  { label: "Active Shops", value: "1,186", note: "Currently operating", accent: "indigo", icon: "check" },
  { label: "Suspended Shops", value: "68", note: "Temporarily restricted", accent: "red", icon: "pause" },
  { label: "Owners", value: "1,254", note: "One owner per shop", accent: "blue", icon: "user" },
  { label: "Salesmen", value: "4,982", note: "Billable shop accounts", accent: "amber", icon: "users" },
  { label: "Products", value: "84,260", note: "Catalog items across shops", accent: "violet", icon: "box" },
];

const detailTabs = ["Overview", "Accounts", "Inventory", "Sales", "Purchases", "Subscription", "Activity Log"] as const;

const shopRows = [
  { id: "shop-rahman", shop: "Rahman Store", owner: "Rahim", salesmen: 4, products: 842, status: "Active", subscription: "Standard" },
  { id: "shop-janata", shop: "Janata Bazar", owner: "Karim", salesmen: 6, products: 911, status: "Active", subscription: "Premium" },
  { id: "shop-fresh", shop: "Fresh Corner", owner: "Mitu", salesmen: 3, products: 604, status: "Suspended", subscription: "Starter" },
  { id: "shop-bondhon", shop: "Bondhon Mart", owner: "Farhan", salesmen: 5, products: 755, status: "Active", subscription: "Standard" },
  { id: "shop-city", shop: "City Point", owner: "Nusrat", salesmen: 7, products: 1_086, status: "Active", subscription: "Enterprise" },
];

const shopDetailData = {
  phone: "01711-223344",
  address: "Mirpur, Dhaka",
  createdDate: "31 May 2024",
  totalAccounts: "5",
  totalProducts: "842",
  currentStockValue: "৳8.4M",
  monthlySales: "৳1.9M",
  monthlyPurchases: "৳1.2M",
  currentPlan: "Standard",
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
    { name: "Tania", role: "Salesman", phone: "01611-223344", lastLogin: "28 Jun 2026, 05:10 PM", status: "Disabled" },
  ],
  inventoryCards: [
    { label: "Total Products", value: "842" },
    { label: "Low Stock", value: "18" },
    { label: "Out of Stock", value: "6" },
    { label: "Inventory Value", value: "৳8.4M" },
  ],
  inventoryRows: [
    { product: "Miniket Rice", stock: "124", purchasePrice: "৳1,820", sellPrice: "৳1,920", value: "৳238,080" },
    { product: "Soybean Oil", stock: "76", purchasePrice: "৳820", sellPrice: "৳860", value: "৳62,320" },
    { product: "Sugar (White)", stock: "98", purchasePrice: "৳108", sellPrice: "৳118", value: "৳10,584" },
  ],
  salesCards: [
    { label: "Total Sales", value: "৳1.9M" },
    { label: "Orders", value: "1,428" },
    { label: "Average Order", value: "৳1,331" },
    { label: "Profit", value: "৳324K" },
  ],
  topSellingProducts: [
    { name: "Miniket Rice", value: "৳420K" },
    { name: "Soybean Oil", value: "৳286K" },
    { name: "Sugar (White)", value: "৳198K" },
  ],
  recentSales: [
    { label: "Latest Invoice", value: "INV-240630-019" },
    { label: "Top Salesman", value: "Karim" },
    { label: "Best Day", value: "29 Jun 2026" },
  ],
  salesRows: [
    { invoice: "INV-240630-019", date: "30 Jun 2026", amount: "৳12,450", profit: "৳2,140", salesman: "Karim" },
    { invoice: "INV-240629-112", date: "29 Jun 2026", amount: "৳9,880", profit: "৳1,720", salesman: "Mitu" },
    { invoice: "INV-240629-091", date: "29 Jun 2026", amount: "৳8,640", profit: "৳1,460", salesman: "Rahim" },
  ],
  purchaseCards: [
    { label: "Total Purchases", value: "৳1.2M" },
    { label: "Purchase Orders", value: "126" },
    { label: "Suppliers", value: "28" },
    { label: "Due Amount", value: "৳184K" },
  ],
  topSuppliers: [
    { name: "Fresh Wholesale Ltd.", value: "৳380K" },
    { name: "Teer Distribution", value: "৳242K" },
    { name: "Pran Foods", value: "৳198K" },
  ],
  recentPurchases: [
    { label: "Latest PO", value: "PO-240630-001" },
    { label: "Largest Supplier", value: "Fresh Wholesale Ltd." },
    { label: "Pending Due", value: "৳184K" },
  ],
  purchaseRows: [
    { purchaseNo: "PO-240630-001", supplier: "Fresh Wholesale Ltd.", amount: "৳68,450", due: "৳12,000", status: "Partial" },
    { purchaseNo: "PO-240629-014", supplier: "Teer Distribution", amount: "৳54,220", due: "৳0", status: "Paid" },
    { purchaseNo: "PO-240628-022", supplier: "Pran Foods", amount: "৳49,880", due: "৳9,500", status: "Pending" },
  ],
  subscriptionCards: [
    { label: "Current Plan", value: "Standard" },
    { label: "Accounts Used", value: "5" },
    { label: "Monthly Bill", value: "৳50" },
    { label: "Days Remaining", value: "24" },
  ],
  activityRows: [
    { date: "30 Jun 2026", user: "Karim", action: "Salesman Added", details: "New salesman account added to Rahman Store." },
    { date: "29 Jun 2026", user: "System", action: "Subscription Renewed", details: "Monthly billing cycle renewed successfully." },
    { date: "28 Jun 2026", user: "Rahim", action: "Product Added", details: "Added a new grocery product to inventory." },
    { date: "27 Jun 2026", user: "Mitu", action: "Stock Adjusted", details: "Corrected stock count after physical audit." },
    { date: "26 Jun 2026", user: "Rahim", action: "Password Reset", details: "Reset salesman login credentials." },
    { date: "25 Jun 2026", user: "System", action: "Owner Changed", details: "Ownership transfer audit entry recorded." },
  ],
} as const;

function ShopManagementIcon({ type }: { type: string }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (type) {
    case "shop":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M4 9h16" />
          <path {...commonProps} d="M5.5 9V19h13V9" />
          <path {...commonProps} d="M4.5 9 6.5 5h11l2 4" />
          <path {...commonProps} d="M9 19v-5h6v5" />
        </svg>
      );
    case "check":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="8.5" />
          <path {...commonProps} d="m8.5 12 2.3 2.3 4.7-4.8" />
        </svg>
      );
    case "pause":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="8.5" />
          <path {...commonProps} d="M10 9.2v5.6" />
          <path {...commonProps} d="M14 9.2v5.6" />
        </svg>
      );
    case "user":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M12 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7Z" />
          <path {...commonProps} d="M5.5 19a6.5 6.5 0 0 1 13 0" />
        </svg>
      );
    case "users":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
          <path {...commonProps} d="M15.5 10a2.5 2.5 0 1 0 0-5" />
          <path {...commonProps} d="M4.5 19a4.5 4.5 0 0 1 9 0" />
          <path {...commonProps} d="M14 17a3.5 3.5 0 0 1 5.5-2.8" />
        </svg>
      );
    case "box":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" />
          <path {...commonProps} d="M12 12 4 7.5" />
          <path {...commonProps} d="M12 12l8-4.5" />
          <path {...commonProps} d="M12 12v9" />
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

function EditIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path d="m4 20 4.5-1 8.8-8.8a1.8 1.8 0 0 0 0-2.5l-1-1a1.8 1.8 0 0 0-2.5 0L5 15.5 4 20Z" />
      <path d="M12.5 8.5 15.5 11.5" />
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
  title,
  columns,
  rows,
}: {
  title?: string;
  columns: T;
  rows: Array<Record<T[number], string>>;
}) {
  return (
    <section className="shop-details-table-section">
      {title ? <h4>{title}</h4> : null}
      <div className="shop-details-table">
        <div className="shop-details-table-head" style={{ gridTemplateColumns: `repeat(${columns.length}, minmax(0, 1fr))` }}>
          {columns.map((column) => (
            <span key={column}>{column}</span>
          ))}
        </div>
        {rows.map((row, index) => (
          <div className="shop-details-table-row" key={`${title ?? "row"}-${index}`} style={{ gridTemplateColumns: `repeat(${columns.length}, minmax(0, 1fr))` }}>
            {columns.map((column) => (
              <span key={column}>{row[column as T[number]]}</span>
            ))}
          </div>
        ))}
      </div>
    </section>
  );
}

export default function ShopManagementShopsPage() {
  const [activeTab, setActiveTab] = useState<(typeof detailTabs)[number]>("Overview");
  const [openActionMenu, setOpenActionMenu] = useState<string | null>(null);
  const [selectedShopId, setSelectedShopId] = useState<string | null>(null);
  const selectedShop = shopRows.find((row) => row.id === selectedShopId) ?? null;

  const openShopDetails = (shopId: string) => {
    setSelectedShopId(shopId);
    setActiveTab("Overview");
    setOpenActionMenu(null);
  };

  const renderActiveTabContent = () => {
    if (!selectedShop) return null;

    if (activeTab === "Overview") {
      return (
        <div className="shop-details-content-grid">
          <section className="shop-details-section">
            <h4>Shop Information</h4>
            <div className="shop-details-info-grid">
              <article className="shop-details-info-item"><span>Shop Name</span><strong>{selectedShop.shop}</strong></article>
              <article className="shop-details-info-item"><span>Owner</span><strong>{selectedShop.owner}</strong></article>
              <article className="shop-details-info-item"><span>Phone</span><strong>{shopDetailData.phone}</strong></article>
              <article className="shop-details-info-item"><span>Address</span><strong>{shopDetailData.address}</strong></article>
              <article className="shop-details-info-item"><span>Created Date</span><strong>{shopDetailData.createdDate}</strong></article>
              <article className="shop-details-info-item"><span>Status</span><strong>{selectedShop.status}</strong></article>
            </div>
          </section>
          <section className="shop-details-section">
            <div className="shop-details-card-grid">
              <article className="shop-details-card"><span>Total Accounts</span><strong>{shopDetailData.totalAccounts}</strong></article>
              <article className="shop-details-card"><span>Total Products</span><strong>{shopDetailData.totalProducts}</strong></article>
              <article className="shop-details-card"><span>Current Stock Value</span><strong>{shopDetailData.currentStockValue}</strong></article>
              <article className="shop-details-card"><span>Monthly Sales</span><strong>{shopDetailData.monthlySales}</strong></article>
              <article className="shop-details-card"><span>Monthly Purchases</span><strong>{shopDetailData.monthlyPurchases}</strong></article>
              <article className="shop-details-card"><span>Current Plan</span><strong>{selectedShop.subscription}</strong></article>
            </div>
          </section>
          {renderMetricCards(shopDetailData.overviewCards)}
        </div>
      );
    }

    if (activeTab === "Accounts") {
      return (
        <div className="shop-details-content-grid">
          {renderMetricCards(shopDetailData.accountCards)}
          <div className="shop-details-split-grid">
            <section className="shop-details-section">
              <h4>Billing Calculation</h4>
              <div className="profit-loss-formula-lines">
                <div className="profit-loss-formula-row">
                  <span>Owner</span>
                  <strong>1 × ৳10</strong>
                </div>
                <div className="profit-loss-formula-row">
                  <span>Salesmen</span>
                  <strong>4 × ৳10</strong>
                </div>
                <div className="profit-loss-formula-result">
                  <span>Total Accounts</span>
                  <strong>5</strong>
                </div>
                <div className="profit-loss-formula-result profit-loss-formula-result-margin">
                  <span>Total Charge</span>
                  <strong>৳50</strong>
                </div>
              </div>
            </section>

            <section className="shop-details-section">
              <h4>Account Billing Logic</h4>
              <div className="shop-details-card-grid shop-details-card-grid-compact">
                <article className="shop-details-card">
                  <span>Example Shop</span>
                  <strong>{selectedShop.shop}</strong>
                </article>
                <article className="shop-details-card">
                  <span>Accounts</span>
                  <strong>1 Owner + 4 Salesmen</strong>
                </article>
                <article className="shop-details-card">
                  <span>Amount</span>
                  <strong>৳50</strong>
                </article>
              </div>
            </section>
          </div>
          <section className="shop-details-section">
            <div className="shop-details-section-header">
              <h4>Accounts</h4>
              <div className="shop-details-actions-inline">
                <button type="button" className="master-category-primary-button">Add Salesman</button>
              </div>
            </div>
            {renderTableSection({
              columns: ["Name", "Role", "Phone", "Last Login", "Status", "Actions"] as const,
              rows: shopDetailData.accountRows.map((row) => ({
                Name: row.name,
                Role: row.role,
                Phone: row.phone,
                "Last Login": row.lastLogin,
                Status: row.status,
                Actions: "Edit | Disable | Reset Password | Transfer Ownership",
              })),
            })}
          </section>
        </div>
      );
    }

    if (activeTab === "Inventory") {
      return (
        <div className="shop-details-content-grid">
          {renderMetricCards(shopDetailData.inventoryCards)}
          {renderTableSection({
            title: "Inventory Overview",
            columns: ["Product", "Stock", "Purchase Price", "Sell Price", "Value", "Actions"] as const,
            rows: shopDetailData.inventoryRows.map((row) => ({
              Product: row.product,
              Stock: row.stock,
              "Purchase Price": row.purchasePrice,
              "Sell Price": row.sellPrice,
              Value: row.value,
              Actions: "View Product | Adjust Stock",
            })),
          })}
        </div>
      );
    }

    if (activeTab === "Sales") {
      return (
        <div className="shop-details-content-grid">
          {renderMetricCards(shopDetailData.salesCards)}
          <div className="shop-details-split-grid">
            <section className="shop-details-section">
              <h4>Sales Trend Chart</h4>
              <div className="shop-details-chart-placeholder">
                <span>Sales Trend Chart</span>
              </div>
            </section>
            <section className="shop-details-section">
              <h4>Top Selling Products</h4>
              <div className="shop-details-list">
                {shopDetailData.topSellingProducts.map((item) => (
                  <article className="shop-details-list-item" key={item.name}>
                    <strong>{item.name}</strong>
                    <span>{item.value}</span>
                  </article>
                ))}
              </div>
            </section>
          </div>
          <section className="shop-details-section">
            <h4>Recent Sales</h4>
            <div className="shop-details-card-grid shop-details-card-grid-compact">
              {shopDetailData.recentSales.map((item) => (
                <article className="shop-details-card" key={item.label}>
                  <span>{item.label}</span>
                  <strong>{item.value}</strong>
                </article>
              ))}
            </div>
          </section>
          {renderTableSection({
            columns: ["Invoice", "Date", "Amount", "Profit", "Salesman"] as const,
            rows: shopDetailData.salesRows.map((row) => ({
              Invoice: row.invoice,
              Date: row.date,
              Amount: row.amount,
              Profit: row.profit,
              Salesman: row.salesman,
            })),
          })}
        </div>
      );
    }

    if (activeTab === "Purchases") {
      return (
        <div className="shop-details-content-grid">
          {renderMetricCards(shopDetailData.purchaseCards)}
          <div className="shop-details-split-grid">
            <section className="shop-details-section">
              <h4>Purchase Trend</h4>
              <div className="shop-details-chart-placeholder">
                <span>Purchase Trend</span>
              </div>
            </section>
            <section className="shop-details-section">
              <h4>Top Suppliers</h4>
              <div className="shop-details-list">
                {shopDetailData.topSuppliers.map((item) => (
                  <article className="shop-details-list-item" key={item.name}>
                    <strong>{item.name}</strong>
                    <span>{item.value}</span>
                  </article>
                ))}
              </div>
            </section>
          </div>
          <section className="shop-details-section">
            <h4>Recent Purchases</h4>
            <div className="shop-details-card-grid shop-details-card-grid-compact">
              {shopDetailData.recentPurchases.map((item) => (
                <article className="shop-details-card" key={item.label}>
                  <span>{item.label}</span>
                  <strong>{item.value}</strong>
                </article>
              ))}
            </div>
          </section>
          {renderTableSection({
            columns: ["Purchase No", "Supplier", "Amount", "Due", "Status"] as const,
            rows: shopDetailData.purchaseRows.map((row) => ({
              "Purchase No": row.purchaseNo,
              Supplier: row.supplier,
              Amount: row.amount,
              Due: row.due,
              Status: row.status,
            })),
          })}
        </div>
      );
    }

    if (activeTab === "Subscription") {
      return (
        <div className="shop-details-content-grid">
          {renderMetricCards(shopDetailData.subscriptionCards)}
          <section className="shop-details-section">
            <h4>Subscription Details</h4>
            <div className="shop-details-info-grid">
              <article className="shop-details-info-item"><span>Plan Name</span><strong>{selectedShop.subscription}</strong></article>
              <article className="shop-details-info-item"><span>Billing Cycle</span><strong>Monthly</strong></article>
              <article className="shop-details-info-item"><span>Price Per Account</span><strong>৳10</strong></article>
              <article className="shop-details-info-item"><span>Current Accounts</span><strong>5</strong></article>
              <article className="shop-details-info-item"><span>Monthly Charge</span><strong>৳50</strong></article>
              <article className="shop-details-info-item"><span>Next Renewal</span><strong>30 Jul 2026</strong></article>
              <article className="shop-details-info-item"><span>Grace Period Status</span><strong>Not Active</strong></article>
            </div>
          </section>
          <section className="shop-details-section">
            <h4>Billing Example</h4>
            <div className="profit-loss-formula-lines">
              <div className="profit-loss-formula-row"><span>Owner</span><strong>1</strong></div>
              <div className="profit-loss-formula-row"><span>Salesmen</span><strong>4</strong></div>
              <div className="profit-loss-formula-result"><span>Total Accounts</span><strong>5</strong></div>
              <div className="profit-loss-formula-result profit-loss-formula-result-margin"><span>5 × ৳10</span><strong>৳50</strong></div>
            </div>
          </section>
        </div>
      );
    }

    return (
      <div className="shop-details-content-grid">
        <section className="shop-details-section">
          <h4>Activity Timeline</h4>
          <div className="shop-details-list">
            {shopDetailData.activityRows.map((item) => (
              <article className="shop-details-list-item" key={`${item.date}-${item.action}`}>
                <strong>{item.action}</strong>
                <span>{item.details}</span>
              </article>
            ))}
          </div>
        </section>
        {renderTableSection({
          columns: ["Date", "User", "Action", "Details"] as const,
          rows: shopDetailData.activityRows.map((row) => ({
            Date: row.date,
            User: row.user,
            Action: row.action,
            Details: row.details,
          })),
        })}
      </div>
    );
  };

  return (
    <>
      <section className="master-category-page">
        <div className="purchase-report-layout sales-report-layout">
        <div className="admin-dashboard-stats shop-management-shops-stats">
          {shopStats.map((stat) => (
            <article className="admin-stat-card" key={stat.label}>
              <div className={`admin-stat-icon admin-stat-icon-${stat.accent}`}>
                <ShopManagementIcon type={stat.icon} />
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
              <h3>Shops</h3>
              <p>Manage business entities, owners, account volume, and subscription coverage.</p>
            </div>
          </div>

          <div className="shop-management-toolbar-grid">
            <label className="master-category-search">
              <input type="text" placeholder="Search shop or owner" />
            </label>
            <select className="master-category-select" defaultValue="All Status">
              <option>All Status</option>
              <option>Active</option>
              <option>Suspended</option>
            </select>
            <select className="master-category-select" defaultValue="All Subscriptions">
              <option>All Subscriptions</option>
              <option>Starter</option>
              <option>Standard</option>
              <option>Premium</option>
              <option>Enterprise</option>
            </select>
            <button type="button" className="master-category-outline-button">Clear</button>
          </div>

          <div className="shop-management-records-table">
            <div className="shop-management-records-head shop-management-records-head-shops">
              <span>Shop</span>
              <span>Owner</span>
              <span>Salesmen</span>
              <span>Products</span>
              <span>Status</span>
              <span>Subscription</span>
              <span>Action</span>
            </div>

            {shopRows.map((row) => (
              <div className="shop-management-records-row shop-management-records-row-shops" key={row.id}>
                <span>{row.shop}</span>
                <span>{row.owner}</span>
                <span>{row.salesmen}</span>
                <span>{row.products}</span>
                <span>
                  <em className={`shop-management-status-badge${row.status === "Suspended" ? " shop-management-status-badge-suspended" : ""}`}>
                    {row.status}
                  </em>
                </span>
                <span>{row.subscription}</span>
                <span className="subscription-table-actions">
                  <button
                    type="button"
                    className="subscription-list-action-button subscription-list-action-button-view"
                    aria-label={`View ${row.shop}`}
                    onClick={() => openShopDetails(row.id)}
                  >
                    <EditIcon />
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
                        <button
                          type="button"
                          className="subscription-table-action-dropdown-item"
                          role="menuitem"
                          onClick={() => openShopDetails(row.id)}
                        >
                          View Shop
                        </button>
                        <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">Edit</button>
                        <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">Suspend</button>
                        <button type="button" className="subscription-table-action-dropdown-item" role="menuitem">Subscription</button>
                        <button
                          type="button"
                          className="subscription-table-action-dropdown-item"
                          role="menuitem"
                          onClick={() => openShopDetails(row.id)}
                        >
                          Shop Details
                        </button>
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

      {selectedShop ? (
        <div className="payment-modal-backdrop" onClick={() => setSelectedShopId(null)}>
          <div
            className="payment-modal shop-management-details-modal"
            onClick={(event) => event.stopPropagation()}
            role="dialog"
            aria-modal="true"
            aria-labelledby="shop-details-modal-title"
          >
            <div className="payment-modal-header shop-management-details-modal-header">
              <div>
                <h3 id="shop-details-modal-title">Shop Details</h3>
                <p>Review entity-level performance, accounts, inventory, and subscription activity from one place.</p>
              </div>
              <button
                type="button"
                className="payment-modal-close"
                onClick={() => setSelectedShopId(null)}
                aria-label="Close shop details modal"
              >
                ×
              </button>
            </div>

            <div className="shop-management-details-modal-body">
              <div className="shop-management-tabs" role="tablist" aria-label="Shop details tabs">
                {detailTabs.map((tab) => (
                  <button
                    key={tab}
                    type="button"
                    className={`shop-management-tab${activeTab === tab ? " shop-management-tab-active" : ""}`}
                    onClick={() => setActiveTab(tab)}
                  >
                    {tab}
                  </button>
                ))}
              </div>
              {renderActiveTabContent()}
            </div>
          </div>
        </div>
      ) : null}
    </>
  );
}
