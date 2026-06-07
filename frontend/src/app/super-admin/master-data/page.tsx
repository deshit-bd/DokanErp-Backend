"use client";

import { useState } from "react";
import { FiCopy, FiCreditCard, FiFileText, FiGrid, FiPackage, FiShield, FiUser } from "react-icons/fi";
import { LuBarcode, LuWallet } from "react-icons/lu";

type ModuleKey =
  | "product-category"
  | "product-catalog"
  | "brand"
  | "unit"
  | "barcode-database"
  | "money-box"
  | "supplier-data"
  | "bank-account"
  | "product-template";

const masterDataFilters: Array<{ key: ModuleKey; label: string }> = [
  { key: "product-category", label: "Product Category" },
  { key: "product-catalog", label: "Product Catalog" },
  { key: "brand", label: "Brand" },
  { key: "unit", label: "Unit" },
  { key: "barcode-database", label: "Barcode Database" },
  { key: "money-box", label: "Money Box" },
  { key: "supplier-data", label: "Supplier Data" },
  { key: "bank-account", label: "Bank Account" },
  { key: "product-template", label: "Product Template" },
];

const masterDataStats = [
  { label: "Total Categories", value: "254", metaLabel: "Active", metaValue: "24", accent: "indigo", icon: FiGrid },
  { label: "Total Products", value: "4,516", metaLabel: "Active", metaValue: "4,500", accent: "green", icon: FiPackage },
  { label: "Total Brands", value: "156", metaLabel: "Active", metaValue: "143", accent: "violet", icon: FiShield },
  { label: "Total Units", value: "156", metaLabel: "Active", metaValue: "143", accent: "gold", icon: FiCopy },
  { label: "Total Barcodes", value: "98,765", metaLabel: "Mapped", metaValue: "87,432", accent: "sky", icon: LuBarcode },
  { label: "Total Money Boxes", value: "16", metaLabel: "Active", metaValue: "14", accent: "emerald", icon: LuWallet },
  { label: "Total Suppliers", value: "4,516", metaLabel: "Active", metaValue: "4,500", accent: "blue", icon: FiUser },
  { label: "Total Accounts", value: "32", metaLabel: "Active", metaValue: "28", accent: "slate", icon: FiCreditCard },
  { label: "Total Templates", value: "25", metaLabel: "Active", metaValue: "22", accent: "rose", icon: FiFileText },
];

const categoryRows = [
  { id: 1, name: "Sugar", description: "Sugar and sweetener products", products: 32, status: "Active", createdDate: "31 may 2024" },
  { id: 2, name: "Oil", description: "Cooking oils and ghee", products: 18, status: "Active", createdDate: "29 may 2024" },
  { id: 3, name: "Snacks", description: "Chips, biscuits, and treats", products: 0, status: "Inactive", createdDate: "27 may 2024" },
];

const productCatalogRows = [
  { id: 1, name: "Sugar (White)", note: "Premium quality", category: "Sugar", brand: "Fresh", unit: "1 KG", barcode: "8901234567001", purchasePrice: "$45", sellingPrice: "$50", status: "Active" },
  { id: 2, name: "Soybean Oil", note: "5 liter bottle", category: "Oil", brand: "Teer", unit: "5 LT", barcode: "8901234567002", purchasePrice: "$820", sellingPrice: "$850", status: "Active" },
  { id: 3, name: "Orange Juice", note: "Natural fruit drink", category: "Beverages", brand: "Pran", unit: "1 LT", barcode: "8901234567007", purchasePrice: "$105", sellingPrice: "$125", status: "Inactive" },
];

const brandRows = [
  { id: 1, brandName: "PRAN", description: "Food & beverage products", categories: 8, products: 232, status: "Active", createdDate: "31 may 2024" },
  { id: 2, brandName: "Fresh", description: "Dairy & grocery products", categories: 5, products: 145, status: "Active", createdDate: "29 may 2024" },
  { id: 3, brandName: "Unilever", description: "Household & personal care", categories: 7, products: 76, status: "Archived", createdDate: "12 may 2024" },
];

const unitRows = [
  { id: 1, name: "Piece", shortName: "Pcs", type: "Countable", description: "Count as pieces", status: "Active", date: "31 may 2024" },
  { id: 2, name: "KG", shortName: "KG", type: "Weight", description: "Weight measurement", status: "Active", date: "30 may 2024" },
  { id: 3, name: "Liter", shortName: "LT", type: "Volume", description: "Liquid measurement", status: "Inactive", date: "29 may 2024" },
];

const barcodeRows = [
  { id: 1, barcode: "79359426436872", productName: "Sugar (White)", sku: "PRD-0001", category: "Sugar", brand: "Fresh", unit: "1 KG", status: "Mapped", date: "30 may 2024" },
  { id: 2, barcode: "79359426436873", productName: "Soybean Oil", sku: "PRD-0002", category: "Oil", brand: "Teer", unit: "5 LT", status: "Unmapped", date: "29 may 2024" },
  { id: 3, barcode: "79359426436874", productName: "Detergent Powder", sku: "PRD-0003", category: "Household", brand: "Wheel", unit: "2 KG", status: "Archived", date: "28 may 2024" },
];

const moneyBoxRows = [
  { id: 1, shopName: "Main Outlet", boxName: "Cash Counter", code: "CASH-001", type: "Cash", balance: "৳54,420", status: "Active", date: "31 may 2024" },
  { id: 2, shopName: "Gazipur Store", boxName: "Bkash Wallet", code: "BKS-002", type: "Bkash", balance: "৳12,850", status: "Active", date: "30 may 2024" },
  { id: 3, shopName: "Tongi Store", boxName: "Nagad Drawer", code: "NGD-003", type: "Nagad", balance: "৳0", status: "Inactive", date: "28 may 2024" },
];

