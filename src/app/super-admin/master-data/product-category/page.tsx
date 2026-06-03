"use client";

import { useState } from "react";

const categoryStats = [
  { label: "Total Category", value: "24", note: "All Category", accent: "indigo" as const },
  { label: "Active Category", value: "20", note: "Active", accent: "green" as const },
  { label: "Inactive Category", value: "3", note: "Temporary Close", accent: "amber" as const },
  { label: "Cancel Category", value: "1", note: "Cancelled", accent: "red" as const },
];

const categoryRows = [
  { id: 1, name: "Health Support", description: "description", donors: "244", donation: "12,34,654", status: "Active" },
  { id: 2, name: "Health Support", description: "description", donors: "244", donation: "12,34,654", status: "Active" },
  { id: 3, name: "Health Support", description: "description", donors: "244", donation: "12,34,654", status: "Active" },
  { id: 4, name: "Health Support", description: "description", donors: "244", donation: "12,34,654", status: "Active" },
  { id: 5, name: "Health Support", description: "description", donors: "244", donation: "12,34,654", status: "Active" },
  { id: 6, name: "Health Support", description: "description", donors: "244", donation: "12,34,654", status: "Active" },
  { id: 7, name: "Health Support", description: "description", donors: "244", donation: "12,34,654", status: "Active" },
  { id: 8, name: "Health Support", description: "description", donors: "244", donation: "12,34,654", status: "Active" },
  { id: 9, name: "Health Support", description: "description", donors: "244", donation: "12,34,654", status: "Active" },
  { id: 10, name: "Health Support", description: "description", donors: "244", donation: "12,34,654", status: "Inactive" },
  { id: 11, name: "Health Support", description: "description", donors: "244", donation: "12,34,654", status: "Active" },
];

function ProductCategoryStatIcon({ accent }: { accent: "indigo" | "green" | "amber" | "red" }) {
  return (
    <span className={`master-category-stat-icon master-category-stat-icon-${accent}`} aria-hidden="true">
      <svg viewBox="0 0 24 24">
        <circle cx="12" cy="12" r="8.5" fill="none" stroke="currentColor" strokeWidth="1.8" />
        <path
          d="m8.6 12.1 2.1 2.1 4.7-4.9"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
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

  return (
    <>
      <section className="master-category-page">
        <div className="master-category-stats">
          {categoryStats.map((item) => (
            <article className="master-category-stat-card" key={item.label}>
              <ProductCategoryStatIcon accent={item.accent} />
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
              <input type="text" placeholder="Search Supplier or Brand name..." />
            </label>

            <select className="master-category-select" defaultValue="All categories">
              <option>All categories</option>
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
              onClick={() => setIsCategoryModalOpen(true)}
            >
              Add New Category +
            </button>
          </div>

          <div className="master-category-table">
            <div className="master-category-table-head">
              <span>#</span>
              <span>Category Name</span>
              <span>Description</span>
              <span>Number of Donners</span>
              <span>Total Donation</span>
              <span>Status</span>
              <span>Action</span>
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
                <span>{row.donors}</span>
                <span>{row.donation}</span>
                <span>
                  <em
                    className={`master-category-status-badge${
                      row.status === "Inactive" ? " master-category-status-badge-inactive" : ""
                    }`}
                  >
                    {row.status}
                  </em>
                </span>
                <span className="master-category-actions">
                  <button type="button" className="master-category-icon-button master-category-icon-button-edit">
                    <MasterCategoryActionIcon type="edit" />
                  </button>
                  <button type="button" className="master-category-icon-button master-category-icon-button-more">
                    <MasterCategoryActionIcon type="more" />
                  </button>
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
                <h3 id="category-modal-title">Add New Category</h3>
              </div>
              <button
                type="button"
                className="payment-modal-close"
                onClick={() => setIsCategoryModalOpen(false)}
                aria-label="Close modal"
              >
                ×
              </button>
            </div>

            <form className="category-modal-form">
              <label className="master-category-form-field">
                <span>Category Name *</span>
                <input type="text" placeholder="Write the category name" />
              </label>

              <label className="master-category-form-field">
                <span>Comment</span>
                <textarea placeholder="Write your comment" />
              </label>

              <div className="master-category-form-field">
                <span>Select Icon *</span>
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
                <select defaultValue="Active">
                  <option>Active</option>
                  <option>Inactive</option>
                </select>
              </label>

              <label className="master-category-form-field">
                <span>Sending Order *</span>
                <input type="text" placeholder="Sending order" />
                <small>Sending order</small>
              </label>

              <div className="master-category-form-actions">
                <button
                  type="button"
                  className="master-category-reset-button"
                  onClick={() => setIsCategoryModalOpen(false)}
                >
                  Reset
                </button>
                <button type="button" className="master-category-save-button">Save Change</button>
              </div>
            </form>
          </div>
        </div>
      ) : null}
    </>
  );
}
