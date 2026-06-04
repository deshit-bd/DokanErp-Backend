"use client";

import { use, useState } from "react";
import { FiAlertCircle, FiCheckCircle, FiCreditCard, FiDollarSign, FiDownload, FiEye, FiFileText, FiFolder, FiMoreVertical, FiPackage, FiPauseCircle, FiRefreshCw, FiTrash2 } from "react-icons/fi";
import { LuArchive, LuBadgeCheck, LuBadgeInfo, LuCircleOff } from "react-icons/lu";

const masterDataPageTitles: Record<string, string> = {
  "product-category": "Product Category",
  "product-catalog": "Product Catalog",
  brand: "Brand",
  unit: "Unit",
  "barcode-database": "Barcode Database",
  "import-export": "Import / Export",
  "money-box": "Money Box",
  "supplier-data": "Supplier Data",
  "bank-account": "Bank Account",
  "product-template": "Product Template",
};

const moneyBoxStats = [
  { label: "Total Money Boxes", value: "16", note: "All Money Boxes", accent: "indigo" as const, type: "users" as const },
  { label: "Total Balance", value: "৳251,200", note: "Current Balance", accent: "green" as const, type: "balance" as const },
  { label: "Active Boxes", value: "14", note: "Currently Active", accent: "indigo" as const, type: "check" as const },
  { label: "Inactive Boxes", value: "2", note: "Currently Inactive", accent: "red" as const, type: "alert" as const },
];

const importExportStats = [
  { label: "Total Imports", value: "4,516", note: "All Imported Records", accent: "indigo" as const, type: "import" as const },
  { label: "Successful Imports", value: "4,380", note: "Imported Successfully", accent: "green" as const, type: "success" as const },
  { label: "Failed Imports", value: "136", note: "Need Review", accent: "amber" as const, type: "failed" as const },
  { label: "Total Exports", value: "2,512", note: "All Exported Records", accent: "red" as const, type: "export" as const },
];

const importRows = [
  { id: 1, fileName: "products-bulk-may.xlsx", module: "Product Catalog", importedBy: "Super Admin", totalRecords: 1240, success: 1218, failed: 22, status: "Completed", date: "31 may 2024" },
  { id: 2, fileName: "suppliers-q2.csv", module: "Supplier Data", importedBy: "Admin Team", totalRecords: 560, success: 560, failed: 0, status: "Completed", date: "30 may 2024" },
  { id: 3, fileName: "units-setup.xlsx", module: "Unit", importedBy: "Operations", totalRecords: 48, success: 44, failed: 4, status: "Partial", date: "29 may 2024" },
  { id: 4, fileName: "brands-master.csv", module: "Brand", importedBy: "Super Admin", totalRecords: 190, success: 170, failed: 20, status: "Failed", date: "28 may 2024" },
];

const exportRows = [
  { id: 1, fileName: "products-export-may.xlsx", module: "Product Catalog", exportedBy: "Super Admin", records: 1240, format: "Excel", date: "31 may 2024" },
  { id: 2, fileName: "bank-accounts-report.csv", module: "Bank Account", exportedBy: "Finance Team", records: 32, format: "CSV", date: "30 may 2024" },
  { id: 3, fileName: "supplier-directory.pdf", module: "Supplier Data", exportedBy: "Admin Team", records: 4516, format: "PDF", date: "29 may 2024" },
  { id: 4, fileName: "barcode-database.xlsx", module: "Barcode Database", exportedBy: "Inventory Team", records: 98765, format: "Excel", date: "28 may 2024" },
];

const moneyBoxRows = Array.from({ length: 10 }, (_, index) => ({
  id: index + 1,
  shopName: index % 2 === 0 ? "Rahman Store" : "Bondhon Store",
  boxName: index === 2 ? "Bkash Wallet" : "Cash Counter",
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

const productCatalogRows = [
  {
    id: 1,
    name: "Sugar (White)",
    note: "Premium Quality",
    category: "Sugar",
    brand: "Fresh",
    unit: "1 KG",
    barcode: "8901234567001",
    purchasePrice: "$45",
    sellingPrice: "$50",
    status: "Active",
    type: "sugar",
  },
  {
    id: 2,
    name: "Soybean Oil",
    note: "5 Liter Bottle",
    category: "Oil",
    brand: "Teer",
    unit: "5 LT",
    barcode: "8901234567002",
    purchasePrice: "$820",
    sellingPrice: "$850",
    status: "Active",
    type: "oil",
  },
  {
    id: 3,
    name: "Miniket Rice",
    note: "Premium Rice",
    category: "Rice",
    brand: "Pran",
    unit: "25 KG",
    barcode: "8901234567003",
    purchasePrice: "$1850",
    sellingPrice: "$1950",
    status: "Active",
    type: "sugar",
  },
  {
    id: 4,
    name: "Fresh Milk",
    note: "Pasteurized Milk",
    category: "Dairy",
    brand: "Milk Vita",
    unit: "1 LT",
    barcode: "8901234567004",
    purchasePrice: "$75",
    sellingPrice: "$85",
    status: "Active",
    type: "oil",
  },
  {
    id: 5,
    name: "Salt",
    note: "Iodized Salt",
    category: "Essentials",
    brand: "ACI Pure",
    unit: "1 KG",
    barcode: "8901234567005",
    purchasePrice: "$38",
    sellingPrice: "$45",
    status: "Active",
    type: "sugar",
  },
  {
    id: 6,
    name: "Biscuits",
    note: "Chocolate Flavor",
    category: "Snacks",
    brand: "Olympic",
    unit: "12 PCS",
    barcode: "8901234567006",
    purchasePrice: "$95",
    sellingPrice: "$120",
    status: "Active",
    type: "oil",
  },
  {
    id: 7,
    name: "Orange Juice",
    note: "Natural Fruit Drink",
    category: "Beverages",
    brand: "Pran",
    unit: "1 LT",
    barcode: "8901234567007",
    purchasePrice: "$105",
    sellingPrice: "$125",
    status: "Inactive",
    type: "oil",
  },
  {
    id: 8,
    name: "Detergent Powder",
    note: "Family Pack",
    category: "Household",
    brand: "Wheel",
    unit: "2 KG",
    barcode: "8901234567008",
    purchasePrice: "$180",
    sellingPrice: "$220",
    status: "Active",
    type: "sugar",
  },
  {
    id: 9,
    name: "Eggs",
    note: "Farm Fresh",
    category: "Poultry",
    brand: "Local Farm",
    unit: "12 PCS",
    barcode: "8901234567009",
    purchasePrice: "$130",
    sellingPrice: "$145",
    status: "Active",
    type: "oil",
  },
  {
    id: 10,
    name: "Instant Noodles",
    note: "Masala Flavor",
    category: "Food",
    brand: "Mr. Noodles",
    unit: "8 PCS",
    barcode: "8901234567010",
    purchasePrice: "$110",
    sellingPrice: "$130",
    status: "Active",
    type: "sugar",
  },
];

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
  status: index < 2 ? "Mapped" : index === 5 ? "Archived" : "Unmapped",
  addedDate: "30 may, 2024",
  addedTime: "10:30 AM",
  type: index % 2 === 0 ? "sugar" : "oil",
  barcode: "79359426436872",
}));

