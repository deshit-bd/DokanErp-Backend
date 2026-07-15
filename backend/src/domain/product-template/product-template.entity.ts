import type { ProductTemplateStatus } from "@prisma/client";

export type TemplateProduct = {
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

export type ProductTemplate = {
  id: string;
  code: string;
  name: string;
  description: string | null;
  status: ProductTemplateStatus;
  products: TemplateProduct[];
  createdAt: Date;
  updatedAt: Date;
};

export type ProductTemplateStats = {
  total: number;
  active: number;
  inactive: number;
  archived: number;
  withProducts: number;
};

export function toDisplayStatus(status: string): string {
  return status.replace(/_/g, " ");
}

export function selectPrimaryBarcode(barcodes: Array<{ barcode: string; status: "MAPPED" | "UNMAPPED" | "ARCHIVED" }>): { barcode: string; status: string } | null {
  return barcodes.find((item) => item.status === "MAPPED") ?? barcodes.find((item) => item.status === "UNMAPPED") ?? barcodes[0] ?? null;
}

export function computeProductTemplateStats(templates: Pick<ProductTemplate, "status" | "products">[]): ProductTemplateStats {
  return {
    total: templates.length,
    active: templates.filter((item) => item.status === "ACTIVE").length,
    inactive: templates.filter((item) => item.status === "INACTIVE").length,
    archived: templates.filter((item) => item.status === "ARCHIVED").length,
    withProducts: templates.filter((item) => item.products.length > 0).length,
  };
}
