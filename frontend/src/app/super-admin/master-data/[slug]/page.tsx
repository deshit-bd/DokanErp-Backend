"use client";

import { type ChangeEvent, type FormEvent, use, useEffect, useRef, useState } from "react";
import { FiAlertCircle, FiCheckCircle, FiCopy, FiCreditCard, FiDollarSign, FiDownload, FiEdit, FiEye, FiFileText, FiFolder, FiMoreVertical, FiPackage, FiPauseCircle, FiRefreshCw, FiToggleLeft, FiTrash2 } from "react-icons/fi";
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

type UnitStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

type UnitTypeValue =
  | "COUNTABLE"
  | "WEIGHT"
  | "VOLUME"
  | "PACKAGING"
  | "LENGTH"
  | "AREA";

type UnitRecord = {
  id: string;
  name: string;
  shortName: string;
  type: UnitTypeValue;
  typeLabel: string;
  description: string | null;
  status: UnitStatusValue;
  statusLabel: string;
  createdAt: string;
  updatedAt: string;
  isGlobal?: boolean;
  isApproved?: boolean;
  shopId?: string | null;
};


type UnitApiResponse = {
  stats: {
    total: number;
    active: number;
    inactive: number;
    archived: number;
  };
  units: UnitRecord[];
};

type UnitFormState = {
  name: string;
  shortName: string;
  type: UnitTypeValue | "";
  description: string;
  status: UnitStatusValue;
};

type UnitPageSizeValue = 5 | 10 | 11 | 20 | 50;

type BrandStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

type BrandRecord = {
  id: string;
  name: string;
  description: string | null;
  logoUrl: string | null;
  status: BrandStatusValue;
  statusLabel: string;
  categories: number;
  products: number;
  createdAt: string;
  updatedAt: string;
};

type BrandApiResponse = {
  stats: {
    total: number;
    active: number;
    inactive: number;
    archived: number;
  };
  brands: BrandRecord[];
};

type BrandFormState = {
  name: string;
  description: string;
  status: BrandStatusValue;
  logoUrl: string;
  logoName: string;
};

type SupplierStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

type SupplierRecord = {
  id: string;
  supplierCode: string;
  name: string;
  mobile: string | null;
  email: string | null;
  address: string | null;
  contactPerson: string | null;
  contactPersonMobile: string | null;
  notes: string | null;
  status: SupplierStatusValue;
  statusLabel: string;
  purchases: number;
  createdAt: string;
  updatedAt: string;
};

type SupplierApiResponse = {
  stats: {
    total: number;
    active: number;
    inactive: number;
    archived: number;
  };
  suppliers: SupplierRecord[];
};

type SupplierFormState = {
  supplierCode: string;
  name: string;
  mobile: string;
  email: string;
  address: string;
  contactPerson: string;
  contactPersonMobile: string;
  notes: string;
  status: SupplierStatusValue;
};

type SupplierModalMode = "create" | "edit" | "view";

type ShopOption = {
  id: string;
  shopName: string;
  status: string;
};

type ShopListResponse = {
  shops: ShopOption[];
};

type MoneyBoxStatusValue = "ACTIVE" | "INACTIVE";
type MoneyBoxTypeValue = "CASH" | "BKASH" | "NAGAD";

type MoneyBoxRecord = {
  id: string;
  shopId: string;
  shopName: string;
  boxName: string;
  code: string;
  type: MoneyBoxTypeValue;
  typeLabel: string;
  openingBalance: number;
  currentBalance: number;
  details: string | null;
  status: MoneyBoxStatusValue;
  statusLabel: string;
  createdAt: string;
  updatedAt: string;
};

type MoneyBoxApiResponse = {
  stats: {
    total: number;
    active: number;
    inactive: number;
    totalBalance: number;
  };
  moneyBoxes: MoneyBoxRecord[];
};

type MoneyBoxFormState = {
  shopId: string;
  boxName: string;
  code: string;
  type: MoneyBoxTypeValue | "";
  openingBalance: string;
  details: string;
  status: MoneyBoxStatusValue;
};

type MoneyBoxModalMode = "create" | "edit";

type BankAccountStatusValue = "ACTIVE" | "INACTIVE" | "CLOSED";
type BankAccountTypeValue = "CURRENT" | "SAVINGS";

type BankAccountRecord = {
  id: string;
  shopId: string;
  shopName: string;
  accountName: string;
  bankName: string;
  branchName: string | null;
  accountNumber: string;
  accountNumberMasked: string;
  accountType: BankAccountTypeValue;
  accountTypeLabel: string;
  openingBalance: number;
  currentBalance: number;
  currency: string;
  status: BankAccountStatusValue;
  statusLabel: string;
  isDefault: boolean;
  notes: string | null;
  createdAt: string;
  updatedAt: string;
};

type BankAccountApiResponse = {
  stats: {
    total: number;
    active: number;
    inactive: number;
    totalBalance: number;
  };
  banks: string[];
  bankAccounts: BankAccountRecord[];
};

type BankAccountFormState = {
  shopId: string;
  accountName: string;
  bankName: string;
  branchName: string;
  accountNumber: string;
  accountType: BankAccountTypeValue | "";
  openingBalance: string;
  currency: string;
  status: BankAccountStatusValue;
  isDefault: boolean;
  notes: string;
};

type BankAccountModalMode = "create" | "edit";

type ProductPictureState = {
  previewUrl: string;
  fileName: string;
};

type ProductStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

type ProductCatalogRecord = {
  id: string;
  sku: string;
  name: string;
  note: string | null;
  categoryId: string | null;
  category: string;
  brandId: string | null;
  brand: string;
  brandLogoUrl: string | null;
  unitId: string | null;
  unit: string;
  barcode: string | null;
  price: number | null;
  priceLabel: string | null;
  suggestedPrice: number | null;
  suggestedPriceLabel: string | null;
  packageSize: string | null;
  pictureUrl: string | null;
  status: ProductStatusValue;
  statusLabel: string;
  type: string;
  createdAt: string;
  updatedAt: string;
};

type ProductCatalogFiltersResponse = {
  categories: Array<{ id: string; name: string }>;
  brands: Array<{ id: string; name: string; logoUrl: string | null }>;
  units: Array<{ id: string; name: string; shortName: string }>;
};

type ProductCatalogApiResponse = {
  stats: {
    total: number;
    active: number;
    inactive: number;
    usingShops: number;
  };
  filters: ProductCatalogFiltersResponse;
  products: ProductCatalogRecord[];
};

type ProductCatalogFormState = {
  name: string;
  sku: string;
  price: string;
  barcode: string;
  suggestedPrice: string;
  categoryId: string;
  brandId: string;
  unitId: string;
  packageSize: string;
  description: string;
  barcodeStatus: "ACTIVE" | "ARCHIVED";
};

type ProductCatalogModalMode = "create" | "edit";
type BarcodeDatabaseStatusValue = "Mapped" | "Unmapped" | "Archived";
type BarcodeModalMode = "assign" | "edit";
type ProductTemplateStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";
type ProductTemplateModalMode = "create" | "edit" | "view";

type BarcodeDatabaseRow = {
  id: string;
  productName: string;
  productNote: string;
  pictureUrl: string | null;
  sku: string;
  category: string;
  categoryId: string | null;
  brand: string;
  brandId: string | null;
  unit: string;
  barcode: string | null;
  status: BarcodeDatabaseStatusValue;
  addedDate: string;
  addedTime: string;
  type: string;
};

type ProductTemplateItemRecord = {
  id: string;
  masterProductId: string;
  name: string;
  sku: string;
  barcode: string | null;
  pictureUrl: string | null;
  category: string;
  brand: string;
  unit: string;
};

type ProductTemplateRecord = {
  id: string;
  code: string;
  name: string;
  description: string | null;
  status: ProductTemplateStatusValue;
  statusLabel: string;
  productCount: number;
  products: ProductTemplateItemRecord[];
  createdAt: string;
  updatedAt: string;
};

type ProductTemplateApiResponse = {
  stats: {
    total: number;
    active: number;
    inactive: number;
    archived: number;
    withProducts: number;
  };
  templates: ProductTemplateRecord[];
};

type ProductTemplateFormState = {
  code: string;
  name: string;
  description: string;
  status: ProductTemplateStatusValue;
};

const unitTypeOptions: Array<{ value: UnitTypeValue; label: string }> = [
  { value: "COUNTABLE", label: "Countable" },
  { value: "WEIGHT", label: "Weight" },
  { value: "VOLUME", label: "Volume" },
  { value: "PACKAGING", label: "Packaging" },
  { value: "LENGTH", label: "Length" },
  { value: "AREA", label: "Area" },
];

const unitStatusOptions: Array<{ value: UnitStatusValue; label: string }> = [
  { value: "ACTIVE", label: "Active" },
  { value: "INACTIVE", label: "Inactive" },
  { value: "ARCHIVED", label: "Archived" },
];

const defaultUnitFormState: UnitFormState = {
  name: "",
  shortName: "",
  type: "",
  description: "",
  status: "ACTIVE",
};

const unitPageSizeOptions: UnitPageSizeValue[] = [5, 10, 11, 20, 50];

const defaultBrandFormState: BrandFormState = {
  name: "",
  description: "",
  status: "ACTIVE",
  logoUrl: "",
  logoName: "",
};
const defaultSupplierData: SupplierApiResponse = {
  stats: {
    total: 0,
    active: 0,
    inactive: 0,
    archived: 0,
  },
  suppliers: [],
};
const defaultSupplierFormState: SupplierFormState = {
  supplierCode: "",
  name: "",
  mobile: "",
  email: "",
  address: "",
  contactPerson: "",
  contactPersonMobile: "",
  notes: "",
  status: "ACTIVE",
};

const defaultMoneyBoxData: MoneyBoxApiResponse = {
  stats: {
    total: 0,
    active: 0,
    inactive: 0,
    totalBalance: 0,
  },
  moneyBoxes: [],
};

const defaultMoneyBoxFormState: MoneyBoxFormState = {
  shopId: "",
  boxName: "",
  code: "",
  type: "",
  openingBalance: "",
  details: "",
  status: "ACTIVE",
};

const defaultBankAccountData: BankAccountApiResponse = {
  stats: {
    total: 0,
    active: 0,
    inactive: 0,
    totalBalance: 0,
  },
  banks: [],
  bankAccounts: [],
};

const defaultBankAccountFormState: BankAccountFormState = {
  shopId: "",
  accountName: "",
  bankName: "",
  branchName: "",
  accountNumber: "",
  accountType: "",
  openingBalance: "0",
  currency: "BDT",
  status: "ACTIVE",
  isDefault: false,
  notes: "",
};

const brandLogoAcceptedTypes = ["image/jpeg", "image/png", "image/svg+xml"];
const maxBrandLogoSizeInBytes = 2 * 1024 * 1024;
const productPictureAcceptedTypes = ["image/jpeg", "image/png", "image/webp", "image/svg+xml"];
const maxProductPictureSizeInBytes = 10 * 1024 * 1024;
const defaultProductCatalogData: ProductCatalogApiResponse = {
  stats: {
    total: 0,
    active: 0,
    inactive: 0,
    usingShops: 0,
  },
  filters: {
    categories: [],
    brands: [],
    units: [],
  },
  products: [],
};
const defaultProductCatalogFormState: ProductCatalogFormState = {
  name: "",
  sku: "",
  price: "",
  barcode: "",
  suggestedPrice: "",
  categoryId: "",
  brandId: "",
  unitId: "",
  packageSize: "",
  description: "",
  barcodeStatus: "ACTIVE",
};
const defaultProductTemplateData: ProductTemplateApiResponse = {
  stats: {
    total: 0,
    active: 0,
    inactive: 0,
    archived: 0,
    withProducts: 0,
  },
  templates: [],
};
const defaultProductTemplateFormState: ProductTemplateFormState = {
  code: "",
  name: "",
  description: "",
  status: "ACTIVE",
};

const supplierStats = [
  { label: "Total Suppliers", value: "4516", note: "All Suppliers", accent: "indigo" as const, type: "users" as const },
  { label: "Active Suppliers", value: "4500", note: "Active Suppliers", accent: "green" as const, type: "check" as const },
  { label: "Inactive Suppliers", value: "16", note: "All Inactive Suppliers", accent: "amber" as const, type: "close" as const },
  { label: "Blocked Suppliers", value: "12,684", note: "All Blocked", accent: "red" as const, type: "alert" as const },
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

function normalizeSearchValue(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9]/g, "");
}

function isSubsequenceMatch(needle: string, haystack: string) {
  const normalizedNeedle = normalizeSearchValue(needle);
  const normalizedHaystack = normalizeSearchValue(haystack);

  if (!normalizedNeedle) {
    return true;
  }

  let needleIndex = 0;
  let haystackIndex = 0;

  while (needleIndex < normalizedNeedle.length && haystackIndex < normalizedHaystack.length) {
    if (normalizedNeedle[needleIndex] === normalizedHaystack[haystackIndex]) {
      needleIndex += 1;
    }

    haystackIndex += 1;
  }

  return needleIndex === normalizedNeedle.length;
}