const productTemplateStats = [
  { label: "Total Templates", value: "25", note: "All Product Templates", accent: "indigo" as const, icon: FiFileText },
  { label: "Active Templates", value: "22", note: "Currently Active", accent: "green" as const, icon: FiCheckCircle },
  { label: "Used Templates", value: "18", note: "Used by Products", accent: "amber" as const, icon: FiPackage },
  { label: "Unused Templates", value: "4", note: "Available for Use", accent: "red" as const, icon: FiFolder },
];

const brandStats = [
  { label: "Total Brands", value: "156", note: "All Brands", accent: "indigo" as const, icon: LuBadgeInfo },
  { label: "Active Brands", value: "143", note: "Active Brands", accent: "green" as const, icon: LuBadgeCheck },
  { label: "Inactive Brands", value: "10", note: "Inactive Brands", accent: "amber" as const, icon: LuCircleOff },
  { label: "Archived Brands", value: "3", note: "Archived Brands", accent: "red" as const, icon: LuArchive },
];

const brandRows = [
  {
    id: 1,
    brandName: "PRAN",
    description: "Food & Beverage Products",
    categories: 8,
    products: 232,
    status: "Active",
    createdDate: "2024-05-31",
  },
  {
    id: 2,
    brandName: "Fresh",
    description: "Dairy & Grocery Products",
    categories: 5,
    products: 145,
    status: "Active",
    createdDate: "2024-05-29",
  },
  {
    id: 3,
    brandName: "Radhuni",
    description: "Spices & Cooking Essentials",
    categories: 4,
    products: 98,
    status: "Active",
    createdDate: "2024-05-28",
  },
  {
    id: 4,
    brandName: "Teer",
    description: "Oil, Flour & Basic Foods",
    categories: 6,
    products: 87,
    status: "Active",
    createdDate: "2024-05-25",
  },
  {
    id: 5,
    brandName: "Olympic",
    description: "Biscuits & Snacks",
    categories: 3,
    products: 64,
    status: "Active",
    createdDate: "2024-05-24",
  },
  {
    id: 6,
    brandName: "Nestle",
    description: "Nutrition & Beverage Products",
    categories: 4,
    products: 52,
    status: "Active",
    createdDate: "2024-05-22",
  },
  {
    id: 7,
    brandName: "Milk Vita",
    description: "Milk & Dairy Products",
    categories: 2,
    products: 18,
    status: "Active",
    createdDate: "2024-05-20",
  },
  {
    id: 8,
    brandName: "Coca-Cola",
    description: "Soft Drinks & Beverages",
    categories: 1,
    products: 12,
    status: "Inactive",
    createdDate: "2024-05-18",
  },
  {
    id: 9,
    brandName: "Pepsi",
    description: "Carbonated Soft Drinks",
    categories: 1,
    products: 10,
    status: "Inactive",
    createdDate: "2024-05-16",
  },
  {
    id: 10,
    brandName: "Unilever",
    description: "Personal Care & Household Products",
    categories: 7,
    products: 76,
    status: "Archived",
    createdDate: "2024-05-12",
  },
];

const unitStats = [
  { label: "Total Units", value: "156", note: "All Units", accent: "indigo" as const, type: "file" as const },
  { label: "Active Units", value: "143", note: "Active Units", accent: "green" as const, type: "check" as const },
  { label: "Inactive Units", value: "13", note: "Inactive Units", accent: "amber" as const, type: "close" as const },
  { label: "Archived Units", value: "3", note: "Archived Units", accent: "red" as const, type: "delete" as const },
];

const unitRows = [
  { id: 1, name: "Piece", shortName: "Pcs", type: "Countable", description: "Count as a pieces", status: "Active", date: "31 may 2024" },
  { id: 2, name: "KG", shortName: "KG", type: "Weight", description: "Count as a kilogram", status: "Active", date: "31 may 2024" },
  { id: 3, name: "Gram", shortName: "GM", type: "Weight", description: "Count as a kilogram", status: "Active", date: "31 may 2024" },
  { id: 4, name: "Liter", shortName: "KG", type: "Weight", description: "Count as a kilogram", status: "Active", date: "31 may 2024" },
  { id: 5, name: "Millimetre", shortName: "KG", type: "Weight", description: "Count as a kilogram", status: "Active", date: "31 may 2024" },
  { id: 6, name: "Box", shortName: "KG", type: "Weight", description: "Count as a kilogram", status: "Active", date: "31 may 2024" },
  { id: 7, name: "Carton", shortName: "KG", type: "Weight", description: "Count as a kilogram", status: "Active", date: "31 may 2024" },
  { id: 8, name: "Box", shortName: "KG", type: "Weight", description: "Count as a kilogram", status: "Inactive", date: "31 may 2024" },
  { id: 9, name: "Carton", shortName: "KG", type: "Weight", description: "Count as a kilogram", status: "Active", date: "31 may 2024" },
  { id: 10, name: "Gram", shortName: "KG", type: "Weight", description: "Count as a kilogram", status: "Active", date: "31 may 2024" },
];

const supplierStats = [
  { label: "Total Suppliers", value: "4516", note: "All Suppliers", accent: "indigo" as const, type: "users" as const },
  { label: "Active Suppliers", value: "4500", note: "Active Suppliers", accent: "green" as const, type: "check" as const },
  { label: "Inactive Suppliers", value: "16", note: "All Inactive Suppliers", accent: "amber" as const, type: "close" as const },
  { label: "Blocked Suppliers", value: "12,684", note: "All Blocked", accent: "red" as const, type: "alert" as const },
];

const bankAccountStats = [
  { label: "Total Accounts", value: "32", note: "All Accounts", accent: "indigo" as const, icon: FiCreditCard },
  { label: "Active Accounts", value: "28", note: "Active Accounts", accent: "green" as const, icon: FiCheckCircle },
  { label: "Inactive Accounts", value: "2", note: "Inactive Accounts", accent: "amber" as const, icon: FiPauseCircle },
  { label: "Total Balance", value: "৳15,487,650", note: "Current Balance", accent: "red" as const, icon: FiDollarSign },
];

