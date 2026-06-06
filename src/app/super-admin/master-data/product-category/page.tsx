"use client";

import { useState } from "react";
import { FiCheckCircle, FiFolderMinus, FiGrid, FiPauseCircle } from "react-icons/fi";

const categoryStats = [
  { label: "Total Categories", value: "24", note: "All Categories", accent: "indigo" as const, icon: FiGrid },
  { label: "Active Categories", value: "20", note: "Active Categories", accent: "green" as const, icon: FiCheckCircle },
  { label: "Inactive Categories", value: "3", note: "Inactive Categories", accent: "amber" as const, icon: FiPauseCircle },
  { label: "Empty Categories", value: "1", note: "No Products Assigned", accent: "red" as const, icon: FiFolderMinus },
];

const categoryRows = [
  { id: 1, name: "Beverages", description: "Soft drinks, juices, and bottled water", products: "244", status: "Active", createdDate: "31 May 2024", updatedDate: "02 Jun 2024" },
  { id: 2, name: "Snacks", description: "Chips, biscuits, and packaged snacks", products: "132", status: "Active", createdDate: "30 May 2024", updatedDate: "01 Jun 2024" },
  { id: 3, name: "Dairy", description: "Milk, yogurt, butter, and cheese", products: "86", status: "Active", createdDate: "29 May 2024", updatedDate: "31 May 2024" },
  { id: 4, name: "Frozen Foods", description: "Frozen meat, vegetables, and ready meals", products: "58", status: "Active", createdDate: "28 May 2024", updatedDate: "30 May 2024" },
  { id: 5, name: "Personal Care", description: "Soap, shampoo, and hygiene essentials", products: "176", status: "Active", createdDate: "27 May 2024", updatedDate: "29 May 2024" },
  { id: 6, name: "Household", description: "Cleaning supplies and home essentials", products: "121", status: "Active", createdDate: "26 May 2024", updatedDate: "28 May 2024" },
  { id: 7, name: "Baby Care", description: "Baby food, diapers, and accessories", products: "74", status: "Active", createdDate: "25 May 2024", updatedDate: "27 May 2024" },
  { id: 8, name: "Stationery", description: "Pens, notebooks, and office materials", products: "34", status: "Active", createdDate: "24 May 2024", updatedDate: "26 May 2024" },
  { id: 9, name: "Pet Supplies", description: "Food, treats, and pet care products", products: "19", status: "Active", createdDate: "23 May 2024", updatedDate: "25 May 2024" },
  { id: 10, name: "Seasonal Items", description: "Occasional and holiday-based products", products: "0", status: "Inactive", createdDate: "22 May 2024", updatedDate: "24 May 2024" },
  { id: 11, name: "Bakery", description: "Bread, buns, and baked snacks", products: "63", status: "Active", createdDate: "21 May 2024", updatedDate: "23 May 2024" },
];

function ProductCategoryStatIcon({
  accent,
  icon: Icon,
}: {
  accent: "indigo" | "green" | "amber" | "red";
  icon: typeof FiGrid;
}) {
  return (
    <span className={`master-category-stat-icon master-category-stat-icon-${accent}`} aria-hidden="true">
      <Icon />
    </span>
  );
}

function CategoryRowIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M4.5 8.5h6l1.6 2h7.4v7.5H4.5z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M4.5 8.5V6.5h5.3l1.6 2"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function MasterCategoryActionIcon({ type }: { type: "edit" | "more" }) {
  if (type === "more") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle cx="12" cy="6" r="1.2" fill="currentColor" />
        <circle cx="12" cy="12" r="1.2" fill="currentColor" />
        <circle cx="12" cy="18" r="1.2" fill="currentColor" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="m4 20 4.5-1 9-9-3.5-3.5-9 9L4 20Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="m12.8 6.7 3.5 3.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

const iconColors = ["green", "blue", "orange", "violet", "pink", "sky", "amber", "lime"] as const;