function formatUnitDate(dateString: string) {
  return new Date(dateString).toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

function formatMasterDataDate(dateString: string) {
  return new Date(dateString).toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

function formatMoneyBoxCurrency(amount: number) {
  return `৳${amount.toLocaleString("en-US", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;
}

function formatMasterDataTime(dateString: string) {
  return new Date(dateString).toLocaleTimeString("en-US", {
    hour: "2-digit",
    minute: "2-digit",
  });
}

function formatStatValue(value: number) {
  return value.toLocaleString("en-US");
}

function getBarcodeDatabaseStatus(product: ProductCatalogRecord): BarcodeDatabaseStatusValue {
  if (product.status === "ARCHIVED") {
    return "Archived";
  }

  if (!product.barcode) {
    return "Unmapped";
  }

  return "Mapped";
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

function ProductCatalogRowIcon({ type }: { type: string }) {
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

function getBarcodeImageUrl(productId: string, download = false) {
  return `/api/products/${productId}/barcode${download ? "?download=1" : ""}`;
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
  const [moneyBoxData, setMoneyBoxData] = useState<MoneyBoxApiResponse>(defaultMoneyBoxData);
  const [isMoneyBoxLoading, setIsMoneyBoxLoading] = useState(false);
  const [moneyBoxLoadError, setMoneyBoxLoadError] = useState<string | null>(null);
  const [moneyBoxSearch, setMoneyBoxSearch] = useState("");
  const [moneyBoxShopFilter, setMoneyBoxShopFilter] = useState("");
  const [moneyBoxStatusFilter, setMoneyBoxStatusFilter] = useState<MoneyBoxStatusValue | "">("");
  const [moneyBoxForm, setMoneyBoxForm] = useState<MoneyBoxFormState>(defaultMoneyBoxFormState);
  const [moneyBoxFormError, setMoneyBoxFormError] = useState<string | null>(null);
  const [isMoneyBoxSaving, setIsMoneyBoxSaving] = useState(false);
  const [moneyBoxModalMode, setMoneyBoxModalMode] = useState<MoneyBoxModalMode>("create");
  const [selectedMoneyBox, setSelectedMoneyBox] = useState<MoneyBoxRecord | null>(null);
  const [bankAccountData, setBankAccountData] = useState<BankAccountApiResponse>(defaultBankAccountData);
  const [isBankAccountLoading, setIsBankAccountLoading] = useState(false);
  const [bankAccountLoadError, setBankAccountLoadError] = useState<string | null>(null);
  const [bankAccountSearch, setBankAccountSearch] = useState("");
  const [bankAccountShopFilter, setBankAccountShopFilter] = useState("");
  const [bankAccountBankFilter, setBankAccountBankFilter] = useState("");
  const [bankAccountStatusFilter, setBankAccountStatusFilter] = useState<BankAccountStatusValue | "">("");
  const [bankAccountForm, setBankAccountForm] = useState<BankAccountFormState>(defaultBankAccountFormState);
  const [bankAccountFormError, setBankAccountFormError] = useState<string | null>(null);
  const [isBankAccountSaving, setIsBankAccountSaving] = useState(false);
  const [bankAccountModalMode, setBankAccountModalMode] = useState<BankAccountModalMode>("create");
  const [selectedBankAccount, setSelectedBankAccount] = useState<BankAccountRecord | null>(null);
  const [isProductTemplateModalOpen, setIsProductTemplateModalOpen] = useState(false);
  const [isManageTemplateProductsModalOpen, setIsManageTemplateProductsModalOpen] = useState(false);
  const [isProductCatalogExportOpen, setIsProductCatalogExportOpen] = useState(false);
  const [isBankAccountExportOpen, setIsBankAccountExportOpen] = useState(false);
  const [isProductCatalogModalOpen, setIsProductCatalogModalOpen] = useState(false);
  const [productTemplateData, setProductTemplateData] = useState<ProductTemplateApiResponse>(defaultProductTemplateData);
  const [isProductTemplateLoading, setIsProductTemplateLoading] = useState(false);
  const [productTemplateLoadError, setProductTemplateLoadError] = useState<string | null>(null);
  const [productTemplateSearch, setProductTemplateSearch] = useState("");
  const [productTemplateStatusFilter, setProductTemplateStatusFilter] = useState<ProductTemplateStatusValue | "">("");
  const [productTemplateForm, setProductTemplateForm] = useState<ProductTemplateFormState>(defaultProductTemplateFormState);
  const [productTemplateFormError, setProductTemplateFormError] = useState<string | null>(null);
  const [isProductTemplateSaving, setIsProductTemplateSaving] = useState(false);
  const [productTemplateModalMode, setProductTemplateModalMode] = useState<ProductTemplateModalMode>("create");
  const [selectedProductTemplate, setSelectedProductTemplate] = useState<ProductTemplateRecord | null>(null);
  const [manageTemplateProductsSearch, setManageTemplateProductsSearch] = useState("");
  const [selectedTemplateProductIds, setSelectedTemplateProductIds] = useState<string[]>([]);
  const [isTemplateProductsSaving, setIsTemplateProductsSaving] = useState(false);
  const [templateProductsError, setTemplateProductsError] = useState<string | null>(null);
  const [barcodeModalMode, setBarcodeModalMode] = useState<BarcodeModalMode>("assign");
  const [selectedBarcodeProduct, setSelectedBarcodeProduct] = useState<ProductCatalogRecord | null>(null);
  const [isBarcodeScannerReady, setIsBarcodeScannerReady] = useState(false);
  const [productCatalogData, setProductCatalogData] = useState<ProductCatalogApiResponse>(defaultProductCatalogData);
  const [isProductCatalogLoading, setIsProductCatalogLoading] = useState(false);
  const [productCatalogLoadError, setProductCatalogLoadError] = useState<string | null>(null);
  const [productCatalogSearch, setProductCatalogSearch] = useState("");
  const [productCatalogCategoryFilter, setProductCatalogCategoryFilter] = useState("");
  const [productCatalogBrandFilter, setProductCatalogBrandFilter] = useState("");
  const [productCatalogStatusFilter, setProductCatalogStatusFilter] = useState<ProductStatusValue | "">("");
  const [barcodeSearch, setBarcodeSearch] = useState("");
  const [barcodeCategoryFilter, setBarcodeCategoryFilter] = useState("");
  const [barcodeBrandFilter, setBarcodeBrandFilter] = useState("");
  const [barcodeStatusFilter, setBarcodeStatusFilter] = useState<BarcodeDatabaseStatusValue | "">("");
  const [productCatalogForm, setProductCatalogForm] = useState<ProductCatalogFormState>(defaultProductCatalogFormState);
  const [productCatalogFormError, setProductCatalogFormError] = useState<string | null>(null);
  const [isProductCatalogSaving, setIsProductCatalogSaving] = useState(false);
  const [productCatalogModalMode, setProductCatalogModalMode] = useState<ProductCatalogModalMode>("create");
  const [editingProductId, setEditingProductId] = useState<string | null>(null);
  const [productPicture, setProductPicture] = useState<ProductPictureState>({
    previewUrl: "",
    fileName: "",
  });
  const [productPictureError, setProductPictureError] = useState<string | null>(null);
  const [isBrandModalOpen, setIsBrandModalOpen] = useState(false);
  const [isSupplierModalOpen, setIsSupplierModalOpen] = useState(false);
  const [shopOptions, setShopOptions] = useState<ShopOption[]>([]);
  const [isShopOptionsLoading, setIsShopOptionsLoading] = useState(false);
  const [shopOptionsLoadError, setShopOptionsLoadError] = useState<string | null>(null);
  const [supplierData, setSupplierData] = useState<SupplierApiResponse>(defaultSupplierData);
  const [isSupplierLoading, setIsSupplierLoading] = useState(false);
  const [supplierLoadError, setSupplierLoadError] = useState<string | null>(null);
  const [supplierSearch, setSupplierSearch] = useState("");
  const [supplierStatusFilter, setSupplierStatusFilter] = useState<SupplierStatusValue | "">("");
  const [supplierForm, setSupplierForm] = useState<SupplierFormState>(defaultSupplierFormState);
  const [supplierFormError, setSupplierFormError] = useState<string | null>(null);
  const [isSupplierSaving, setIsSupplierSaving] = useState(false);
  const [supplierModalMode, setSupplierModalMode] = useState<SupplierModalMode>("create");
  const [selectedSupplier, setSelectedSupplier] = useState<SupplierRecord | null>(null);
  const [openSupplierActionMenuId, setOpenSupplierActionMenuId] = useState<string | null>(null);
  const [openBarcodeActionMenuId, setOpenBarcodeActionMenuId] = useState<string | null>(null);
  const [openMoneyBoxActionMenuId, setOpenMoneyBoxActionMenuId] = useState<string | null>(null);
  const [openProductCatalogActionMenuId, setOpenProductCatalogActionMenuId] = useState<string | null>(null);
  const [openProductTemplateActionMenuId, setOpenProductTemplateActionMenuId] = useState<string | null>(null);
  const [openUnitActionMenuId, setOpenUnitActionMenuId] = useState<string | null>(null);
  const [openImportActionMenuId, setOpenImportActionMenuId] = useState<number | null>(null);
  const [openExportActionMenuId, setOpenExportActionMenuId] = useState<number | null>(null);
  const [importExportTab, setImportExportTab] = useState<"import" | "export">("import");
  const [isImportDataModalOpen, setIsImportDataModalOpen] = useState(false);
  const [isExportDataModalOpen, setIsExportDataModalOpen] = useState(false);
  const [brandData, setBrandData] = useState<BrandApiResponse>({
    stats: {
      total: 0,
      active: 0,
      inactive: 0,
      archived: 0,
    },
    brands: [],
  });
  const [isBrandLoading, setIsBrandLoading] = useState(false);
  const [brandLoadError, setBrandLoadError] = useState<string | null>(null);
  const [brandSearch, setBrandSearch] = useState("");
  const [brandStatusFilter, setBrandStatusFilter] = useState<BrandStatusValue | "">("");
  const [brandForm, setBrandForm] = useState<BrandFormState>(defaultBrandFormState);
  const [brandFormError, setBrandFormError] = useState<string | null>(null);
  const [isBrandSaving, setIsBrandSaving] = useState(false);
  const [unitData, setUnitData] = useState<UnitApiResponse>({
    stats: {
      total: 0,
      active: 0,
      inactive: 0,
      archived: 0,
    },
    units: [],
  });
  const [isUnitLoading, setIsUnitLoading] = useState(false);
  const [unitLoadError, setUnitLoadError] = useState<string | null>(null);
  const [unitSearch, setUnitSearch] = useState("");
  const [unitTypeFilter, setUnitTypeFilter] = useState<UnitTypeValue | "">("");
  const [unitStatusFilter, setUnitStatusFilter] = useState<UnitStatusValue | "">("");
  const [unitForm, setUnitForm] = useState<UnitFormState>(defaultUnitFormState);
  const [unitFormError, setUnitFormError] = useState<string | null>(null);
  const [isUnitSaving, setIsUnitSaving] = useState(false);
  const [unitCurrentPage, setUnitCurrentPage] = useState(1);
  const [unitPageSize, setUnitPageSize] = useState<UnitPageSizeValue>(11);
  const barcodeFormRef = useRef<HTMLFormElement | null>(null);
  const barcodeInputRef = useRef<HTMLInputElement | null>(null);
  const isBrandPage = slug === "brand";
  const isSupplierPage = slug === "supplier-data";
  const isProductCatalogPage = slug === "product-catalog";
  const isBarcodePage = slug === "barcode-database";
  const isMoneyBoxPage = slug === "money-box";
  const isBankAccountPage = slug === "bank-account";
  const isProductTemplatePage = slug === "product-template";
  const isUnitPage = slug === "unit";

  useEffect(() => {
    if (!isMoneyBoxPage && !isBankAccountPage) {
      return;
    }

    let isActive = true;

    async function loadShops() {
      setIsShopOptionsLoading(true);
      setShopOptionsLoadError(null);

      try {
        const response = await fetch("/api/shops", {
          credentials: "include",
          cache: "no-store",
        });

        const payload = (await response.json().catch(() => null)) as
          | ShopListResponse
          | { message?: string }
          | null;

        if (!response.ok) {
          throw new Error(payload && "message" in payload ? payload.message || "Failed to load shops." : "Failed to load shops.");
        }

        if (isActive && payload && "shops" in payload) {
          setShopOptions(payload.shops);
        }
      } catch (error) {
        if (isActive) {
          setShopOptionsLoadError(error instanceof Error ? error.message : "Failed to load shops.");
        }
      } finally {
        if (isActive) {
          setIsShopOptionsLoading(false);
        }
      }
    }

    void loadShops();

    return () => {
      isActive = false;
    };
  }, [isBankAccountPage, isMoneyBoxPage]);

  useEffect(() => {
    if (!isMoneyBoxPage) {
      return;
    }

    let isActive = true;

    async function loadMoneyBoxes() {
      setIsMoneyBoxLoading(true);
      setMoneyBoxLoadError(null);

      try {
        const response = await fetch("/api/money-boxes", {
          credentials: "include",
          cache: "no-store",
        });

        const payload = (await response.json().catch(() => null)) as
          | MoneyBoxApiResponse
          | { message?: string }
          | null;

        if (!response.ok) {
          throw new Error(payload && "message" in payload ? payload.message || "Failed to load money boxes." : "Failed to load money boxes.");
        }

        if (isActive && payload && "moneyBoxes" in payload) {
          setMoneyBoxData(payload);
        }
      } catch (error) {
        if (isActive) {
          setMoneyBoxLoadError(error instanceof Error ? error.message : "Failed to load money boxes.");
        }
      } finally {
        if (isActive) {
          setIsMoneyBoxLoading(false);
        }
      }
    }

    void loadMoneyBoxes();

    return () => {
      isActive = false;
    };
  }, [isMoneyBoxPage]);

  useEffect(() => {
    if (!isBankAccountPage) {
      return;
    }

    let isActive = true;

    async function loadBankAccounts() {
      setIsBankAccountLoading(true);
      setBankAccountLoadError(null);

      try {
        const response = await fetch("/api/bank-accounts", {
          credentials: "include",
          cache: "no-store",
        });

        const payload = (await response.json().catch(() => null)) as
          | BankAccountApiResponse
          | { message?: string }
          | null;

        if (!response.ok) {
          throw new Error(
            payload && "message" in payload
              ? payload.message || "Failed to load bank accounts."
              : "Failed to load bank accounts.",
          );
        }

        if (isActive && payload && "bankAccounts" in payload) {
          setBankAccountData(payload);
        }
      } catch (error) {
        if (isActive) {
          setBankAccountLoadError(error instanceof Error ? error.message : "Failed to load bank accounts.");
        }
      } finally {
        if (isActive) {
          setIsBankAccountLoading(false);
        }
      }
    }

    void loadBankAccounts();

    return () => {
      isActive = false;
    };
  }, [isBankAccountPage]);

  function openCreateMoneyBoxModal() {
    setMoneyBoxModalMode("create");
    setSelectedMoneyBox(null);
    setMoneyBoxForm(defaultMoneyBoxFormState);
    setMoneyBoxFormError(null);
    setIsMoneyBoxModalOpen(true);
  }

  function openEditMoneyBoxModal(moneyBox: MoneyBoxRecord) {
    setMoneyBoxModalMode("edit");
    setSelectedMoneyBox(moneyBox);
    setMoneyBoxForm({
      shopId: moneyBox.shopId,
      boxName: moneyBox.boxName,
      code: moneyBox.code,
      type: moneyBox.type,
      openingBalance: String(moneyBox.openingBalance),
      details: moneyBox.details ?? "",
      status: moneyBox.status,
    });
    setMoneyBoxFormError(null);
    setOpenMoneyBoxActionMenuId(null);
    setIsMoneyBoxModalOpen(true);
  }

  function closeMoneyBoxModal() {
    setIsMoneyBoxModalOpen(false);
    setMoneyBoxModalMode("create");
    setSelectedMoneyBox(null);
    setMoneyBoxForm(defaultMoneyBoxFormState);
    setMoneyBoxFormError(null);
  }

  async function refreshMoneyBoxes() {
    const response = await fetch("/api/money-boxes", {
      credentials: "include",
      cache: "no-store",
    });

    const payload = (await response.json().catch(() => null)) as
      | MoneyBoxApiResponse
      | { message?: string }
      | null;

    if (!response.ok) {
      throw new Error(payload && "message" in payload ? payload.message || "Failed to load money boxes." : "Failed to load money boxes.");
    }

    if (payload && "moneyBoxes" in payload) {
      setMoneyBoxData(payload);
    }
  }

  async function handleMoneyBoxSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setMoneyBoxFormError(null);

    if (!moneyBoxForm.shopId) {
      setMoneyBoxFormError("Shop is required.");
      return;
    }

    if (!moneyBoxForm.boxName.trim()) {
      setMoneyBoxFormError("Money box name is required.");
      return;
    }

    if (!moneyBoxForm.code.trim()) {
      setMoneyBoxFormError("Money box code is required.");
      return;
    }

    if (!moneyBoxForm.type) {
      setMoneyBoxFormError("Money box type is required.");
      return;
    }

    const openingBalance = Number(moneyBoxForm.openingBalance || 0);

    if (Number.isNaN(openingBalance)) {
      setMoneyBoxFormError("Opening balance must be a valid number.");
      return;
    }

    setIsMoneyBoxSaving(true);

    try {
      const endpoint =
        moneyBoxModalMode === "edit" && selectedMoneyBox
          ? `/api/money-boxes/${selectedMoneyBox.id}`
          : "/api/money-boxes";
      const method = moneyBoxModalMode === "edit" ? "PUT" : "POST";

      const response = await fetch(endpoint, {
        method,
        credentials: "include",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          shopId: moneyBoxForm.shopId,
          boxName: moneyBoxForm.boxName,
          code: moneyBoxForm.code,
          type: moneyBoxForm.type,
          openingBalance,
          details: moneyBoxForm.details || null,
          status: moneyBoxForm.status,
        }),
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to save money box.");
      }

      await refreshMoneyBoxes();
      closeMoneyBoxModal();
    } catch (error) {
      setMoneyBoxFormError(error instanceof Error ? error.message : "Failed to save money box.");
    } finally {
      setIsMoneyBoxSaving(false);
    }
  }

  function openCreateBankAccountModal() {
    setBankAccountModalMode("create");
    setSelectedBankAccount(null);
    setBankAccountForm(defaultBankAccountFormState);
    setBankAccountFormError(null);
    setIsBankAccountModalOpen(true);
  }

  function openEditBankAccountModal(bankAccount: BankAccountRecord) {
    setBankAccountModalMode("edit");
    setSelectedBankAccount(bankAccount);
    setBankAccountForm({
      shopId: bankAccount.shopId,
      accountName: bankAccount.accountName,
      bankName: bankAccount.bankName,
      branchName: bankAccount.branchName ?? "",
      accountNumber: bankAccount.accountNumber,
      accountType: bankAccount.accountType,
      openingBalance: String(bankAccount.openingBalance),
      currency: bankAccount.currency,
      status: bankAccount.status,
      isDefault: bankAccount.isDefault,
      notes: bankAccount.notes ?? "",
    });
    setBankAccountFormError(null);
    setIsBankAccountModalOpen(true);
  }

  function closeBankAccountModal() {
    setIsBankAccountModalOpen(false);
    setBankAccountModalMode("create");
    setSelectedBankAccount(null);
    setBankAccountForm(defaultBankAccountFormState);
    setBankAccountFormError(null);
  }

  async function refreshBankAccounts() {
    const response = await fetch("/api/bank-accounts", {
      credentials: "include",
      cache: "no-store",
    });

    const payload = (await response.json().catch(() => null)) as
      | BankAccountApiResponse
      | { message?: string }
      | null;

    if (!response.ok) {
      throw new Error(
        payload && "message" in payload
          ? payload.message || "Failed to load bank accounts."
          : "Failed to load bank accounts.",
      );
    }

    if (payload && "bankAccounts" in payload) {
      setBankAccountData(payload);
    }
  }

  async function handleBankAccountSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setBankAccountFormError(null);

    if (!bankAccountForm.shopId) {
      setBankAccountFormError("Shop is required.");
      return;
    }
    if (!bankAccountForm.accountName.trim()) {
      setBankAccountFormError("Account name is required.");
      return;
    }
    if (!bankAccountForm.bankName.trim()) {
      setBankAccountFormError("Bank name is required.");
      return;
    }
    if (!bankAccountForm.accountNumber.trim()) {
      setBankAccountFormError("Account number is required.");
      return;
    }
    if (!bankAccountForm.accountType) {
      setBankAccountFormError("Account type is required.");
      return;
    }

    const openingBalance = Number(bankAccountForm.openingBalance || 0);

    if (Number.isNaN(openingBalance)) {
      setBankAccountFormError("Opening balance must be a valid number.");
      return;
    }

    setIsBankAccountSaving(true);

    try {
      const endpoint =
        bankAccountModalMode === "edit" && selectedBankAccount
          ? `/api/bank-accounts/${selectedBankAccount.id}`
          : "/api/bank-accounts";
      const method = bankAccountModalMode === "edit" ? "PUT" : "POST";

      const response = await fetch(endpoint, {
        method,
        credentials: "include",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          shopId: bankAccountForm.shopId,
          accountName: bankAccountForm.accountName,
          bankName: bankAccountForm.bankName,
          branchName: bankAccountForm.branchName || null,
          accountNumber: bankAccountForm.accountNumber,
          accountType: bankAccountForm.accountType,
          openingBalance,
          currency: bankAccountForm.currency,
          status: bankAccountForm.status,
          isDefault: bankAccountForm.isDefault,
          notes: bankAccountForm.notes || null,
        }),
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to save bank account.");
      }

      await refreshBankAccounts();
      closeBankAccountModal();
    } catch (error) {
      setBankAccountFormError(error instanceof Error ? error.message : "Failed to save bank account.");
    } finally {
      setIsBankAccountSaving(false);
    }
  }

  useEffect(() => {
    if (!isProductCatalogPage && !isBarcodePage && !isProductTemplatePage) {
      return;
    }

    let isActive = true;

    async function loadProducts() {
      setIsProductCatalogLoading(true);
      setProductCatalogLoadError(null);

      try {
        const response = await fetch("/api/products", {
          credentials: "include",
          cache: "no-store",
        });

        const payload = (await response.json().catch(() => null)) as
          | ProductCatalogApiResponse
          | { message?: string }
          | null;

        if (!response.ok) {
          throw new Error(payload && "message" in payload ? payload.message || "Failed to load products." : "Failed to load products.");
        }

        if (isActive && payload && "products" in payload) {
          setProductCatalogData(payload);
        }
      } catch (error) {
        if (isActive) {
          setProductCatalogLoadError(error instanceof Error ? error.message : "Failed to load products.");
        }
      } finally {
        if (isActive) {
          setIsProductCatalogLoading(false);
        }
      }
    }

    void loadProducts();

    return () => {
      isActive = false;
    };
  }, [isBarcodePage, isProductCatalogPage, isProductTemplatePage]);

  useEffect(() => {
    if (!isProductTemplatePage) {
      return;
    }

    let isActive = true;

    async function loadProductTemplates() {
      setIsProductTemplateLoading(true);
      setProductTemplateLoadError(null);

      try {
        const response = await fetch("/api/product-templates", {
          credentials: "include",
          cache: "no-store",
        });

        const payload = (await response.json().catch(() => null)) as
          | ProductTemplateApiResponse
          | { message?: string }
          | null;

        if (!response.ok) {
          throw new Error(payload && "message" in payload ? payload.message || "Failed to load product templates." : "Failed to load product templates.");
        }

        if (isActive && payload && "templates" in payload) {
          setProductTemplateData(payload);
        }
      } catch (error) {
        if (isActive) {
          setProductTemplateLoadError(error instanceof Error ? error.message : "Failed to load product templates.");
        }
      } finally {
        if (isActive) {
          setIsProductTemplateLoading(false);
        }
      }
    }

    void loadProductTemplates();

    return () => {
      isActive = false;
    };
  }, [isProductTemplatePage]);

  useEffect(() => {
    if (!isSupplierPage) {
      return;
    }

    let isActive = true;

    async function loadSuppliers() {
      setIsSupplierLoading(true);
      setSupplierLoadError(null);

      try {
        const response = await fetch("/api/suppliers", {
          credentials: "include",
          cache: "no-store",
        });

        const payload = (await response.json().catch(() => null)) as SupplierApiResponse | { message?: string } | null;

        if (!response.ok) {
          throw new Error(payload && "message" in payload ? payload.message || "Failed to load suppliers." : "Failed to load suppliers.");
        }

        if (isActive && payload && "suppliers" in payload) {
          setSupplierData(payload);
        }
      } catch (error) {
        if (isActive) {
          setSupplierLoadError(error instanceof Error ? error.message : "Failed to load suppliers.");
        }
      } finally {
        if (isActive) {
          setIsSupplierLoading(false);
        }
      }
    }

    void loadSuppliers();

    return () => {
      isActive = false;
    };
  }, [isSupplierPage]);

  useEffect(() => {
    if (!selectedProductTemplate) {
      return;
    }

    const latestTemplate = productTemplateData.templates.find((item) => item.id === selectedProductTemplate.id) ?? null;

    if (!latestTemplate) {
      setSelectedProductTemplate(null);
      return;
    }

    if (latestTemplate !== selectedProductTemplate) {
      setSelectedProductTemplate(latestTemplate);
    }
  }, [productTemplateData.templates, selectedProductTemplate]);

  useEffect(() => {
    if (!isBrandPage) {
      return;
    }

    let isActive = true;

    async function loadBrands() {
      setIsBrandLoading(true);
      setBrandLoadError(null);

      try {
        const response = await fetch("/api/brands", {
          credentials: "include",
          cache: "no-store",
        });

        const payload = (await response.json().catch(() => null)) as
          | BrandApiResponse
          | { message?: string }
          | null;

        if (!response.ok) {
          throw new Error(payload && "message" in payload ? payload.message || "Failed to load brands." : "Failed to load brands.");
        }

        if (isActive && payload && "brands" in payload) {
          setBrandData(payload);
        }
      } catch (error) {
        if (isActive) {
          setBrandLoadError(error instanceof Error ? error.message : "Failed to load brands.");
        }
      } finally {
        if (isActive) {
          setIsBrandLoading(false);
        }
      }
    }

    void loadBrands();

    return () => {
      isActive = false;
    };
  }, [isBrandPage]);

  useEffect(() => {
    if (!isUnitPage) {
      return;
    }

    let isActive = true;

    async function loadUnits() {
      setIsUnitLoading(true);
      setUnitLoadError(null);

      try {
        const response = await fetch("/api/units", {
          credentials: "include",
          cache: "no-store",
        });

        const payload = (await response.json().catch(() => null)) as
          | UnitApiResponse
          | { message?: string }
          | null;

        if (!response.ok) {
          throw new Error(payload && "message" in payload ? payload.message || "Failed to load units." : "Failed to load units.");
        }

        if (isActive && payload && "units" in payload) {
          setUnitData(payload);
        }
      } catch (error) {
        if (isActive) {
          setUnitLoadError(error instanceof Error ? error.message : "Failed to load units.");
        }
      } finally {
        if (isActive) {
          setIsUnitLoading(false);
        }
      }
    }

    void loadUnits();

    return () => {
      isActive = false;
    };
  }, [isUnitPage]);

  useEffect(() => {
    if (!isBarcodeModalOpen) {
      setIsBarcodeScannerReady(false);
      return;
    }

    const timeoutId = window.setTimeout(() => {
      barcodeInputRef.current?.focus();
      barcodeInputRef.current?.select();
      setIsBarcodeScannerReady(true);
    }, 80);

    return () => window.clearTimeout(timeoutId);
  }, [isBarcodeModalOpen, barcodeModalMode]);

  function resetUnitFilters() {
    setUnitSearch("");
    setUnitTypeFilter("");
    setUnitStatusFilter("");
    setUnitCurrentPage(1);
  }

  function resetBrandFilters() {
    setBrandSearch("");
    setBrandStatusFilter("");
  }

  function closeBrandModal() {
    setIsBrandModalOpen(false);
    setBrandForm(defaultBrandFormState);
    setBrandFormError(null);
  }

  async function refreshSuppliers() {
    setIsSupplierLoading(true);
    setSupplierLoadError(null);

    try {
      const response = await fetch("/api/suppliers", {
        credentials: "include",
        cache: "no-store",
      });

      const payload = (await response.json().catch(() => null)) as SupplierApiResponse | { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload && "message" in payload ? payload.message || "Failed to load suppliers." : "Failed to load suppliers.");
      }

      if (payload && "suppliers" in payload) {
        setSupplierData(payload);
      }
    } catch (error) {
      setSupplierLoadError(error instanceof Error ? error.message : "Failed to load suppliers.");
    } finally {
      setIsSupplierLoading(false);
    }
  }

  function openCreateSupplierModal() {
    setSupplierModalMode("create");
    setSelectedSupplier(null);
    setSupplierForm(defaultSupplierFormState);
    setSupplierFormError(null);
    setOpenSupplierActionMenuId(null);
    setIsSupplierModalOpen(true);
  }

  function openEditSupplierModal(supplier: SupplierRecord) {
    setSupplierModalMode("edit");
    setSelectedSupplier(supplier);
    setSupplierForm({
      supplierCode: supplier.supplierCode,
      name: supplier.name,
      mobile: supplier.mobile ?? "",
      email: supplier.email ?? "",
      address: supplier.address ?? "",
      contactPerson: supplier.contactPerson ?? "",
      contactPersonMobile: supplier.contactPersonMobile ?? "",
      notes: supplier.notes ?? "",
      status: supplier.status,
    });
    setSupplierFormError(null);
    setOpenSupplierActionMenuId(null);
    setIsSupplierModalOpen(true);
  }

  function openViewSupplierModal(supplier: SupplierRecord) {
    setSupplierModalMode("view");
    setSelectedSupplier(supplier);
    setSupplierForm({
      supplierCode: supplier.supplierCode,
      name: supplier.name,
      mobile: supplier.mobile ?? "",
      email: supplier.email ?? "",
      address: supplier.address ?? "",
      contactPerson: supplier.contactPerson ?? "",
      contactPersonMobile: supplier.contactPersonMobile ?? "",
      notes: supplier.notes ?? "",
      status: supplier.status,
    });
    setSupplierFormError(null);
    setOpenSupplierActionMenuId(null);
    setIsSupplierModalOpen(true);
  }

  function closeSupplierModal() {
    setIsSupplierModalOpen(false);
    setSupplierModalMode("create");
    setSelectedSupplier(null);
    setSupplierForm(defaultSupplierFormState);
    setSupplierFormError(null);
  }

  async function handleSupplierSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!supplierForm.supplierCode.trim()) {
      setSupplierFormError("Supplier code is required.");
      return;
    }

    if (!supplierForm.name.trim()) {
      setSupplierFormError("Supplier name is required.");
      return;
    }

    setIsSupplierSaving(true);
    setSupplierFormError(null);

    try {
      const endpoint =
        supplierModalMode === "edit" && selectedSupplier ? `/api/suppliers/${selectedSupplier.id}` : "/api/suppliers";
      const method = supplierModalMode === "edit" && selectedSupplier ? "PUT" : "POST";

      const response = await fetch(endpoint, {
        method,
        credentials: "include",
        headers: {
          "content-type": "application/json",
        },
          body: JSON.stringify({
          supplierCode: supplierForm.supplierCode,
          name: supplierForm.name,
          mobile: supplierForm.mobile || null,
          email: supplierForm.email || null,
          address: supplierForm.address || null,
          contactPerson: supplierForm.contactPerson || null,
          contactPersonMobile: supplierForm.contactPersonMobile || null,
          notes: supplierForm.notes || null,
          status: supplierForm.status,
        }),
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to save supplier.");
      }

      closeSupplierModal();
      await refreshSuppliers();
    } catch (error) {
      setSupplierFormError(error instanceof Error ? error.message : "Failed to save supplier.");
    } finally {
      setIsSupplierSaving(false);
    }
  }

  async function setSupplierStatus(supplier: SupplierRecord, status: SupplierStatusValue) {
    try {
      const response = await fetch(`/api/suppliers/${supplier.id}/status`, {
        method: "PATCH",
        credentials: "include",
        headers: {
          "content-type": "application/json",
        },
        body: JSON.stringify({ status }),
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to change supplier status.");
      }

      setOpenSupplierActionMenuId(null);
      await refreshSuppliers();
    } catch (error) {
      setSupplierLoadError(error instanceof Error ? error.message : "Failed to change supplier status.");
    }
  }

  async function deleteSupplier(supplier: SupplierRecord) {
    const shouldDelete = window.confirm(`Archive supplier "${supplier.name}"?`);

    if (!shouldDelete) {
      return;
    }

    try {
      const response = await fetch(`/api/suppliers/${supplier.id}`, {
        method: "DELETE",
        credentials: "include",
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to delete supplier.");
      }

      setOpenSupplierActionMenuId(null);
      await refreshSuppliers();
    } catch (error) {
      setSupplierLoadError(error instanceof Error ? error.message : "Failed to delete supplier.");
    }
  }

  function closeProductCatalogModal() {
    setIsProductCatalogModalOpen(false);
    setProductCatalogModalMode("create");
    setEditingProductId(null);
    setProductCatalogForm(defaultProductCatalogFormState);
    setProductPicture({
      previewUrl: "",
      fileName: "",
    });
    setProductPictureError(null);
    setProductCatalogFormError(null);
  }

  function closeBarcodeModal() {
    setIsBarcodeModalOpen(false);
    setBarcodeModalMode("assign");
    setSelectedBarcodeProduct(null);
    setEditingProductId(null);
    setIsBarcodeScannerReady(false);
    setProductCatalogForm(defaultProductCatalogFormState);
    setProductCatalogFormError(null);
    setOpenBarcodeActionMenuId(null);
  }

  async function refreshProductTemplates() {
    setIsProductTemplateLoading(true);
    setProductTemplateLoadError(null);

    try {
      const response = await fetch("/api/product-templates", {
        credentials: "include",
        cache: "no-store",
      });

      const payload = (await response.json().catch(() => null)) as ProductTemplateApiResponse | { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload && "message" in payload ? payload.message || "Failed to load product templates." : "Failed to load product templates.");
      }

      if (payload && "templates" in payload) {
        setProductTemplateData(payload);
      }
    } catch (error) {
      setProductTemplateLoadError(error instanceof Error ? error.message : "Failed to load product templates.");
    } finally {
      setIsProductTemplateLoading(false);
    }
  }

  function openCreateProductTemplateModal() {
    setProductTemplateModalMode("create");
    setSelectedProductTemplate(null);
    setProductTemplateForm(defaultProductTemplateFormState);
    setProductTemplateFormError(null);
    setOpenProductTemplateActionMenuId(null);
    setIsProductTemplateModalOpen(true);
  }

  function openEditProductTemplateModal(template: ProductTemplateRecord) {
    setProductTemplateModalMode("edit");
    setSelectedProductTemplate(template);
    setProductTemplateForm({
      code: template.code,
      name: template.name,
      description: template.description ?? "",
      status: template.status,
    });
    setProductTemplateFormError(null);
    setOpenProductTemplateActionMenuId(null);
    setIsProductTemplateModalOpen(true);
  }

  function openViewProductTemplateModal(template: ProductTemplateRecord) {
    setProductTemplateModalMode("view");
    setSelectedProductTemplate(template);
    setProductTemplateForm({
      code: template.code,
      name: template.name,
      description: template.description ?? "",
      status: template.status,
    });
    setProductTemplateFormError(null);
    setOpenProductTemplateActionMenuId(null);
    setIsProductTemplateModalOpen(true);
  }

  function closeProductTemplateModal() {
    setIsProductTemplateModalOpen(false);
    setProductTemplateModalMode("create");
    setSelectedProductTemplate(null);
    setProductTemplateForm(defaultProductTemplateFormState);
    setProductTemplateFormError(null);
  }

  function openManageTemplateProductsModal(template: ProductTemplateRecord) {
    setSelectedProductTemplate(template);
    setSelectedTemplateProductIds(template.products.map((item) => item.masterProductId));
    setManageTemplateProductsSearch("");
    setTemplateProductsError(null);
    setOpenProductTemplateActionMenuId(null);
    setIsManageTemplateProductsModalOpen(true);
  }

  function closeManageTemplateProductsModal() {
    setIsManageTemplateProductsModalOpen(false);
    setManageTemplateProductsSearch("");
    setSelectedTemplateProductIds([]);
    setTemplateProductsError(null);
    setIsTemplateProductsSaving(false);
  }

  async function handleProductTemplateSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!productTemplateForm.code.trim()) {
      setProductTemplateFormError("Template code is required.");
      return;
    }

    if (!productTemplateForm.name.trim()) {
      setProductTemplateFormError("Template name is required.");
      return;
    }

    setIsProductTemplateSaving(true);
    setProductTemplateFormError(null);

    try {
      const endpoint =
        productTemplateModalMode === "edit" && selectedProductTemplate
          ? `/api/product-templates/${selectedProductTemplate.id}`
          : "/api/product-templates";
      const method = productTemplateModalMode === "edit" && selectedProductTemplate ? "PUT" : "POST";

      const response = await fetch(endpoint, {
        method,
        credentials: "include",
        headers: {
          "content-type": "application/json",
        },
        body: JSON.stringify({
          code: productTemplateForm.code,
          name: productTemplateForm.name,
          description: productTemplateForm.description,
          status: productTemplateForm.status,
        }),
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to save product template.");
      }

      closeProductTemplateModal();
      await refreshProductTemplates();
    } catch (error) {
      setProductTemplateFormError(error instanceof Error ? error.message : "Failed to save product template.");
    } finally {
      setIsProductTemplateSaving(false);
    }
  }

  async function deleteProductTemplate(template: ProductTemplateRecord) {
    const shouldDelete = window.confirm(`Delete template "${template.name}"?`);

    if (!shouldDelete) {
      return;
    }

    try {
      const response = await fetch(`/api/product-templates/${template.id}`, {
        method: "DELETE",
        credentials: "include",
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to delete template.");
      }

      await refreshProductTemplates();
    } catch (error) {
      setProductTemplateLoadError(error instanceof Error ? error.message : "Failed to delete template.");
    }
  }

  async function handleManageTemplateProductsSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!selectedProductTemplate) {
      setTemplateProductsError("Select a template first.");
      return;
    }

    setIsTemplateProductsSaving(true);
    setTemplateProductsError(null);

    try {
      const response = await fetch(`/api/product-templates/${selectedProductTemplate.id}/products`, {
        method: "PUT",
        credentials: "include",
        headers: {
          "content-type": "application/json",
        },
        body: JSON.stringify({
          productIds: selectedTemplateProductIds,
        }),
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to update template products.");
      }

      closeManageTemplateProductsModal();
      await refreshProductTemplates();
    } catch (error) {
      setTemplateProductsError(error instanceof Error ? error.message : "Failed to update template products.");
    } finally {
      setIsTemplateProductsSaving(false);
    }
  }

  async function removeTemplateProduct(templateId: string, productId: string) {
    try {
      const response = await fetch(`/api/product-templates/${templateId}/products/${productId}`, {
        method: "DELETE",
        credentials: "include",
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to remove product.");
      }

      await refreshProductTemplates();
    } catch (error) {
      setProductTemplateLoadError(error instanceof Error ? error.message : "Failed to remove product.");
    }
  }

  const filteredBrands = brandData.brands.filter((brand) => {
    if (brandStatusFilter && brand.status !== brandStatusFilter) {
      return false;
    }

    if (!brandSearch.trim()) {
      return true;
    }

    return isSubsequenceMatch(
      brandSearch,
      [brand.name, brand.description ?? "", brand.statusLabel].join(" "),
    );
  });

  function resetProductCatalogFilters() {
    setProductCatalogSearch("");
    setProductCatalogCategoryFilter("");
    setProductCatalogBrandFilter("");
    setProductCatalogStatusFilter("");
  }

  function resetBarcodeFilters() {
    setBarcodeSearch("");
    setBarcodeCategoryFilter("");
    setBarcodeBrandFilter("");
    setBarcodeStatusFilter("");
  }

  function openCreateProductCatalogModal() {
    setProductCatalogModalMode("create");
    setEditingProductId(null);
    setProductCatalogForm(defaultProductCatalogFormState);
    setProductCatalogFormError(null);
    setProductPicture({
      previewUrl: "",
      fileName: "",
    });
    setProductPictureError(null);
    setIsProductCatalogModalOpen(true);
  }

  function openCreateBarcodeModal() {
    setBarcodeModalMode("assign");
    setSelectedBarcodeProduct(null);
    setEditingProductId(null);
    setProductCatalogForm(defaultProductCatalogFormState);
    setProductCatalogFormError(null);
    setOpenBarcodeActionMenuId(null);
    setIsBarcodeModalOpen(true);
  }

  function openEditProductCatalogModal(product: ProductCatalogRecord) {
    setProductCatalogModalMode("edit");
    setEditingProductId(product.id);
    setProductCatalogForm({
      name: product.name,
      sku: product.sku,
      price: product.price != null ? String(product.price) : "",
      barcode: product.barcode ?? "",
      suggestedPrice: product.suggestedPrice != null ? String(product.suggestedPrice) : "",
      categoryId: product.categoryId ?? "",
      brandId: product.brandId ?? "",
      unitId: product.unitId ?? "",
      packageSize: product.packageSize ?? "",
      description: product.note ?? "",
      barcodeStatus: product.status === "ARCHIVED" ? "ARCHIVED" : "ACTIVE",
    });
    setProductPicture({
      previewUrl: product.pictureUrl ?? "",
      fileName: product.pictureUrl ? product.pictureUrl.split("/").pop() ?? "product-picture" : "",
    });
    setProductPictureError(null);
    setProductCatalogFormError(null);
    setOpenBarcodeActionMenuId(null);
    setOpenProductCatalogActionMenuId(null);
    setIsProductCatalogModalOpen(true);
  }

  function openEditBarcodeModal(product: ProductCatalogRecord) {
    setBarcodeModalMode(product.barcode ? "edit" : "assign");
    setSelectedBarcodeProduct(product);
    setEditingProductId(product.id);
    setProductCatalogForm({
      name: product.name,
      sku: product.sku,
      price: product.price != null ? String(product.price) : "",
      barcode: product.barcode ?? "",
      suggestedPrice: product.suggestedPrice != null ? String(product.suggestedPrice) : "",
      categoryId: product.categoryId ?? "",
      brandId: product.brandId ?? "",
      unitId: product.unitId ?? "",
      packageSize: product.packageSize ?? "",
      description: product.note ?? "",
      barcodeStatus: product.status === "ARCHIVED" ? "ARCHIVED" : "ACTIVE",
    });
    setProductCatalogFormError(null);
    setOpenBarcodeActionMenuId(null);
    setIsBarcodeModalOpen(true);
  }

  const filteredProductCatalogRows = productCatalogData.products.filter((product) => {
    if (productCatalogCategoryFilter && product.categoryId !== productCatalogCategoryFilter) {
      return false;
    }

    if (productCatalogBrandFilter && product.brandId !== productCatalogBrandFilter) {
      return false;
    }

    if (productCatalogStatusFilter && product.status !== productCatalogStatusFilter) {
      return false;
    }

    if (!productCatalogSearch.trim()) {
      return true;
    }

    return isSubsequenceMatch(
      productCatalogSearch,
      [product.name, product.sku, product.barcode ?? "", product.category, product.brand, product.unit].join(" "),
    );
  });

  const filteredProductTemplateRows = productTemplateData.templates.filter((template) => {
    if (productTemplateStatusFilter && template.status !== productTemplateStatusFilter) {
      return false;
    }

    if (!productTemplateSearch.trim()) {
      return true;
    }

    return isSubsequenceMatch(
      productTemplateSearch,
      [template.code, template.name, template.description ?? "", template.statusLabel].join(" "),
    );
  });

  const productTemplateStatCards = [
    {
      label: "Total Templates",
      value: String(productTemplateData.stats.total),
      note: "All product templates",
      accent: "indigo" as const,
      icon: FiFileText,
    },
    {
      label: "Active Templates",
      value: String(productTemplateData.stats.active),
      note: "Currently active",
      accent: "green" as const,
      icon: FiCheckCircle,
    },
    {
      label: "Inactive Templates",
      value: String(productTemplateData.stats.inactive),
      note: "Temporarily hidden",
      accent: "amber" as const,
      icon: FiPauseCircle,
    },
    {
      label: "With Products",
      value: String(productTemplateData.stats.withProducts),
      note: "Starter packs ready",
      accent: "red" as const,
      icon: FiPackage,
    },
  ];

  const availableTemplateProducts = productCatalogData.products.filter((product) => {
    if (!manageTemplateProductsSearch.trim()) {
      return true;
    }

    return isSubsequenceMatch(
      manageTemplateProductsSearch,
      [product.name, product.sku, product.barcode ?? "", product.category, product.brand, product.unit].join(" "),
    );
  });

  const barcodeDatabaseRows = productCatalogData.products
    .map<BarcodeDatabaseRow>((product) => ({
      id: product.id,
      productName: product.name,
      productNote: product.note ?? product.packageSize ?? "No additional note",
      pictureUrl: product.pictureUrl,
      sku: product.sku,
      category: product.category,
      categoryId: product.categoryId,
      brand: product.brand,
      brandId: product.brandId,
      unit: product.unit,
      barcode: product.barcode,
      status: getBarcodeDatabaseStatus(product),
      addedDate: formatMasterDataDate(product.createdAt),
      addedTime: formatMasterDataTime(product.createdAt),
      type: product.type,
    }))
    .filter((product) => {
      if (barcodeCategoryFilter && product.categoryId !== barcodeCategoryFilter) {
        return false;
      }

      if (barcodeBrandFilter && product.brandId !== barcodeBrandFilter) {
        return false;
      }

      if (barcodeStatusFilter && product.status !== barcodeStatusFilter) {
        return false;
      }

      if (!barcodeSearch.trim()) {
        return true;
      }

      return isSubsequenceMatch(
        barcodeSearch,
        [product.productName, product.sku, product.barcode ?? "", product.category, product.brand, product.unit].join(" "),
      );
    });

  const mappedBarcodeCount = productCatalogData.products.filter((product) => getBarcodeDatabaseStatus(product) === "Mapped").length;
  const unmappedBarcodeCount = productCatalogData.products.filter((product) => getBarcodeDatabaseStatus(product) === "Unmapped").length;
  const archivedBarcodeCount = productCatalogData.products.filter((product) => getBarcodeDatabaseStatus(product) === "Archived").length;
  const currentMonth = new Date().getMonth();
  const currentYear = new Date().getFullYear();
  const newBarcodeThisMonthCount = productCatalogData.products.filter((product) => {
    if (!product.barcode) {
      return false;
    }

    const createdAt = new Date(product.createdAt);
    return createdAt.getMonth() === currentMonth && createdAt.getFullYear() === currentYear;
  }).length;

  const barcodeDatabaseStats = [
    {
      label: "Total Barcodes",
      value: formatStatValue(mappedBarcodeCount),
      note: "Products with barcode",
      accent: "indigo" as const,
      type: "barcode" as const,
    },
    {
      label: "Mapped",
      value: formatStatValue(mappedBarcodeCount),
      note: `${productCatalogData.products.length === 0 ? 0 : Math.round((mappedBarcodeCount / productCatalogData.products.length) * 100)}% of products`,
      accent: "green" as const,
      type: "mapped" as const,
    },
    {
      label: "Unmapped",
      value: formatStatValue(unmappedBarcodeCount),
      note: "Need barcode assignment",
      accent: "amber" as const,
      type: "grid" as const,
    },
    {
      label: "New ( This Month)",
      value: formatStatValue(newBarcodeThisMonthCount),
      note: "Created this month",
      accent: "violet" as const,
      type: "badge" as const,
    },
    {
      label: "Archived",
      value: formatStatValue(archivedBarcodeCount),
      note: "Inactive barcode records",
      accent: "red" as const,
      type: "scan" as const,
    },
  ];

  function closeUnitModal() {
    setIsUnitModalOpen(false);
    setUnitForm(defaultUnitFormState);
    setUnitFormError(null);
  }

  const filteredUnits = unitData.units.filter((unit) => {
    if (unitTypeFilter && unit.type !== unitTypeFilter) {
      return false;
    }

    if (unitStatusFilter && unit.status !== unitStatusFilter) {
      return false;
    }

    if (!unitSearch.trim()) {
      return true;
    }

    return isSubsequenceMatch(
      unitSearch,
      [unit.name, unit.shortName, unit.typeLabel, unit.description ?? "", unit.statusLabel].join(" "),
    );
  });

  useEffect(() => {
    setUnitCurrentPage(1);
  }, [unitSearch, unitTypeFilter, unitStatusFilter, unitPageSize]);

  const unitTotalPages = Math.max(1, Math.ceil(filteredUnits.length / unitPageSize));
  const safeUnitCurrentPage = Math.min(unitCurrentPage, unitTotalPages);
  const unitPageStartIndex = (safeUnitCurrentPage - 1) * unitPageSize;
  const paginatedUnits = filteredUnits.slice(unitPageStartIndex, unitPageStartIndex + unitPageSize);

  const unitVisiblePages = (() => {
    if (unitTotalPages <= 5) {
      return Array.from({ length: unitTotalPages }, (_, index) => index + 1);
    }

    if (safeUnitCurrentPage <= 3) {
      return [1, 2, 3, 4, unitTotalPages];
    }

    if (safeUnitCurrentPage >= unitTotalPages - 2) {
      return [1, unitTotalPages - 3, unitTotalPages - 2, unitTotalPages - 1, unitTotalPages];
    }

    return [1, safeUnitCurrentPage - 1, safeUnitCurrentPage, safeUnitCurrentPage + 1, unitTotalPages];
  })();

  async function refreshUnits() {
    setIsUnitLoading(true);
    setUnitLoadError(null);

    try {
      const response = await fetch("/api/units", {
        credentials: "include",
        cache: "no-store",
      });

      const payload = (await response.json().catch(() => null)) as
        | UnitApiResponse
        | { message?: string }
        | null;

      if (!response.ok) {
        throw new Error(payload && "message" in payload ? payload.message || "Failed to load units." : "Failed to load units.");
      }

      if (payload && "units" in payload) {
        setUnitData(payload);
      }
    } catch (error) {
      setUnitLoadError(error instanceof Error ? error.message : "Failed to load units.");
    } finally {
      setIsUnitLoading(false);
    }
  }

  async function refreshBrands() {
    setIsBrandLoading(true);
    setBrandLoadError(null);

    try {
      const response = await fetch("/api/brands", {
        credentials: "include",
        cache: "no-store",
      });

      const payload = (await response.json().catch(() => null)) as
        | BrandApiResponse
        | { message?: string }
        | null;

      if (!response.ok) {
        throw new Error(payload && "message" in payload ? payload.message || "Failed to load brands." : "Failed to load brands.");
      }

      if (payload && "brands" in payload) {
        setBrandData(payload);
      }
    } catch (error) {
      setBrandLoadError(error instanceof Error ? error.message : "Failed to load brands.");
    } finally {
      setIsBrandLoading(false);
    }
  }

async function refreshProductCatalog() {
    setIsProductCatalogLoading(true);
    setProductCatalogLoadError(null);

    try {
      const response = await fetch("/api/products", {
        credentials: "include",
        cache: "no-store",
      });

      const payload = (await response.json().catch(() => null)) as
        | ProductCatalogApiResponse
        | { message?: string }
        | null;

      if (!response.ok) {
        throw new Error(payload && "message" in payload ? payload.message || "Failed to load products." : "Failed to load products.");
      }

      if (payload && "products" in payload) {
        setProductCatalogData(payload);
      }
    } catch (error) {
      setProductCatalogLoadError(error instanceof Error ? error.message : "Failed to load products.");
    } finally {
      setIsProductCatalogLoading(false);
  }
}

  async function setProductCatalogStatus(product: ProductCatalogRecord, nextStatus: ProductStatusValue) {
    setProductCatalogFormError(null);
    setProductCatalogLoadError(null);

    try {
      const response = await fetch(`/api/products/${product.id}/status`, {
        method: "PATCH",
        credentials: "include",
        headers: {
          "content-type": "application/json",
        },
        body: JSON.stringify({ status: nextStatus }),
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to change product status.");
      }

      setOpenBarcodeActionMenuId(null);
      setOpenProductCatalogActionMenuId(null);
      await refreshProductCatalog();
    } catch (error) {
      setProductCatalogLoadError(error instanceof Error ? error.message : "Failed to change product status.");
    }
  }

  async function unmapBarcodeRecord(product: ProductCatalogRecord) {
    setProductCatalogFormError(null);
    setProductCatalogLoadError(null);

    try {
      const response = await fetch(`/api/products/${product.id}`, {
        method: "PUT",
        credentials: "include",
        headers: {
          "content-type": "application/json",
        },
        body: JSON.stringify({
          name: product.name,
          sku: product.sku,
          price: product.price,
          barcode: null,
          suggestedPrice: product.suggestedPrice,
          categoryId: product.categoryId,
          brandId: product.brandId,
          unitId: product.unitId,
          packageSize: product.packageSize,
          description: product.note,
          pictureUrl: product.pictureUrl,
        }),
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to unmap barcode.");
      }

      setOpenBarcodeActionMenuId(null);
      await refreshProductCatalog();
    } catch (error) {
      setProductCatalogLoadError(error instanceof Error ? error.message : "Failed to unmap barcode.");
    }
  }

  async function handleBarcodeSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!selectedBarcodeProduct) {
      setProductCatalogFormError("Select an unmapped product from the table to assign a barcode.");
      return;
    }

    if (!productCatalogForm.barcode.trim()) {
      setProductCatalogFormError("Barcode number is required.");
      return;
    }

    setIsProductCatalogSaving(true);
    setProductCatalogFormError(null);

    try {
      const updateResponse = await fetch(`/api/products/${selectedBarcodeProduct.id}`, {
        method: "PUT",
        credentials: "include",
        headers: {
          "content-type": "application/json",
        },
        body: JSON.stringify({
          name: selectedBarcodeProduct.name,
          sku: selectedBarcodeProduct.sku,
          price: selectedBarcodeProduct.price,
          barcode: productCatalogForm.barcode,
          suggestedPrice: selectedBarcodeProduct.suggestedPrice,
          categoryId: selectedBarcodeProduct.categoryId,
          brandId: selectedBarcodeProduct.brandId,
          unitId: selectedBarcodeProduct.unitId,
          packageSize: productCatalogForm.packageSize,
          description: selectedBarcodeProduct.note,
          pictureUrl: selectedBarcodeProduct.pictureUrl,
        }),
      });

      const updatePayload = (await updateResponse.json().catch(() => null)) as { message?: string } | null;

      if (!updateResponse.ok) {
        throw new Error(updatePayload?.message || "Failed to save barcode.");
      }

      if (barcodeModalMode === "edit") {
        const nextStatus = productCatalogForm.barcodeStatus;

        if (selectedBarcodeProduct.status !== nextStatus) {
          const statusResponse = await fetch(`/api/products/${selectedBarcodeProduct.id}/status`, {
            method: "PATCH",
            credentials: "include",
            headers: {
              "content-type": "application/json",
            },
            body: JSON.stringify({ status: nextStatus }),
          });

          const statusPayload = (await statusResponse.json().catch(() => null)) as { message?: string } | null;

          if (!statusResponse.ok) {
            throw new Error(statusPayload?.message || "Failed to update barcode status.");
          }
        }
      } else if (selectedBarcodeProduct.status !== "ACTIVE") {
        const statusResponse = await fetch(`/api/products/${selectedBarcodeProduct.id}/status`, {
          method: "PATCH",
          credentials: "include",
          headers: {
            "content-type": "application/json",
          },
          body: JSON.stringify({ status: "ACTIVE" }),
        });

        const statusPayload = (await statusResponse.json().catch(() => null)) as { message?: string } | null;

        if (!statusResponse.ok) {
          throw new Error(statusPayload?.message || "Failed to activate barcode.");
        }
      }

      closeBarcodeModal();
      await refreshProductCatalog();
    } catch (error) {
      setProductCatalogFormError(error instanceof Error ? error.message : "Failed to save barcode.");
    } finally {
      setIsProductCatalogSaving(false);
    }
  }

  function openGeneratedBarcode(productId: string) {
    window.open(getBarcodeImageUrl(productId), "_blank", "noopener,noreferrer");
  }

  function downloadGeneratedBarcode(productId: string) {
    const link = document.createElement("a");
    link.href = getBarcodeImageUrl(productId, true);
    link.download = "";
    document.body.appendChild(link);
    link.click();
    link.remove();
  }

  async function handleProductCatalogSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!productCatalogForm.name.trim()) {
      setProductCatalogFormError("Product name is required.");
      return;
    }

    if (!productCatalogForm.sku.trim()) {
      setProductCatalogFormError("SKU is required.");
      return;
    }

    setIsProductCatalogSaving(true);
    setProductCatalogFormError(null);

    try {
      const endpoint =
        productCatalogModalMode === "edit" && editingProductId
          ? `/api/products/${editingProductId}`
          : "/api/products";
      const method = productCatalogModalMode === "edit" && editingProductId ? "PUT" : "POST";

      const response = await fetch(endpoint, {
        method,
        credentials: "include",
        headers: {
          "content-type": "application/json",
        },
        body: JSON.stringify({
          name: productCatalogForm.name,
          sku: productCatalogForm.sku,
          price: productCatalogForm.price,
          barcode: productCatalogForm.barcode,
          suggestedPrice: productCatalogForm.suggestedPrice,
          categoryId: productCatalogForm.categoryId || null,
          brandId: productCatalogForm.brandId || null,
          unitId: productCatalogForm.unitId || null,
          packageSize: productCatalogForm.packageSize,
          description: productCatalogForm.description,
          pictureUrl: productPicture.previewUrl || null,
        }),
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to save product.");
      }

      if (isBarcodeModalOpen) {
        closeBarcodeModal();
      } else {
        closeProductCatalogModal();
      }
      await refreshProductCatalog();
    } catch (error) {
      setProductCatalogFormError(error instanceof Error ? error.message : "Failed to save product.");
    } finally {
      setIsProductCatalogSaving(false);
    }
  }

  async function duplicateProductCatalogRow(productId: string) {
    setProductCatalogFormError(null);
    setProductCatalogLoadError(null);

    try {
      const response = await fetch(`/api/products/${productId}/duplicate`, {
        method: "POST",
        credentials: "include",
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to duplicate product.");
      }

      setOpenProductCatalogActionMenuId(null);
      await refreshProductCatalog();
    } catch (error) {
      setProductCatalogLoadError(error instanceof Error ? error.message : "Failed to duplicate product.");
    }
  }

  async function changeProductCatalogStatus(product: ProductCatalogRecord) {
    const nextStatus: ProductStatusValue =
      product.status === "ACTIVE"
        ? "INACTIVE"
        : product.status === "INACTIVE"
          ? "ACTIVE"
          : "ACTIVE";
    await setProductCatalogStatus(product, nextStatus);
  }

  async function deleteProductCatalogRow(product: ProductCatalogRecord) {
    const shouldDelete = window.confirm(`Delete "${product.name}"? This action cannot be undone.`);

    if (!shouldDelete) {
      return;
    }

    setProductCatalogFormError(null);
    setProductCatalogLoadError(null);

    try {
      const response = await fetch(`/api/products/${product.id}`, {
        method: "DELETE",
        credentials: "include",
      });

      const payload = (await response.json().catch(() => null)) as { message?: string } | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to delete product.");
      }

      setOpenProductCatalogActionMenuId(null);
      await refreshProductCatalog();
    } catch (error) {
      setProductCatalogLoadError(error instanceof Error ? error.message : "Failed to delete product.");
    }
  }

  async function handleBrandSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!brandForm.name.trim()) {
      setBrandFormError("Brand name is required.");
      return;
    }

    setIsBrandSaving(true);
    setBrandFormError(null);

    try {
      const response = await fetch("/api/brands", {
        method: "POST",
        credentials: "include",
        headers: {
          "content-type": "application/json",
        },
        body: JSON.stringify({
          name: brandForm.name,
          description: brandForm.description,
          status: brandForm.status,
          logoUrl: brandForm.logoUrl || null,
        }),
      });

      const payload = (await response.json().catch(() => null)) as
        | { message?: string }
        | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to save brand.");
      }

      closeBrandModal();
      await refreshBrands();
    } catch (error) {
      setBrandFormError(error instanceof Error ? error.message : "Failed to save brand.");
    } finally {
      setIsBrandSaving(false);
    }
  }

  async function handleBrandLogoChange(event: ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];

    if (!file) {
      return;
    }

    if (!brandLogoAcceptedTypes.includes(file.type)) {
      setBrandFormError("Brand logo must be a JPG, PNG, or SVG file.");
      event.target.value = "";
      return;
    }

    if (file.size > maxBrandLogoSizeInBytes) {
      setBrandFormError("Brand logo must be 2 MB or smaller.");
      event.target.value = "";
      return;
    }

    try {
      const dataUrl = await new Promise<string>((resolve, reject) => {
        const reader = new FileReader();

        reader.onload = () => resolve(typeof reader.result === "string" ? reader.result : "");
        reader.onerror = () => reject(new Error("Failed to read logo file."));
        reader.readAsDataURL(file);
      });

      setBrandForm((current) => ({
        ...current,
        logoUrl: dataUrl,
        logoName: file.name,
      }));
      setBrandFormError(null);
    } catch (error) {
      setBrandFormError(error instanceof Error ? error.message : "Failed to read logo file.");
    } finally {
      event.target.value = "";
    }
  }

  async function handleProductPictureChange(event: ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];

    if (!file) {
      return;
    }

    if (!productPictureAcceptedTypes.includes(file.type)) {
      setProductPictureError("Product picture must be JPG, PNG, WEBP, or SVG.");
      event.target.value = "";
      return;
    }

    if (file.size > maxProductPictureSizeInBytes) {
      setProductPictureError("Product picture must be 10 MB or smaller.");
      event.target.value = "";
      return;
    }

    try {
      const previewUrl = await new Promise<string>((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(typeof reader.result === "string" ? reader.result : "");
        reader.onerror = () => reject(new Error("Failed to read product picture."));
        reader.readAsDataURL(file);
      });

      setProductPicture({
        previewUrl,
        fileName: file.name,
      });
      setProductPictureError(null);
    } catch (error) {
      setProductPictureError(error instanceof Error ? error.message : "Failed to read product picture.");
    } finally {
      event.target.value = "";
    }
  }

  async function handleUnitSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!unitForm.name.trim()) {
      setUnitFormError("Unit name is required.");
      return;
    }

    if (!unitForm.shortName.trim()) {
      setUnitFormError("Short name is required.");
      return;
    }

    if (!unitForm.type) {
      setUnitFormError("Unit type is required.");
      return;
    }

    setIsUnitSaving(true);
    setUnitFormError(null);

    try {
      const response = await fetch("/api/units", {
        method: "POST",
        credentials: "include",
        headers: {
          "content-type": "application/json",
        },
        body: JSON.stringify({
          name: unitForm.name,
          shortName: unitForm.shortName,
          type: unitForm.type,
          description: unitForm.description,
          status: unitForm.status,
        }),
      });

      const payload = (await response.json().catch(() => null)) as
        | { message?: string }
        | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to save unit.");
      }

      closeUnitModal();
      await refreshUnits();
    } catch (error) {
      setUnitFormError(error instanceof Error ? error.message : "Failed to save unit.");
    } finally {
      setIsUnitSaving(false);
    }
  }

  async function handleApproveUnit(unitId: string) {
    setUnitLoadError(null);
    setOpenUnitActionMenuId(null);

    try {
      const response = await fetch(`/api/units/${unitId}/approve`, {
        method: "POST",
      });
      const payload = (await response.json().catch(() => null)) as
        | { message?: string }
        | null;

      if (!response.ok) {
        throw new Error(payload?.message || "Failed to approve unit.");
      }

      await refreshUnits();
    } catch (error) {
      setUnitLoadError(error instanceof Error ? error.message : "Failed to approve unit.");
    }
  }

  if (slug === "brand") {

    return (
      <section className="master-category-page">
        <div className="master-category-stats">
          {[
            { label: "Total Brands", value: String(brandData.stats.total), note: "All Brands", accent: "indigo" as const, icon: LuBadgeInfo },
            { label: "Active Brands", value: String(brandData.stats.active), note: "Active Brands", accent: "green" as const, icon: LuBadgeCheck },
            { label: "Inactive Brands", value: String(brandData.stats.inactive), note: "Inactive Brands", accent: "amber" as const, icon: LuCircleOff },
            { label: "Archived Brands", value: String(brandData.stats.archived), note: "Archived Brands", accent: "red" as const, icon: LuArchive },
          ].map((item) => (
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
              <input
                type="text"
                placeholder="Search brands..."
                value={brandSearch}
                onChange={(event) => setBrandSearch(event.target.value)}
              />
            </label>

            <select
              className="master-category-select"
              value={brandStatusFilter}
              onChange={(event) => setBrandStatusFilter(event.target.value as BrandStatusValue | "")}
            >
              <option value="">All Status</option>
              <option value="ACTIVE">Active</option>
              <option value="INACTIVE">Inactive</option>
              <option value="ARCHIVED">Archived</option>
            </select>

            <button
              type="button"
              className="master-category-outline-button brand-page-reset-button"
              onClick={resetBrandFilters}
            >
              Clear Filters
            </button>

            <button
              type="button"
              className="master-category-primary-button brand-page-add-button"
              onClick={() => {
                setBrandForm(defaultBrandFormState);
                setBrandFormError(null);
                setIsBrandModalOpen(true);
              }}
            >
              + Add Brand
            </button>
          </div>

          {brandLoadError ? (
            <p style={{ margin: "0 0 16px", color: "#b42318", fontSize: "0.95rem" }}>{brandLoadError}</p>
          ) : null}

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

            {isBrandLoading ? (
              <div className="brand-page-table-row">
                <span style={{ gridColumn: "1 / -1", color: "#667085" }}>Loading brands...</span>
              </div>
            ) : filteredBrands.length === 0 ? (
              <div className="brand-page-table-row">
                <span style={{ gridColumn: "1 / -1", color: "#667085" }}>No brands found for the current filters.</span>
              </div>
            ) : (
              filteredBrands.map((row, index) => (
                <div className="brand-page-table-row" key={row.id}>
                  <span>{index + 1}</span>
                  <span className="brand-page-brand-cell">
                    {row.logoUrl ? (
                      <img
                        src={row.logoUrl}
                        alt={`${row.name} logo`}
                        className="brand-page-brand-logo"
                      />
                    ) : (
                      <span className="brand-page-brand-logo-fallback" aria-hidden="true">
                        {row.name.charAt(0).toUpperCase()}
                      </span>
                    )}
                    <span>{row.name}</span>
                  </span>
                  <span>{row.description || "No description"}</span>
                  <span>{row.categories}</span>
                  <span>{row.products}</span>
                  <span>
                    <em
                      className={`master-category-status-badge${
                        row.status === "INACTIVE"
                          ? " master-category-status-badge-inactive"
                          : row.status === "ARCHIVED"
                            ? " brand-page-status-badge-archived"
                            : ""
                      }`}
                    >
                      {row.statusLabel}
                    </em>
                  </span>
                  <span>{formatUnitDate(row.createdAt)}</span>
                  <span className="master-category-actions">
                    <button type="button" className="master-category-icon-button master-category-icon-button-edit">
                      <MoneyBoxActionIcon type="edit" />
                    </button>
                    <button type="button" className="master-category-icon-button master-category-icon-button-more">
                      <ProductCatalogControlIcon type="more" />
                    </button>
                  </span>
                </div>
              ))
            )}
          </div>

          <div className="master-category-footer">
            <span className="master-category-footer-text">Showing {filteredBrands.length} brands total</span>

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
          <div className="payment-modal-backdrop" onClick={closeBrandModal}>
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
                  onClick={closeBrandModal}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="brand-modal-form" onSubmit={handleBrandSubmit}>
                <label className="master-category-form-field">
                  <span>Brand Name *</span>
                  <input
                    type="text"
                    placeholder="Enter brand name"
                    value={brandForm.name}
                    onChange={(event) =>
                      setBrandForm((current) => ({
                        ...current,
                        name: event.target.value,
                      }))
                    }
                  />
                </label>

                <label className="master-category-form-field">
                  <span>Description</span>
                  <textarea
                    placeholder="Write brand description"
                    value={brandForm.description}
                    onChange={(event) =>
                      setBrandForm((current) => ({
                        ...current,
                        description: event.target.value,
                      }))
                    }
                  />
                </label>

                <div className="master-category-form-field">
                  <span>Brand Logo</span>
                  <label className="brand-modal-upload-box">
                    <input
                      type="file"
                      accept=".jpg,.jpeg,.png,.svg,image/jpeg,image/png,image/svg+xml"
                      onChange={handleBrandLogoChange}
                      style={{ display: "none" }}
                    />
                    {brandForm.logoUrl ? (
                      <>
                        <img
                          src={brandForm.logoUrl}
                          alt="Brand logo preview"
                          className="brand-modal-upload-preview"
                        />
                        <strong>{brandForm.logoName || "Selected logo"}</strong>
                        <small>Click to replace</small>
                      </>
                    ) : (
                      <>
                        <strong>Upload logo</strong>
                        <small>JPG, PNG, or SVG</small>
                        <small>Recommended for square brand marks</small>
                      </>
                    )}
                  </label>
                  {brandForm.logoUrl ? (
                    <button
                      type="button"
                      className="brand-modal-upload-clear"
                      onClick={() =>
                        setBrandForm((current) => ({
                          ...current,
                          logoUrl: "",
                          logoName: "",
                        }))
                      }
                    >
                      Remove Logo
                    </button>
                  ) : null}
                </div>

                <label className="master-category-form-field">
                  <span>Status *</span>
                  <select
                    value={brandForm.status}
                    onChange={(event) =>
                      setBrandForm((current) => ({
                        ...current,
                        status: event.target.value as BrandStatusValue,
                      }))
                    }
                  >
                    <option value="ACTIVE">Active</option>
                    <option value="INACTIVE">Inactive</option>
                    <option value="ARCHIVED">Archived</option>
                  </select>
                </label>

                {brandFormError ? (
                  <p style={{ margin: 0, color: "#b42318", fontSize: "0.95rem" }}>{brandFormError}</p>
                ) : null}

                <div className="master-category-form-actions">
                  <button
                    type="button"
                    className="master-category-reset-button"
                    onClick={closeBrandModal}
                  >
                    Cancel
                  </button>
                  <button type="submit" className="master-category-save-button" disabled={isBrandSaving}>
                    {isBrandSaving ? "Saving..." : "Save Brand"}
                  </button>
                </div>
              </form>
            </div>
          </div>
        ) : null}
      </section>
    );
  }

  if (slug === "supplier-data") {
    const filteredSuppliers = supplierData.suppliers.filter((supplier) => {
      if (supplierStatusFilter && supplier.status !== supplierStatusFilter) {
        return false;
      }

      if (!supplierSearch.trim()) {
        return true;
      }

      return isSubsequenceMatch(
        supplierSearch,
        [
          supplier.supplierCode,
          supplier.name,
          supplier.mobile ?? "",
          supplier.email ?? "",
          supplier.contactPerson ?? "",
          supplier.contactPersonMobile ?? "",
        ].join(" "),
      );
    });

    const supplierStatCards = [
      { label: "Total Suppliers", value: String(supplierData.stats.total), note: "All suppliers", accent: "indigo" as const, type: "users" as const },
      { label: "Active Suppliers", value: String(supplierData.stats.active), note: "Currently active", accent: "green" as const, type: "check" as const },
      { label: "Inactive Suppliers", value: String(supplierData.stats.inactive), note: "Temporarily inactive", accent: "amber" as const, type: "close" as const },
      { label: "Archived Suppliers", value: String(supplierData.stats.archived), note: "Soft deleted", accent: "red" as const, type: "alert" as const },
    ];

    return (
      <>
        <section className="master-category-page">
          <div className="master-category-stats">
            {supplierStatCards.map((item) => (
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
            <div className="master-category-toolbar supplier-page-toolbar">
              <label className="master-category-search product-catalog-search">
                <span className="product-catalog-search-icon" aria-hidden="true">
                  <ProductCatalogControlIcon type="search" />
                </span>
                <input
                  type="text"
                  placeholder="Search supplier, mobile, contact person..."
                  value={supplierSearch}
                  onChange={(event) => setSupplierSearch(event.target.value)}
                />
              </label>

              <select
                className="master-category-select"
                value={supplierStatusFilter}
                onChange={(event) => setSupplierStatusFilter(event.target.value as SupplierStatusValue | "")}
              >
                <option value="">All Status</option>
                <option value="ACTIVE">Active</option>
                <option value="INACTIVE">Inactive</option>
                <option value="ARCHIVED">Archived</option>
              </select>

              <button
                type="button"
                className="master-category-outline-button supplier-page-reset-button"
                onClick={() => {
                  setSupplierSearch("");
                  setSupplierStatusFilter("");
                }}
              >
                Reset
              </button>

              <button
                type="button"
                className="master-category-primary-button supplier-page-add-button"
                onClick={openCreateSupplierModal}
              >
                + Add Supplier
              </button>
            </div>

            {supplierLoadError ? (
              <p className="master-category-inline-error">{supplierLoadError}</p>
            ) : null}

            <div className="supplier-page-table">
              <div className="supplier-page-table-head">
                <span>#</span>
                <span>Supplier Code</span>
                <span>Supplier Name</span>
                <span>Mobile</span>
                <span>Contact Person</span>
                <span>Status</span>
                <span>Date</span>
                <span>Action</span>
              </div>

              {isSupplierLoading ? (
                <div className="supplier-page-table-row">
                  <span style={{ gridColumn: "1 / -1" }}>Loading suppliers...</span>
                </div>
              ) : filteredSuppliers.length === 0 ? (
                <div className="supplier-page-table-row">
                  <span style={{ gridColumn: "1 / -1" }}>No suppliers matched your filters.</span>
                </div>
              ) : (
                filteredSuppliers.map((row, index) => (
                  <div className="supplier-page-table-row" key={row.id}>
                    <span>{index + 1}</span>
                    <span>{row.supplierCode}</span>
                    <span className="supplier-page-name-cell">
                      <strong>{row.name}</strong>
                      <small>{row.email || row.address || "No extra contact info"}</small>
                    </span>
                    <span>{row.mobile || "N/A"}</span>
                    <span className="supplier-page-name-cell">
                      <strong>{row.contactPerson || "N/A"}</strong>
                      <small>{row.contactPersonMobile || "No contact number"}</small>
                    </span>
                    <span>
                      <em
                        className={`master-category-status-badge${
                          row.status === "INACTIVE"
                            ? " unit-page-status-badge-inactive"
                            : row.status === "ARCHIVED"
                              ? " bank-account-status-badge-closed"
                              : ""
                        }`}
                      >
                        {row.statusLabel}
                      </em>
                    </span>
                    <span>{formatMasterDataDate(row.createdAt)}</span>
                    <span className="master-category-actions">
                      <button
                        type="button"
                        className="master-category-icon-button master-category-icon-button-edit"
                        onClick={() => openEditSupplierModal(row)}
                        aria-label={`Edit ${row.name}`}
                      >
                        <FiEdit />
                      </button>
                      <span className="master-category-action-menu">
                        <button
                          type="button"
                          className="master-category-icon-button master-category-icon-button-more"
                          onClick={() =>
                            setOpenSupplierActionMenuId((current) => (current === row.id ? null : row.id))
                          }
                          aria-haspopup="menu"
                          aria-expanded={openSupplierActionMenuId === row.id}
                          aria-label="More"
                        >
                          <ProductCatalogControlIcon type="more" />
                        </button>
                        {openSupplierActionMenuId === row.id ? (
                          <div className="master-category-action-dropdown" role="menu">
                            <button
                              type="button"
                              className="master-category-action-dropdown-item"
                              role="menuitem"
                              onClick={() => openViewSupplierModal(row)}
                            >
                              View Details
                            </button>
                            <button
                              type="button"
                              className="master-category-action-dropdown-item"
                              role="menuitem"
                              onClick={() => openEditSupplierModal(row)}
                            >
                              Edit
                            </button>
                            <button
                              type="button"
                              className="master-category-action-dropdown-item"
                              role="menuitem"
                              onClick={() => void setSupplierStatus(row, row.status === "ACTIVE" ? "INACTIVE" : "ACTIVE")}
                            >
                              {row.status === "ACTIVE" ? "Change Status to Inactive" : "Change Status to Active"}
                            </button>
                            <button
                              type="button"
                              className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                              role="menuitem"
                              onClick={() => void deleteSupplier(row)}
                            >
                              Delete
                            </button>
                          </div>
                        ) : null}
                      </span>
                    </span>
                  </div>
                ))
              )}
            </div>

            <div className="master-category-footer">
              <span className="master-category-footer-text">
                Showing {filteredSuppliers.length.toLocaleString("en-US")} suppliers total
              </span>
            </div>
          </section>
        </section>

        {isSupplierModalOpen ? (
          <div className="payment-modal-backdrop" onClick={closeSupplierModal}>
            <div
              className="payment-modal supplier-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="supplier-modal-title"
            >
              <div className="payment-modal-header supplier-modal-header">
                <div>
                  <h3 id="supplier-modal-title">
                    {supplierModalMode === "view" ? "View Supplier" : supplierModalMode === "edit" ? "Edit Supplier" : "Add Supplier"}
                  </h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={closeSupplierModal}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="supplier-modal-form" onSubmit={handleSupplierSubmit}>
                <div className="supplier-modal-grid">
                  <label className="payment-modal-field">
                    <span>Supplier Code</span>
                    <input
                      type="text"
                      value={supplierForm.supplierCode}
                      readOnly={supplierModalMode === "view"}
                      onChange={(event) =>
                        setSupplierForm((current) => ({
                          ...current,
                          supplierCode: event.target.value,
                        }))
                      }
                    />
                  </label>

                  <label className="payment-modal-field">
                    <span>Supplier Name</span>
                    <input
                      type="text"
                      value={supplierForm.name}
                      readOnly={supplierModalMode === "view"}
                      onChange={(event) =>
                        setSupplierForm((current) => ({
                          ...current,
                          name: event.target.value,
                        }))
                      }
                    />
                  </label>

                  <label className="payment-modal-field">
                    <span>Mobile</span>
                    <input
                      type="text"
                      value={supplierForm.mobile}
                      readOnly={supplierModalMode === "view"}
                      onChange={(event) =>
                        setSupplierForm((current) => ({
                          ...current,
                          mobile: event.target.value,
                        }))
                      }
                    />
                  </label>

                  <label className="payment-modal-field">
                    <span>Email</span>
                    <input
                      type="text"
                      value={supplierForm.email}
                      readOnly={supplierModalMode === "view"}
                      onChange={(event) =>
                        setSupplierForm((current) => ({
                          ...current,
                          email: event.target.value,
                        }))
                      }
                    />
                  </label>

                  <label className="payment-modal-field">
                    <span>Contact Person</span>
                    <input
                      type="text"
                      value={supplierForm.contactPerson}
                      readOnly={supplierModalMode === "view"}
                      onChange={(event) =>
                        setSupplierForm((current) => ({
                          ...current,
                          contactPerson: event.target.value,
                        }))
                      }
                    />
                  </label>

                  <label className="payment-modal-field">
                    <span>Contact Person Mobile</span>
                    <input
                      type="text"
                      value={supplierForm.contactPersonMobile}
                      readOnly={supplierModalMode === "view"}
                      onChange={(event) =>
                        setSupplierForm((current) => ({
                          ...current,
                          contactPersonMobile: event.target.value,
                        }))
                      }
                    />
                  </label>

                  <label className="payment-modal-field">
                    <span>Status</span>
                    <select
                      value={supplierForm.status}
                      disabled={supplierModalMode === "view"}
                      onChange={(event) =>
                        setSupplierForm((current) => ({
                          ...current,
                          status: event.target.value as SupplierStatusValue,
                        }))
                      }
                    >
                      <option value="ACTIVE">Active</option>
                      <option value="INACTIVE">Inactive</option>
                      <option value="ARCHIVED">Archived</option>
                    </select>
                  </label>

                  <label className="payment-modal-field payment-modal-field-full">
                    <span>Address</span>
                    <textarea
                      value={supplierForm.address}
                      readOnly={supplierModalMode === "view"}
                      onChange={(event) =>
                        setSupplierForm((current) => ({
                          ...current,
                          address: event.target.value,
                        }))
                      }
                    />
                  </label>

                  <label className="payment-modal-field payment-modal-field-full">
                    <span>Notes</span>
                    <textarea
                      value={supplierForm.notes}
                      readOnly={supplierModalMode === "view"}
                      onChange={(event) =>
                        setSupplierForm((current) => ({
                          ...current,
                          notes: event.target.value,
                        }))
                      }
                    />
                  </label>
                </div>

                {supplierFormError ? (
                  <p className="master-category-inline-error">{supplierFormError}</p>
                ) : null}

                <div className="payment-modal-actions supplier-modal-actions">
                  <button
                    type="button"
                    className="payment-modal-secondary-button"
                    onClick={closeSupplierModal}
                  >
                    {supplierModalMode === "view" ? "Close" : "Cancel"}
                  </button>
                  {supplierModalMode !== "view" ? (
                    <button type="submit" className="payment-modal-primary-button" disabled={isSupplierSaving}>
                      {isSupplierSaving ? "Saving..." : "Save Supplier"}
                    </button>
                  ) : null}
                </div>
              </form>
            </div>
          </div>
        ) : null}
      </>
    );
  }

  if (slug === "bank-account") {
    const filteredBankAccounts = bankAccountData.bankAccounts.filter((row) => {
      const matchesSearch = bankAccountSearch
        ? [row.shopName, row.accountName, row.bankName, row.branchName ?? "", row.accountNumber]
            .join(" ")
            .toLowerCase()
            .includes(bankAccountSearch.toLowerCase())
        : true;
      const matchesShop = bankAccountShopFilter ? row.shopId === bankAccountShopFilter : true;
      const matchesBank = bankAccountBankFilter ? row.bankName === bankAccountBankFilter : true;
      const matchesStatus = bankAccountStatusFilter ? row.status === bankAccountStatusFilter : true;

      return matchesSearch && matchesShop && matchesBank && matchesStatus;
    });

    const bankAccountStatCards = [
      {
        label: "Total Accounts",
        value: formatStatValue(bankAccountData.stats.total),
        note: "All Accounts",
        accent: "indigo" as const,
        icon: FiCreditCard,
      },
      {
        label: "Active Accounts",
        value: formatStatValue(bankAccountData.stats.active),
        note: "Active Accounts",
        accent: "green" as const,
        icon: FiCheckCircle,
      },
      {
        label: "Inactive Accounts",
        value: formatStatValue(bankAccountData.stats.inactive),
        note: "Inactive Accounts",
        accent: "amber" as const,
        icon: FiPauseCircle,
      },
      {
        label: "Total Balance",
        value: formatMoneyBoxCurrency(bankAccountData.stats.totalBalance),
        note: "Current Balance",
        accent: "red" as const,
        icon: FiDollarSign,
      },
    ];

    return (
      <>
        <section className="master-category-page">
          <div className="master-category-stats">
            {bankAccountStatCards.map((item) => (
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
                <input
                  type="text"
                  placeholder="Search account, bank or number..."
                  value={bankAccountSearch}
                  onChange={(event) => setBankAccountSearch(event.target.value)}
                />
              </label>

              <select
                className="master-category-select"
                value={bankAccountShopFilter}
                onChange={(event) => setBankAccountShopFilter(event.target.value)}
              >
                <option value="">All Stores</option>
                {shopOptions.map((shop) => (
                  <option key={shop.id} value={shop.id}>
                    {shop.shopName}
                  </option>
                ))}
              </select>

              <select
                className="master-category-select"
                value={bankAccountBankFilter}
                onChange={(event) => setBankAccountBankFilter(event.target.value)}
              >
                <option value="">All Banks</option>
                {bankAccountData.banks.map((bank) => (
                  <option key={bank} value={bank}>
                    {bank}
                  </option>
                ))}
              </select>

              <select
                className="master-category-select"
                value={bankAccountStatusFilter}
                onChange={(event) => setBankAccountStatusFilter(event.target.value as BankAccountStatusValue | "")}
              >
                <option value="">All Status</option>
                <option value="ACTIVE">Active</option>
                <option value="INACTIVE">Inactive</option>
                <option value="CLOSED">Closed</option>
              </select>

              <button
                type="button"
                className="master-category-outline-button bank-account-reset-button"
                onClick={() => {
                  setBankAccountSearch("");
                  setBankAccountShopFilter("");
                  setBankAccountBankFilter("");
                  setBankAccountStatusFilter("");
                }}
              >
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
                onClick={openCreateBankAccountModal}
              >
                + Add Account
              </button>
            </div>

            {bankAccountLoadError ? (
              <p className="master-category-inline-error">{bankAccountLoadError}</p>
            ) : null}

            {shopOptionsLoadError ? (
              <p className="master-category-inline-error">{shopOptionsLoadError}</p>
            ) : null}

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

              {isBankAccountLoading ? (
                <div className="master-category-empty-state">Loading bank accounts...</div>
              ) : filteredBankAccounts.length === 0 ? (
                <div className="master-category-empty-state">No bank accounts found.</div>
              ) : (
                filteredBankAccounts.map((row, index) => (
                  <div className="bank-account-table-row" key={row.id}>
                    <span>{index + 1}</span>
                    <span>{row.shopName}</span>
                    <span>{row.accountName}</span>
                    <span>{row.bankName}</span>
                    <span>{row.accountNumberMasked}</span>
                    <span>{row.branchName || "—"}</span>
                    <span>{formatBankAccountBalance(row.currentBalance, row.currency)}</span>
                    <span>
                      <em
                        className={`master-category-status-badge${
                          row.status === "INACTIVE"
                            ? " unit-page-status-badge-inactive"
                            : row.status === "CLOSED"
                              ? " bank-account-status-badge-closed"
                              : ""
                        }`}
                      >
                        {row.statusLabel}
                      </em>
                    </span>
                    <span>{formatMasterDataDate(row.updatedAt)}</span>
                    <span className="master-category-actions">
                      <button
                        type="button"
                        className="master-category-icon-button master-category-icon-button-edit"
                        onClick={() => openEditBankAccountModal(row)}
                      >
                        <MoneyBoxActionIcon type="edit" />
                      </button>
                      <button type="button" className="master-category-icon-button master-category-icon-button-more">
                        <ProductCatalogControlIcon type="more" />
                      </button>
                    </span>
                  </div>
                ))
              )}
            </div>

            <div className="master-category-footer">
              <span className="master-category-footer-text">
                Showing {filteredBankAccounts.length.toLocaleString("en-US")} bank accounts total
              </span>

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
          <div className="payment-modal-backdrop" onClick={closeBankAccountModal}>
            <div
              className="payment-modal bank-account-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="bank-account-modal-title"
            >
              <div className="payment-modal-header bank-account-modal-header">
                <div>
                  <h3 id="bank-account-modal-title">
                    {bankAccountModalMode === "edit" ? "Edit Bank Account" : "Add Bank Account"}
                  </h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={closeBankAccountModal}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="payment-modal-form bank-account-modal-form" onSubmit={handleBankAccountSubmit}>
                <div className="bank-account-modal-section">
                  <h4>Basic Information</h4>
                  <div className="bank-account-modal-grid">
                    <label className="payment-modal-field bank-account-modal-field payment-modal-field-full">
                      <span>Shop</span>
                      <select
                        value={bankAccountForm.shopId}
                        onChange={(event) =>
                          setBankAccountForm((current) => ({
                            ...current,
                            shopId: event.target.value,
                          }))
                        }
                      >
                        <option value="" disabled>
                          Select shop
                        </option>
                        {shopOptions.map((shop) => (
                          <option key={shop.id} value={shop.id}>
                            {shop.shopName}
                          </option>
                        ))}
                      </select>
                    </label>

                    <label className="payment-modal-field bank-account-modal-field">
                      <span>Account Name</span>
                      <input
                        type="text"
                        placeholder="Enter account name"
                        value={bankAccountForm.accountName}
                        onChange={(event) =>
                          setBankAccountForm((current) => ({
                            ...current,
                            accountName: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field bank-account-modal-field">
                      <span>Bank Name</span>
                      <input
                        type="text"
                        placeholder="Enter bank name"
                        value={bankAccountForm.bankName}
                        onChange={(event) =>
                          setBankAccountForm((current) => ({
                            ...current,
                            bankName: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field bank-account-modal-field">
                      <span>Branch Name</span>
                      <input
                        type="text"
                        placeholder="Enter branch name"
                        value={bankAccountForm.branchName}
                        onChange={(event) =>
                          setBankAccountForm((current) => ({
                            ...current,
                            branchName: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field bank-account-modal-field">
                      <span>Account Number</span>
                      <input
                        type="text"
                        placeholder="Enter account number"
                        value={bankAccountForm.accountNumber}
                        onChange={(event) =>
                          setBankAccountForm((current) => ({
                            ...current,
                            accountNumber: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field bank-account-modal-field payment-modal-field-full">
                      <span>Account Type</span>
                      <select
                        value={bankAccountForm.accountType}
                        onChange={(event) =>
                          setBankAccountForm((current) => ({
                            ...current,
                            accountType: event.target.value as BankAccountTypeValue | "",
                          }))
                        }
                      >
                        <option value="" disabled>Select account type</option>
                        <option value="CURRENT">Current</option>
                        <option value="SAVINGS">Savings</option>
                      </select>
                    </label>
                  </div>
                </div>

                <div className="bank-account-modal-section">
                  <h4>Balance Information</h4>
                  <div className="bank-account-modal-grid">
                    <label className="payment-modal-field bank-account-modal-field">
                      <span>Opening Balance</span>
                      <input
                        type="text"
                        placeholder="0.00"
                        value={bankAccountForm.openingBalance}
                        onChange={(event) =>
                          setBankAccountForm((current) => ({
                            ...current,
                            openingBalance: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field bank-account-modal-field">
                      <span>Currency</span>
                      <select
                        value={bankAccountForm.currency}
                        onChange={(event) =>
                          setBankAccountForm((current) => ({
                            ...current,
                            currency: event.target.value,
                          }))
                        }
                      >
                        <option value="BDT">BDT</option>
                        <option value="USD">USD</option>
                      </select>
                    </label>
                  </div>
                </div>

                <div className="bank-account-modal-section">
                  <h4>Settings</h4>
                  <div className="bank-account-modal-grid">
                    <label className="payment-modal-field bank-account-modal-field">
                      <span>Status</span>
                      <select
                        value={bankAccountForm.status}
                        onChange={(event) =>
                          setBankAccountForm((current) => ({
                            ...current,
                            status: event.target.value as BankAccountStatusValue,
                          }))
                        }
                      >
                        <option value="ACTIVE">Active</option>
                        <option value="INACTIVE">Inactive</option>
                        <option value="CLOSED">Closed</option>
                      </select>
                    </label>

                    <label className="bank-account-modal-check">
                      <input
                        type="checkbox"
                        checked={bankAccountForm.isDefault}
                        onChange={(event) =>
                          setBankAccountForm((current) => ({
                            ...current,
                            isDefault: event.target.checked,
                          }))
                        }
                      />
                      <span>Set as Default Account</span>
                    </label>

                    <label className="payment-modal-field bank-account-modal-field payment-modal-field-full">
                      <span>Notes</span>
                      <textarea
                        placeholder="Write account notes"
                        value={bankAccountForm.notes}
                        onChange={(event) =>
                          setBankAccountForm((current) => ({
                            ...current,
                            notes: event.target.value,
                          }))
                        }
                      />
                    </label>
                  </div>
                </div>

                {bankAccountFormError ? (
                  <p className="master-category-inline-error">{bankAccountFormError}</p>
                ) : null}

                <div className="payment-modal-actions bank-account-modal-actions">
                  <button
                    type="button"
                    className="payment-modal-secondary-button bank-account-modal-secondary-button"
                    onClick={closeBankAccountModal}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="payment-modal-primary-button bank-account-modal-primary-button"
                    disabled={isBankAccountSaving}
                  >
                    {isBankAccountSaving
                      ? "Saving..."
                      : bankAccountModalMode === "edit"
                        ? "Update Account"
                        : "Save Account"}
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
            {[
              { label: "Total Units", value: String(unitData.stats.total), note: "All Units", accent: "indigo" as const, type: "file" as const },
              { label: "Active Units", value: String(unitData.stats.active), note: "Active Units", accent: "green" as const, type: "check" as const },
              { label: "Inactive Units", value: String(unitData.stats.inactive), note: "Inactive Units", accent: "amber" as const, type: "close" as const },
              { label: "Archived Units", value: String(unitData.stats.archived), note: "Archived Units", accent: "red" as const, type: "delete" as const },
            ].map((item) => (
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
                <input
                  type="text"
                  placeholder="Search units..."
                  value={unitSearch}
                  onChange={(event) => setUnitSearch(event.target.value)}
                />
              </label>

              <select
                className="master-category-select"
                value={unitTypeFilter}
                onChange={(event) => setUnitTypeFilter(event.target.value as UnitTypeValue | "")}
              >
                <option value="">Type</option>
                {unitTypeOptions.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>

              <select
                className="master-category-select"
                value={unitStatusFilter}
                onChange={(event) => setUnitStatusFilter(event.target.value as UnitStatusValue | "")}
              >
                <option value="">Status</option>
                {unitStatusOptions.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>

              <button
                type="button"
                className="master-category-outline-button unit-page-reset-button"
                onClick={resetUnitFilters}
              >
                Clear Filters
              </button>

              <button
                type="button"
                className="master-category-primary-button unit-page-add-button"
                onClick={() => {
                  setUnitForm(defaultUnitFormState);
                  setUnitFormError(null);
                  setIsUnitModalOpen(true);
                }}
              >
                + Add New Unit
              </button>
            </div>

            {unitLoadError ? (
              <p style={{ margin: "0 0 16px", color: "#b42318", fontSize: "0.95rem" }}>{unitLoadError}</p>
            ) : null}

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

              {isUnitLoading ? (
                <div className="unit-page-table-row">
                  <span style={{ gridColumn: "1 / -1", color: "#667085" }}>Loading units...</span>
                </div>
              ) : filteredUnits.length === 0 ? (
                <div className="unit-page-table-row">
                  <span style={{ gridColumn: "1 / -1", color: "#667085" }}>No units found for the current filters.</span>
                </div>
              ) : (
                paginatedUnits.map((row, index) => (
                  <div className="unit-page-table-row" key={row.id}>
                    <span>{unitPageStartIndex + index + 1}</span>
                    <span>{row.name}</span>
                    <span>{row.shortName}</span>
                    <span>{row.typeLabel}</span>
                    <span>{row.description || "N/A"}</span>
                    <span>
                      <span style={{ display: "flex", flexDirection: "column", gap: "4px", alignItems: "flex-start" }}>
                        <em
                          className={`master-category-status-badge${
                            row.status === "INACTIVE" ? " unit-page-status-badge-inactive" : ""
                          }`}
                        >
                          {row.statusLabel}
                        </em>
                        {row.isApproved === false ? (
                          <em className="master-category-status-badge master-category-status-badge-pending">Pending Approval</em>
                        ) : null}
                      </span>
                    </span>
                    <span>{formatUnitDate(row.createdAt)}</span>
                    <span className="master-category-actions">
                      <button
                        type="button"
                        className="master-category-icon-button master-category-icon-button-edit"
                        aria-label="Edit Unit"
                      >
                        <FiEdit />
                      </button>
                      <span className="master-category-action-menu">
                        <button
                          type="button"
                          className="master-category-icon-button master-category-icon-button-more"
                          aria-label="More Actions"
                          aria-haspopup="menu"
                          aria-expanded={openUnitActionMenuId === row.id}
                          onClick={() =>
                            setOpenUnitActionMenuId((current) => (current === row.id ? null : row.id))
                          }
                        >
                          <FiMoreVertical />
                        </button>

                        {openUnitActionMenuId === row.id ? (
                          <div className="master-category-action-dropdown" role="menu">
                            {row.isApproved === false ? (
                              <button
                                type="button"
                                className="master-category-action-dropdown-item"
                                style={{ color: "#0b7a57", fontWeight: "bold" }}
                                role="menuitem"
                                onClick={() => void handleApproveUnit(row.id)}
                              >
                                <FiCheckCircle style={{ color: "#0b7a57" }} />
                                <span>Approve Unit</span>
                              </button>
                            ) : null}
                            <button
                              type="button"
                              className="master-category-action-dropdown-item"
                              role="menuitem"
                              onClick={() => setOpenUnitActionMenuId(null)}
                            >
                              <FiEye />
                              <span>View Details</span>
                            </button>
                            <button
                              type="button"
                              className="master-category-action-dropdown-item"
                              role="menuitem"
                              onClick={() => setOpenUnitActionMenuId(null)}
                            >
                              <FiCopy />
                              <span>Duplicate</span>
                            </button>
                            <button
                              type="button"
                              className="master-category-action-dropdown-item"
                              role="menuitem"
                              onClick={() => setOpenUnitActionMenuId(null)}
                            >
                              <FiToggleLeft />
                              <span>Change Status</span>
                            </button>
                            <button
                              type="button"
                              className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                              role="menuitem"
                              onClick={() => setOpenUnitActionMenuId(null)}
                            >
                              <FiTrash2 />
                              <span>Delete</span>
                            </button>
                          </div>
                        ) : null}
                      </span>
                    </span>

                  </div>
                ))
              )}
            </div>

            <div className="master-category-footer">
              <span className="master-category-footer-text">
                Showing{" "}
                {filteredUnits.length === 0
                  ? 0
                  : `${unitPageStartIndex + 1}-${Math.min(unitPageStartIndex + paginatedUnits.length, filteredUnits.length)}`}{" "}
                of {filteredUnits.length} filtered units
              </span>

              <div className="master-category-pagination">
                <button
                  type="button"
                  className="master-category-page-button"
                  onClick={() => setUnitCurrentPage((current) => Math.max(1, current - 1))}
                  disabled={safeUnitCurrentPage === 1}
                >
                  {"<"} Previous
                </button>

                {unitVisiblePages.map((page, index) => {
                  const previousPage = unitVisiblePages[index - 1];
                  const shouldShowEllipsis = previousPage && page - previousPage > 1;

                  return (
                    <span key={page} style={{ display: "contents" }}>
                      {shouldShowEllipsis ? (
                        <button type="button" className="master-category-page-chip" disabled>
                          ...
                        </button>
                      ) : null}
                      <button
                        type="button"
                        className={`master-category-page-chip${
                          page === safeUnitCurrentPage ? " master-category-page-chip-active" : ""
                        }`}
                        onClick={() => setUnitCurrentPage(page)}
                      >
                        {page}
                      </button>
                    </span>
                  );
                })}

                <button
                  type="button"
                  className="master-category-page-button"
                  onClick={() => setUnitCurrentPage((current) => Math.min(unitTotalPages, current + 1))}
                  disabled={safeUnitCurrentPage === unitTotalPages}
                >
                  Next Page {">"}
                </button>
              </div>

              <select
                className="master-category-page-size"
                value={String(unitPageSize)}
                onChange={(event) => setUnitPageSize(Number(event.target.value) as UnitPageSizeValue)}
              >
                {unitPageSizeOptions.map((option) => (
                  <option key={option} value={option}>
                    {option}
                  </option>
                ))}
              </select>
            </div>
          </section>
        </section>

        {isUnitModalOpen ? (
          <div className="payment-modal-backdrop" onClick={closeUnitModal}>
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
                  onClick={closeUnitModal}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="payment-modal-form unit-modal-form" onSubmit={handleUnitSubmit}>
                <label className="payment-modal-field payment-modal-field-full unit-modal-field">
                  <span>Unit Name <sup>*</sup></span>
                  <input
                    type="text"
                    placeholder="Enter name"
                    value={unitForm.name}
                    onChange={(event) =>
                      setUnitForm((current) => ({
                        ...current,
                        name: event.target.value,
                      }))
                    }
                  />
                </label>

                <label className="payment-modal-field payment-modal-field-full unit-modal-field">
                  <span>Short Name <sup>*</sup></span>
                  <input
                    type="text"
                    placeholder="Example: pcs"
                    value={unitForm.shortName}
                    onChange={(event) =>
                      setUnitForm((current) => ({
                        ...current,
                        shortName: event.target.value,
                      }))
                    }
                  />
                </label>

                <label className="payment-modal-field payment-modal-field-full unit-modal-field">
                  <span>Unit Type <sup>*</sup></span>
                  <select
                    value={unitForm.type}
                    onChange={(event) =>
                      setUnitForm((current) => ({
                        ...current,
                        type: event.target.value as UnitTypeValue | "",
                      }))
                    }
                  >
                    <option value="" disabled>Select</option>
                    {unitTypeOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </label>

                <label className="payment-modal-field payment-modal-field-full unit-modal-field">
                  <span>Description (optional)</span>
                  <textarea
                    placeholder="Write description about unit"
                    value={unitForm.description}
                    onChange={(event) =>
                      setUnitForm((current) => ({
                        ...current,
                        description: event.target.value,
                      }))
                    }
                  />
                </label>

                <label className="payment-modal-field payment-modal-field-full unit-modal-field">
                  <span>Status <sup>*</sup></span>
                  <select
                    value={unitForm.status}
                    onChange={(event) =>
                      setUnitForm((current) => ({
                        ...current,
                        status: event.target.value as UnitStatusValue,
                      }))
                    }
                  >
                    <option value="ACTIVE">Active</option>
                    <option value="INACTIVE">Inactive</option>
                  </select>
                </label>

                {unitFormError ? (
                  <p style={{ margin: 0, color: "#b42318", fontSize: "0.95rem" }}>{unitFormError}</p>
                ) : null}

                <div className="payment-modal-actions unit-modal-actions">
                  <button
                    type="button"
                    className="payment-modal-secondary-button unit-modal-secondary-button"
                    onClick={closeUnitModal}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="payment-modal-primary-button unit-modal-primary-button"
                    disabled={isUnitSaving}
                  >
                    {isUnitSaving ? "Saving..." : "Save"}
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
            {productTemplateStatCards.map((item) => (
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
                <input
                  type="text"
                  placeholder="Search template..."
                  value={productTemplateSearch}
                  onChange={(event) => setProductTemplateSearch(event.target.value)}
                />
              </label>

              <select
                className="master-category-select"
                value={productTemplateStatusFilter}
                onChange={(event) => setProductTemplateStatusFilter(event.target.value as ProductTemplateStatusValue | "")}
              >
                <option value="">All Status</option>
                <option value="ACTIVE">Active</option>
                <option value="INACTIVE">Inactive</option>
                <option value="ARCHIVED">Archived</option>
              </select>

              <button
                type="button"
                className="master-category-outline-button product-template-refresh-button"
                onClick={() => {
                  setProductTemplateSearch("");
                  setProductTemplateStatusFilter("");
                }}
              >
                <ProductCatalogControlIcon type="reset" />
                <span>Reset</span>
              </button>

              <button
                type="button"
                className="master-category-primary-button"
                onClick={openCreateProductTemplateModal}
              >
                + Add Template
              </button>
            </div>

            {productTemplateLoadError ? (
              <p className="master-category-inline-error">{productTemplateLoadError}</p>
            ) : null}

            <div className="product-template-table">
              <div className="product-template-table-head">
                <span>#</span>
                <span>Template Code</span>
                <span>Template Name</span>
                <span>Description</span>
                <span>Products</span>
                <span>Status</span>
                <span>Created Date</span>
                <span>Actions</span>
              </div>

              {isProductTemplateLoading ? (
                <div className="product-template-table-row">
                  <span>Loading templates...</span>
                </div>
              ) : filteredProductTemplateRows.length === 0 ? (
                <div className="product-template-table-row">
                  <span>No product templates matched your filters.</span>
                </div>
              ) : (
                filteredProductTemplateRows.map((row, index) => (
                  <div className="product-template-table-row" key={row.id}>
                    <span>{index + 1}</span>
                    <span>{row.code}</span>
                    <span>{row.name}</span>
                    <span>{row.description || "No description"}</span>
                    <span>{row.productCount}</span>
                    <span>
                      <em
                        className={`product-template-status-badge${
                          row.status === "INACTIVE"
                            ? " unit-page-status-badge-inactive"
                            : row.status === "ARCHIVED"
                              ? " bank-account-status-badge-closed"
                              : ""
                        }`}
                      >
                        {row.statusLabel}
                      </em>
                    </span>
                    <span className="product-template-date-cell">
                      <strong>{formatMasterDataDate(row.createdAt)}</strong>
                      <small>{formatMasterDataTime(row.createdAt)}</small>
                    </span>
                    <span className="master-category-actions">
                      <button
                        type="button"
                        className="master-category-icon-button master-category-icon-button-edit"
                        onClick={() => openEditProductTemplateModal(row)}
                      >
                        <MoneyBoxActionIcon type="edit" />
                      </button>
                      <button
                        type="button"
                        className="master-category-outline-button product-template-manage-button"
                        onClick={() => openManageTemplateProductsModal(row)}
                      >
                        Manage Products
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
                            <button
                              type="button"
                              className="master-category-action-dropdown-item"
                              role="menuitem"
                              onClick={() => openViewProductTemplateModal(row)}
                            >
                              View Template
                            </button>
                            <button
                              type="button"
                              className="master-category-action-dropdown-item"
                              role="menuitem"
                              onClick={() => openEditProductTemplateModal(row)}
                            >
                              Edit
                            </button>
                            <button
                              type="button"
                              className="master-category-action-dropdown-item"
                              role="menuitem"
                              onClick={() => openManageTemplateProductsModal(row)}
                            >
                              Manage Products
                            </button>
                            <button
                              type="button"
                              className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                              role="menuitem"
                              onClick={() => deleteProductTemplate(row)}
                            >
                              Delete Template
                            </button>
                          </div>
                        ) : null}
                      </span>
                    </span>
                  </div>
                ))
              )}
            </div>

            <div className="master-category-footer">
              <span className="master-category-footer-text">
                Showing {filteredProductTemplateRows.length.toLocaleString("en-US")} templates total
              </span>
            </div>
          </section>

          {selectedProductTemplate ? (
            <section className="master-category-table-card">
              <div className="master-category-section-heading">
                <h3>{selectedProductTemplate.name}</h3>
                <p>Products in this starter pack</p>
              </div>

              {selectedProductTemplate.products.length === 0 ? (
                <p className="master-category-empty-state">No products added to this template yet.</p>
              ) : (
                <div className="product-template-selected-products">
                  {selectedProductTemplate.products.map((product) => (
                    <div className="product-template-selected-product-row" key={product.masterProductId}>
                      <div className="product-template-selected-product-copy">
                        <strong>{product.name}</strong>
                        <span>{product.sku}</span>
                        <small>{product.barcode || `${product.category} • ${product.brand} • ${product.unit}`}</small>
                      </div>
                      <button
                        type="button"
                        className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                        onClick={() => void removeTemplateProduct(selectedProductTemplate.id, product.masterProductId)}
                      >
                        Remove
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </section>
          ) : null}
        </section>

        {isProductTemplateModalOpen ? (
          <div className="payment-modal-backdrop" onClick={closeProductTemplateModal}>
            <div
              className="payment-modal product-template-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="product-template-modal-title"
            >
              <div className="payment-modal-header product-template-modal-header">
                <div>
                  <h3 id="product-template-modal-title">
                    {productTemplateModalMode === "view"
                      ? "View Template"
                      : productTemplateModalMode === "edit"
                        ? "Edit Template"
                        : "Add Template"}
                  </h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={closeProductTemplateModal}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="product-template-modal-form" onSubmit={handleProductTemplateSubmit}>
                <label className="product-template-modal-field">
                  <span>Template Code <sup>*</sup></span>
                  <input
                    type="text"
                    value={productTemplateForm.code}
                    readOnly={productTemplateModalMode === "view"}
                    onChange={(event) =>
                      setProductTemplateForm((current) => ({
                        ...current,
                        code: event.target.value,
                      }))
                    }
                    placeholder="Exm: TMP-GROCERY-001"
                  />
                </label>

                <label className="product-template-modal-field">
                  <span>Template Name <sup>*</sup></span>
                  <input
                    type="text"
                    value={productTemplateForm.name}
                    readOnly={productTemplateModalMode === "view"}
                    onChange={(event) =>
                      setProductTemplateForm((current) => ({
                        ...current,
                        name: event.target.value,
                      }))
                    }
                    placeholder="Basic Grocery Starter Pack"
                  />
                </label>

                <label className="product-template-modal-field">
                  <span>Description</span>
                  <textarea
                    value={productTemplateForm.description}
                    readOnly={productTemplateModalMode === "view"}
                    onChange={(event) =>
                      setProductTemplateForm((current) => ({
                        ...current,
                        description: event.target.value,
                      }))
                    }
                    placeholder="Starter pack for grocery shops"
                  />
                </label>

                <label className="product-template-modal-field">
                  <span>Status</span>
                  <select
                    value={productTemplateForm.status}
                    disabled={productTemplateModalMode === "view"}
                    onChange={(event) =>
                      setProductTemplateForm((current) => ({
                        ...current,
                        status: event.target.value as ProductTemplateStatusValue,
                      }))
                    }
                  >
                    <option value="ACTIVE">Active</option>
                    <option value="INACTIVE">Inactive</option>
                    <option value="ARCHIVED">Archived</option>
                  </select>
                </label>

                {productTemplateModalMode === "view" && selectedProductTemplate ? (
                  <div className="product-template-modal-field">
                    <span>Products</span>
                    {selectedProductTemplate.products.length === 0 ? (
                      <p className="master-category-empty-state">No products added to this template yet.</p>
                    ) : (
                      <div className="product-template-selected-products">
                        {selectedProductTemplate.products.map((product) => (
                          <div className="product-template-selected-product-row" key={product.masterProductId}>
                            <div className="product-template-selected-product-copy">
                              <strong>{product.name}</strong>
                              <span>{product.sku}</span>
                              <small>{product.barcode || `${product.category} • ${product.brand} • ${product.unit}`}</small>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                ) : null}

                {productTemplateFormError ? (
                  <p className="master-category-inline-error">{productTemplateFormError}</p>
                ) : null}

                <div className="product-template-modal-actions">
                  <button type="button" className="payment-modal-secondary-button product-template-download-button" onClick={closeProductTemplateModal}>
                    {productTemplateModalMode === "view" ? "Close" : "Cancel"}
                  </button>
                  {productTemplateModalMode !== "view" ? (
                    <button type="submit" className="payment-modal-primary-button product-template-upload-button" disabled={isProductTemplateSaving}>
                      {isProductTemplateSaving ? "Saving..." : "Save"}
                    </button>
                  ) : null}
                </div>
              </form>
            </div>
          </div>
        ) : null}

        {isManageTemplateProductsModalOpen && selectedProductTemplate ? (
          <div className="payment-modal-backdrop" onClick={closeManageTemplateProductsModal}>
            <div
              className="payment-modal product-template-manage-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="manage-template-products-modal-title"
            >
              <div className="payment-modal-header product-template-modal-header">
                <div>
                  <h3 id="manage-template-products-modal-title">Manage Template Products</h3>
                  <p>Template: {selectedProductTemplate.name}</p>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={closeManageTemplateProductsModal}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="product-template-manage-form" onSubmit={handleManageTemplateProductsSubmit}>
                <label className="master-category-search product-catalog-search">
                  <span className="product-catalog-search-icon" aria-hidden="true">
                    <ProductCatalogControlIcon type="search" />
                  </span>
                  <input
                    type="text"
                    placeholder="Search by name / SKU / barcode"
                    value={manageTemplateProductsSearch}
                    onChange={(event) => setManageTemplateProductsSearch(event.target.value)}
                  />
                </label>

                <div className="product-template-manage-summary">
                  <strong>Selected Products: {selectedTemplateProductIds.length}</strong>
                </div>

                <div className="product-template-available-list">
                  {availableTemplateProducts.map((product) => (
                    <label className="product-template-available-item" key={product.id}>
                      <input
                        type="checkbox"
                        checked={selectedTemplateProductIds.includes(product.id)}
                        onChange={(event) =>
                          setSelectedTemplateProductIds((current) =>
                            event.target.checked
                              ? Array.from(new Set([...current, product.id]))
                              : current.filter((item) => item !== product.id),
                          )
                        }
                      />
                      <span className="product-template-available-copy">
                        <strong>{product.name}</strong>
                        <small>{product.sku} • {product.barcode || "No barcode"} • {product.unit}</small>
                      </span>
                    </label>
                  ))}
                </div>

                {templateProductsError ? (
                  <p className="master-category-inline-error">{templateProductsError}</p>
                ) : null}

                <div className="payment-modal-actions product-template-modal-actions">
                  <button type="button" className="payment-modal-secondary-button" onClick={closeManageTemplateProductsModal}>
                    Cancel
                  </button>
                  <button type="submit" className="payment-modal-primary-button product-template-upload-button" disabled={isTemplateProductsSaving}>
                    {isTemplateProductsSaving ? "Saving..." : "Add Selected Products"}
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
                <input
                  type="text"
                  placeholder="Search barcode, product or SKU..."
                  value={barcodeSearch}
                  onChange={(event) => setBarcodeSearch(event.target.value)}
                />
              </label>

              <select
                className="master-category-select"
                value={barcodeCategoryFilter}
                onChange={(event) => setBarcodeCategoryFilter(event.target.value)}
              >
                <option value="">Category</option>
                {productCatalogData.filters.categories.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.name}
                  </option>
                ))}
              </select>

              <select
                className="master-category-select"
                value={barcodeBrandFilter}
                onChange={(event) => setBarcodeBrandFilter(event.target.value)}
              >
                <option value="">Brand</option>
                {productCatalogData.filters.brands.map((brand) => (
                  <option key={brand.id} value={brand.id}>
                    {brand.name}
                  </option>
                ))}
              </select>

              <select
                className="master-category-select"
                value={barcodeStatusFilter}
                onChange={(event) => setBarcodeStatusFilter(event.target.value as BarcodeDatabaseStatusValue | "")}
              >
                <option value="">Status</option>
                <option value="Mapped">Mapped</option>
                <option value="Unmapped">Unmapped</option>
                <option value="Archived">Archived</option>
              </select>

              <button
                type="button"
                className="master-category-outline-button product-catalog-reset-button"
                onClick={resetBarcodeFilters}
              >
                <span>Reset</span>
              </button>

              <button
                type="button"
                className="master-category-primary-button barcode-database-add-button"
                onClick={openCreateBarcodeModal}
              >
                + Add Barcode
              </button>
            </div>
          </section>

          <section className="master-category-table-card">
            {productCatalogLoadError ? (
              <p className="master-category-inline-error">{productCatalogLoadError}</p>
            ) : null}

            {isProductCatalogLoading ? (
              <p className="master-category-empty-state">Loading barcode records...</p>
            ) : barcodeDatabaseRows.length === 0 ? (
              <p className="master-category-empty-state">No barcode records matched your filters.</p>
            ) : (
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

                {barcodeDatabaseRows.map((row, index) => {
                  const sourceProduct = productCatalogData.products.find((product) => product.id === row.id);
                  const canPreviewBarcode = Boolean(row.barcode && sourceProduct);

                  return (
                    <div className="barcode-database-table-row" key={row.id}>
                      <span>{index + 1}</span>
                      <span>
                        {canPreviewBarcode && sourceProduct ? (
                          <button
                            type="button"
                            className="barcode-database-preview-button"
                            onClick={() => openGeneratedBarcode(sourceProduct.id)}
                            title="Open generated barcode"
                          >
                            <img
                              src={getBarcodeImageUrl(sourceProduct.id)}
                              alt={`Generated barcode for ${row.productName}`}
                              className="barcode-database-preview-image"
                            />
                          </button>
                        ) : row.barcode ? (
                          <BarcodeRowPreview barcode={row.barcode} />
                        ) : (
                          "N/A"
                        )}
                      </span>
                      <span className="product-catalog-product-cell">
                        <span className={`product-catalog-product-icon product-catalog-product-icon-${row.type}`}>
                          {row.pictureUrl ? (
                            <img
                              src={row.pictureUrl}
                              alt={`${row.productName} picture`}
                              className="product-catalog-table-thumbnail"
                            />
                          ) : (
                            <ProductCatalogRowIcon type={row.type} />
                          )}
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
                      <span className="barcode-database-actions">
                        {sourceProduct ? (
                          <>
                            {row.status === "Unmapped" ? (
                              <button
                                type="button"
                                className="barcode-database-quick-action"
                                onClick={() => openEditBarcodeModal(sourceProduct)}
                              >
                                Assign Barcode
                              </button>
                            ) : null}

                            {row.status === "Mapped" ? (
                              <button
                                type="button"
                                className="barcode-database-quick-action barcode-database-quick-action-mapped"
                                onClick={() => openEditBarcodeModal(sourceProduct)}
                              >
                                Edit
                              </button>
                            ) : null}

                            {row.status === "Archived" ? (
                              <button
                                type="button"
                                className="barcode-database-quick-action barcode-database-quick-action-archived"
                                onClick={() => void setProductCatalogStatus(sourceProduct, "ACTIVE")}
                              >
                                Restore
                              </button>
                            ) : null}
                          </>
                        ) : null}

                        <span className="master-category-action-menu">
                          <button
                            type="button"
                            className="master-category-icon-button product-catalog-icon-button-more"
                            onClick={() =>
                              setOpenBarcodeActionMenuId((current) => (current === row.id ? null : row.id))
                            }
                            aria-haspopup="menu"
                            aria-expanded={openBarcodeActionMenuId === row.id}
                          >
                            <ProductCatalogControlIcon type="more" />
                          </button>
                          {openBarcodeActionMenuId === row.id && sourceProduct ? (
                            <div className="master-category-action-dropdown" role="menu">
                              {row.status === "Unmapped" ? (
                                <>
                                  <button
                                    type="button"
                                    className="master-category-action-dropdown-item"
                                    role="menuitem"
                                    onClick={() => openEditBarcodeModal(sourceProduct)}
                                  >
                                    Edit
                                  </button>
                                  <button
                                    type="button"
                                    className="master-category-action-dropdown-item"
                                    role="menuitem"
                                    onClick={() => void setProductCatalogStatus(sourceProduct, "ARCHIVED")}
                                  >
                                    Archive
                                  </button>
                                  <button
                                    type="button"
                                    className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                                    role="menuitem"
                                    onClick={() => deleteProductCatalogRow(sourceProduct)}
                                  >
                                    Delete
                                  </button>
                                </>
                              ) : null}

                              {row.status === "Mapped" ? (
                                <>
                                  <button
                                    type="button"
                                    className="master-category-action-dropdown-item"
                                    role="menuitem"
                                    onClick={() => openGeneratedBarcode(sourceProduct.id)}
                                  >
                                    View Barcode
                                  </button>
                                  <button
                                    type="button"
                                    className="master-category-action-dropdown-item"
                                    role="menuitem"
                                    onClick={() => downloadGeneratedBarcode(sourceProduct.id)}
                                  >
                                    Download Barcode
                                  </button>
                                  <button
                                    type="button"
                                    className="master-category-action-dropdown-item"
                                    role="menuitem"
                                    onClick={() => openEditProductCatalogModal(sourceProduct)}
                                  >
                                    View Product
                                  </button>
                                  <button
                                    type="button"
                                    className="master-category-action-dropdown-item"
                                    role="menuitem"
                                    onClick={() => void unmapBarcodeRecord(sourceProduct)}
                                  >
                                    Unmap
                                  </button>
                                  <button
                                    type="button"
                                    className="master-category-action-dropdown-item"
                                    role="menuitem"
                                    onClick={() => void setProductCatalogStatus(sourceProduct, "ARCHIVED")}
                                  >
                                    Archive
                                  </button>
                                </>
                              ) : null}

                              {row.status === "Archived" ? (
                                <>
                                  <button
                                    type="button"
                                    className="master-category-action-dropdown-item"
                                    role="menuitem"
                                    onClick={() => openGeneratedBarcode(sourceProduct.id)}
                                  >
                                    View Barcode
                                  </button>
                                  <button
                                    type="button"
                                    className="master-category-action-dropdown-item"
                                    role="menuitem"
                                    onClick={() => openEditProductCatalogModal(sourceProduct)}
                                  >
                                    View
                                  </button>
                                  <button
                                    type="button"
                                    className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                                    role="menuitem"
                                    onClick={() => deleteProductCatalogRow(sourceProduct)}
                                  >
                                    Delete Permanently
                                  </button>
                                </>
                              ) : null}
                            </div>
                          ) : null}
                        </span>
                      </span>
                    </div>
                  );
                })}
              </div>
            )}

            <div className="master-category-footer">
              <span className="master-category-footer-text">
                Showing {barcodeDatabaseRows.length.toLocaleString("en-US")} barcode records total
              </span>
            </div>
          </section>
        </section>

        {isBarcodeModalOpen ? (
          <div className="payment-modal-backdrop" onClick={closeBarcodeModal}>
            <div
              className="payment-modal barcode-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="barcode-modal-title"
            >
              <div className="payment-modal-header barcode-modal-header">
                <div>
                  <h3 id="barcode-modal-title">
                    {barcodeModalMode === "edit" ? "Edit Barcode" : "Assign Barcode"}
                  </h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={closeBarcodeModal}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form ref={barcodeFormRef} className="barcode-modal-form" onSubmit={handleBarcodeSubmit}>
                <div className="barcode-modal-section">
                  <h4>Product information</h4>
                  <div className="barcode-modal-grid barcode-modal-grid-product">
                    <label className="payment-modal-field">
                      <span>Product Name</span>
                      <input
                        type="text"
                        value={selectedBarcodeProduct?.name ?? ""}
                        readOnly
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>SKU</span>
                      <input
                        type="text"
                        value={selectedBarcodeProduct?.sku ?? ""}
                        readOnly
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>Category</span>
                      <select
                        value={selectedBarcodeProduct?.categoryId ?? ""}
                        disabled
                      >
                        <option value="">{selectedBarcodeProduct?.category ?? "Uncategorized"}</option>
                        {productCatalogData.filters.categories.map((category) => (
                          <option key={category.id} value={category.id}>
                            {category.name}
                          </option>
                        ))}
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>Brand</span>
                      <select
                        value={selectedBarcodeProduct?.brandId ?? ""}
                        disabled
                      >
                        <option value="">{selectedBarcodeProduct?.brand ?? "No Brand"}</option>
                        {productCatalogData.filters.brands.map((brand) => (
                          <option key={brand.id} value={brand.id}>
                            {brand.name}
                          </option>
                        ))}
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>Unit</span>
                      <select
                        value={selectedBarcodeProduct?.unitId ?? ""}
                        disabled
                      >
                        <option value="">{selectedBarcodeProduct?.unit ?? "No Unit"}</option>
                        {productCatalogData.filters.units.map((unit) => (
                          <option key={unit.id} value={unit.id}>
                            {unit.name} ({unit.shortName})
                          </option>
                        ))}
                      </select>
                    </label>
                  </div>
                </div>

                <div className="barcode-modal-section">
                  <h4>{barcodeModalMode === "edit" ? "Barcode Information" : "Barcode Assignment"}</h4>
                  <div className="barcode-modal-grid barcode-modal-grid-packaging">
                    <div className="payment-modal-field barcode-modal-scan-field">
                      <span>Barcode Number *</span>
                      <div className="barcode-modal-scan-row">
                        <input
                          ref={barcodeInputRef}
                          type="text"
                          placeholder="Enter barcode number"
                          value={productCatalogForm.barcode}
                          onChange={(event) =>
                            setProductCatalogForm((current) => ({
                              ...current,
                              barcode: event.target.value,
                            }))
                          }
                          onFocus={() => setIsBarcodeScannerReady(true)}
                          onKeyDown={(event) => {
                            if (event.key === "Enter") {
                              event.preventDefault();
                              barcodeFormRef.current?.requestSubmit();
                            }
                          }}
                        />
                        <button
                          type="button"
                          className="barcode-modal-scan-button"
                          onClick={() => {
                            barcodeInputRef.current?.focus();
                            barcodeInputRef.current?.select();
                            setIsBarcodeScannerReady(true);
                          }}
                        >
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
                          <span>{isBarcodeScannerReady ? "Scanner Ready" : "Scan Barcode"}</span>
                        </button>
                      </div>
                      <small className="barcode-modal-scan-helper">
                        {isBarcodeScannerReady
                          ? "Scan now or type the barcode number, then press Enter or Save."
                          : "Click Scan Barcode to capture the scanner input here."}
                      </small>
                    </div>

                    <label className="payment-modal-field">
                      <span>Pack Size</span>
                      <input
                        type="text"
                        placeholder="100 GM, 1 LT, 500ml etc."
                        value={productCatalogForm.packageSize}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            packageSize: event.target.value,
                          }))
                        }
                      />
                    </label>

                    {barcodeModalMode === "edit" ? (
                      <label className="payment-modal-field">
                        <span>Status</span>
                        <select
                          value={productCatalogForm.barcodeStatus}
                          onChange={(event) =>
                            setProductCatalogForm((current) => ({
                              ...current,
                              barcodeStatus: event.target.value as "ACTIVE" | "ARCHIVED",
                            }))
                          }
                        >
                          <option value="ACTIVE">Mapped</option>
                          <option value="ARCHIVED">Archived</option>
                        </select>
                      </label>
                    ) : null}

                    {!selectedBarcodeProduct ? (
                      <p className="master-category-empty-state">
                        Use the Assign Barcode action from an unmapped product row.
                      </p>
                    ) : null}
                  </div>
                </div>

                {productCatalogFormError ? (
                  <p className="master-category-inline-error">{productCatalogFormError}</p>
                ) : null}

                <div className="barcode-modal-actions">
                  <button
                    type="button"
                    className="payment-modal-secondary-button"
                    onClick={closeBarcodeModal}
                  >
                    Cancel
                  </button>
                  <button type="submit" className="payment-modal-primary-button" disabled={isProductCatalogSaving}>
                    {isProductCatalogSaving
                      ? "Saving..."
                      : barcodeModalMode === "edit"
                        ? "Save Changes"
                        : "Assign Barcode"}
                  </button>
                </div>
              </form>
            </div>
          </div>
        ) : null}

        {isProductCatalogModalOpen ? (
          <div className="payment-modal-backdrop" onClick={closeProductCatalogModal}>
            <div
              className="payment-modal product-catalog-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="product-catalog-modal-title"
            >
              <div className="payment-modal-header product-catalog-modal-header">
                <div>
                  <h3 id="product-catalog-modal-title">
                    {productCatalogModalMode === "edit" ? "Edit Product" : "Add new Product"}
                  </h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={closeProductCatalogModal}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="payment-modal-form product-catalog-modal-form" onSubmit={handleProductCatalogSubmit}>
                <div className="product-catalog-modal-section">
                  <h4>Price and Inventory</h4>
                  <div className="product-catalog-modal-grid">
                    <label className="payment-modal-field">
                      <span>Product name</span>
                      <input
                        type="text"
                        placeholder="Enter product name"
                        value={productCatalogForm.name}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            name: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>SKU</span>
                      <input
                        type="text"
                        placeholder="Enter SKU (Exm: PRD-0001)"
                        value={productCatalogForm.sku}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            sku: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>Price</span>
                      <input
                        type="text"
                        placeholder="Enter price"
                        value={productCatalogForm.price}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            price: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>Barcode</span>
                      <input
                        type="text"
                        placeholder="Enter Barcode"
                        value={productCatalogForm.barcode}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            barcode: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>Suggested selling price</span>
                      <input
                        type="text"
                        placeholder="Enter suggested selling price"
                        value={productCatalogForm.suggestedPrice}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            suggestedPrice: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>Category</span>
                      <select
                        value={productCatalogForm.categoryId}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            categoryId: event.target.value,
                          }))
                        }
                      >
                        <option value="" disabled>Select category</option>
                        {productCatalogData.filters.categories.map((category) => (
                          <option key={category.id} value={category.id}>
                            {category.name}
                          </option>
                        ))}
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>Brand</span>
                      <select
                        value={productCatalogForm.brandId}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            brandId: event.target.value,
                          }))
                        }
                      >
                        <option value="" disabled>Select Brand</option>
                        {productCatalogData.filters.brands.map((brand) => (
                          <option key={brand.id} value={brand.id}>
                            {brand.name}
                          </option>
                        ))}
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>Unit</span>
                      <select
                        value={productCatalogForm.unitId}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            unitId: event.target.value,
                          }))
                        }
                      >
                        <option value="" disabled>Select Unit</option>
                        {productCatalogData.filters.units.map((unit) => (
                          <option key={unit.id} value={unit.id}>
                            {unit.name} ({unit.shortName})
                          </option>
                        ))}
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>package Size</span>
                      <input
                        type="text"
                        placeholder="Exm: 100gm, 1 LT, 500 ML"
                        value={productCatalogForm.packageSize}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            packageSize: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field payment-modal-field-full">
                      <span>Additional Information</span>
                      <textarea
                        placeholder="Enter additional information."
                        value={productCatalogForm.description}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            description: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <div className="product-catalog-modal-upload-card">
                      <span>Product Picture</span>
                      <label className="product-catalog-modal-upload-box">
                        <input
                          type="file"
                          accept=".jpg,.jpeg,.png,.webp,.svg,image/jpeg,image/png,image/webp,image/svg+xml"
                          onChange={handleProductPictureChange}
                          style={{ display: "none" }}
                        />
                        {productPicture.previewUrl ? (
                          <img
                            src={productPicture.previewUrl}
                            alt="Product picture preview"
                            className="product-catalog-modal-upload-preview"
                          />
                        ) : (
                          <>
                            <strong>Upload picture</strong>
                            <small>JPG, PNG, WEBP, or SVG</small>
                            <small>maximum file size: 10MB</small>
                          </>
                        )}
                      </label>
                      {productPicture.previewUrl ? (
                        <button
                          type="button"
                          className="product-catalog-modal-upload-clear"
                          onClick={() => {
                            setProductPicture({
                              previewUrl: "",
                              fileName: "",
                            });
                            setProductPictureError(null);
                          }}
                        >
                          Remove picture
                        </button>
                      ) : null}
                      {productPictureError ? (
                        <p className="product-catalog-modal-upload-error">{productPictureError}</p>
                      ) : null}
                    </div>
                  </div>
                </div>

                {productCatalogFormError ? (
                  <p className="master-category-inline-error">{productCatalogFormError}</p>
                ) : null}

                <div className="payment-modal-actions product-catalog-modal-actions">
                  <button
                    type="button"
                    className="payment-modal-secondary-button"
                    onClick={closeProductCatalogModal}
                  >
                    Cancel
                  </button>
                  <button type="submit" className="payment-modal-primary-button" disabled={isProductCatalogSaving}>
                    {isProductCatalogSaving
                      ? "Saving..."
                      : productCatalogModalMode === "edit"
                        ? "Update Product"
                        : "Save Product"}
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
    const productCatalogStatCards = [
      {
        label: "Total Products",
        value: String(productCatalogData.stats.total),
        note: "All products",
        accent: "indigo" as const,
        type: "box" as const,
      },
      {
        label: "Active Products",
        value: String(productCatalogData.stats.active),
        note: "Shops can use these",
        accent: "green" as const,
        type: "check" as const,
      },
      {
        label: "Inactive Products",
        value: String(productCatalogData.stats.inactive),
        note: "In system, not visible",
        accent: "amber" as const,
        type: "clock" as const,
      },
      {
        label: "Using Shops",
        value: String(productCatalogData.stats.usingShops),
        note: "Shops using products",
        accent: "blue" as const,
        type: "shop" as const,
      },
    ];

    return (
      <>
        <section className="master-category-page">
          <div className="master-category-stats">
            {productCatalogStatCards.map((item) => (
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
              <input
                type="text"
                placeholder="Search products, barcode or SKU..."
                value={productCatalogSearch}
                onChange={(event) => setProductCatalogSearch(event.target.value)}
              />
            </label>

            <select
              className="master-category-select"
              value={productCatalogCategoryFilter}
              onChange={(event) => setProductCatalogCategoryFilter(event.target.value)}
            >
              <option value="">Category</option>
              {productCatalogData.filters.categories.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>

            <select
              className="master-category-select"
              value={productCatalogBrandFilter}
              onChange={(event) => setProductCatalogBrandFilter(event.target.value)}
            >
              <option value="">Brand</option>
              {productCatalogData.filters.brands.map((brand) => (
                <option key={brand.id} value={brand.id}>
                  {brand.name}
                </option>
              ))}
            </select>

            <select
              className="master-category-select"
              value={productCatalogStatusFilter}
              onChange={(event) => setProductCatalogStatusFilter(event.target.value as ProductStatusValue | "")}
            >
              <option value="">All Status</option>
              <option value="ACTIVE">Active</option>
              <option value="INACTIVE">Inactive</option>
              <option value="ARCHIVED">Archived</option>
            </select>

            <button
              type="button"
              className="master-category-outline-button product-catalog-reset-button"
              onClick={resetProductCatalogFilters}
            >
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
              onClick={openCreateProductCatalogModal}
            >
              + Add Product
            </button>
          </div>

          {productCatalogLoadError ? (
            <p className="master-category-inline-error">{productCatalogLoadError}</p>
          ) : null}

          <div className="product-catalog-table">
            <div className="product-catalog-table-head">
              <span>#</span>
              <span>Product</span>
              <span>Category</span>
              <span>Brand</span>
              <span>Unit</span>
              <span>Bar code</span>
              <span>Price</span>
              <span>Status</span>
              <span>Action</span>
            </div>

            {isProductCatalogLoading ? (
              <div className="product-catalog-table-row">
                <span>Loading products...</span>
              </div>
            ) : filteredProductCatalogRows.length ? (
              filteredProductCatalogRows.map((row, index) => (
                <div className="product-catalog-table-row" key={row.id}>
                  <span>{index + 1}</span>
                  <span className="product-catalog-product-cell">
                    <span className={`product-catalog-product-icon product-catalog-product-icon-${row.type}`}>
                      {row.pictureUrl ? (
                        <img
                          src={row.pictureUrl}
                          alt={`${row.name} picture`}
                          className="product-catalog-table-thumbnail"
                        />
                      ) : (
                        <ProductCatalogRowIcon type={row.type} />
                      )}
                    </span>
                    <span className="product-catalog-product-copy">
                      <strong>{row.name}</strong>
                      <small>{row.note || row.sku}</small>
                    </span>
                  </span>
                  <span>{row.category}</span>
                  <span>{row.brand}</span>
                  <span>{row.unit}</span>
                  <span>{row.barcode || "N/A"}</span>
                  <span>{row.priceLabel || "N/A"}</span>
                  <span>
                    <em className="product-catalog-status-badge">{row.statusLabel}</em>
                  </span>
                  <span className="master-category-actions">
                    <button
                      type="button"
                      className="master-category-icon-button master-category-icon-button-edit"
                      onClick={() => openEditProductCatalogModal(row)}
                      aria-label={`Edit ${row.name}`}
                    >
                      <MoneyBoxActionIcon type="edit" />
                    </button>
                    <span className="master-category-action-menu">
                      <button
                        type="button"
                        className="master-category-icon-button product-catalog-icon-button-more"
                        onClick={() =>
                          setOpenProductCatalogActionMenuId((current) => (current === row.id ? null : row.id))
                        }
                        aria-haspopup="menu"
                        aria-expanded={openProductCatalogActionMenuId === row.id}
                        aria-label="More"
                      >
                        <ProductCatalogControlIcon type="more" />
                      </button>

                      {openProductCatalogActionMenuId === row.id ? (
                        <div className="master-category-action-dropdown" role="menu">
                          <button
                            type="button"
                            className="master-category-action-dropdown-item"
                            role="menuitem"
                            onClick={() => openEditProductCatalogModal(row)}
                          >
                            <FiEye />
                            <span>View Details</span>
                          </button>
                          <button
                            type="button"
                            className="master-category-action-dropdown-item"
                            role="menuitem"
                            onClick={() => duplicateProductCatalogRow(row.id)}
                          >
                            <FiCopy />
                            <span>Duplicate</span>
                          </button>
                          <button
                            type="button"
                            className="master-category-action-dropdown-item"
                            role="menuitem"
                            onClick={() => changeProductCatalogStatus(row)}
                          >
                            <FiToggleLeft />
                            <span>{row.status === "ACTIVE" ? "Mark Inactive" : "Mark Active"}</span>
                          </button>
                          <button
                            type="button"
                            className="master-category-action-dropdown-item master-category-action-dropdown-item-danger"
                            role="menuitem"
                            onClick={() => deleteProductCatalogRow(row)}
                          >
                            <FiTrash2 />
                            <span>Delete</span>
                          </button>
                        </div>
                      ) : null}
                    </span>
                  </span>
                </div>
              ))
            ) : (
              <div className="product-catalog-table-row">
                <span>No products found.</span>
              </div>
            )}
          </div>

          <div className="master-category-footer">
            <span className="master-category-footer-text">
              Showing {filteredProductCatalogRows.length} products total
            </span>

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
          <div className="payment-modal-backdrop" onClick={closeProductCatalogModal}>
            <div
              className="payment-modal product-catalog-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="product-catalog-modal-title"
            >
              <div className="payment-modal-header product-catalog-modal-header">
                <div>
                  <h3 id="product-catalog-modal-title">
                    {productCatalogModalMode === "edit" ? "Edit Product" : "Add new Product"}
                  </h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={closeProductCatalogModal}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="payment-modal-form product-catalog-modal-form" onSubmit={handleProductCatalogSubmit}>
                <div className="product-catalog-modal-section">
                  <h4>Price and Inventory</h4>
                  <div className="product-catalog-modal-grid">
                    <label className="payment-modal-field">
                      <span>Product name</span>
                      <input
                        type="text"
                        placeholder="Enter product name"
                        value={productCatalogForm.name}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            name: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>SKU</span>
                      <input
                        type="text"
                        placeholder="Enter SKU (Exm: PRD-0001)"
                        value={productCatalogForm.sku}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            sku: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>Price</span>
                      <input
                        type="text"
                        placeholder="Enter price"
                        value={productCatalogForm.price}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            price: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>Barcode</span>
                      <input
                        type="text"
                        placeholder="Enter Barcode"
                        value={productCatalogForm.barcode}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            barcode: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>Suggested selling price</span>
                      <input
                        type="text"
                        placeholder="Enter suggested selling price"
                        value={productCatalogForm.suggestedPrice}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            suggestedPrice: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field">
                      <span>Category</span>
                      <select
                        value={productCatalogForm.categoryId}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            categoryId: event.target.value,
                          }))
                        }
                      >
                        <option value="" disabled>Select category</option>
                        {productCatalogData.filters.categories.map((category) => (
                          <option key={category.id} value={category.id}>
                            {category.name}
                          </option>
                        ))}
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>Brand</span>
                      <select
                        value={productCatalogForm.brandId}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            brandId: event.target.value,
                          }))
                        }
                      >
                        <option value="" disabled>Select Brand</option>
                        {productCatalogData.filters.brands.map((brand) => (
                          <option key={brand.id} value={brand.id}>
                            {brand.name}
                          </option>
                        ))}
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>Unit</span>
                      <select
                        value={productCatalogForm.unitId}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            unitId: event.target.value,
                          }))
                        }
                      >
                        <option value="" disabled>Select Unit</option>
                        {productCatalogData.filters.units.map((unit) => (
                          <option key={unit.id} value={unit.id}>
                            {unit.name} ({unit.shortName})
                          </option>
                        ))}
                      </select>
                    </label>

                    <label className="payment-modal-field">
                      <span>package Size</span>
                      <input
                        type="text"
                        placeholder="Exm: 100gm, 1 LT, 500 ML"
                        value={productCatalogForm.packageSize}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            packageSize: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <label className="payment-modal-field payment-modal-field-full">
                      <span>Additional Information</span>
                      <textarea
                        placeholder="Enter additional information."
                        value={productCatalogForm.description}
                        onChange={(event) =>
                          setProductCatalogForm((current) => ({
                            ...current,
                            description: event.target.value,
                          }))
                        }
                      />
                    </label>

                    <div className="product-catalog-modal-upload-card">
                      <span>Product Picture</span>
                      <label className="product-catalog-modal-upload-box">
                        <input
                          type="file"
                          accept=".jpg,.jpeg,.png,.webp,.svg,image/jpeg,image/png,image/webp,image/svg+xml"
                          onChange={handleProductPictureChange}
                          style={{ display: "none" }}
                        />
                        {productPicture.previewUrl ? (
                          <img
                            src={productPicture.previewUrl}
                            alt="Product picture preview"
                            className="product-catalog-modal-upload-preview"
                          />
                        ) : (
                          <>
                            <strong>Upload picture</strong>
                            <small>JPG, PNG, WEBP, or SVG</small>
                            <small>maximum file size: 10MB</small>
                          </>
                        )}
                      </label>
                      {productPicture.previewUrl ? (
                        <button
                          type="button"
                          className="product-catalog-modal-upload-clear"
                          onClick={() => {
                            setProductPicture({
                              previewUrl: "",
                              fileName: "",
                            });
                            setProductPictureError(null);
                          }}
                        >
                          Remove picture
                        </button>
                      ) : null}
                      {productPictureError ? (
                        <p className="product-catalog-modal-upload-error">{productPictureError}</p>
                      ) : null}
                    </div>
                  </div>
                </div>

                {productCatalogFormError ? (
                  <p className="master-category-inline-error">{productCatalogFormError}</p>
                ) : null}

                <div className="payment-modal-actions product-catalog-modal-actions">
                  <button
                    type="button"
                    className="payment-modal-secondary-button"
                    onClick={closeProductCatalogModal}
                  >
                    Cancel
                  </button>
                  <button type="submit" className="payment-modal-primary-button" disabled={isProductCatalogSaving}>
                    {isProductCatalogSaving
                      ? "Saving..."
                      : productCatalogModalMode === "edit"
                        ? "Update Product"
                        : "Save Product"}
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
    const filteredMoneyBoxes = moneyBoxData.moneyBoxes.filter((row) => {
      if (moneyBoxShopFilter && row.shopId !== moneyBoxShopFilter) {
        return false;
      }

      if (moneyBoxStatusFilter && row.status !== moneyBoxStatusFilter) {
        return false;
      }

      if (!moneyBoxSearch.trim()) {
        return true;
      }

      return isSubsequenceMatch(moneyBoxSearch, [row.shopName, row.boxName, row.code, row.typeLabel].join(" "));
    });

    const moneyBoxStatCards = [
      { label: "Total Money Boxes", value: String(moneyBoxData.stats.total), note: "All Money Boxes", accent: "indigo" as const, type: "users" as const },
      { label: "Total Balance", value: formatMoneyBoxCurrency(moneyBoxData.stats.totalBalance), note: "Current Balance", accent: "green" as const, type: "balance" as const },
      { label: "Active Boxes", value: String(moneyBoxData.stats.active), note: "Currently Active", accent: "indigo" as const, type: "check" as const },
      { label: "Inactive Boxes", value: String(moneyBoxData.stats.inactive), note: "Currently Inactive", accent: "red" as const, type: "alert" as const },
    ];

    return (
      <>
        <section className="master-category-page">
          <div className="master-category-stats">
            {moneyBoxStatCards.map((item) => (
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
                <input
                  type="text"
                  placeholder="Search box name, code or shop..."
                  value={moneyBoxSearch}
                  onChange={(event) => setMoneyBoxSearch(event.target.value)}
                />
              </label>

              <select
                className="master-category-select"
                value={moneyBoxShopFilter}
                onChange={(event) => setMoneyBoxShopFilter(event.target.value)}
              >
                <option value="">All Shops</option>
                {shopOptions.map((shop) => (
                  <option key={shop.id} value={shop.id}>
                    {shop.shopName}
                  </option>
                ))}
              </select>

              <select
                className="master-category-select"
                value={moneyBoxStatusFilter}
                onChange={(event) => setMoneyBoxStatusFilter(event.target.value as MoneyBoxStatusValue | "")}
              >
                <option value="">All Status</option>
                <option value="ACTIVE">Active</option>
                <option value="INACTIVE">Inactive</option>
              </select>

              <button
                type="button"
                className="master-category-outline-button"
                onClick={() => {
                  setMoneyBoxSearch("");
                  setMoneyBoxShopFilter("");
                  setMoneyBoxStatusFilter("");
                }}
              >
                Clear Filters
              </button>

              <button
                type="button"
                className="master-category-primary-button"
                onClick={openCreateMoneyBoxModal}
              >
                Add Money Box
              </button>
            </div>

            {moneyBoxLoadError || shopOptionsLoadError ? (
              <p className="master-category-inline-error">{moneyBoxLoadError || shopOptionsLoadError}</p>
            ) : null}

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

              {isMoneyBoxLoading ? (
                <div className="money-box-table-row">
                  <span style={{ gridColumn: "1 / -1" }}>Loading money boxes...</span>
                </div>
              ) : filteredMoneyBoxes.length === 0 ? (
                <div className="money-box-table-row">
                  <span style={{ gridColumn: "1 / -1" }}>No money boxes found for the current filters.</span>
                </div>
              ) : filteredMoneyBoxes.map((row, index) => (
                <div className="money-box-table-row" key={row.id}>
                  <span>{index + 1}</span>
                  <span>{row.shopName}</span>
                  <span>{row.boxName}</span>
                  <span>{row.code}</span>
                  <span>{row.typeLabel}</span>
                  <span>{formatMoneyBoxCurrency(row.currentBalance)}</span>
                  <span>
                    <em className={`master-category-status-badge${row.status === "INACTIVE" ? " unit-page-status-badge-inactive" : ""}`}>
                      {row.statusLabel}
                    </em>
                  </span>
                  <span>{formatMasterDataDate(row.createdAt)}</span>
                  <span className="master-category-actions money-box-row-actions">
                    <button
                      type="button"
                      className="money-box-action-button money-box-action-button-edit"
                      onClick={() => openEditMoneyBoxModal(row)}
                    >
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
              <span className="master-category-footer-text">
                Showing {filteredMoneyBoxes.length.toLocaleString("en-US")} money boxes total
              </span>
            </div>
          </section>
        </section>

        {isMoneyBoxModalOpen ? (
          <div className="payment-modal-backdrop" onClick={closeMoneyBoxModal}>
            <div
              className="payment-modal money-box-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
              aria-labelledby="money-box-modal-title"
            >
              <div className="payment-modal-header money-box-modal-header">
                <div>
                  <h3 id="money-box-modal-title">
                    {moneyBoxModalMode === "edit" ? "Edit Money Box" : "Add New Money Box"}
                  </h3>
                </div>
                <button
                  type="button"
                  className="payment-modal-close"
                  onClick={closeMoneyBoxModal}
                  aria-label="Close modal"
                >
                  ×
                </button>
              </div>

              <form className="payment-modal-form money-box-modal-form" onSubmit={handleMoneyBoxSubmit}>
                <label className="payment-modal-field payment-modal-field-full">
                  <span>Shop</span>
                  <select
                    value={moneyBoxForm.shopId}
                    disabled={isShopOptionsLoading || shopOptions.length === 0}
                    onChange={(event) =>
                      setMoneyBoxForm((current) => ({
                        ...current,
                        shopId: event.target.value,
                      }))
                    }
                  >
                    <option value="" disabled>
                      {isShopOptionsLoading ? "Loading shops..." : "Select shop"}
                    </option>
                    {shopOptions.map((shop) => (
                      <option key={shop.id} value={shop.id}>
                        {shop.shopName}
                      </option>
                    ))}
                  </select>
                </label>

                <label className="payment-modal-field payment-modal-field-full">
                  <span>Money box name</span>
                  <input
                    type="text"
                    placeholder="Enter name"
                    value={moneyBoxForm.boxName}
                    onChange={(event) =>
                      setMoneyBoxForm((current) => ({
                        ...current,
                        boxName: event.target.value,
                      }))
                    }
                  />
                </label>

                <label className="payment-modal-field payment-modal-field-full">
                  <span>Code</span>
                  <input
                    type="text"
                    placeholder="Enter Enter code  (CASH-001)"
                    value={moneyBoxForm.code}
                    onChange={(event) =>
                      setMoneyBoxForm((current) => ({
                        ...current,
                        code: event.target.value,
                      }))
                    }
                  />
                </label>

                <label className="payment-modal-field payment-modal-field-full">
                  <span>Type</span>
                  <select
                    value={moneyBoxForm.type}
                    onChange={(event) =>
                      setMoneyBoxForm((current) => ({
                        ...current,
                        type: event.target.value as MoneyBoxTypeValue | "",
                      }))
                    }
                  >
                    <option value="" disabled>
                      Select Type
                    </option>
                    <option value="NAGAD">Nagad</option>
                    <option value="BKASH">Bkash</option>
                    <option value="CASH">Cash</option>
                  </select>
                </label>

                <label className="payment-modal-field payment-modal-field-full">
                  <span>First Balance</span>
                  <input
                    type="text"
                    placeholder="$000"
                    value={moneyBoxForm.openingBalance}
                    onChange={(event) =>
                      setMoneyBoxForm((current) => ({
                        ...current,
                        openingBalance: event.target.value,
                      }))
                    }
                  />
                </label>

                <label className="payment-modal-field payment-modal-field-full">
                  <span>Details</span>
                  <textarea
                    placeholder="Enter Details"
                    value={moneyBoxForm.details}
                    onChange={(event) =>
                      setMoneyBoxForm((current) => ({
                        ...current,
                        details: event.target.value,
                      }))
                    }
                  />
                </label>

                <label className="payment-modal-field payment-modal-field-full">
                  <span>Condition</span>
                  <select
                    value={moneyBoxForm.status}
                    onChange={(event) =>
                      setMoneyBoxForm((current) => ({
                        ...current,
                        status: event.target.value as MoneyBoxStatusValue,
                      }))
                    }
                  >
                    <option value="ACTIVE">Active</option>
                    <option value="INACTIVE">Inactive</option>
                  </select>
                </label>

                {moneyBoxFormError ? (
                  <p className="master-category-inline-error">{moneyBoxFormError}</p>
                ) : null}

                <div className="payment-modal-actions money-box-modal-actions">
                  <button
                    type="button"
                    className="payment-modal-secondary-button money-box-modal-secondary-button"
                    onClick={closeMoneyBoxModal}
                  >
                    Reset
                  </button>
                  <button type="submit" className="payment-modal-primary-button money-box-modal-primary-button" disabled={isMoneyBoxSaving}>
                    {isMoneyBoxSaving
                      ? "Saving..."
                      : moneyBoxModalMode === "edit"
                        ? "Update Money Box"
                        : "Save Change"}
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
