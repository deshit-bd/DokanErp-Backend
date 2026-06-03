"use client";

import { use, useState } from "react";

const masterDataPageTitles: Record<string, string> = {
  "product-category": "Product Category",
  category: "Category",
  brand: "Brand",
  unity: "Unity",
  "barcode-database": "Barcode Database",
  "import-export": "Import / Export",
  "money-box": "Money Box",
  "supplier-data": "Supplier Data",
  "bank-account": "Bank Account",
  "product-template": "Product Template",
};

const moneyBoxStats = [
  { label: "Money Box", value: "4516", note: "All Suppler", accent: "indigo" as const, type: "users" as const },
  { label: "Total Balance", value: "$2512.2", note: "Active Suppler", accent: "green" as const, type: "balance" as const },
  { label: "Active box", value: "16", note: "All Unused Suppler", accent: "indigo" as const, type: "check" as const },
  { label: "Inactive Box", value: "12,684", note: "All Block", accent: "red" as const, type: "alert" as const },
];

const moneyBoxRows = Array.from({ length: 10 }, (_, index) => ({
  id: index + 1,
  supplierCode: "SUO-001",
  code: "CASH-001",
  type: index === 2 ? "Bkash" : "Nagad",
  balance: "$544.20",
  status: "Active",
  date: "31 may 2024",
}));

const productCatalogStats = [
  { label: "Total Products", value: "4516", note: "All products", accent: "indigo" as const, type: "box" as const },
  { label: "Active Products", value: "4500", note: "Shops can use these", accent: "green" as const, type: "check" as const },
  { label: "Inactive Products", value: "16", note: "In system, not visible", accent: "amber" as const, type: "clock" as const },
  { label: "Using Shops", value: "12,684", note: "Shops using products", accent: "blue" as const, type: "shop" as const },
];

const productCatalogRows = Array.from({ length: 8 }, (_, index) => ({
  id: index + 1,
  name: index % 2 === 0 ? "Sugar(white)" : "Soybean oil",
  note: index % 2 === 0 ? "Premium Quality" : "1 Litter",
  category: index % 2 === 0 ? "Sugar" : "Oil",
  brand: "Fresh",
  unit: index % 2 === 0 ? "1 KG" : "1 LT",
  barcode: "54542145432",
  purchasePrice: index % 2 === 0 ? "$45" : "$20",
  sellingPrice: index % 2 === 0 ? "$50" : "$25",
  status: "Account",
  type: index % 2 === 0 ? "sugar" : "oil",
}));

const barcodeDatabaseStats = [
  { label: "Total Barcodes", value: "98,765", note: "All Total", accent: "indigo" as const, type: "barcode" as const },
  { label: "Mapped", value: "87,432", note: "88.53%", accent: "green" as const, type: "mapped" as const },
  { label: "Unmapped", value: "11,333", note: "All Total", accent: "amber" as const, type: "grid" as const },
  { label: "New ( This Month)", value: "4,321", note: "All Total", accent: "violet" as const, type: "badge" as const },
  { label: "Scanned", value: "25,678", note: "All Total", accent: "red" as const, type: "scan" as const },
];

const barcodeDatabaseRows = Array.from({ length: 7 }, (_, index) => ({
  id: 1,
  productName: index % 2 === 0 ? "Sugar(white)" : "Soybean oil",
  productNote: index % 2 === 0 ? "Premium Quality" : "1 Litter",
  sku: "PRD-0001",
  category: "Rice, Flour & Flour",
  brand: "Frash",
  unit: index % 2 === 0 ? "1 KG" : "1 LT",
  status: index < 2 ? "Mapped" : "Unmapped",
  addedDate: "30 may, 2024",
  addedTime: "10:30 AM",
  type: index % 2 === 0 ? "sugar" : "oil",
  barcode: "79359426436872",
}));

