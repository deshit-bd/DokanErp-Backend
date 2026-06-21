"use client";

import { type ChangeEvent, type FormEvent, useEffect, useMemo, useRef, useState } from "react";
import { FiCheckCircle, FiFolderMinus, FiGrid, FiPauseCircle } from "react-icons/fi";

type CategoryStatus = "ACTIVE" | "INACTIVE" | "ARCHIVED";

type CategoryRow = {
  id: string;
  name: string;
  description: string | null;
  status: CategoryStatus;
  statusLabel: string;
  products: number;
  createdAt: string;
  updatedAt: string;
  createdBy?: { id: string; name: string } | null;
  updatedBy?: { id: string; name: string } | null;
  isGlobal?: boolean;
  isApproved?: boolean;
  shopId?: string | null;
};


type CategoryResponse = {
  stats?: {
    total: number;
    active: number;
    inactive: number;
    empty: number;
  };
  categories?: CategoryRow[];
  category?: CategoryRow;
  message?: string;
};

const emptyStats = {
  total: 0,
  active: 0,
  inactive: 0,
  empty: 0,
};

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

function formatDate(value: string) {
  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  }).format(new Date(value));
}

function getBadgeClass(status: CategoryStatus) {
  if (status === "INACTIVE") {
    return "master-category-status-badge master-category-status-badge-inactive";
  }

  if (status === "ARCHIVED") {
    return "master-category-status-badge master-category-status-badge-archived";
  }

  return "master-category-status-badge";
}

function matchesWithTwoPointers(source: string, query: string) {
  const sourceTokens = source
    .toLowerCase()
    .split(/\s+/)
    .filter(Boolean);
  const queryTokens = query
    .toLowerCase()
    .split(/\s+/)
    .filter(Boolean);

  if (queryTokens.length === 0) {
    return true;
  }

  function isSubsequence(sourceToken: string, queryToken: string) {
    let sourcePointer = 0;
    let queryPointer = 0;

    while (sourcePointer < sourceToken.length && queryPointer < queryToken.length) {
      if (sourceToken[sourcePointer] === queryToken[queryPointer]) {
        queryPointer += 1;
      }

      sourcePointer += 1;
    }

    return queryPointer === queryToken.length;
  }

  let sourcePointer = 0;
  let queryPointer = 0;

  while (sourcePointer < sourceTokens.length && queryPointer < queryTokens.length) {
    if (isSubsequence(sourceTokens[sourcePointer], queryTokens[queryPointer])) {
      queryPointer += 1;
    }

    sourcePointer += 1;
  }

  return queryPointer === queryTokens.length;
}