const supplierRows = [
  { id: 1, code: "SUP-001", name: "All Arafa Trade", mobile: "01245-4552", email: "allarafa@gmail.com", address: "Dhaka", status: "Active", date: "31 may 2024" },
  { id: 2, code: "SUP-002", name: "Fresh Foods BD", mobile: "01711-123456", email: "freshfoods@gmail.com", address: "Gazipur", status: "Active", date: "30 may 2024" },
  { id: 3, code: "SUP-003", name: "Daily Needs Ltd", mobile: "01844-998877", email: "dailyneeds@gmail.com", address: "Tongi", status: "Blocked", date: "28 may 2024" },
];

const bankRows = [
  { id: 1, storeName: "Main Outlet", accountName: "Main Business Account", bankName: "BRAC Bank", accountNumber: "****2145", branch: "Gazipur Branch", balance: "BDT 487,650.75", status: "Active", updatedAt: "2025-06-01" },
  { id: 2, storeName: "Gazipur Store", accountName: "Daily Sales Deposit", bankName: "Dutch-Bangla Bank", accountNumber: "****1230", branch: "Kaliganj Branch", balance: "BDT 156,420.50", status: "Active", updatedAt: "2025-06-01" },
  { id: 3, storeName: "Banani Store", accountName: "Legacy Business Account", bankName: "Mutual Trust Bank", accountNumber: "****4862", branch: "Banani Branch", balance: "BDT 0.00", status: "Closed", updatedAt: "2025-04-15" },
];

const templateRows = [
  { id: 1, code: "TPL-001", name: "Basic Grocery Template", category: "Essentials", usedByProducts: 12, status: "Active", createdDate: "31 may 2024" },
  { id: 2, code: "TPL-002", name: "Fresh Food Template", category: "Beverages", usedByProducts: 8, status: "Active", createdDate: "29 may 2024" },
  { id: 3, code: "TPL-003", name: "Household Starter", category: "Household", usedByProducts: 0, status: "Draft", createdDate: "27 may 2024" },
];

function MasterDataStatIcon({ icon: Icon }: { icon: typeof FiGrid }) {
  return <Icon />;
}

function DashboardControlIcon({ type }: { type: "search" | "edit" | "more" }) {
  if (type === "search") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle cx="11" cy="11" r="6.5" fill="none" stroke="currentColor" strokeWidth="1.8" />
        <path d="m16 16 4 4" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
      </svg>
    );
  }

  if (type === "more") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle cx="12" cy="6" r="1.4" fill="currentColor" />
        <circle cx="12" cy="12" r="1.4" fill="currentColor" />
        <circle cx="12" cy="18" r="1.4" fill="currentColor" />
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

function SearchField({ placeholder, className = "master-category-search" }: { placeholder: string; className?: string }) {
  return (
    <label className={className}>
      {className.includes("product-catalog-search") ? (
        <span className="product-catalog-search-icon" aria-hidden="true">
          <DashboardControlIcon type="search" />
        </span>
      ) : null}
      <input type="text" placeholder={placeholder} />
    </label>
  );
}

function RowActions() {
  return (
    <span className="master-category-actions">
      <button type="button" className="master-category-icon-button master-category-icon-button-edit" aria-label="Edit">
        <DashboardControlIcon type="edit" />
      </button>
      <button type="button" className="master-category-icon-button master-category-icon-button-more" aria-label="More actions">
        <DashboardControlIcon type="more" />
      </button>
    </span>
  );
}

function Footer({ text }: { text: string }) {
  return (
    <div className="master-category-footer">
      <span className="master-category-footer-text">{text}</span>

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
  );
}