export default function ProductCategoryPage() {
  const [isCategoryModalOpen, setIsCategoryModalOpen] = useState(false);
  const [openActionMenuId, setOpenActionMenuId] = useState<number | null>(null);
  const [editingCategoryId, setEditingCategoryId] = useState<number | null>(null);
  const [selectedCategoryId, setSelectedCategoryId] = useState<number | null>(null);
  const editingCategory = categoryRows.find((row) => row.id === editingCategoryId) ?? null;
  const selectedCategory = categoryRows.find((row) => row.id === selectedCategoryId) ?? null;

  return (
    <>
      <section className="master-category-page">
        <div className="master-category-stats">
          {categoryStats.map((item) => (
            <article className="master-category-stat-card" key={item.label}>
              <ProductCategoryStatIcon accent={item.accent} icon={item.icon} />
              <div className="master-category-stat-copy">
                <strong>{item.label}</strong>
                <span>{item.value}</span>
                <small>{item.note}</small>
              </div>
            </article>
          ))}
        </div>

        <section className="master-category-table-card">
          <div className="master-category-toolbar">
            <label className="master-category-search">
              <input type="text" placeholder="Search category name..." />
            </label>

            <select className="master-category-select" defaultValue="All Status">
              <option>All Status</option>
            </select>

            <button type="button" className="master-category-outline-button">
              Filter
            </button>

            <button type="button" className="master-category-outline-button">
              Refresh
            </button>

            <button
              type="button"
              className="master-category-primary-button"
              onClick={() => {
                setEditingCategoryId(null);
                setIsCategoryModalOpen(true);
              }}
            >
              Add New Category +
            </button>
          </div>

          <div className="master-category-table">
            <div className="master-category-table-head">
              <span>#</span>
              <span>Category Name</span>
              <span>Description</span>
              <span>Products</span>
              <span>Status</span>
              <span>Created Date</span>
              <span>Actions</span>
            </div>

            {categoryRows.map((row) => (
              <div className="master-category-table-row" key={row.id}>
                <span>{row.id}</span>
                <span className="master-category-name-cell">
                  <span className="master-category-name-icon">
                    <CategoryRowIcon />
                  </span>
                  <span>{row.name}</span>
                </span>
                <span>{row.description}</span>
                <span>{row.products}</span>
                <span>
                  <em
                    className={`master-category-status-badge${
                      row.status === "Inactive" ? " master-category-status-badge-inactive" : ""
                    }`}
                  >
                    {row.status}
                  </em>
                </span>
                <span>{row.createdDate}</span>
                <span className="master-category-actions">
                  <button
                    type="button"
                    className="master-category-icon-button master-category-icon-button-edit"
                    onClick={() => {
                      setEditingCategoryId(row.id);
                      setOpenActionMenuId(null);
                      setIsCategoryModalOpen(true);
                    }}
                  >
                    <MasterCategoryActionIcon type="edit" />
                  </button>
                  <span className="master-category-action-menu">
                    <button
                      type="button"
                      className="master-category-icon-button master-category-icon-button-more"
                      onClick={() =>
                        setOpenActionMenuId((current) => (current === row.id ? null : row.id))
                      }
                      aria-haspopup="menu"
                      aria-expanded={openActionMenuId === row.id}
                    >
                      <MasterCategoryActionIcon type="more" />
                    </button>

                    {openActionMenuId === row.id ? (
                      <div className="master-category-action-dropdown" role="menu">
                        <button
                          type="button"
                          className="master-category-action-dropdown-item"
                          role="menuitem"
                          onClick={() => {
                            setSelectedCategoryId(row.id);
                            setOpenActionMenuId(null);
                          }}
                        >
                          View Details
                        </button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          Duplicate Category
                        </button>
                        <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                          Archive Category
                        </button>
                        <button
                          type="button"
                          className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                          role="menuitem"
                        >
                          Delete Category
                        </button>
                      </div>
                    ) : null}
                  </span>
                </span>
              </div>
            ))}
          </div>

          <div className="master-category-footer">
            <span className="master-category-footer-text">Showing 5,842 products total</span>

            <div className="master-category-pagination">
              <button type="button" className="master-category-page-button">{"<"} Preview</button>
              <button type="button" className="master-category-page-chip master-category-page-chip-active">1</button>
              <button type="button" className="master-category-page-chip">2</button>
              <button type="button" className="master-category-page-chip">...</button>
              <button type="button" className="master-category-page-chip">150</button>
              <button type="button" className="master-category-page-button">Next Page {">"}</button>
            </div>

            <select className="master-category-page-size" defaultValue="11">
              <option>11</option>
            </select>
          </div>
        </section>
      </section>

      {isCategoryModalOpen ? (
        <div className="payment-modal-backdrop" onClick={() => setIsCategoryModalOpen(false)}>
          <div
            className="payment-modal category-modal"
            onClick={(event) => event.stopPropagation()}
            role="dialog"
            aria-modal="true"
            aria-labelledby="category-modal-title"
          >
            <div className="payment-modal-header category-modal-header">
              <div>
                <h3 id="category-modal-title">{editingCategory ? "Edit Category" : "Add New Category"}</h3>
              </div>
              <button
                type="button"
                className="payment-modal-close"
                onClick={() => {
                  setIsCategoryModalOpen(false);
                  setEditingCategoryId(null);
                }}
                aria-label="Close modal"
              >
                ×
              </button>
            </div>

            <form className="category-modal-form">
              <label className="master-category-form-field">
                <span>Category Name *</span>
                <input type="text" placeholder="Write the category name" defaultValue={editingCategory?.name ?? ""} />
              </label>

              <label className="master-category-form-field">
                <span>Description</span>
                <textarea placeholder="Write category description" defaultValue={editingCategory?.description ?? ""} />
              </label>

              <div className="master-category-form-field">
                <span>Category Icon (Optional)</span>
                <div className="master-category-icon-grid">
                  {iconColors.map((color, index) => (
                    <button
                      type="button"
                      key={`${color}-${index}`}
                      className={`master-category-picker-button master-category-picker-button-${color}`}
                    >
                      <CategoryRowIcon />
                    </button>
                  ))}
                </div>
              </div>

              <label className="master-category-form-field">
                <span>Status *</span>
                <select defaultValue={editingCategory?.status ?? "Active"}>
                  <option>Active</option>
                  <option>Inactive</option>
                </select>
              </label>

              {editingCategory ? (
                <div className="category-modal-meta">
                  <strong>Optional Read-Only Information</strong>
                  <div className="category-modal-meta-grid">
                    <span>Created: {editingCategory.createdDate}</span>
                    <span>Last Updated: {editingCategory.updatedDate}</span>
                    <span>Products: {editingCategory.products}</span>
                  </div>
                </div>
              ) : null}

              <div className="master-category-form-actions">
                <button
                  type="button"
                  className="master-category-reset-button"
                  onClick={() => {
                    setIsCategoryModalOpen(false);
                    setEditingCategoryId(null);
                  }}
                >
                  Cancel
                </button>
                <button type="button" className="master-category-save-button">
                  {editingCategory ? "Update Category" : "Save Category"}
                </button>
              </div>
            </form>
          </div>
        </div>
      ) : null}

      {selectedCategory ? (
        <>
          <button
            type="button"
            className="master-category-details-backdrop"
            onClick={() => {
              setSelectedCategoryId(null);
              setOpenActionMenuId(null);
            }}
            aria-label="Close category details"
          />
          <aside
            className="master-category-details-drawer"
            role="dialog"
            aria-modal="true"
            aria-labelledby="category-details-title"
          >
            <div className="master-category-details-header">
              <div>
                <span className="master-category-details-eyebrow">Category Details</span>
                <h3 id="category-details-title">{selectedCategory.name}</h3>
              </div>
              <button
                type="button"
                className="master-category-details-close"
                onClick={() => setSelectedCategoryId(null)}
                aria-label="Close category details"
              >
                ×
              </button>
            </div>

            <div className="master-category-details-body">
              <div className="master-category-details-card">
                <span className="master-category-details-label">Category Name</span>
                <strong>{selectedCategory.name}</strong>
              </div>

              <div className="master-category-details-card">
                <span className="master-category-details-label">Description</span>
                <p>{selectedCategory.description}</p>
              </div>

              <div className="master-category-details-grid">
                <div className="master-category-details-card">
                  <span className="master-category-details-label">Total Products</span>
                  <strong>{selectedCategory.products}</strong>
                </div>

                <div className="master-category-details-card">
                  <span className="master-category-details-label">Status</span>
                  <em
                    className={`master-category-status-badge${
                      selectedCategory.status === "Inactive" ? " master-category-status-badge-inactive" : ""
                    }`}
                  >
                    {selectedCategory.status}
                  </em>
                </div>
              </div>

              <div className="master-category-details-grid">
                <div className="master-category-details-card">
                  <span className="master-category-details-label">Created Date</span>
                  <strong>{selectedCategory.createdDate}</strong>
                </div>

                <div className="master-category-details-card">
                  <span className="master-category-details-label">Updated Date</span>
                  <strong>{selectedCategory.updatedDate}</strong>
                </div>
              </div>
            </div>
          </aside>
        </>
      ) : null}
    </>
  );
}