const productTemplateStats = [
  { label: "Total Templates", value: "4516", note: "All templates", accent: "indigo" as const, type: "file" as const },
  { label: "Active Templates", value: "4500", note: "Ready to use", accent: "green" as const, type: "check" as const },
  { label: "Used in Products", value: "8", note: "Assigned templates", accent: "amber" as const, type: "close" as const },
  { label: "Unused Templates", value: "3", note: "Not yet assigned", accent: "red" as const, type: "alert" as const },
];

const productTemplateRows = Array.from({ length: 10 }, (_, index) => ({
  id: index + 1,
  code: "TPL-001",
  name: "Simple product template",
  details: "Template for common products",
  startDate: "01 may 2024",
  startTime: "10:00 Am",
  endDate: "31 may 2024",
  endTime: "10:00 Am",
  status: "Success",
}));

function formatTitle(slug: string) {
  return masterDataPageTitles[slug] ?? slug.replace(/-/g, " ").replace(/\b\w/g, (char) => char.toUpperCase());
}

function MoneyBoxStatIcon({
  accent,
  type,
}: {
  accent: "indigo" | "green" | "red";
  type: "users" | "balance" | "check" | "alert";
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

        {type === "balance" ? (
          <>
            <circle cx="12" cy="12" r="8.5" fill="none" stroke="currentColor" strokeWidth="1.8" />
            <path
              d="M12 7.7v8.6"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
            />
            <path
              d="M14.9 9.7c-.5-.8-1.6-1.4-2.9-1.4-1.7 0-3 .9-3 2.2 0 3.3 6 1.6 6 4.5 0 1.3-1.3 2.2-3 2.2-1.4 0-2.6-.5-3.3-1.5"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </>
        ) : null}

        {type === "check" ? (
          <path
            d="m7.5 12.2 2.7 2.8 6.3-6.5"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        ) : null}

        {type === "alert" ? (
          <>
            <path
              d="M12 4.2 19 8.3v7.4l-7 4.1-7-4.1V8.3l7-4.1Z"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M12 8.5v4.5"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
            />
            <path
              d="M12 15.8h.01"
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

function MoneyBoxToolbarIcon({ type }: { type: "search" | "filter" }) {
  if (type === "filter") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path
          d="M4.5 5.5h15l-6 7v5l-3 1.7v-6.7l-6-7Z"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <circle
        cx="11"
        cy="11"
        r="6.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
      />
      <path
        d="m16 16 3.5 3.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
    </svg>
  );
}

function MoneyBoxActionIcon({ type }: { type: "edit" | "delete" }) {
  if (type === "delete") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path
          d="M8 7.5h8"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
        />
        <path
          d="M9 7.5V6.4c0-.8.6-1.4 1.4-1.4h3.2c.8 0 1.4.6 1.4 1.4v1.1"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path
          d="M7.5 7.5l.7 10c.1.9.8 1.5 1.7 1.5h4.2c.9 0 1.6-.7 1.7-1.5l.7-10"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path
          d="M10.5 10.5v4.8"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
        />
        <path
          d="M13.5 10.5v4.8"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
        />
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

function ProductCatalogStatIcon({
  accent,
  type,
}: {
  accent: "indigo" | "green" | "amber" | "blue";
  type: "box" | "check" | "clock" | "shop";
}) {
  return (
    <span className={`master-category-stat-icon master-category-stat-icon-${accent}`} aria-hidden="true">
      <svg viewBox="0 0 24 24">
        {type === "box" ? (
          <>
            <path
              d="m12 3 7.5 4.3v9.4L12 21l-7.5-4.3V7.3L12 3Z"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M12 12 4.5 7.3"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M12 12 19.5 7.3"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path d="M12 12v9" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
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

        {type === "clock" ? (
          <>
            <circle cx="12" cy="12" r="8.5" fill="none" stroke="currentColor" strokeWidth="1.8" />
            <path d="M12 8v4.5l3 1.7" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
          </>
        ) : null}

        {type === "shop" ? (
          <>
            <path
              d="M6 9.5 7.1 5h9.8L18 9.5"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M7 9.5h10v9.5H7z"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path d="M10 19V14h4v5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
          </>
        ) : null}
      </svg>
    </span>
  );
}

function ProductCatalogControlIcon({ type }: { type: "search" | "filter" | "reset" | "more" }) {
  if (type === "filter") {
    return <MoneyBoxToolbarIcon type="filter" />;
  }

  if (type === "reset") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path
          d="M19 12a7 7 0 1 1-2-4.9"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path
          d="M19 5v4h-4"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    );
  }

  if (type === "more") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle cx="12" cy="6" r="1.2" fill="currentColor" />
        <circle cx="12" cy="12" r="1.2" fill="currentColor" />
        <circle cx="12" cy="18" r="1.2" fill="currentColor" />
      </svg>
    );
  }

  return <MoneyBoxToolbarIcon type="search" />;
}

function ProductCatalogRowIcon({ type }: { type: "sugar" | "oil" }) {
  if (type === "oil") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path
          d="M9 5.5h6v3H9z"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path
          d="M8 8.5h8l1.5 10h-11z"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <circle cx="12" cy="13" r="1.7" fill="none" stroke="currentColor" strokeWidth="1.6" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M7 8.5h10l-1 10H8z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M9 8.5V7a3 3 0 0 1 6 0v1.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <path
        d="M10 13h4"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
    </svg>
  );
}

function BarcodeDatabaseStatIcon({
  accent,
  type,
}: {
  accent: "indigo" | "green" | "amber" | "violet" | "red";
  type: "barcode" | "mapped" | "grid" | "badge" | "scan";
}) {
  return (
    <span className={`master-category-stat-icon master-category-stat-icon-${accent}`} aria-hidden="true">
      <svg viewBox="0 0 24 24">
        {type === "barcode" ? (
          <>
            <path d="M6 6v12" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
            <path d="M9 6v12" fill="none" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" />
            <path d="M11 6v12" fill="none" stroke="currentColor" strokeWidth="2.1" strokeLinecap="round" />
            <path d="M14 6v12" fill="none" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" />
            <path d="M16 6v12" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
            <path d="M18 6v12" fill="none" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" />
          </>
        ) : null}

        {type === "mapped" ? (
          <>
            <path
              d="M18.5 12a6.5 6.5 0 1 1-1.9-4.6"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M18.5 6.5v4h-4"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </>
        ) : null}

        {type === "grid" ? (
          <>
            <rect x="5.5" y="5.5" width="4.5" height="4.5" rx="0.8" fill="none" stroke="currentColor" strokeWidth="1.6" />
            <rect x="14" y="5.5" width="4.5" height="4.5" rx="0.8" fill="none" stroke="currentColor" strokeWidth="1.6" />
            <rect x="5.5" y="14" width="4.5" height="4.5" rx="0.8" fill="none" stroke="currentColor" strokeWidth="1.6" />
            <rect x="14" y="14" width="4.5" height="4.5" rx="0.8" fill="none" stroke="currentColor" strokeWidth="1.6" />
          </>
        ) : null}

        {type === "badge" ? (
          <>
            <path
              d="M12 4.5 18 7v5.5c0 3.2-2 5.7-6 7-4-1.3-6-3.8-6-7V7l6-2.5Z"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="m10.3 11.8 1.2 1.2 2.3-2.5"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </>
        ) : null}

        {type === "scan" ? (
          <>
            <path d="M7 5.5H5.5V9" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
            <path d="M17 5.5h1.5V9" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
            <path d="M7 18.5H5.5V15" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
            <path d="M17 18.5h1.5V15" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
            <path d="M9 12h6" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
          </>
        ) : null}
      </svg>
    </span>
  );
}

function BarcodeRowPreview() {
  return (
    <span className="barcode-database-preview" aria-hidden="true">
      <span />
      <span />
      <span />
      <span />
      <span />
      <span />
      <span />
      <span />
      <span />
      <span />
      <small>79359426436872</small>
    </span>
  );
}

function ProductTemplateStatIcon({
  accent,
  type,
}: {
  accent: "indigo" | "green" | "amber" | "red";
  type: "file" | "check" | "close" | "alert";
}) {
  return (
    <span className={`master-category-stat-icon master-category-stat-icon-${accent}`} aria-hidden="true">
      <svg viewBox="0 0 24 24">
        {type === "file" ? (
          <>
            <path
              d="M8 4.5h6l3 3v12H8z"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M14 4.5v3h3"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path d="M10 11h5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
            <path d="M10 14.5h5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
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

        {type === "alert" ? (
          <>
            <path
              d="M12 4.2 19 8.3v7.4l-7 4.1-7-4.1V8.3l7-4.1Z"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M12 8.5v4.5"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
            />
            <path
              d="M12 15.8h.01"
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

export default function MasterDataSubmodulePage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = use(params);
  const title = formatTitle(slug);
  const [isBarcodeModalOpen, setIsBarcodeModalOpen] = useState(false);
  const [isMoneyBoxModalOpen, setIsMoneyBoxModalOpen] = useState(false);
  const [isProductTemplateModalOpen, setIsProductTemplateModalOpen] = useState(false);

  if (slug === "product-template") {
    return (
      <>
        <section className="master-category-page">
          <div className="master-category-stats">
            {productTemplateStats.map((item) => (
              <article className="master-category-stat-card" key={item.label}>
                <ProductTemplateStatIcon accent={item.accent} type={item.type} />
                <div className="master-category-stat-copy">
                  <strong>{item.label}</strong>
                  <span>{item.value}</span>
                  <small>{item.note}</small>
                </div>
              </article>
            ))}
          </div>

          <section className="master-category-table-card">
            <div className="master-category-toolbar product-template-toolbar">
              <label className="master-category-search product-catalog-search">
                <span className="product-catalog-search-icon" aria-hidden="true">
                  <ProductCatalogControlIcon type="search" />
                </span>
                <input type="text" placeholder="Search Template name.." />
              </label>

              <select className="master-category-select" defaultValue="All Conditions">
                <option>All Conditions</option>
              </select>

              <button type="button" className="master-category-outline-button product-catalog-filter-button">
                <ProductCatalogControlIcon type="filter" />
                <span>Filter</span>
              </button>

              <button type="button" className="master-category-outline-button product-template-refresh-button">
                <ProductCatalogControlIcon type="reset" />
                <span>Refresh</span>
              </button>

              <button
                type="button"
                className="master-category-primary-button"
                onClick={() => setIsProductTemplateModalOpen(true)}
              >
                + Add new Template
              </button>
            </div>

            <div className="product-template-table">
              <div className="product-template-table-head">
                <span>#</span>
                <span>Template Code</span>
                <span>Template Name</span>
                <span>Details</span>
                <span>Start Date</span>
                <span>End Date</span>
                <span>Status</span>
                <span>Action</span>
              </div>

              {productTemplateRows.map((row) => (
                <div className="product-template-table-row" key={row.id}>
                  <span>{row.id}</span>
                  <span>{row.code}</span>
                  <span>{row.name}</span>
                  <span>{row.details}</span>
                  <span className="product-template-date-cell">
                    <strong>{row.startDate}</strong>
                    <small>{row.startTime}</small>
                  </span>
                  <span className="product-template-date-cell">
                    <strong>{row.endDate}</strong>
                    <small>{row.endTime}</small>
                  </span>
                  <span>
                    <em className="product-template-status-badge">{row.status}</em>
                  </span>
                  <span className="master-category-actions">
                    <button type="button" className="master-category-icon-button master-category-icon-button-edit">
                      <MoneyBoxActionIcon type="edit" />
                    </button>
                    <button type="button" className="master-category-icon-button product-template-icon-button-clone">
                      <ProductTemplateStatIcon accent="indigo" type="file" />
                    </button>
                    <button type="button" className="master-category-icon-button money-box-icon-button-delete">
                      <MoneyBoxActionIcon type="delete" />
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

        {isProductTemplateModalOpen ? (
          <div className="payment-modal-backdrop" onClick={() => setIsProductTemplateModalOpen(false)}>
            <div
              className="payment-modal product-template-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="product-template-modal-title"
            >
              <div className="payment-modal-header product-template-modal-header">
                <div>
                  <h3 id="product-template-modal-title">New Template import file</h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={() => setIsProductTemplateModalOpen(false)}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="product-template-modal-form">
                <div className="product-template-modal-field">
                  <span>Select file <sup>*</sup></span>
                  <button type="button" className="product-template-upload-box">
                    <strong>Drag the file here or click and select the file</strong>
                    <small>Only Excel file (.xls, .xlsx)</small>
                    <small>Supported</small>
                    <small>maximum file size: 10MB</small>
                  </button>
                </div>

                <label className="product-template-modal-field">
                  <span>Import Type <sup>*</sup></span>
                  <select defaultValue="">
                    <option value="" disabled>Add new and update</option>
                  </select>
                </label>

                <label className="product-template-modal-field">
                  <span>File Formate <sup>*</sup></span>
                  <select defaultValue="">
                    <option value="" disabled>Excel (.xlsx)</option>
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
        ) : null}
      </>
    );
  }

  if (slug === "barcode-database") {
    return (
      <>
        <section className="master-category-page">
          <div className="master-category-stats barcode-database-stats">
            {barcodeDatabaseStats.map((item) => (
              <article className="master-category-stat-card" key={item.label}>
                <BarcodeDatabaseStatIcon accent={item.accent} type={item.type} />
                <div className="master-category-stat-copy">
                  <strong>{item.label}</strong>
                  <span>{item.value}</span>
                  <small>{item.note}</small>
                </div>
              </article>
            ))}
          </div>

          <div className="product-catalog-toolbar">
            <button
              type="button"
              className="master-category-primary-button"
              onClick={() => setIsBarcodeModalOpen(true)}
            >
              Add New Barcode +
            </button>
          </div>

          <section className="master-category-table-card barcode-database-filter-card">
            <div className="product-catalog-filters">
              <label className="master-category-search product-catalog-search">
                <span className="product-catalog-search-icon" aria-hidden="true">
                  <ProductCatalogControlIcon type="search" />
                </span>
                <input type="text" placeholder="Search Barcode or Brand name..." />
              </label>

              <select className="master-category-select" defaultValue="All categories">
                <option>All categories</option>
              </select>

              <select className="master-category-select" defaultValue="All Brand">
                <option>All Brand</option>
              </select>

              <select className="master-category-select" defaultValue="All Status">
                <option>All Status</option>
              </select>

              <button type="button" className="master-category-outline-button product-catalog-filter-button">
                <ProductCatalogControlIcon type="filter" />
                <span>Filter</span>
              </button>

              <button type="button" className="master-category-outline-button product-catalog-reset-button">
                <ProductCatalogControlIcon type="reset" />
                <span>Reset</span>
              </button>
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

              {barcodeDatabaseRows.map((row, index) => (
                <div className="barcode-database-table-row" key={`${row.barcode}-${index}`}>
                  <span>{row.id}</span>
                  <span>
                    <BarcodeRowPreview />
                  </span>
                  <span className="product-catalog-product-cell">
                    <span className={`product-catalog-product-icon product-catalog-product-icon-${row.type}`}>
                      <ProductCatalogRowIcon type={row.type} />
                    </span>
                    <span className="product-catalog-product-copy">
                      <strong>{row.productName}</strong>
                      <small>{row.productNote}</small>
                    </span>
                  </span>
                  <span>{row.sku}</span>
                  <span>{row.category}</span>
                  <span>{row.brand}</span>
                  <span>{row.unit}</span>
                  <span>
                    <em
                      className={`barcode-database-status-badge${
                        row.status === "Unmapped" ? " barcode-database-status-badge-unmapped" : ""
                      }`}
                    >
                      {row.status}
                    </em>
                  </span>
                  <span className="barcode-database-date-cell">
                    <strong>{row.addedDate}</strong>
                    <small>{row.addedTime}</small>
                  </span>
                  <span className="master-category-actions">
                    <button type="button" className="master-category-icon-button master-category-icon-button-edit">
                      <MoneyBoxActionIcon type="edit" />
                    </button>
                    <button type="button" className="master-category-icon-button product-catalog-icon-button-more">
                      <ProductCatalogControlIcon type="more" />
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
                <button type="button" className="master-category-page-chip">3</button>
                <button type="button" className="master-category-page-chip">4</button>
                <button type="button" className="master-category-page-chip">5</button>
                <button type="button" className="master-category-page-chip">...</button>
                <button type="button" className="master-category-page-chip">150</button>
                <button type="button" className="master-category-page-button">Next Page {">"}</button>
              </div>

              <select className="master-category-page-size" defaultValue="20">
                <option>20</option>
              </select>
            </div>
          </section>
        </section>

        {isBarcodeModalOpen ? (
          <div className="payment-modal-backdrop" onClick={() => setIsBarcodeModalOpen(false)}>
            <div
              className="payment-modal barcode-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="barcode-modal-title"
            >
              <div className="payment-modal-header barcode-modal-header">
                <div>
                  <h3 id="barcode-modal-title">Add new Barcode</h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={() => setIsBarcodeModalOpen(false)}
                  aria-label="Close modal"
                >
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
                        <ProductCatalogControlIcon type="search" />
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
                          <svg aria-hidden="true" viewBox="0 0 24 24">
                            <path
                              d="M8 4.5H4.5V8"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth="1.8"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                            />
                            <path
                              d="M16 4.5h3.5V8"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth="1.8"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                            />
                            <path
                              d="M8 19.5H4.5V16"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth="1.8"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                            />
                            <path
                              d="M16 19.5h3.5V16"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth="1.8"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                            />
                            <circle cx="12" cy="10" r="2.3" fill="none" stroke="currentColor" strokeWidth="1.8" />
                            <path
                              d="M9.2 18v-2.1a2.8 2.8 0 0 1 5.6 0V18"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth="1.8"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                            />
                          </svg>
                          <span>Scan</span>
                        </button>
                      </div>
                    </div>

                    <label className="payment-modal-field">
                      <span>Category</span>
                      <select defaultValue="">
                        <option value="" disabled>Select Category</option>
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>Brand</span>
                      <select defaultValue="">
                        <option value="" disabled>Select Brand</option>
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>Unit</span>
                      <select defaultValue="">
                        <option value="" disabled>Select Unit</option>
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
                        <ProductCatalogControlIcon type="search" />
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
                        <option value="" disabled>Select package type</option>
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>Pitch/Unite Per Quantity</span>
                      <select defaultValue="">
                        <option value="" disabled>12 pitch, 6 bottle</option>
                      </select>
                    </label>
                  </div>
                </div>

                <div className="barcode-modal-section">
                  <h4>Price and Inventory</h4>
                  <div className="barcode-modal-grid barcode-modal-grid-pricing">
                    <label className="payment-modal-field">
                      <span>Purchase Price</span>
                      <input type="text" placeholder="Enter Number" />
                    </label>

                    <label className="payment-modal-field">
                      <span>Sale Price (MRP)</span>
                      <input type="text" placeholder="Enter number" />
                    </label>

                    <label className="payment-modal-field">
                      <span>Discount</span>
                      <input type="text" placeholder="00" />
                    </label>

                    <label className="payment-modal-field">
                      <span>Sale Price</span>
                      <input type="text" placeholder="0.00" />
                    </label>

                    <label className="payment-modal-field">
                      <span>Stock Quantity</span>
                      <input type="text" placeholder="Enter Number" />
                    </label>

                    <label className="payment-modal-field">
                      <span>Minimum stock level</span>
                      <input type="text" placeholder="Enter number" />
                    </label>

                    <label className="payment-modal-field">
                      <span>Storage Location</span>
                      <select defaultValue="">
                        <option value="" disabled>Select Location</option>
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>Barcode location</span>
                      <select defaultValue="Active">
                        <option>Active</option>
                      </select>
                    </label>

                    <div className="barcode-modal-upload-card">
                      <span>Purchase Price</span>
                      <button type="button" className="barcode-modal-upload-box">
                        <strong>Upload picture</strong>
                        <small>(ex .xlsx, .xls)</small>
                        <small>maximum file size: 10MB</small>
                      </button>
                    </div>

                    <label className="payment-modal-field payment-modal-field-full">
                      <span>Additional Information</span>
                      <textarea placeholder="Enter additional information." />
                    </label>
                  </div>
                </div>

                <div className="barcode-modal-actions">
                  <button
                    type="button"
                    className="payment-modal-secondary-button"
                    onClick={() => setIsBarcodeModalOpen(false)}
                  >
                    Cancel
                  </button>
                  <button type="button" className="payment-modal-primary-button">
                    Save Barcode
                  </button>
                </div>
              </form>
            </div>
          </div>
        ) : null}
      </>
    );
  }

  if (slug === "category") {
    return (
      <section className="master-category-page">
        <div className="product-catalog-toolbar">
          <button type="button" className="master-category-outline-button product-catalog-export-button">
            Export
          </button>
          <button type="button" className="master-category-primary-button">
            Add New Product +
          </button>
        </div>

        <div className="master-category-stats">
          {productCatalogStats.map((item) => (
            <article className="master-category-stat-card" key={item.label}>
              <ProductCatalogStatIcon accent={item.accent} type={item.type} />
              <div className="master-category-stat-copy">
                <strong>{item.label}</strong>
                <span>{item.value}</span>
                <small>{item.note}</small>
              </div>
            </article>
          ))}
        </div>

        <section className="master-category-table-card">
          <div className="product-catalog-filters">
            <label className="master-category-search product-catalog-search">
              <span className="product-catalog-search-icon" aria-hidden="true">
                <ProductCatalogControlIcon type="search" />
              </span>
              <input type="text" placeholder="Search Product or Brand name..." />
            </label>

            <select className="master-category-select" defaultValue="All categories">
              <option>All categories</option>
            </select>

            <select className="master-category-select" defaultValue="All Brand">
              <option>All Brand</option>
            </select>

            <select className="master-category-select" defaultValue="All Status">
              <option>All Status</option>
            </select>

            <button type="button" className="master-category-outline-button product-catalog-filter-button">
              <ProductCatalogControlIcon type="filter" />
              <span>Filter</span>
            </button>

            <button type="button" className="master-category-outline-button product-catalog-reset-button">
              <ProductCatalogControlIcon type="reset" />
              <span>Reset</span>
            </button>
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
                  <span className={`product-catalog-product-icon product-catalog-product-icon-${row.type}`}>
                    <ProductCatalogRowIcon type={row.type} />
                  </span>
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
                  <em className="product-catalog-status-badge">{row.status}</em>
                </span>
                <span className="master-category-actions">
                  <button type="button" className="master-category-icon-button master-category-icon-button-edit">
                    <MoneyBoxActionIcon type="edit" />
                  </button>
                  <button type="button" className="master-category-icon-button product-catalog-icon-button-more">
                    <ProductCatalogControlIcon type="more" />
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
              <button type="button" className="master-category-page-chip">3</button>
              <button type="button" className="master-category-page-chip">4</button>
              <button type="button" className="master-category-page-chip">5</button>
              <button type="button" className="master-category-page-chip">...</button>
              <button type="button" className="master-category-page-chip">150</button>
              <button type="button" className="master-category-page-button">Next Page {">"}</button>
            </div>

            <select className="master-category-page-size" defaultValue="20">
              <option>20</option>
            </select>
          </div>
        </section>
      </section>
    );
  }

  if (slug === "money-box") {
    return (
      <>
        <section className="master-category-page">
          <div className="master-category-stats">
            {moneyBoxStats.map((item) => (
              <article className="master-category-stat-card" key={item.label}>
                <MoneyBoxStatIcon accent={item.accent} type={item.type} />
                <div className="master-category-stat-copy">
                  <strong>{item.label}</strong>
                  <span>{item.value}</span>
                  <small>{item.note}</small>
                </div>
              </article>
            ))}
          </div>

          <section className="master-category-table-card">
            <div className="master-category-toolbar money-box-toolbar">
              <label className="master-category-search money-box-search">
                <span className="money-box-search-icon" aria-hidden="true">
                  <MoneyBoxToolbarIcon type="search" />
                </span>
                <input type="text" placeholder="Search Suppler or Brand name..." />
              </label>

              <select className="master-category-select" defaultValue="All conditions">
                <option>All conditions</option>
              </select>

              <button type="button" className="master-category-outline-button money-box-filter-button">
                <MoneyBoxToolbarIcon type="filter" />
                <span>Filter</span>
              </button>

              <button
                type="button"
                className="master-category-primary-button"
                onClick={() => setIsMoneyBoxModalOpen(true)}
              >
                Add New payment +
              </button>
            </div>

            <div className="money-box-table">
              <div className="money-box-table-head">
                <span>#</span>
                <span>Suppler Code</span>
                <span>Code</span>
                <span>Type</span>
                <span>Present Balance</span>
                <span>Status</span>
                <span>Date</span>
                <span>Action</span>
              </div>

              {moneyBoxRows.map((row) => (
                <div className="money-box-table-row" key={row.id}>
                  <span>{row.id}</span>
                  <span>{row.supplierCode}</span>
                  <span>{row.code}</span>
                  <span>{row.type}</span>
                  <span>{row.balance}</span>
                  <span>
                    <em className="master-category-status-badge">{row.status}</em>
                  </span>
                  <span>{row.date}</span>
                  <span className="master-category-actions">
                    <button type="button" className="master-category-icon-button master-category-icon-button-edit">
                      <MoneyBoxActionIcon type="edit" />
                    </button>
                    <button type="button" className="master-category-icon-button money-box-icon-button-delete">
                      <MoneyBoxActionIcon type="delete" />
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

        {isMoneyBoxModalOpen ? (
          <div className="payment-modal-backdrop" onClick={() => setIsMoneyBoxModalOpen(false)}>
            <div
              className="payment-modal money-box-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="money-box-modal-title"
            >
              <div className="payment-modal-header money-box-modal-header">
                <div>
                  <h3 id="money-box-modal-title">Add New Money Box</h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={() => setIsMoneyBoxModalOpen(false)}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="payment-modal-form money-box-modal-form">
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
                  <button
                    type="button"
                    className="payment-modal-secondary-button money-box-modal-secondary-button"
                    onClick={() => setIsMoneyBoxModalOpen(false)}
                  >
                    Reset
                  </button>
                  <button type="button" className="payment-modal-primary-button money-box-modal-primary-button">
                    Save Change
                  </button>
                </div>
              </form>
            </div>
          </div>
        ) : null}
      </>
    );
  }

  return (
    <section className="admin-dashboard">
      <article className="admin-dashboard-panel">
        <h2>{title}</h2>
        <p>Manage {title.toLowerCase()} records from the Master Data module.</p>
      </article>
    </section>
  );
}