const bankAccountRows = [
  {
    id: 1,
    storeName: "Main Outlet",
    accountCode: "BANK-001",
    accountName: "Main Business Account",
    bankName: "BRAC Bank",
    branch: "Gazipur Branch",
    accountNumber: "****2145",
    accountType: "Current",
    currentBalance: 487650.75,
    currency: "BDT",
    status: "Active",
    isDefault: true,
    updatedAt: "2025-06-01",
  },
  {
    id: 2,
    storeName: "Gazipur Store",
    accountCode: "BANK-002",
    accountName: "Daily Sales Deposit",
    bankName: "Dutch-Bangla Bank",
    branch: "Kaliganj Branch",
    accountNumber: "****1230",
    accountType: "Current",
    currentBalance: 156420.5,
    currency: "BDT",
    status: "Active",
    isDefault: false,
    updatedAt: "2025-06-01",
  },
  {
    id: 3,
    storeName: "Uttara Store",
    accountCode: "BANK-003",
    accountName: "Supplier Payment Account",
    bankName: "City Bank",
    branch: "Uttara Branch",
    accountNumber: "****7890",
    accountType: "Current",
    currentBalance: 94350.0,
    currency: "BDT",
    status: "Active",
    isDefault: false,
    updatedAt: "2025-05-31",
  },
  {
    id: 4,
    storeName: "Head Office",
    accountCode: "BANK-004",
    accountName: "Payroll Account",
    bankName: "Eastern Bank PLC",
    branch: "Gulshan Branch",
    accountNumber: "****4582",
    accountType: "Savings",
    currentBalance: 78500.0,
    currency: "BDT",
    status: "Active",
    isDefault: false,
    updatedAt: "2025-05-30",
  },
  {
    id: 5,
    storeName: "Main Outlet",
    accountCode: "BANK-005",
    accountName: "Emergency Reserve Fund",
    bankName: "Prime Bank",
    branch: "Motijheel Branch",
    accountNumber: "****9630",
    accountType: "Savings",
    currentBalance: 650000.0,
    currency: "BDT",
    status: "Active",
    isDefault: false,
    updatedAt: "2025-05-29",
  },
  {
    id: 6,
    storeName: "Online Shop",
    accountCode: "BANK-006",
    accountName: "Online Order Collection",
    bankName: "Bank Asia",
    branch: "Dhanmondi Branch",
    accountNumber: "****7412",
    accountType: "Current",
    currentBalance: 128940.25,
    currency: "BDT",
    status: "Active",
    isDefault: false,
    updatedAt: "2025-06-01",
  },
  {
    id: 7,
    storeName: "Mirpur Store",
    accountCode: "BANK-007",
    accountName: "VAT & Tax Account",
    bankName: "Islami Bank Bangladesh PLC",
    branch: "Mirpur Branch",
    accountNumber: "****8524",
    accountType: "Savings",
    currentBalance: 42500.0,
    currency: "BDT",
    status: "Active",
    isDefault: false,
    updatedAt: "2025-05-28",
  },
  {
    id: 8,
    storeName: "Tongi Store",
    accountCode: "BANK-008",
    accountName: "Branch Store Account",
    bankName: "Pubali Bank",
    branch: "Tongi Branch",
    accountNumber: "****3691",
    accountType: "Current",
    currentBalance: 212750.0,
    currency: "BDT",
    status: "Inactive",
    isDefault: false,
    updatedAt: "2025-05-25",
  },
  {
    id: 9,
    storeName: "Gazipur Store",
    accountCode: "BANK-009",
    accountName: "Petty Cash Reserve",
    bankName: "Sonali Bank",
    branch: "Gazipur Sadar Branch",
    accountNumber: "****9517",
    accountType: "Savings",
    currentBalance: 15000.0,
    currency: "BDT",
    status: "Inactive",
    isDefault: false,
    updatedAt: "2025-05-20",
  },
  {
    id: 10,
    storeName: "Banani Store",
    accountCode: "BANK-010",
    accountName: "Legacy Business Account",
    bankName: "Mutual Trust Bank",
    branch: "Banani Branch",
    accountNumber: "****4862",
    accountType: "Current",
    currentBalance: 0.0,
    currency: "BDT",
    status: "Closed",
    isDefault: false,
    updatedAt: "2025-04-15",
  },
];

const productTemplateRows = Array.from({ length: 10 }, (_, index) => ({
  id: index + 1,
  code: `TPL-00${index + 1}`,
  name: index % 2 === 0 ? "Basic Grocery Template" : "Fresh Food Template",
  category: index % 3 === 0 ? "Essentials" : index % 3 === 1 ? "Beverages" : "Household",
  usedByProducts: index % 4 === 0 ? 12 : index % 4 === 1 ? 8 : index % 4 === 2 ? 0 : 5,
  status: index === 8 ? "Draft" : index === 9 ? "Archived" : "Active",
  createdDate: index % 2 === 0 ? "31 may 2024" : "29 may 2024",
}));

function formatTitle(slug: string) {
  return masterDataPageTitles[slug] ?? slug.replace(/-/g, " ").replace(/\b\w/g, (char) => char.toUpperCase());
}

