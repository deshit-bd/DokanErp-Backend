"use client";

import { useState } from "react";

const supplierStats = [
  { label: "Total Suppler", value: "4516", note: "All Suppler", accent: "indigo" as const, type: "users" as const },
  { label: "Active Suppler", value: "4500", note: "Active Suppler", accent: "green" as const, type: "check" as const },
  { label: "Unused Suppler", value: "16", note: "All Unused Suppler", accent: "amber" as const, type: "close" as const },
  { label: "Block Suppler", value: "12,684", note: "All Block", accent: "blue" as const, type: "shield" as const },
];

const supplierRows = Array.from({ length: 11 }, (_, index) => ({
  id: index + 1,
  code: "SUO-001",
  name: "All Arafa Trad",
  mobile: "01245-4552",
  email: "allarafa@gmail.com",
  address: "Dhaka",
  status: "Active",
  date: "31 may 2024",
}));

function SupplierStatIcon({
  accent,
  type,
}: {
  accent: "indigo" | "green" | "amber" | "blue";
  type: "users" | "check" | "close" | "shield";
}) {
  return (
    <span className={`master-category-stat-icon master-category-stat-icon-${accent}`} aria-hidden="true">
      <svg viewBox="0 0 24 24">
        {type === "users" ? (
          <>
            <path
              d="M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M15.5 10a2.5 2.5 0 1 0 0-5"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M4.5 19a4.5 4.5 0 0 1 9 0"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M14.5 18a3.5 3.5 0 0 1 5-2.3"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </>
        ) : null}

        {type === "check" ? (
          <>
            <circle cx="12" cy="12" r="8.5" fill="none" stroke="currentColor" strokeWidth="1.8" />
            <path
              d="m8.6 12.1 2.1 2.1 4.7-4.9"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </>
        ) : null}

        {type === "close" ? (
          <>
            <path
              d="m8 8 8 8"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="m16 8-8 8"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </>
        ) : null}

        {type === "shield" ? (
          <>
            <path
              d="M12 3 5 6v5c0 4.6 2.7 7.8 7 10 4.3-2.2 7-5.4 7-10V6l-7-3Z"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M12 8v5"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
            />
            <path
              d="M12 16h.01"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
            />
          </>
        ) : null}
      </svg>
    </span>
  );
}

function SupplierActionIcon({ type }: { type: "edit" | "more" }) {
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

export default function SupplierDataPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <>
      <section className="master-category-page">
        <div className="master-category-stats">
          {supplierStats.map((item) => (
            <article className="master-category-stat-card" key={item.label}>
              <SupplierStatIcon accent={item.accent} type={item.type} />
              <div className="master-category-stat-copy">
                <strong>{item.label}</strong>
                <span>{item.value}</span>
                <small>{item.note}</small>
              </div>
            </article>
          ))}
        </div>

        <section className="master-category-table-card">
          <div className="master-category-toolbar supplier-data-toolbar">
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

            <button type="button" className="master-category-primary-button" onClick={() => setIsModalOpen(true)}>
              Add New Suppler +
            </button>
          </div>

          <div className="supplier-data-table">
            <div className="supplier-data-table-head">
              <span>#</span>
              <span>Suppler Code</span>
              <span>Suppler Name</span>
              <span>Mobile</span>
              <span>Email</span>
              <span>Address</span>
              <span>Status</span>
              <span>Date</span>
              <span>Action</span>
            </div>

            {supplierRows.map((row) => (
              <div className="supplier-data-table-row" key={row.id}>
                <span>{row.id}</span>
                <span>{row.code}</span>
                <span>{row.name}</span>
                <span>{row.mobile}</span>
                <span>{row.email}</span>
                <span>{row.address}</span>
                <span>
                  <em className="master-category-status-badge">{row.status}</em>
                </span>
                <span>{row.date}</span>
                <span className="master-category-actions">
                  <button type="button" className="master-category-icon-button master-category-icon-button-edit">
                    <SupplierActionIcon type="edit" />
                  </button>
                  <button type="button" className="master-category-icon-button master-category-icon-button-more">
                    <SupplierActionIcon type="more" />
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

      {isModalOpen ? (
        <div className="payment-modal-backdrop" onClick={() => setIsModalOpen(false)}>
          <div
            className="payment-modal supplier-modal"
            onClick={(event) => event.stopPropagation()}
            role="dialog"
            aria-modal="true"
            aria-labelledby="supplier-modal-title"
          >
            <div className="payment-modal-header supplier-modal-header">
              <div>
                <h3 id="supplier-modal-title">Add New Suppler</h3>
              </div>
              <button
                type="button"
                className="payment-modal-close"
                onClick={() => setIsModalOpen(false)}
                aria-label="Close modal"
              >
                ×
              </button>
            </div>

            <form className="payment-modal-form supplier-modal-form">
              <label className="payment-modal-field">
                <span>Suppler Code</span>
                <input type="text" placeholder="Enter suppler code (SUP-001)" />
              </label>

              <label className="payment-modal-field">
                <span>Suppler Name</span>
                <input type="text" placeholder="Enter suppler name" />
              </label>

              <label className="payment-modal-field">
                <span>Mobile Number</span>
                <input type="text" placeholder="Enter mobile number" />
              </label>

              <label className="payment-modal-field">
                <span>Email</span>
                <input type="email" placeholder="Enter email" />
              </label>

              <label className="payment-modal-field payment-modal-field-full">
                <span>Address</span>
                <textarea placeholder="Enter all address" />
              </label>

              <label className="payment-modal-field">
                <span>Contact Person</span>
                <input type="text" placeholder="Enter contact person name" />
              </label>

              <label className="payment-modal-field">
                <span>Condition</span>
                <select defaultValue="Active">
                  <option>Active</option>
                  <option>Inactive</option>
                </select>
              </label>

              <label className="payment-modal-field payment-modal-field-full">
                <span>Comment</span>
                <textarea placeholder="Write your comment" />
              </label>

              <div className="payment-modal-actions supplier-modal-actions">
                <button
                  type="button"
                  className="payment-modal-secondary-button"
                  onClick={() => setIsModalOpen(false)}
                >
                  Reset
                </button>
                <button type="button" className="payment-modal-primary-button">
                  + Add Supplier
                </button>
              </div>
            </form>
          </div>
        </div>
      ) : null}
    </>
  );
}