function DashboardAddModal({
  module,
  onClose,
}: {
  module: ModuleKey | null;
  onClose: () => void;
}) {
  if (!module) {
    return null;
  }

  if (module === "product-category") {
    return (
      <div className="payment-modal-backdrop" onClick={onClose}>
        <div
          className="payment-modal category-modal"
          onClick={(event) => event.stopPropagation()}
          role="dialog"
          aria-modal="true"
          aria-labelledby="dashboard-category-modal-title"
        >
          <div className="payment-modal-header category-modal-header">
            <div>
              <h3 id="dashboard-category-modal-title">Add New Category</h3>
            </div>
            <button type="button" className="payment-modal-close" onClick={onClose} aria-label="Close modal">
              ×
            </button>
          </div>

          <form className="category-modal-form">
            <label className="master-category-form-field">
              <span>Category Name *</span>
              <input type="text" placeholder="Write the category name" />
            </label>

            <label className="master-category-form-field">
              <span>Description</span>
              <textarea placeholder="Write category description" />
            </label>

            <div className="master-category-form-field">
              <span>Category Icon (Optional)</span>
              <div className="master-category-icon-grid">
                {["green", "blue", "violet", "gold", "rose"].map((color) => (
                  <button
                    type="button"
                    key={color}
                    className={`master-category-picker-button master-category-picker-button-${color}`}
                  >
                    <FiGrid />
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

            <div className="master-category-form-actions">
              <button type="button" className="master-category-reset-button" onClick={onClose}>
                Cancel
              </button>
              <button type="button" className="master-category-save-button">
                Save Category
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  if (module === "product-catalog") {
    return (
      <div className="payment-modal-backdrop" onClick={onClose}>
        <div
          className="payment-modal product-catalog-modal"
          onClick={(event) => event.stopPropagation()}
          role="dialog"
          aria-modal="true"
          aria-labelledby="dashboard-product-modal-title"
        >
          <div className="payment-modal-header product-catalog-modal-header">
            <div>
              <h3 id="dashboard-product-modal-title">Add new Product</h3>
            </div>
            <button type="button" className="payment-modal-close" onClick={onClose} aria-label="Close modal">
              ×
            </button>
          </div>

          <form className="payment-modal-form product-catalog-modal-form">
            <div className="product-catalog-modal-section">
              <h4>Price and Inventory</h4>
              <div className="product-catalog-modal-grid">
                <label className="payment-modal-field">
                  <span>Product name</span>
                  <input type="text" placeholder="Enter product name" />
                </label>

                <label className="payment-modal-field">
                  <span>purchase price</span>
                  <input type="text" placeholder="Enter purchase price" />
                </label>

                <label className="payment-modal-field">
                  <span>SKU</span>
                  <input type="text" placeholder="Enter SKU (Exm: (PRD-0001)" />
                </label>

                <label className="payment-modal-field">
                  <span>Selling Price</span>
                  <input type="text" placeholder="Enter selling price" />
                </label>

                <label className="payment-modal-field">
                  <span>Barcode</span>
                  <input type="text" placeholder="Enter Barcode" />
                </label>

                <label className="payment-modal-field">
                  <span>Suggested selling price</span>
                  <input type="text" placeholder="Enter Suggested selling price" />
                </label>

                <label className="payment-modal-field">
                  <span>Category</span>
                  <select defaultValue="">
                    <option value="" disabled>
                      Select category
                    </option>
                  </select>
                </label>

                <label className="payment-modal-field">
                  <span>Brand</span>
                  <select defaultValue="">
                    <option value="" disabled>
                      Select Brand
                    </option>
                  </select>
                </label>

                <label className="payment-modal-field">
                  <span>Unit</span>
                  <select defaultValue="">
                    <option value="" disabled>
                      Select Unit
                    </option>
                  </select>
                </label>

                <label className="payment-modal-field">
                  <span>Tax Group</span>
                  <input type="text" placeholder="Enter tax group" />
                </label>

                <label className="payment-modal-field">
                  <span>package Size</span>
                  <input type="text" placeholder="Exam: 100gm,1 LTD, 500 ML" />
                </label>

                <label className="payment-modal-field payment-modal-field-full">
                  <span>Additional Information</span>
                  <textarea placeholder="Enter additional information." />
                </label>

                <div className="product-catalog-modal-upload-card">
                  <span>Product Picture</span>
                  <button type="button" className="product-catalog-modal-upload-box">
                    <strong>Upload picture</strong>
                    <small>(ex: .xlsx, .xls)</small>
                    <small>maximum file size: 10MB</small>
                  </button>
                </div>
              </div>
            </div>

            <div className="payment-modal-actions product-catalog-modal-actions">
              <button type="button" className="payment-modal-secondary-button" onClick={onClose}>
                Cancel
              </button>
              <button type="button" className="payment-modal-primary-button">
                Save Product
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  if (module === "brand") {
    return (
      <div className="payment-modal-backdrop" onClick={onClose}>
        <div
          className="payment-modal brand-modal"
          onClick={(event) => event.stopPropagation()}
          role="dialog"
          aria-modal="true"
          aria-labelledby="dashboard-brand-modal-title"
        >
          <div className="payment-modal-header brand-modal-header">
            <div>
              <h3 id="dashboard-brand-modal-title">Add New Brand</h3>
            </div>
            <button type="button" className="payment-modal-close" onClick={onClose} aria-label="Close modal">
              ×
            </button>
          </div>

          <form className="brand-modal-form">
            <label className="master-category-form-field">
              <span>Brand Name *</span>
              <input type="text" placeholder="Enter brand name" />
            </label>

            <label className="master-category-form-field">
              <span>Description</span>
              <textarea placeholder="Write brand description" />
            </label>

            <div className="master-category-form-field">
              <span>Brand Logo</span>
              <button type="button" className="brand-modal-upload-box">
                <strong>Upload logo</strong>
                <small>(jpg, png, svg)</small>
              </button>
            </div>

            <label className="master-category-form-field">
              <span>Status *</span>
              <select defaultValue="Active">
                <option>Active</option>
                <option>Inactive</option>
                <option>Archived</option>
              </select>
            </label>

            <div className="master-category-form-actions">
              <button type="button" className="master-category-reset-button" onClick={onClose}>
                Cancel
              </button>
              <button type="button" className="master-category-save-button">
                Save Brand
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  if (module === "unit") {
    return (
      <div className="payment-modal-backdrop" onClick={onClose}>
        <div
          className="payment-modal unit-modal"
          onClick={(event) => event.stopPropagation()}
          role="dialog"
          aria-modal="true"
          aria-labelledby="dashboard-unit-modal-title"
        >
          <div className="payment-modal-header unit-modal-header">
            <div>
              <h3 id="dashboard-unit-modal-title">Add new unit</h3>
            </div>
            <button type="button" className="payment-modal-close" onClick={onClose} aria-label="Close modal">
              ×
            </button>
          </div>

          <form className="payment-modal-form unit-modal-form">
            <label className="payment-modal-field payment-modal-field-full unit-modal-field">
              <span>
                Unit Name <sup>*</sup>
              </span>
              <input type="text" placeholder="Enter name" />
            </label>

            <label className="payment-modal-field payment-modal-field-full unit-modal-field">
              <span>
                Short Name <sup>*</sup>
              </span>
              <input type="text" placeholder="Example: pcs" />
            </label>

            <label className="payment-modal-field payment-modal-field-full unit-modal-field">
              <span>
                Unit Type <sup>*</sup>
              </span>
              <select defaultValue="">
                <option value="" disabled>
                  Select
                </option>
                <option>Weight</option>
                <option>Volume</option>
                <option>Countable</option>
                <option>Packaging</option>
              </select>
            </label>

            <label className="payment-modal-field payment-modal-field-full unit-modal-field">
              <span>Description (optional)</span>
              <textarea placeholder="Write description about unit" />
            </label>

            <label className="payment-modal-field payment-modal-field-full unit-modal-field">
              <span>
                Status <sup>*</sup>
              </span>
              <select defaultValue="Active">
                <option>Active</option>
                <option>Inactive</option>
              </select>
            </label>

            <div className="payment-modal-actions unit-modal-actions">
              <button type="button" className="payment-modal-secondary-button unit-modal-secondary-button" onClick={onClose}>
                Cancel
              </button>
              <button type="button" className="payment-modal-primary-button unit-modal-primary-button">
                Save
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  if (module === "barcode-database") {
    return (
      <div className="payment-modal-backdrop" onClick={onClose}>
        <div
          className="payment-modal barcode-modal"
          onClick={(event) => event.stopPropagation()}
          role="dialog"
          aria-modal="true"
          aria-labelledby="dashboard-barcode-modal-title"
        >
          <div className="payment-modal-header barcode-modal-header">
            <div>
              <h3 id="dashboard-barcode-modal-title">Add new Barcode</h3>
            </div>
            <button type="button" className="payment-modal-close" onClick={onClose} aria-label="Close modal">
              ×
            </button>
          </div>

          <form className="barcode-modal-form">
            <div className="barcode-modal-section">
              <h4>Product information</h4>
              <div className="barcode-modal-grid barcode-modal-grid-product">
                <label className="payment-modal-field barcode-modal-search-field">
                  <span>Product Name</span>
                  <input type="text" placeholder="Enter product name" />
                  <span className="barcode-modal-inline-icon" aria-hidden="true">
                    <DashboardControlIcon type="search" />
                  </span>
                </label>

                <label className="payment-modal-field">
                  <span>SKU</span>
                  <input type="text" placeholder="Enter SKU (PDR-0001)" />
                </label>

                <div className="payment-modal-field barcode-modal-scan-field">
                  <span>Barcode (EAN/UPC)</span>
                  <div className="barcode-modal-scan-row">
                    <input type="text" placeholder="Scan barcode or Write number" />
                    <button type="button" className="barcode-modal-scan-button">
                      <span>Scan</span>
                    </button>
                  </div>
                </div>

                <label className="payment-modal-field">
                  <span>Category</span>
                  <select defaultValue="">
                    <option value="" disabled>
                      Select Category
                    </option>
                  </select>
                </label>

                <label className="payment-modal-field">
                  <span>Brand</span>
                  <select defaultValue="">
                    <option value="" disabled>
                      Select Brand
                    </option>
                  </select>
                </label>

                <label className="payment-modal-field">
                  <span>Unit</span>
                  <select defaultValue="">
                    <option value="" disabled>
                      Select Unit
                    </option>
                  </select>
                </label>
              </div>
            </div>

            <div className="barcode-modal-section">
              <h4>Packaging and quantity</h4>
              <div className="barcode-modal-grid barcode-modal-grid-packaging">
                <label className="payment-modal-field barcode-modal-search-field">
                  <span>Pack Size</span>
                  <input type="text" placeholder="100 GM, 1 LT, 500ml etc." />
                  <span className="barcode-modal-inline-icon" aria-hidden="true">
                    <DashboardControlIcon type="search" />
                  </span>
                </label>

                <div className="payment-modal-field barcode-modal-inline-select">
                  <span>Net weight/quantity</span>
                  <div className="barcode-modal-inline-row">
                    <input type="text" placeholder="Enter number" />
                    <select defaultValue="GRM">
                      <option>GRM</option>
                    </select>
                  </div>
                </div>

                <label className="payment-modal-field">
                  <span>Package type</span>
                  <select defaultValue="">
                    <option value="" disabled>
                      Select package type
                    </option>
                  </select>
                </label>

                <label className="payment-modal-field">
                  <span>Pitch/Unite Per Quantity</span>
                  <select defaultValue="">
                    <option value="" disabled>
                      12 pitch, 6 bottle
                    </option>
                  </select>
                </label>
              </div>
            </div>

            <div className="barcode-modal-actions">
              <button type="button" className="payment-modal-secondary-button" onClick={onClose}>
                Cancel
              </button>
              <button type="button" className="payment-modal-primary-button">
                Save Barcode
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  if (module === "money-box") {
    return (
      <div className="payment-modal-backdrop" onClick={onClose}>
        <div
          className="payment-modal money-box-modal"
          onClick={(event) => event.stopPropagation()}
          role="dialog"
          aria-modal="true"
          aria-labelledby="dashboard-money-box-modal-title"
        >
          <div className="payment-modal-header money-box-modal-header">
            <div>
              <h3 id="dashboard-money-box-modal-title">Add New Money Box</h3>
            </div>
            <button type="button" className="payment-modal-close" onClick={onClose} aria-label="Close modal">
              ×
            </button>
          </div>

          <form className="payment-modal-form money-box-modal-form">
            <label className="payment-modal-field payment-modal-field-full">
              <span>Shop</span>
              <select defaultValue="">
                <option value="" disabled>
                  Select shop
                </option>
                <option>Main Outlet</option>
                <option>Gazipur Store</option>
                <option>Tongi Store</option>
              </select>
            </label>

            <label className="payment-modal-field payment-modal-field-full">
              <span>Money box name</span>
              <input type="text" placeholder="Enter name" />
            </label>

            <label className="payment-modal-field payment-modal-field-full">
              <span>Code</span>
              <input type="text" placeholder="Enter Enter code  (CASH-001)" />
            </label>

            <label className="payment-modal-field payment-modal-field-full">
              <span>Type</span>
              <select defaultValue="">
                <option value="" disabled>
                  Select Type
                </option>
                <option>Nagad</option>
                <option>Bkash</option>
                <option>Cash</option>
              </select>
            </label>

            <label className="payment-modal-field payment-modal-field-full">
              <span>First Balance</span>
              <input type="text" placeholder="$000" />
            </label>

            <label className="payment-modal-field payment-modal-field-full">
              <span>Details</span>
              <textarea placeholder="Enter Details" />
            </label>

            <label className="payment-modal-field payment-modal-field-full">
              <span>Condition</span>
              <select defaultValue="Active">
                <option>Active</option>
                <option>Inactive</option>
              </select>
            </label>

            <label className="money-box-modal-check">
              <input type="checkbox" defaultChecked />
              <span>Save first balance</span>
            </label>

            <div className="payment-modal-actions money-box-modal-actions">
              <button type="button" className="payment-modal-secondary-button money-box-modal-secondary-button" onClick={onClose}>
                Reset
              </button>
              <button type="button" className="payment-modal-primary-button money-box-modal-primary-button">
                Save Change
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  if (module === "supplier-data") {
    return (
      <div className="payment-modal-backdrop" onClick={onClose}>
        <div
          className="payment-modal"
          onClick={(event) => event.stopPropagation()}
          role="dialog"
          aria-modal="true"
          aria-labelledby="dashboard-supplier-modal-title"
        >
          <div className="payment-modal-header">
            <div>
              <h3 id="dashboard-supplier-modal-title">Add Supplier</h3>
            </div>
            <button type="button" className="payment-modal-close" onClick={onClose} aria-label="Close modal">
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
              <span>Status</span>
              <select defaultValue="Active">
                <option>Active</option>
                <option>Inactive</option>
                <option>Blocked</option>
              </select>
            </label>

            <label className="payment-modal-field payment-modal-field-full">
              <span>Notes</span>
              <textarea placeholder="Write your notes" />
            </label>

            <div className="payment-modal-actions supplier-modal-actions">
              <button type="button" className="payment-modal-secondary-button" onClick={onClose}>
                Reset
              </button>
              <button type="button" className="payment-modal-primary-button">
                + Add Supplier
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  if (module === "bank-account") {
    return (
      <div className="payment-modal-backdrop" onClick={onClose}>
        <div
          className="payment-modal bank-account-modal"
          onClick={(event) => event.stopPropagation()}
          role="dialog"
          aria-modal="true"
          aria-labelledby="dashboard-bank-account-modal-title"
        >
          <div className="payment-modal-header bank-account-modal-header">
            <div>
              <h3 id="dashboard-bank-account-modal-title">Add Bank Account</h3>
            </div>
            <button type="button" className="payment-modal-close" onClick={onClose} aria-label="Close modal">
              ×
            </button>
          </div>

          <form className="payment-modal-form bank-account-modal-form">
            <div className="bank-account-modal-section">
              <h4>Basic Information</h4>
              <div className="bank-account-modal-grid">
                <label className="payment-modal-field bank-account-modal-field">
                  <span>Account Name</span>
                  <input type="text" placeholder="Enter account name" />
                </label>

                <label className="payment-modal-field bank-account-modal-field">
                  <span>Bank Name</span>
                  <input type="text" placeholder="Enter bank name" />
                </label>

                <label className="payment-modal-field bank-account-modal-field">
                  <span>Branch Name</span>
                  <input type="text" placeholder="Enter branch name" />
                </label>

                <label className="payment-modal-field bank-account-modal-field">
                  <span>Account Number</span>
                  <input type="text" placeholder="Enter account number" />
                </label>

                <label className="payment-modal-field bank-account-modal-field payment-modal-field-full">
                  <span>Account Type</span>
                  <select defaultValue="">
                    <option value="" disabled>
                      Select account type
                    </option>
                    <option>Current</option>
                    <option>Savings</option>
                  </select>
                </label>
              </div>
            </div>

            <div className="bank-account-modal-section">
              <h4>Balance Information</h4>
              <div className="bank-account-modal-grid">
                <label className="payment-modal-field bank-account-modal-field">
                  <span>Opening Balance</span>
                  <input type="text" placeholder="0.00" />
                </label>

                <label className="payment-modal-field bank-account-modal-field">
                  <span>Currency</span>
                  <select defaultValue="BDT">
                    <option>BDT</option>
                    <option>USD</option>
                  </select>
                </label>
              </div>
            </div>

            <div className="bank-account-modal-section">
              <h4>Settings</h4>
              <div className="bank-account-modal-grid">
                <label className="payment-modal-field bank-account-modal-field">
                  <span>Status</span>
                  <select defaultValue="Active">
                    <option>Active</option>
                    <option>Inactive</option>
                    <option>Closed</option>
                  </select>
                </label>

                <label className="bank-account-modal-check">
                  <input type="checkbox" />
                  <span>Set as Default Account</span>
                </label>

                <label className="payment-modal-field bank-account-modal-field payment-modal-field-full">
                  <span>Notes</span>
                  <textarea placeholder="Write account notes" />
                </label>
              </div>
            </div>

            <div className="payment-modal-actions bank-account-modal-actions">
              <button type="button" className="payment-modal-secondary-button bank-account-modal-secondary-button" onClick={onClose}>
                Cancel
              </button>
              <button type="button" className="payment-modal-primary-button bank-account-modal-primary-button">
                Save Account
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="payment-modal-backdrop" onClick={onClose}>
      <div
        className="payment-modal product-template-modal"
        onClick={(event) => event.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-labelledby="dashboard-product-template-modal-title"
      >
        <div className="payment-modal-header product-template-modal-header">
          <div>
            <h3 id="dashboard-product-template-modal-title">New Template import file</h3>
          </div>
          <button type="button" className="payment-modal-close" onClick={onClose} aria-label="Close modal">
            ×
          </button>
        </div>

        <form className="product-template-modal-form">
          <div className="product-template-modal-field">
            <span>
              Select file <sup>*</sup>
            </span>
            <button type="button" className="product-template-upload-box">
              <strong>Drag the file here or click and select the file</strong>
              <small>Only Excel file (.xls, .xlsx)</small>
              <small>Supported</small>
              <small>maximum file size: 10MB</small>
            </button>
          </div>

          <label className="product-template-modal-field">
            <span>
              Import Type <sup>*</sup>
            </span>
            <select defaultValue="">
              <option value="" disabled>
                Add new and update
              </option>
            </select>
          </label>

          <label className="product-template-modal-field">
            <span>
              File Formate <sup>*</sup>
            </span>
            <select defaultValue="">
              <option value="" disabled>
                Excel (.xlsx)
              </option>
            </select>
          </label>

          <div className="product-template-modal-field">
            <span>Guidelines on format</span>
            <div className="product-template-guidelines">
              <p>Please follow the instructions below.</p>
              <ul>
                <li>Template Code</li>
                <li>Template Name</li>
                <li>Description</li>
                <li>Status</li>
              </ul>
            </div>
          </div>

          <label className="money-box-modal-check">
            <input type="checkbox" defaultChecked />
            <span>Header data on the first line</span>
          </label>

          <div className="product-template-modal-actions">
            <button type="button" className="payment-modal-secondary-button product-template-download-button">
              Download
            </button>
            <button type="button" className="payment-modal-primary-button product-template-upload-button">
              Upload
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function ModuleSection({
  onAddClick,
  selectedModule,
}: {
  onAddClick: (module: ModuleKey) => void;
  selectedModule: ModuleKey;
}) {
  if (selectedModule === "product-category") {
    return (
      <section className="master-category-table-card">
        <div className="master-category-toolbar">
          <SearchField placeholder="Search category name..." />
          <select className="master-category-select" defaultValue="All Status">
            <option>All Status</option>
            <option>Active</option>
            <option>Inactive</option>
          </select>
          <button type="button" className="master-category-outline-button">Filter</button>
          <button type="button" className="master-category-outline-button">Reset</button>
          <button type="button" className="master-category-primary-button" onClick={() => onAddClick("product-category")}>+ Add Category</button>
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
              <span>{row.name}</span>
              <span>{row.description}</span>
              <span>{row.products}</span>
              <span>
                <em className={`master-category-status-badge${row.status === "Inactive" ? " master-category-status-badge-inactive" : ""}`}>{row.status}</em>
              </span>
              <span>{row.createdDate}</span>
              <RowActions />
            </div>
          ))}
        </div>
        <Footer text="Showing 3 categories total" />
      </section>
    );
  }

  if (selectedModule === "product-catalog") {
    return (
      <section className="master-category-table-card">
        <div className="product-catalog-filters">
          <SearchField placeholder="Search products, barcode or SKU..." className="master-category-search product-catalog-search" />
          <select className="master-category-select" defaultValue="Category">
            <option>Category</option>
            <option>Sugar</option>
            <option>Oil</option>
            <option>Beverages</option>
          </select>
          <select className="master-category-select" defaultValue="Brand">
            <option>Brand</option>
            <option>Fresh</option>
            <option>Teer</option>
            <option>Pran</option>
          </select>
          <select className="master-category-select" defaultValue="Active">
            <option>Active</option>
            <option>Inactive</option>
          </select>
          <button type="button" className="master-category-outline-button product-catalog-reset-button">Clear Filters</button>
          <button type="button" className="master-category-outline-button product-catalog-export-button">Export</button>
          <button type="button" className="master-category-primary-button product-catalog-add-button" onClick={() => onAddClick("product-catalog")}>+ Add Product</button>
        </div>

        <div className="product-catalog-table">
          <div className="product-catalog-table-head">
            <span>#</span>
            <span>Product</span>
            <span>Category</span>
            <span>Brand</span>
            <span>Unit</span>
            <span>Bar code</span>
            <span>Purchase price</span>
            <span>Selling Price</span>
            <span>Status</span>
            <span>Action</span>
          </div>
          {productCatalogRows.map((row) => (
            <div className="product-catalog-table-row" key={row.id}>
              <span>{row.id}</span>
              <span className="product-catalog-product-cell">
                <span className="product-catalog-product-copy">
                  <strong>{row.name}</strong>
                  <small>{row.note}</small>
                </span>
              </span>
              <span>{row.category}</span>
              <span>{row.brand}</span>
              <span>{row.unit}</span>
              <span>{row.barcode}</span>
              <span>{row.purchasePrice}</span>
              <span>{row.sellingPrice}</span>
              <span>
                <em className={`master-category-status-badge${row.status === "Inactive" ? " unit-page-status-badge-inactive" : ""}`}>{row.status}</em>
              </span>
              <RowActions />
            </div>
          ))}
        </div>
        <Footer text="Showing 3 products total" />
      </section>
    );
  }

  if (selectedModule === "brand") {
    return (
      <section className="master-category-table-card">
        <div className="master-category-toolbar brand-page-toolbar">
          <SearchField placeholder="Search brands..." className="master-category-search product-catalog-search brand-page-search" />
          <select className="master-category-select" defaultValue="All Status">
            <option>All Status</option>
            <option>Active</option>
            <option>Inactive</option>
            <option>Archived</option>
          </select>
          <button type="button" className="master-category-outline-button brand-page-reset-button">Clear Filters</button>
          <button type="button" className="master-category-primary-button brand-page-add-button" onClick={() => onAddClick("brand")}>+ Add Brand</button>
        </div>

        <div className="brand-page-table">
          <div className="brand-page-table-head">
            <span>#</span>
            <span>Brand</span>
            <span>Description</span>
            <span>Categories</span>
            <span>Products</span>
            <span>Status</span>
            <span>Created Date</span>
            <span>Actions</span>
          </div>
          {brandRows.map((row) => (
            <div className="brand-page-table-row" key={row.id}>
              <span>{row.id}</span>
              <span>{row.brandName}</span>
              <span>{row.description}</span>
              <span>{row.categories}</span>
              <span>{row.products}</span>
              <span>
                <em
                  className={`master-category-status-badge${
                    row.status === "Inactive" ? " master-category-status-badge-inactive" : row.status === "Archived" ? " brand-page-status-badge-archived" : ""
                  }`}
                >
                  {row.status}
                </em>
              </span>
              <span>{row.createdDate}</span>
              <RowActions />
            </div>
          ))}
        </div>
        <Footer text="Showing 3 brands total" />
      </section>
    );
  }

  if (selectedModule === "unit") {
    return (
      <section className="master-category-table-card">
        <div className="master-category-toolbar unit-page-toolbar">
          <SearchField placeholder="Search units..." className="master-category-search product-catalog-search unit-page-search" />
          <select className="master-category-select" defaultValue="Type">
            <option>Type</option>
            <option>Countable</option>
            <option>Weight</option>
            <option>Volume</option>
            <option>Packaging</option>
          </select>
          <select className="master-category-select" defaultValue="Status">
            <option>Status</option>
            <option>Active</option>
            <option>Inactive</option>
          </select>
          <button type="button" className="master-category-outline-button unit-page-reset-button">Clear Filters</button>
          <button type="button" className="master-category-primary-button unit-page-add-button" onClick={() => onAddClick("unit")}>+ Add Unit</button>
        </div>

        <div className="unit-page-table">
          <div className="unit-page-table-head">
            <span>#</span>
            <span>Unit Name</span>
            <span>Short Name</span>
            <span>Type</span>
            <span>Description</span>
            <span>Status</span>
            <span>Date</span>
            <span>Action</span>
          </div>
          {unitRows.map((row) => (
            <div className="unit-page-table-row" key={row.id}>
              <span>{row.id}</span>
              <span>{row.name}</span>
              <span>{row.shortName}</span>
              <span>{row.type}</span>
              <span>{row.description}</span>
              <span>
                <em className={`master-category-status-badge${row.status === "Inactive" ? " unit-page-status-badge-inactive" : ""}`}>{row.status}</em>
              </span>
              <span>{row.date}</span>
              <RowActions />
            </div>
          ))}
        </div>
        <Footer text="Showing 3 units total" />
      </section>
    );
  }

  if (selectedModule === "barcode-database") {
    return (
      <>
        <section className="master-category-table-card barcode-database-filter-card">
          <div className="barcode-database-filters">
            <SearchField placeholder="Search barcode, product or SKU..." className="master-category-search product-catalog-search" />
            <select className="master-category-select" defaultValue="Category">
              <option>Category</option>
              <option>Sugar</option>
              <option>Oil</option>
              <option>Household</option>
            </select>
            <select className="master-category-select" defaultValue="Brand">
              <option>Brand</option>
              <option>Fresh</option>
              <option>Teer</option>
              <option>Wheel</option>
            </select>
            <select className="master-category-select" defaultValue="Status">
              <option>Status</option>
              <option>Mapped</option>
              <option>Unmapped</option>
              <option>Archived</option>
            </select>
            <button type="button" className="master-category-outline-button product-catalog-reset-button">Reset</button>
            <button type="button" className="master-category-primary-button barcode-database-add-button" onClick={() => onAddClick("barcode-database")}>+ Add Barcode</button>
          </div>
        </section>

        <section className="master-category-table-card">
          <div className="barcode-database-table">
            <div className="barcode-database-table-head">
              <span>#</span>
              <span>Bar code</span>
              <span>Product Name</span>
              <span>SKU</span>
              <span>Category</span>
              <span>Brand</span>
              <span>Unit</span>
              <span>Status</span>
              <span>Added Date</span>
              <span>Action</span>
            </div>
            {barcodeRows.map((row) => (
              <div className="barcode-database-table-row" key={row.id}>
                <span>{row.id}</span>
                <span>{row.barcode}</span>
                <span>{row.productName}</span>
                <span>{row.sku}</span>
                <span>{row.category}</span>
                <span>{row.brand}</span>
                <span>{row.unit}</span>
                <span>
                  <em
                    className={`barcode-database-status-badge${
                      row.status === "Unmapped"
                        ? " barcode-database-status-badge-unmapped"
                        : row.status === "Archived"
                          ? " barcode-database-status-badge-archived"
                          : ""
                    }`}
                  >
                    {row.status}
                  </em>
                </span>
                <span>{row.date}</span>
                <RowActions />
              </div>
            ))}
          </div>
          <Footer text="Showing 3 barcode records total" />
        </section>
      </>
    );
  }

  if (selectedModule === "money-box") {
    return (
      <section className="master-category-table-card">
        <div className="master-category-toolbar money-box-toolbar">
          <SearchField placeholder="Search box name, code or shop..." className="master-category-search money-box-search" />
          <select className="master-category-select" defaultValue="All Shops">
            <option>All Shops</option>
            <option>Main Outlet</option>
            <option>Gazipur Store</option>
            <option>Tongi Store</option>
          </select>
          <select className="master-category-select" defaultValue="All Status">
            <option>All Status</option>
            <option>Active</option>
            <option>Inactive</option>
          </select>
          <button type="button" className="master-category-outline-button">Clear Filters</button>
          <button type="button" className="master-category-primary-button" onClick={() => onAddClick("money-box")}>Add Money Box</button>
        </div>

        <div className="money-box-table">
          <div className="money-box-table-head">
            <span>#</span>
            <span>Shop Name</span>
            <span>Box Name</span>
            <span>Box Code</span>
            <span>Type</span>
            <span>Current Balance</span>
            <span>Status</span>
            <span>Created Date</span>
            <span>Actions</span>
          </div>
          {moneyBoxRows.map((row) => (
            <div className="money-box-table-row" key={row.id}>
              <span>{row.id}</span>
              <span>{row.shopName}</span>
              <span>{row.boxName}</span>
              <span>{row.code}</span>
              <span>{row.type}</span>
              <span>{row.balance}</span>
              <span>
                <em className={`master-category-status-badge${row.status === "Inactive" ? " unit-page-status-badge-inactive" : ""}`}>{row.status}</em>
              </span>
              <span>{row.date}</span>
              <RowActions />
            </div>
          ))}
        </div>
        <Footer text="Showing 3 money boxes total" />
      </section>
    );
  }

  if (selectedModule === "supplier-data") {
    return (
      <section className="master-category-table-card">
        <div className="master-category-toolbar supplier-data-toolbar">
          <SearchField placeholder="Search supplier name, code or store..." />
          <select className="master-category-select" defaultValue="All Status">
            <option>All Status</option>
            <option>Active</option>
            <option>Inactive</option>
            <option>Blocked</option>
          </select>
          <button type="button" className="master-category-outline-button">Clear Filters</button>
          <button type="button" className="master-category-primary-button" onClick={() => onAddClick("supplier-data")}>Add Supplier</button>
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
                <em className={`master-category-status-badge${row.status === "Blocked" ? " bank-account-status-badge-closed" : ""}`}>{row.status}</em>
              </span>
              <span>{row.date}</span>
              <RowActions />
            </div>
          ))}
        </div>
        <Footer text="Showing 3 suppliers total" />
      </section>
    );
  }

  if (selectedModule === "bank-account") {
    return (
      <section className="master-category-table-card">
        <div className="master-category-toolbar bank-account-toolbar">
          <SearchField placeholder="Search account, bank or number..." className="master-category-search product-catalog-search bank-account-search" />
          <select className="master-category-select" defaultValue="All Stores">
            <option>All Stores</option>
            <option>Main Outlet</option>
            <option>Gazipur Store</option>
            <option>Banani Store</option>
          </select>
          <select className="master-category-select" defaultValue="All Banks">
            <option>All Banks</option>
            <option>BRAC Bank</option>
            <option>Dutch-Bangla Bank</option>
            <option>Mutual Trust Bank</option>
          </select>
          <select className="master-category-select" defaultValue="All Status">
            <option>All Status</option>
            <option>Active</option>
            <option>Inactive</option>
            <option>Closed</option>
          </select>
          <button type="button" className="master-category-outline-button bank-account-reset-button">Reset</button>
          <button type="button" className="master-category-outline-button product-catalog-export-button">Export</button>
          <button type="button" className="master-category-primary-button bank-account-add-button" onClick={() => onAddClick("bank-account")}>+ Add Account</button>
        </div>

        <div className="bank-account-table">
          <div className="bank-account-table-head">
            <span>#</span>
            <span>Store Name</span>
            <span>Account Name</span>
            <span>Bank Name</span>
            <span>Account Number</span>
            <span>Branch</span>
            <span>Current Balance</span>
            <span>Status</span>
            <span>Last Updated</span>
            <span>Actions</span>
          </div>
          {bankRows.map((row) => (
            <div className="bank-account-table-row" key={row.id}>
              <span>{row.id}</span>
              <span>{row.storeName}</span>
              <span>{row.accountName}</span>
              <span>{row.bankName}</span>
              <span>{row.accountNumber}</span>
              <span>{row.branch}</span>
              <span>{row.balance}</span>
              <span>
                <em className={`master-category-status-badge${row.status === "Closed" ? " bank-account-status-badge-closed" : ""}`}>{row.status}</em>
              </span>
              <span>{row.updatedAt}</span>
              <RowActions />
            </div>
          ))}
        </div>
        <Footer text="Showing 3 bank accounts total" />
      </section>
    );
  }

  return (
    <section className="master-category-table-card">
      <div className="master-category-toolbar product-template-toolbar">
        <SearchField placeholder="Search Template..." className="master-category-search product-catalog-search" />
        <select className="master-category-select" defaultValue="All Status">
          <option>All Status</option>
          <option>Active</option>
          <option>Inactive</option>
          <option>Draft</option>
          <option>Archived</option>
        </select>
        <button type="button" className="master-category-outline-button product-template-refresh-button">Reset</button>
        <button type="button" className="master-category-primary-button" onClick={() => onAddClick("product-template")}>+ Add Template</button>
      </div>

      <div className="product-template-table">
        <div className="product-template-table-head">
          <span>#</span>
          <span>Template Code</span>
          <span>Template Name</span>
          <span>Category</span>
          <span>Used By Products</span>
          <span>Status</span>
          <span>Created Date</span>
          <span>Actions</span>
        </div>
        {templateRows.map((row) => (
          <div className="product-template-table-row" key={row.id}>
            <span>{row.id}</span>
            <span>{row.code}</span>
            <span>{row.name}</span>
            <span>{row.category}</span>
            <span>{row.usedByProducts}</span>
            <span>
              <em
                className={`product-template-status-badge${
                  row.status === "Draft" ? " unit-page-status-badge-inactive" : row.status === "Archived" ? " bank-account-status-badge-closed" : ""
                }`}
              >
                {row.status}
              </em>
            </span>
            <span>{row.createdDate}</span>
            <RowActions />
          </div>
        ))}
      </div>
      <Footer text="Showing 3 templates total" />
    </section>
  );
}

export default function MasterDataModulePage() {
  const [selectedModule, setSelectedModule] = useState<ModuleKey>("product-category");
  const [openModal, setOpenModal] = useState<ModuleKey | null>(null);

  const handleAddClick = (module: ModuleKey) => {
    setOpenModal(module);
  };

  return (
    <section className="admin-dashboard">
      <div className="master-data-stats">
        {masterDataStats.map((stat) => (
          <article className="master-data-stat-card" key={stat.label}>
            <div className={`master-data-stat-icon master-data-stat-icon-${stat.accent}`}>
              <MasterDataStatIcon icon={stat.icon} />
            </div>

            <div className="master-data-stat-content">
              <span className="master-data-stat-label">{stat.label}</span>
              <strong>{stat.value}</strong>
              <p className="master-data-stat-meta">
                {stat.metaLabel}: <span className="master-data-stat-meta-value">{stat.metaValue}</span>
              </p>
            </div>
          </article>
        ))}
      </div>

      <fieldset className="master-data-filter-group">
        <legend className="master-data-filter-legend">Master data sections</legend>
        <div className="master-data-filter-options" role="radiogroup" aria-label="Master data sections">
          {masterDataFilters.map((item) => {
            const id = `master-data-filter-${item.key}`;

            return (
              <label className="master-data-filter-option" htmlFor={id} key={item.key}>
                <input
                  checked={selectedModule === item.key}
                  id={id}
                  name="master-data-filter"
                  onChange={() => setSelectedModule(item.key)}
                  type="radio"
                />
                <span>{item.label}</span>
              </label>
            );
          })}
        </div>
      </fieldset>

      <ModuleSection onAddClick={handleAddClick} selectedModule={selectedModule} />
      <DashboardAddModal module={openModal} onClose={() => setOpenModal(null)} />
    </section>
  );
}