function formatBankAccountBalance(amount: number, currency: string) {
  return `${currency} ${amount.toLocaleString("en-US", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;
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

function ImportExportStatIcon({
  accent,
  type,
}: {
  accent: "indigo" | "green" | "amber" | "red";
  type: "import" | "success" | "failed" | "export";
}) {
  return (
    <span className={`master-category-stat-icon master-category-stat-icon-${accent}`} aria-hidden="true">
      <svg viewBox="0 0 24 24">
        {type === "import" ? (
          <>
            <path d="M12 5v10" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
            <path d="m8.5 11.5 3.5 3.5 3.5-3.5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
            <path d="M6 18.5h12" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
          </>
        ) : null}

        {type === "success" ? (
          <>
            <circle cx="12" cy="12" r="8.5" fill="none" stroke="currentColor" strokeWidth="1.8" />
            <path d="m8.6 12.1 2.1 2.1 4.7-4.9" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
          </>
        ) : null}

        {type === "failed" ? (
          <>
            <circle cx="12" cy="12" r="8.5" fill="none" stroke="currentColor" strokeWidth="1.8" />
            <path d="m9 9 6 6" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
            <path d="m15 9-6 6" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
          </>
        ) : null}

        {type === "export" ? (
          <>
            <path d="M12 19V9" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
            <path d="m15.5 12.5-3.5-3.5-3.5 3.5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
            <path d="M6 5.5h12" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
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

function BarcodeRowPreview({ barcode }: { barcode: string }) {
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
      <small>{barcode}</small>
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

function ProductTemplateCardIcon({
  accent,
  icon: Icon,
}: {
  accent: "indigo" | "green" | "amber" | "red";
  icon: typeof FiFileText;
}) {
  return (
    <span className={`master-category-stat-icon master-category-stat-icon-${accent}`} aria-hidden="true">
      <Icon />
    </span>
  );
}

function BrandStatIcon({
  accent,
  icon: Icon,
}: {
  accent: "indigo" | "green" | "amber" | "red";
  icon: typeof LuBadgeInfo;
}) {
  return (
    <span className={`master-category-stat-icon master-category-stat-icon-${accent}`} aria-hidden="true">
      <Icon />
    </span>
  );
}

function UnitStatIcon({
  accent,
  type,
}: {
  accent: "indigo" | "green" | "amber" | "red";
  type: "file" | "check" | "close" | "delete";
}) {
  return (
    <span className={`master-category-stat-icon master-category-stat-icon-${accent}`} aria-hidden="true">
      <svg viewBox="0 0 24 24">
        {type === "file" ? (
          <>
            <path
              d="M8 4.5h6l4 4V19.5H8z"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M14 4.5v4h4"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M10.5 12h5"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
            />
            <path
              d="M10.5 15.5h5"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
            />
          </>
        ) : null}

        {type === "check" ? (
          <>
            <circle
              cx="12"
              cy="12"
              r="8"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
            />
            <path
              d="m8.8 12 2.1 2.2 4.4-4.7"
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
            />
            <path
              d="m16 8-8 8"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
            />
          </>
        ) : null}

        {type === "delete" ? (
          <>
            <path
              d="M8 7.5h8"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
            />
            <path
              d="M9 7.5V6a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v1.5"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M7.5 7.5l.7 10h7.6l.7-10"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M10.5 10.5v4"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
            />
            <path
              d="M13.5 10.5v4"
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

function SupplierStatIcon({
  accent,
  type,
}: {
  accent: "indigo" | "green" | "amber" | "red";
  type: "users" | "check" | "close" | "alert";
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
              d="M15.5 9.5a2.5 2.5 0 1 0 0-5"
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
              d="M14 17a3.5 3.5 0 0 1 5.5-2.8"
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

function BankAccountStatIcon({
  accent,
  icon: Icon,
}: {
  accent: "indigo" | "green" | "amber" | "red";
  icon: typeof FiCreditCard;
}) {
  return (
    <span className={`master-category-stat-icon master-category-stat-icon-${accent}`} aria-hidden="true">
      <Icon />
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
  const [isBankAccountModalOpen, setIsBankAccountModalOpen] = useState(false);
  const [isUnitModalOpen, setIsUnitModalOpen] = useState(false);
  const [isBarcodeModalOpen, setIsBarcodeModalOpen] = useState(false);
  const [isMoneyBoxModalOpen, setIsMoneyBoxModalOpen] = useState(false);
  const [isProductTemplateModalOpen, setIsProductTemplateModalOpen] = useState(false);
  const [isProductCatalogExportOpen, setIsProductCatalogExportOpen] = useState(false);
  const [isBankAccountExportOpen, setIsBankAccountExportOpen] = useState(false);
  const [isProductCatalogModalOpen, setIsProductCatalogModalOpen] = useState(false);
  const [isBrandModalOpen, setIsBrandModalOpen] = useState(false);
  const [openBarcodeActionMenuId, setOpenBarcodeActionMenuId] = useState<number | null>(null);
  const [openMoneyBoxActionMenuId, setOpenMoneyBoxActionMenuId] = useState<number | null>(null);
  const [openProductTemplateActionMenuId, setOpenProductTemplateActionMenuId] = useState<number | null>(null);
  const [openImportActionMenuId, setOpenImportActionMenuId] = useState<number | null>(null);
  const [openExportActionMenuId, setOpenExportActionMenuId] = useState<number | null>(null);
  const [importExportTab, setImportExportTab] = useState<"import" | "export">("import");
  const [isImportDataModalOpen, setIsImportDataModalOpen] = useState(false);
  const [isExportDataModalOpen, setIsExportDataModalOpen] = useState(false);

  if (slug === "brand") {
    return (
      <section className="master-category-page">
        <div className="master-category-stats">
          {brandStats.map((item) => (
            <article className="master-category-stat-card" key={item.label}>
              <BrandStatIcon accent={item.accent} icon={item.icon} />
              <div className="master-category-stat-copy">
                <strong>{item.label}</strong>
                <span>{item.value}</span>
                <small>{item.note}</small>
              </div>
            </article>
          ))}
        </div>

        <section className="master-category-table-card">
          <div className="master-category-toolbar brand-page-toolbar">
            <label className="master-category-search product-catalog-search brand-page-search">
              <span className="product-catalog-search-icon" aria-hidden="true">
                <ProductCatalogControlIcon type="search" />
              </span>
              <input type="text" placeholder="Search brands..." />
            </label>

            <select className="master-category-select" defaultValue="All Status">
              <option>All Status</option>
              <option>Active</option>
              <option>Inactive</option>
              <option>Archived</option>
            </select>

            <button type="button" className="master-category-outline-button brand-page-reset-button">
              Clear Filters
            </button>

            <button
              type="button"
              className="master-category-primary-button brand-page-add-button"
              onClick={() => setIsBrandModalOpen(true)}
            >
              + Add Brand
            </button>
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
                      row.status === "Inactive"
                        ? " master-category-status-badge-inactive"
                        : row.status === "Archived"
                          ? " brand-page-status-badge-archived"
                          : ""
                    }`}
                  >
                    {row.status}
                  </em>
                </span>
                <span>{row.createdDate}</span>
                <span className="master-category-actions">
                  <button type="button" className="master-category-icon-button master-category-icon-button-edit">
                    <MoneyBoxActionIcon type="edit" />
                  </button>
                  <button type="button" className="master-category-icon-button master-category-icon-button-more">
                    <ProductCatalogControlIcon type="more" />
                  </button>
                </span>
              </div>
            ))}
          </div>

          <div className="master-category-footer">
            <span className="master-category-footer-text">Showing 10 brands total</span>

            <div className="master-category-pagination">
              <button type="button" className="master-category-page-button">{"<"} Preview</button>
              <button type="button" className="master-category-page-chip master-category-page-chip-active">1</button>
              <button type="button" className="master-category-page-chip">2</button>
              <button type="button" className="master-category-page-chip">...</button>
              <button type="button" className="master-category-page-chip">150</button>
              <button type="button" className="master-category-page-button">Next Page {">"}</button>
            </div>

            <select className="master-category-page-size" defaultValue="10">
              <option>10</option>
            </select>
          </div>
        </section>

        {isBrandModalOpen ? (
          <div className="payment-modal-backdrop" onClick={() => setIsBrandModalOpen(false)}>
            <div
              className="payment-modal brand-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="brand-modal-title"
            >
              <div className="payment-modal-header brand-modal-header">
                <div>
                  <h3 id="brand-modal-title">Add New Brand</h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={() => setIsBrandModalOpen(false)}
                  aria-label="Close modal"
                >
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
                  <button
                    type="button"
                    className="master-category-reset-button"
                    onClick={() => setIsBrandModalOpen(false)}
                  >
                    Cancel
                  </button>
                  <button type="button" className="master-category-save-button">Save Brand</button>
                </div>
              </form>
            </div>
          </div>
        ) : null}
      </section>
    );
  }

  if (slug === "supplier-data") {
    return (
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
      </section>
    );
  }

  if (slug === "bank-account") {
    return (
      <>
        <section className="master-category-page">
          <div className="master-category-stats">
            {bankAccountStats.map((item) => (
              <article className="master-category-stat-card" key={item.label}>
                <BankAccountStatIcon accent={item.accent} icon={item.icon} />
                <div className="master-category-stat-copy">
                  <strong>{item.label}</strong>
                  <span>{item.value}</span>
                  <small>{item.note}</small>
                </div>
              </article>
            ))}
          </div>

          <section className="master-category-table-card">
            <div className="master-category-toolbar bank-account-toolbar">
              <label className="master-category-search product-catalog-search bank-account-search">
                <span className="product-catalog-search-icon" aria-hidden="true">
                  <ProductCatalogControlIcon type="search" />
                </span>
                <input type="text" placeholder="Search account, bank or number..." />
              </label>

              <select className="master-category-select" defaultValue="All Stores">
                <option>All Stores</option>
                <option>Main Outlet</option>
                <option>Gazipur Store</option>
                <option>Uttara Store</option>
                <option>Head Office</option>
              </select>

              <select className="master-category-select" defaultValue="All Banks">
                <option>All Banks</option>
                <option>BRAC Bank</option>
                <option>Dutch-Bangla Bank</option>
                <option>City Bank</option>
                <option>Eastern Bank PLC</option>
              </select>

              <select className="master-category-select" defaultValue="All Status">
                <option>All Status</option>
                <option>Active</option>
                <option>Inactive</option>
                <option>Closed</option>
              </select>

              <button type="button" className="master-category-outline-button bank-account-reset-button">
                Reset
              </button>

              <div className="product-catalog-export-menu bank-account-export-menu">
                <button
                  type="button"
                  className="master-category-outline-button product-catalog-export-button"
                  onClick={() => setIsBankAccountExportOpen((current) => !current)}
                  aria-haspopup="menu"
                  aria-expanded={isBankAccountExportOpen}
                >
                  <span>Export</span>
                  <span className="product-catalog-export-caret">▼</span>
                </button>

                {isBankAccountExportOpen ? (
                  <div className="product-catalog-export-dropdown" role="menu">
                    <button type="button" className="product-catalog-export-item" role="menuitem">
                      Excel
                    </button>
                    <button type="button" className="product-catalog-export-item" role="menuitem">
                      CSV
                    </button>
                    <button type="button" className="product-catalog-export-item" role="menuitem">
                      PDF
                    </button>
                  </div>
                ) : null}
              </div>

              <button
                type="button"
                className="master-category-primary-button bank-account-add-button"
                onClick={() => setIsBankAccountModalOpen(true)}
              >
                + Add Account
              </button>
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

              {bankAccountRows.map((row) => (
                <div className="bank-account-table-row" key={row.id}>
                  <span>{row.id}</span>
                  <span>{row.storeName}</span>
                  <span>{row.accountName}</span>
                  <span>{row.bankName}</span>
                  <span>{row.accountNumber}</span>
                  <span>{row.branch}</span>
                  <span>{formatBankAccountBalance(row.currentBalance, row.currency)}</span>
                  <span>
                    <em
                      className={`master-category-status-badge${
                        row.status === "Inactive"
                          ? " unit-page-status-badge-inactive"
                          : row.status === "Closed"
                            ? " bank-account-status-badge-closed"
                            : ""
                      }`}
                    >
                      {row.status}
                    </em>
                  </span>
                  <span>{row.updatedAt}</span>
                  <span className="master-category-actions">
                    <button type="button" className="master-category-icon-button master-category-icon-button-edit">
                      <MoneyBoxActionIcon type="edit" />
                    </button>
                    <button type="button" className="master-category-icon-button master-category-icon-button-more">
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

        {isBankAccountModalOpen ? (
          <div className="payment-modal-backdrop" onClick={() => setIsBankAccountModalOpen(false)}>
            <div
              className="payment-modal bank-account-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="bank-account-modal-title"
            >
              <div className="payment-modal-header bank-account-modal-header">
                <div>
                  <h3 id="bank-account-modal-title">Add Bank Account</h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={() => setIsBankAccountModalOpen(false)}
                  aria-label="Close modal"
                >
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
                        <option value="" disabled>Select account type</option>
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
                  <button
                    type="button"
                    className="payment-modal-secondary-button bank-account-modal-secondary-button"
                    onClick={() => setIsBankAccountModalOpen(false)}
                  >
                    Cancel
                  </button>
                  <button type="button" className="payment-modal-primary-button bank-account-modal-primary-button">
                    Save Account
                  </button>
                </div>
              </form>
            </div>
          </div>
        ) : null}
      </>
    );
  }

  if (slug === "unit") {
    return (
      <>
        <section className="master-category-page">
          <div className="master-category-stats">
            {unitStats.map((item) => (
              <article className="master-category-stat-card" key={item.label}>
                <UnitStatIcon accent={item.accent} type={item.type} />
                <div className="master-category-stat-copy">
                  <strong>{item.label}</strong>
                  <span>{item.value}</span>
                  <small>{item.note}</small>
                </div>
              </article>
            ))}
          </div>

          <section className="master-category-table-card">
            <div className="master-category-toolbar unit-page-toolbar">
              <label className="master-category-search product-catalog-search unit-page-search">
                <span className="product-catalog-search-icon" aria-hidden="true">
                  <ProductCatalogControlIcon type="search" />
                </span>
                <input type="text" placeholder="Search units..." />
              </label>

              <select className="master-category-select" defaultValue="Type">
                <option>Type</option>
                <option>Countable</option>
                <option>Weight</option>
                <option>Volume</option>
              </select>

              <select className="master-category-select" defaultValue="Status">
                <option>Status</option>
                <option>Active</option>
                <option>Inactive</option>
                <option>Archived</option>
              </select>

              <button type="button" className="master-category-outline-button unit-page-reset-button">
                Clear Filters
              </button>

              <button type="button" className="master-category-primary-button unit-page-add-button" onClick={() => setIsUnitModalOpen(true)}>
                + Add New Unit
              </button>
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
                    <em
                      className={`master-category-status-badge${
                        row.status === "Inactive" ? " unit-page-status-badge-inactive" : ""
                      }`}
                    >
                      {row.status}
                    </em>
                  </span>
                  <span>{row.date}</span>
                  <span className="master-category-actions import-export-actions">
                    <button type="button" className="master-category-icon-button import-export-icon-button-view" aria-label="View Details">
                      <FiEye />
                    </button>
                    <button type="button" className="master-category-icon-button import-export-icon-button-download" aria-label="Download File">
                      <FiDownload />
                    </button>
                    <button type="button" className="master-category-icon-button import-export-icon-button-alert" aria-label="Download Error Log">
                      <FiAlertCircle />
                    </button>
                    <button type="button" className="master-category-icon-button import-export-icon-button-delete" aria-label="Delete Log">
                      <FiTrash2 />
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

        {isUnitModalOpen ? (
          <div className="payment-modal-backdrop" onClick={() => setIsUnitModalOpen(false)}>
            <div
              className="payment-modal unit-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="unit-modal-title"
            >
              <div className="payment-modal-header unit-modal-header">
                <div>
                  <h3 id="unit-modal-title">Add new unit</h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={() => setIsUnitModalOpen(false)}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="payment-modal-form unit-modal-form">
                <label className="payment-modal-field payment-modal-field-full unit-modal-field">
                  <span>Unit Name <sup>*</sup></span>
                  <input type="text" placeholder="Enter name" />
                </label>

                <label className="payment-modal-field payment-modal-field-full unit-modal-field">
                  <span>Short Name <sup>*</sup></span>
                  <input type="text" placeholder="Example: pcs" />
                </label>

                <label className="payment-modal-field payment-modal-field-full unit-modal-field">
                  <span>Unit Type <sup>*</sup></span>
                  <select defaultValue="">
                    <option value="" disabled>Select</option>
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
                  <span>Status <sup>*</sup></span>
                  <select defaultValue="Active">
                    <option>Active</option>
                    <option>Inactive</option>
                  </select>
                </label>

                <label className="unit-modal-check">
                  <input type="checkbox" defaultChecked />
                  <span>Visible in System</span>
                </label>

                <div className="payment-modal-actions unit-modal-actions">
                  <button
                    type="button"
                    className="payment-modal-secondary-button unit-modal-secondary-button"
                    onClick={() => setIsUnitModalOpen(false)}
                  >
                    Cancel
                  </button>
                  <button type="button" className="payment-modal-primary-button unit-modal-primary-button">
                    Save
                  </button>
                </div>
              </form>
            </div>
          </div>
        ) : null}
      </>
    );
  }

  if (slug === "product-template") {
    return (
      <>
        <section className="master-category-page">
          <div className="master-category-stats">
            {productTemplateStats.map((item) => (
              <article className="master-category-stat-card" key={item.label}>
                <ProductTemplateCardIcon accent={item.accent} icon={item.icon} />
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
                <input type="text" placeholder="Search Template..." />
              </label>

              <select className="master-category-select" defaultValue="All Status">
                <option>All Status</option>
                <option>Active</option>
                <option>Inactive</option>
                <option>Draft</option>
                <option>Archived</option>
              </select>

              <button type="button" className="master-category-outline-button product-template-refresh-button">
                <ProductCatalogControlIcon type="reset" />
                <span>Reset</span>
              </button>

              <button
                type="button"
                className="master-category-primary-button"
                onClick={() => setIsProductTemplateModalOpen(true)}
              >
                + Add Template
              </button>
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

              {productTemplateRows.map((row) => (
                <div className="product-template-table-row" key={row.id}>
                  <span>{row.id}</span>
                  <span>{row.code}</span>
                  <span>{row.name}</span>
                  <span>{row.category}</span>
                  <span>{row.usedByProducts}</span>
                  <span>
                    <em
                      className={`product-template-status-badge${
                        row.status === "Draft"
                          ? " unit-page-status-badge-inactive"
                          : row.status === "Archived"
                            ? " bank-account-status-badge-closed"
                            : ""
                      }`}
                    >
                      {row.status}
                    </em>
                  </span>
                  <span>{row.createdDate}</span>
                  <span className="master-category-actions">
                    <button type="button" className="master-category-icon-button master-category-icon-button-edit">
                      <MoneyBoxActionIcon type="edit" />
                    </button>
                    <span className="master-category-action-menu">
                      <button
                        type="button"
                        className="master-category-icon-button master-category-icon-button-more"
                        onClick={() =>
                          setOpenProductTemplateActionMenuId((current) => (current === row.id ? null : row.id))
                        }
                        aria-haspopup="menu"
                        aria-expanded={openProductTemplateActionMenuId === row.id}
                      >
                        <ProductCatalogControlIcon type="more" />
                      </button>
                      {openProductTemplateActionMenuId === row.id ? (
                        <div className="master-category-action-dropdown" role="menu">
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            View Template
                          </button>
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            Duplicate Template
                          </button>
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            Use Template
                          </button>
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            Archive Template
                          </button>
                          <button
                            type="button"
                            className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                            role="menuitem"
                          >
                            Delete Template
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

          <section className="master-category-table-card barcode-database-filter-card">
            <div className="barcode-database-filters">
              <label className="master-category-search product-catalog-search">
                <span className="product-catalog-search-icon" aria-hidden="true">
                  <ProductCatalogControlIcon type="search" />
                </span>
                <input type="text" placeholder="Search barcode, product or SKU..." />
              </label>

              <select className="master-category-select" defaultValue="Category">
                <option>Category</option>
              </select>

              <select className="master-category-select" defaultValue="Brand">
                <option>Brand</option>
              </select>

              <select className="master-category-select" defaultValue="Status">
                <option>Status</option>
                <option>Mapped</option>
                <option>Unmapped</option>
                <option>Archived</option>
              </select>

              <button type="button" className="master-category-outline-button product-catalog-reset-button">
                <span>Reset</span>
              </button>

              <button
                type="button"
                className="master-category-primary-button barcode-database-add-button"
                onClick={() => setIsBarcodeModalOpen(true)}
              >
                + Add Barcode
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
                    <BarcodeRowPreview barcode={row.barcode} />
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
                  <span className="barcode-database-date-cell">
                    <strong>{row.addedDate}</strong>
                    <small>{row.addedTime}</small>
                  </span>
                  <span className="master-category-actions">
                    <button type="button" className="master-category-icon-button master-category-icon-button-edit">
                      <MoneyBoxActionIcon type="edit" />
                    </button>
                    <span className="master-category-action-menu">
                      <button
                        type="button"
                        className="master-category-icon-button product-catalog-icon-button-more"
                        onClick={() =>
                          setOpenBarcodeActionMenuId((current) => (current === index ? null : index))
                        }
                        aria-haspopup="menu"
                        aria-expanded={openBarcodeActionMenuId === index}
                      >
                        <ProductCatalogControlIcon type="more" />
                      </button>
                      {openBarcodeActionMenuId === index ? (
                        <div className="master-category-action-dropdown" role="menu">
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            View Barcode
                          </button>
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            Print Barcode
                          </button>
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            Download Barcode
                          </button>
                          <button
                            type="button"
                            className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                            role="menuitem"
                          >
                            Delete Barcode
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

  if (slug === "product-catalog") {
    return (
      <>
        <section className="master-category-page">
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
              <input type="text" placeholder="Search products, barcode or SKU..." />
            </label>

            <select className="master-category-select" defaultValue="Category">
              <option>Category</option>
            </select>

            <select className="master-category-select" defaultValue="Brand">
              <option>Brand</option>
            </select>

            <select className="master-category-select" defaultValue="Active">
              <option>Active</option>
              <option>Inactive</option>
            </select>

            <button type="button" className="master-category-outline-button product-catalog-reset-button">
              <span>Clear Filters</span>
            </button>

            <div className="product-catalog-export-menu">
              <button
                type="button"
                className="master-category-outline-button product-catalog-export-button"
                onClick={() => setIsProductCatalogExportOpen((current) => !current)}
                aria-haspopup="menu"
                aria-expanded={isProductCatalogExportOpen}
              >
                <span>Export</span>
                <span className="product-catalog-export-caret">▼</span>
              </button>

              {isProductCatalogExportOpen ? (
                <div className="product-catalog-export-dropdown" role="menu">
                  <button type="button" className="product-catalog-export-item" role="menuitem">
                    Excel
                  </button>
                  <button type="button" className="product-catalog-export-item" role="menuitem">
                    CSV
                  </button>
                  <button type="button" className="product-catalog-export-item" role="menuitem">
                    PDF
                  </button>
                </div>
              ) : null}
            </div>

            <button
              type="button"
              className="master-category-primary-button product-catalog-add-button"
              onClick={() => setIsProductCatalogModalOpen(true)}
            >
              + Add Product
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
        
        {isProductCatalogModalOpen ? (
          <div className="payment-modal-backdrop" onClick={() => setIsProductCatalogModalOpen(false)}>
            <div
              className="payment-modal product-catalog-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="product-catalog-modal-title"
            >
              <div className="payment-modal-header product-catalog-modal-header">
                <div>
                  <h3 id="product-catalog-modal-title">Add new Product</h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={() => setIsProductCatalogModalOpen(false)}
                  aria-label="Close modal"
                >
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
                        <option value="" disabled>Select category</option>
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
                  <button
                    type="button"
                    className="payment-modal-secondary-button"
                    onClick={() => setIsProductCatalogModalOpen(false)}
                  >
                    Cancel
                  </button>
                  <button type="button" className="payment-modal-primary-button">
                    Save Product
                  </button>
                </div>
              </form>
            </div>
          </div>
        ) : null}
      </>
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
                <input type="text" placeholder="Search box name, code or shop..." />
              </label>

              <select className="master-category-select" defaultValue="All Shops">
                <option>All Shops</option>
                <option>Rahman Store</option>
                <option>Bondhon Store</option>
                <option>Main Outlet</option>
              </select>

              <select className="master-category-select" defaultValue="All Status">
                <option>All Status</option>
                <option>Active</option>
                <option>Inactive</option>
              </select>

              <button type="button" className="master-category-outline-button">
                Clear Filters
              </button>

              <button
                type="button"
                className="master-category-primary-button"
                onClick={() => setIsMoneyBoxModalOpen(true)}
              >
                Add Money Box
              </button>
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
                    <em className="master-category-status-badge">{row.status}</em>
                  </span>
                  <span>{row.date}</span>
                  <span className="master-category-actions money-box-row-actions">
                    <button type="button" className="money-box-action-button money-box-action-button-edit">
                      <MoneyBoxActionIcon type="edit" />
                      <span>Edit</span>
                    </button>
                    <span className="master-category-action-menu">
                      <button
                        type="button"
                        className="money-box-action-button money-box-action-button-more"
                        onClick={() =>
                          setOpenMoneyBoxActionMenuId((current) => (current === row.id ? null : row.id))
                        }
                        aria-haspopup="menu"
                        aria-expanded={openMoneyBoxActionMenuId === row.id}
                      >
                        <ProductCatalogControlIcon type="more" />
                        <span>More</span>
                      </button>
                      {openMoneyBoxActionMenuId === row.id ? (
                        <div className="master-category-action-dropdown" role="menu">
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            👁 View Details
                          </button>
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            💰 Deposit Money
                          </button>
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            💸 Withdraw Money
                          </button>
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            🔄 Transfer Balance
                          </button>
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            📜 Transaction History
                          </button>
                          <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                            📦 Archive Box
                          </button>
                          <button
                            type="button"
                            className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                            role="menuitem"
                          >
                            🗑 Delete Box
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
                  <span>Shop</span>
                  <select defaultValue="">
                    <option value="" disabled>
                      Select shop
                    </option>
                    <option>Rahman Store</option>
                    <option>Bondhon Store</option>
                    <option>Main Outlet</option>
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

  if (slug === "import-export") {
    return (
      <section className="master-category-page">
        <div className="master-category-stats">
          {importExportStats.map((item) => (
            <article className="master-category-stat-card" key={item.label}>
              <ImportExportStatIcon accent={item.accent} type={item.type} />
              <div className="master-category-stat-copy">
                <strong>{item.label}</strong>
                <span>{item.value}</span>
                <small>{item.note}</small>
              </div>
            </article>
          ))}
        </div>

        <section className="master-category-table-card">
          <div className="import-export-tabs" role="tablist" aria-label="Import and export tabs">
            <button
              type="button"
              className={`import-export-tab${importExportTab === "import" ? " import-export-tab-active" : ""}`}
              onClick={() => setImportExportTab("import")}
              role="tab"
              aria-selected={importExportTab === "import"}
            >
              Import
            </button>
            <button
              type="button"
              className={`import-export-tab${importExportTab === "export" ? " import-export-tab-active" : ""}`}
              onClick={() => setImportExportTab("export")}
              role="tab"
              aria-selected={importExportTab === "export"}
            >
              Export
            </button>
          </div>

          <div className="master-category-toolbar import-export-toolbar">
            <label className="master-category-search product-catalog-search">
              <span className="product-catalog-search-icon" aria-hidden="true">
                <ProductCatalogControlIcon type="search" />
              </span>
              <input type="text" placeholder="Search file name..." />
            </label>

            <select className="master-category-select" defaultValue="All Modules">
              <option>All Modules</option>
              <option>Product Catalog</option>
              <option>Product Category</option>
              <option>Brand</option>
              <option>Unit</option>
              <option>Supplier Data</option>
              <option>Barcode Database</option>
              <option>Bank Account</option>
              <option>Money Box</option>
              <option>Product Template</option>
            </select>

            <select className="master-category-select" defaultValue="All Status">
              <option>All Status</option>
              <option>Completed</option>
              <option>Partial</option>
              <option>Failed</option>
              <option>Pending</option>
            </select>

            <button type="button" className="master-category-outline-button">
              Clear Filters
            </button>
          </div>

          {importExportTab === "import" ? (
            <>
              <div className="import-export-action-row">
                <div className="import-export-action-copy">
                  <strong>Import Data</strong>
                  <p>Upload an Excel or CSV file, validate rows, and review any failed entries from the error log.</p>
                </div>
                <button
                  type="button"
                  className="master-category-primary-button import-export-open-button"
                  onClick={() => setIsImportDataModalOpen(true)}
                >
                  Import Data
                </button>
              </div>

              <div className="import-export-table">
                <div className="import-export-table-head import-export-table-head-import">
                  <span>#</span>
                  <span>File Name</span>
                  <span>Module</span>
                  <span>Imported By</span>
                  <span>Total Records</span>
                  <span>Success</span>
                  <span>Failed</span>
                  <span>Status</span>
                  <span>Date</span>
                  <span>Actions</span>
                </div>

                {importRows.map((row) => (
                  <div className="import-export-table-row import-export-table-row-import" key={row.id}>
                    <span>{row.id}</span>
                    <span>{row.fileName}</span>
                    <span>{row.module}</span>
                    <span>{row.importedBy}</span>
                    <span>{row.totalRecords}</span>
                    <span>{row.success}</span>
                    <span>{row.failed}</span>
                    <span>
                      <em
                        className={`product-template-status-badge${
                          row.status === "Partial"
                            ? " unit-page-status-badge-inactive"
                            : row.status === "Failed"
                              ? " bank-account-status-badge-closed"
                              : ""
                        }`}
                      >
                        {row.status}
                      </em>
                    </span>
                    <span>{row.date}</span>
                    <span className="master-category-actions import-export-actions">
                      <button type="button" className="master-category-icon-button import-export-icon-button-view" aria-label="View">
                        <FiEye />
                      </button>
                      <span className="master-category-action-menu">
                        <button
                          type="button"
                          className="master-category-icon-button import-export-icon-button-more"
                          onClick={() => setOpenImportActionMenuId((current) => (current === row.id ? null : row.id))}
                          aria-haspopup="menu"
                          aria-expanded={openImportActionMenuId === row.id}
                          aria-label="More"
                        >
                          <FiMoreVertical />
                        </button>
                        {openImportActionMenuId === row.id ? (
                          <div className="master-category-action-dropdown" role="menu">
                            <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                              <FiEye />
                              <span>View Details</span>
                            </button>
                            <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                              <FiDownload />
                              <span>Download Original File</span>
                            </button>
                            <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                              <FiDownload />
                              <span>Download Error Log</span>
                            </button>
                            <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                              <FiRefreshCw />
                              <span>Retry Import</span>
                            </button>
                            <button
                              type="button"
                              className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                              role="menuitem"
                            >
                              <FiTrash2 />
                              <span>Delete Log</span>
                            </button>
                          </div>
                        ) : null}
                      </span>
                    </span>
                  </div>
                ))}
              </div>

              <div className="master-category-footer">
                <span className="master-category-footer-text">Showing {importRows.length} import logs total</span>

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
            </>
          ) : (
            <>
              <div className="import-export-action-row">
                <div className="import-export-action-copy">
                  <strong>Export Data</strong>
                  <p>Select a module, choose a file format, set optional filters, and export the latest data instantly.</p>
                </div>
                <button
                  type="button"
                  className="master-category-primary-button import-export-open-button"
                  onClick={() => setIsExportDataModalOpen(true)}
                >
                  Export Data
                </button>
              </div>

              <div className="import-export-table">
                <div className="import-export-table-head import-export-table-head-export">
                  <span>#</span>
                  <span>File Name</span>
                  <span>Module</span>
                  <span>Exported By</span>
                  <span>Records</span>
                  <span>Format</span>
                  <span>Date</span>
                  <span>Actions</span>
                </div>

                {exportRows.map((row) => (
                  <div className="import-export-table-row import-export-table-row-export" key={row.id}>
                    <span>{row.id}</span>
                    <span>{row.fileName}</span>
                    <span>{row.module}</span>
                    <span>{row.exportedBy}</span>
                    <span>{row.records}</span>
                    <span>{row.format}</span>
                    <span>{row.date}</span>
                    <span className="master-category-actions import-export-actions">
                      <button type="button" className="master-category-icon-button import-export-icon-button-download" aria-label="Download">
                        <FiDownload />
                      </button>
                      <span className="master-category-action-menu">
                        <button
                          type="button"
                          className="master-category-icon-button import-export-icon-button-more"
                          onClick={() => setOpenExportActionMenuId((current) => (current === row.id ? null : row.id))}
                          aria-haspopup="menu"
                          aria-expanded={openExportActionMenuId === row.id}
                          aria-label="More"
                        >
                          <FiMoreVertical />
                        </button>
                        {openExportActionMenuId === row.id ? (
                          <div className="master-category-action-dropdown" role="menu">
                            <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                              <FiDownload />
                              <span>Download File</span>
                            </button>
                            <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                              <FiEye />
                              <span>View Export Details</span>
                            </button>
                            <button type="button" className="master-category-action-dropdown-item" role="menuitem">
                              <FiRefreshCw />
                              <span>Generate Again</span>
                            </button>
                            <button
                              type="button"
                              className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                              role="menuitem"
                            >
                              <FiTrash2 />
                              <span>Delete Log</span>
                            </button>
                          </div>
                        ) : null}
                      </span>
                    </span>
                  </div>
                ))}
              </div>

              <div className="master-category-footer">
                <span className="master-category-footer-text">Showing {exportRows.length} export logs total</span>

                <div className="master-category-pagination">
                  <button type="button" className="master-category-page-button">{"<"} Preview</button>
                  <button type="button" className="master-category-page-chip master-category-page-chip-active">1</button>
                  <button type="button" className="master-category-page-chip">2</button>
                  <button type="button" className="master-category-page-chip">...</button>
                  <button type="button" className="master-category-page-chip">18</button>
                  <button type="button" className="master-category-page-button">Next Page {">"}</button>
                </div>

                <select className="master-category-page-size" defaultValue="10">
                  <option>10</option>
                </select>
              </div>
            </>
          )}
        </section>

        {isImportDataModalOpen ? (
          <div className="payment-modal-backdrop" onClick={() => setIsImportDataModalOpen(false)}>
            <div
              className="payment-modal import-export-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="import-data-modal-title"
            >
              <div className="payment-modal-header import-export-modal-header">
                <div>
                  <h3 id="import-data-modal-title">Import Data</h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={() => setIsImportDataModalOpen(false)}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="payment-modal-form import-export-modal-form">
                <label className="payment-modal-field payment-modal-field-full">
                  <span>Module *</span>
                  <select defaultValue="">
                    <option value="" disabled>Select Module</option>
                    <option>Product Catalog</option>
                    <option>Product Category</option>
                    <option>Brand</option>
                    <option>Unit</option>
                    <option>Supplier Data</option>
                    <option>Barcode Database</option>
                    <option>Bank Account</option>
                    <option>Money Box</option>
                    <option>Product Template</option>
                  </select>
                </label>

                <div className="payment-modal-field payment-modal-field-full">
                  <span>Download Template</span>
                  <button type="button" className="master-category-outline-button import-export-modal-secondary-action">
                    Download Template
                  </button>
                </div>

                <div className="payment-modal-field payment-modal-field-full">
                  <span>Upload File *</span>
                  <button type="button" className="import-export-upload-box">
                    <strong>Drag & drop Excel/CSV file</strong>
                    <small>Supported formats: .xlsx, .xls, .csv</small>
                  </button>
                </div>

                <label className="payment-modal-field">
                  <span>Duplicate Handling *</span>
                  <select defaultValue="Skip Duplicate">
                    <option>Skip Duplicate</option>
                    <option>Update Existing</option>
                    <option>Stop Import</option>
                  </select>
                </label>

                <label className="payment-modal-field">
                  <span>Error Handling *</span>
                  <select defaultValue="Skip Error Rows">
                    <option>Skip Error Rows</option>
                    <option>Stop on First Error</option>
                    <option>Import Valid Rows Only</option>
                  </select>
                </label>

                <label className="payment-modal-field payment-modal-field-full">
                  <span>Notes</span>
                  <textarea placeholder="Optional note" />
                </label>

                <label className="import-export-modal-check payment-modal-field-full">
                  <input type="checkbox" defaultChecked />
                  <span>Send report by email</span>
                </label>

                <div className="payment-modal-actions import-export-modal-actions">
                  <button
                    type="button"
                    className="payment-modal-secondary-button"
                    onClick={() => setIsImportDataModalOpen(false)}
                  >
                    Cancel
                  </button>
                  <button type="button" className="payment-modal-primary-button">
                    Import Data
                  </button>
                </div>
              </form>
            </div>
          </div>
        ) : null}

        {isExportDataModalOpen ? (
          <div className="payment-modal-backdrop" onClick={() => setIsExportDataModalOpen(false)}>
            <div
              className="payment-modal import-export-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="export-data-modal-title"
            >
              <div className="payment-modal-header import-export-modal-header">
                <div>
                  <h3 id="export-data-modal-title">Export Data</h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={() => setIsExportDataModalOpen(false)}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="payment-modal-form import-export-modal-form">
                <label className="payment-modal-field">
                  <span>Module *</span>
                  <select defaultValue="">
                    <option value="" disabled>Select Module</option>
                    <option>Product Catalog</option>
                    <option>Product Category</option>
                    <option>Brand</option>
                    <option>Unit</option>
                    <option>Supplier Data</option>
                    <option>Barcode Database</option>
                    <option>Bank Account</option>
                    <option>Money Box</option>
                    <option>Product Template</option>
                  </select>
                </label>

                <label className="payment-modal-field">
                  <span>Format *</span>
                  <select defaultValue="Excel">
                    <option>Excel</option>
                    <option>CSV</option>
                    <option>PDF</option>
                  </select>
                </label>

                <div className="import-export-date-grid payment-modal-field-full">
                  <label className="payment-modal-field">
                    <span>Date Range</span>
                    <input type="date" />
                  </label>
                  <label className="payment-modal-field">
                    <span>&nbsp;</span>
                    <input type="date" />
                  </label>
                </div>

                <label className="payment-modal-field payment-modal-field-full">
                  <span>Status</span>
                  <select defaultValue="All Status">
                    <option>All Status</option>
                    <option>Completed</option>
                    <option>Partial</option>
                    <option>Failed</option>
                    <option>Pending</option>
                  </select>
                </label>

                <div className="payment-modal-actions import-export-modal-actions">
                  <button
                    type="button"
                    className="payment-modal-secondary-button"
                    onClick={() => setIsExportDataModalOpen(false)}
                  >
                    Cancel
                  </button>
                  <button type="button" className="payment-modal-primary-button">
                    Export Data
                  </button>
                </div>
              </form>
            </div>
          </div>
        ) : null}
      </section>
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