export default function ProductCategoryPage() {
  const pageSizeOptions = [10, 20, 40];
  const [categories, setCategories] = useState<CategoryRow[]>([]);
  const [stats, setStats] = useState(emptyStats);
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState<"ALL" | CategoryStatus>("ALL");
  const [pageSize, setPageSize] = useState<number | "all">(20);
  const [currentPage, setCurrentPage] = useState(1);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isImporting, setIsImporting] = useState(false);
  const [feedback, setFeedback] = useState("");
  const [error, setError] = useState("");
  const [isCategoryModalOpen, setIsCategoryModalOpen] = useState(false);
  const [openActionMenuId, setOpenActionMenuId] = useState<string | null>(null);
  const [editingCategoryId, setEditingCategoryId] = useState<string | null>(null);
  const [selectedCategoryId, setSelectedCategoryId] = useState<string | null>(null);
  const [formName, setFormName] = useState("");
  const [formDescription, setFormDescription] = useState("");
  const [formStatus, setFormStatus] = useState<CategoryStatus>("ACTIVE");
  const importInputRef = useRef<HTMLInputElement | null>(null);

  const editingCategory = categories.find((row) => row.id === editingCategoryId) ?? null;
  const selectedCategory = categories.find((row) => row.id === selectedCategoryId) ?? null;

  async function loadCategories() {
    setIsLoading(true);

    try {
      const response = await fetch("/api/categories", {
        cache: "no-store",
      });
      const result = (await response.json()) as CategoryResponse;

      if (!response.ok) {
        setError(result.message ?? "Failed to load categories.");
        return;
      }

      setCategories(result.categories ?? []);
      setStats(result.stats ?? emptyStats);
      setError("");
    } catch {
      setError("Unable to load categories right now.");
    } finally {
      setIsLoading(false);
    }
  }

  useEffect(() => {
    void loadCategories();
  }, []);

  useEffect(() => {
    if (!editingCategory) {
      setFormName("");
      setFormDescription("");
      setFormStatus("ACTIVE");
      return;
    }

    setFormName(editingCategory.name);
    setFormDescription(editingCategory.description ?? "");
    setFormStatus(editingCategory.status);
  }, [editingCategory]);

  const filteredCategories = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();

    return categories.filter((row) => {
      const searchableText = `${row.name} ${row.description ?? ""}`;
      const matchesQuery =
        !query ||
        matchesWithTwoPointers(searchableText, query);

      const matchesStatus = statusFilter === "ALL" || row.status === statusFilter;
      return matchesQuery && matchesStatus;
    });
  }, [categories, searchQuery, statusFilter]);

  useEffect(() => {
    setCurrentPage(1);
  }, [searchQuery, statusFilter, pageSize]);

  useEffect(() => {
    const maxPage = Math.max(1, pageSize === "all" ? 1 : Math.ceil(filteredCategories.length / pageSize));

    if (currentPage > maxPage) {
      setCurrentPage(maxPage);
    }
  }, [currentPage, filteredCategories.length, pageSize]);

  const totalPages = pageSize === "all" ? 1 : Math.max(1, Math.ceil(filteredCategories.length / pageSize));
  const pageStartIndex = pageSize === "all" ? 0 : (currentPage - 1) * pageSize;
  const paginatedCategories =
    pageSize === "all" ? filteredCategories : filteredCategories.slice(pageStartIndex, pageStartIndex + pageSize);
  const visibleStart = filteredCategories.length === 0 ? 0 : pageStartIndex + 1;
  const visibleEnd = filteredCategories.length === 0 ? 0 : pageStartIndex + paginatedCategories.length;
  const paginationChips = (() => {
    if (totalPages <= 5) {
      return Array.from({ length: totalPages }, (_, index) => index + 1);
    }

    const start = Math.max(1, Math.min(currentPage - 2, totalPages - 4));
    return Array.from({ length: 5 }, (_, index) => start + index);
  })();

  const categoryStats = [
    { label: "Total Categories", value: String(stats.total), note: "All Categories", accent: "indigo" as const, icon: FiGrid },
    { label: "Active Categories", value: String(stats.active), note: "Active Categories", accent: "green" as const, icon: FiCheckCircle },
    { label: "Inactive Categories", value: String(stats.inactive), note: "Inactive Categories", accent: "amber" as const, icon: FiPauseCircle },
    { label: "Empty Categories", value: String(stats.empty), note: "No Products Assigned", accent: "red" as const, icon: FiFolderMinus },
  ];

  function openCreateModal() {
    setEditingCategoryId(null);
    setFormName("");
    setFormDescription("");
    setFormStatus("ACTIVE");
    setIsCategoryModalOpen(true);
  }

  function openEditModal(categoryId: string) {
    setEditingCategoryId(categoryId);
    setOpenActionMenuId(null);
    setIsCategoryModalOpen(true);
  }

  function closeModal() {
    setIsCategoryModalOpen(false);
    setEditingCategoryId(null);
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setIsSaving(true);
    setFeedback("");
    setError("");

    try {
      const response = await fetch(editingCategory ? `/api/categories/${editingCategory.id}` : "/api/categories", {
        method: editingCategory ? "PATCH" : "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name: formName,
          description: formDescription,
          status: formStatus,
        }),
      });

      const result = (await response.json()) as CategoryResponse;

      if (!response.ok) {
        setError(result.message ?? "Failed to save category.");
        return;
      }

      setFeedback(result.message ?? "Category saved successfully.");
      closeModal();
      await loadCategories();
    } catch {
      setError("Unable to save category right now.");
    } finally {
      setIsSaving(false);
    }
  }

  async function handleArchive(categoryId: string) {
    setFeedback("");
    setError("");
    setOpenActionMenuId(null);

    try {
      const category = categories.find((item) => item.id === categoryId);
      if (!category) {
        return;
      }

      const response = await fetch(`/api/categories/${categoryId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name: category.name,
          description: category.description,
          status: "ARCHIVED",
        }),
      });
      const result = (await response.json()) as CategoryResponse;

      if (!response.ok) {
        setError(result.message ?? "Failed to archive category.");
        return;
      }

      setFeedback(result.message ?? "Category archived successfully.");
      await loadCategories();
    } catch {
      setError("Unable to archive category right now.");
    }
  }

  async function handleDelete(categoryId: string) {
    setFeedback("");
    setError("");
    setOpenActionMenuId(null);

    try {
      const response = await fetch(`/api/categories/${categoryId}`, {
        method: "DELETE",
      });
      const result = (await response.json()) as CategoryResponse;

      if (!response.ok && response.status !== 409) {
        setError(result.message ?? "Failed to delete category.");
        return;
      }

      if (response.status === 409) {
        setFeedback(result.message ?? "Category archived instead of deleted.");
      } else {
        setFeedback(result.message ?? "Category deleted successfully.");
      }

      if (selectedCategoryId === categoryId) {
        setSelectedCategoryId(null);
      }

      await loadCategories();
    } catch {
      setError("Unable to delete category right now.");
    }
  }

  async function handleApprove(categoryId: string) {
    setFeedback("");
    setError("");
    setOpenActionMenuId(null);

    try {
      const response = await fetch(`/api/categories/${categoryId}/approve`, {
        method: "POST",
      });
      const result = (await response.json()) as CategoryResponse;

      if (!response.ok) {
        setError(result.message ?? "Failed to approve category.");
        return;
      }

      setFeedback(result.message ?? "Category approved successfully.");
      await loadCategories();
    } catch {
      setError("Unable to approve category right now.");
    }
  }

  async function handleDuplicate(categoryId: string) {

    const source = categories.find((item) => item.id === categoryId);

    if (!source) {
      return;
    }

    setFeedback("");
    setError("");
    setOpenActionMenuId(null);

    try {
      const response = await fetch("/api/categories", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name: `${source.name} Copy`,
          description: source.description,
          status: source.status,
        }),
      });
      const result = (await response.json()) as CategoryResponse;

      if (!response.ok) {
        setError(result.message ?? "Failed to duplicate category.");
        return;
      }

      setFeedback(result.message ?? "Category duplicated successfully.");
      await loadCategories();
    } catch {
      setError("Unable to duplicate category right now.");
    }
  }

  async function handleImportFileChange(event: ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];
    event.target.value = "";

    if (!file) {
      return;
    }

    setIsImporting(true);
    setFeedback("");
    setError("");

    try {
      const formData = new FormData();
      formData.append("file", file);

      const response = await fetch("/api/categories/import", {
        method: "POST",
        body: formData,
      });
      const result = (await response.json()) as CategoryResponse & { summary?: { created: number; skipped: number } };

      if (!response.ok) {
        setError(result.message ?? "Failed to import categories.");
        return;
      }

      setFeedback(result.message ?? "Categories imported successfully.");
      await loadCategories();
    } catch {
      setError("Unable to import categories right now.");
    } finally {
      setIsImporting(false);
    }
  }

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
          <div className="master-category-toolbar product-category-toolbar">
            <label className="master-category-search">
              <input
                type="text"
                placeholder="Search category name..."
                value={searchQuery}
                onChange={(event) => setSearchQuery(event.target.value)}
              />
            </label>

            <select
              className="master-category-select"
              value={statusFilter}
              onChange={(event) => setStatusFilter(event.target.value as "ALL" | CategoryStatus)}
            >
              <option value="ALL">All Status</option>
              <option value="ACTIVE">Active</option>
              <option value="INACTIVE">Inactive</option>
              <option value="ARCHIVED">Archived</option>
            </select>

            <button type="button" className="master-category-outline-button" onClick={() => void loadCategories()}>
              Refresh
            </button>

            <input
              ref={importInputRef}
              type="file"
              accept=".xlsx,.xls"
              style={{ display: "none" }}
              onChange={(event) => void handleImportFileChange(event)}
            />

            <button
              type="button"
              className="master-category-outline-button product-category-import-button"
              onClick={() => importInputRef.current?.click()}
              disabled={isImporting}
            >
              {isImporting ? "Importing..." : "Upload Categories"}
            </button>

            <button
              type="button"
              className="master-category-primary-button product-category-create-button"
              onClick={openCreateModal}
            >
              Add New Category +
            </button>
          </div>

          {feedback ? <p className="profile-form-feedback profile-form-feedback-success">{feedback}</p> : null}
          {error ? <p className="profile-form-feedback profile-form-feedback-error">{error}</p> : null}

          {isLoading ? (
            <div className="master-category-table-empty">
              <strong>Loading categories...</strong>
              <p>We are pulling the latest category records from the database.</p>
            </div>
          ) : filteredCategories.length === 0 ? (
            <div className="master-category-table-empty">
              <strong>No categories found</strong>
              <p>Try a different search or create a new category.</p>
            </div>
          ) : (
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

              {paginatedCategories.map((row, index) => (
                <div className="master-category-table-row" key={row.id}>
                  <span>{pageStartIndex + index + 1}</span>
                  <span className="master-category-name-cell">{row.name}</span>
                  <span>{row.description || "No description"}</span>
                  <span>{row.products}</span>
                  <span>
                    <span style={{ display: "flex", flexDirection: "column", gap: "4px", alignItems: "flex-start" }}>
                      <em className={getBadgeClass(row.status)}>{row.statusLabel}</em>
                      {row.isApproved === false ? (
                        <em className="master-category-status-badge master-category-status-badge-pending">Pending Approval</em>
                      ) : null}
                    </span>
                  </span>
                  <span>{formatDate(row.createdAt)}</span>
                  <span className="master-category-actions">
                    <button
                      type="button"
                      className="master-category-icon-button master-category-icon-button-edit"
                      onClick={() => openEditModal(row.id)}
                    >
                      <MasterCategoryActionIcon type="edit" />
                    </button>
                    <span className="master-category-action-menu">
                      <button
                        type="button"
                        className="master-category-icon-button master-category-icon-button-more"
                        onClick={() => setOpenActionMenuId((current) => (current === row.id ? null : row.id))}
                        aria-haspopup="menu"
                        aria-expanded={openActionMenuId === row.id}
                      >
                        <MasterCategoryActionIcon type="more" />
                      </button>

                      {openActionMenuId === row.id ? (
                        <div className="master-category-action-dropdown" role="menu">
                          {row.isApproved === false ? (
                            <button
                              type="button"
                              className="master-category-action-dropdown-item"
                              style={{ color: "#0b7a57", fontWeight: "bold" }}
                              role="menuitem"
                              onClick={() => void handleApprove(row.id)}
                            >
                              Approve Category
                            </button>
                          ) : null}
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
                          <button
                            type="button"
                            className="master-category-action-dropdown-item"
                            role="menuitem"
                            onClick={() => void handleDuplicate(row.id)}
                          >
                            Duplicate Category
                          </button>
                          <button
                            type="button"
                            className="master-category-action-dropdown-item"
                            role="menuitem"
                            onClick={() => void handleArchive(row.id)}
                          >
                            Archive Category
                          </button>
                          <button
                            type="button"
                            className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                            role="menuitem"
                            onClick={() => void handleDelete(row.id)}
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
          )}

          <div className="master-category-footer">
            <span className="master-category-footer-text">
              Showing {visibleStart}-{visibleEnd} of {filteredCategories.length} categories
            </span>

            <div className="master-category-pagination">
              <button
                type="button"
                className="master-category-page-button"
                onClick={() => setCurrentPage((page) => Math.max(1, page - 1))}
                disabled={currentPage === 1 || totalPages <= 1}
              >
                Prev
              </button>
              {paginationChips.map((page) => (
                <button
                  key={page}
                  type="button"
                  className={`master-category-page-chip${page === currentPage ? " master-category-page-chip-active" : ""}`}
                  onClick={() => setCurrentPage(page)}
                  aria-current={page === currentPage ? "page" : undefined}
                >
                  {page}
                </button>
              ))}
              <button
                type="button"
                className="master-category-page-button"
                onClick={() => setCurrentPage((page) => Math.min(totalPages, page + 1))}
                disabled={currentPage === totalPages || totalPages <= 1}
              >
                Next
              </button>
            </div>

            <select
              className="master-category-page-size"
              value={String(pageSize)}
              onChange={(event) => {
                const value = event.target.value;
                setPageSize(value === "all" ? "all" : Number(value));
              }}
            >
              {pageSizeOptions.map((option) => (
                <option key={option} value={option}>
                  {option} / page
                </option>
              ))}
              <option value="all">All</option>
            </select>
          </div>
        </section>
      </section>

      {isCategoryModalOpen ? (
        <div className="payment-modal-backdrop" onClick={closeModal}>
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
              <button type="button" className="payment-modal-close" onClick={closeModal} aria-label="Close modal">
                ×
              </button>
            </div>

            <form className="category-modal-form" onSubmit={handleSubmit}>
              <label className="master-category-form-field">
                <span>Category Name *</span>
                <input type="text" placeholder="Write the category name" value={formName} onChange={(event) => setFormName(event.target.value)} />
              </label>

              <label className="master-category-form-field">
                <span>Description</span>
                <textarea placeholder="Write category description" value={formDescription} onChange={(event) => setFormDescription(event.target.value)} />
              </label>

              <label className="master-category-form-field">
                <span>Status *</span>
                <select value={formStatus} onChange={(event) => setFormStatus(event.target.value as CategoryStatus)}>
                  <option value="ACTIVE">Active</option>
                  <option value="INACTIVE">Inactive</option>
                  <option value="ARCHIVED">Archived</option>
                </select>
              </label>

              <div className="master-category-form-actions">
                <button type="button" className="master-category-reset-button" onClick={closeModal}>
                  Cancel
                </button>
                <button type="submit" className="master-category-save-button" disabled={isSaving}>
                  {isSaving ? "Saving..." : editingCategory ? "Update Category" : "Save Category"}
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
                <p>{selectedCategory.description || "No description provided."}</p>
              </div>

              <div className="master-category-details-grid">
                <div className="master-category-details-card">
                  <span className="master-category-details-label">Total Products</span>
                  <strong>{selectedCategory.products}</strong>
                </div>

                <div className="master-category-details-card">
                  <span className="master-category-details-label">Status</span>
                  <em className={getBadgeClass(selectedCategory.status)}>{selectedCategory.statusLabel}</em>
                </div>
              </div>

              <div className="master-category-details-grid">
                <div className="master-category-details-card" style={{ gridColumn: "1 / -1" }}>
                  <span className="master-category-details-label">Approval Status</span>
                  {selectedCategory.isApproved === false ? (
                    <div style={{ display: "flex", alignItems: "center", gap: "8px", marginTop: "4px" }}>
                      <em className="master-category-status-badge master-category-status-badge-pending">Pending Approval</em>
                      <button
                        type="button"
                        className="master-category-primary-button"
                        style={{ padding: "4px 12px", fontSize: "0.75rem", background: "#0b7a57", color: "#fff", border: "none", borderRadius: "4px", cursor: "pointer" }}
                        onClick={() => {
                          void handleApprove(selectedCategory.id);
                          setSelectedCategoryId(null);
                        }}
                      >
                        Approve Request
                      </button>
                    </div>
                  ) : (
                    <em className="master-category-status-badge" style={{ marginTop: "4px" }}>Approved (Global)</em>
                  )}
                </div>
              </div>

              <div className="master-category-details-grid">
                <div className="master-category-details-card">
                  <span className="master-category-details-label">Created Date</span>
                  <strong>{formatDate(selectedCategory.createdAt)}</strong>
                </div>

                <div className="master-category-details-card">
                  <span className="master-category-details-label">Updated Date</span>
                  <strong>{formatDate(selectedCategory.updatedAt)}</strong>
                </div>
              </div>

            </div>
          </aside>
        </>
      ) : null}
    </>
  );
}
