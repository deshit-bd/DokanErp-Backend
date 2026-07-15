import type { CategoryStatus } from "@prisma/client";

export type Category = {
  id: string;
  name: string;
  description: string | null;
  status: CategoryStatus;
  isGlobal: boolean;
  isApproved: boolean;
  shopId: string | null;
  productCount: number;
  createdAt: Date;
  updatedAt: Date;
  createdBy: { id: string; name: string } | null;
  updatedBy: { id: string; name: string } | null;
};

export type CategoryStats = {
  total: number;
  active: number;
  inactive: number;
  empty: number;
};

export function toDisplayStatus(status: CategoryStatus): string {
  return status.replace(/_/g, " ");
}

export function computeCategoryStats(categories: Pick<Category, "status" | "productCount">[]): CategoryStats {
  return {
    total: categories.length,
    active: categories.filter((item) => item.status === "ACTIVE").length,
    inactive: categories.filter((item) => item.status === "INACTIVE").length,
    empty: categories.filter((item) => item.productCount === 0).length,
  };
}
