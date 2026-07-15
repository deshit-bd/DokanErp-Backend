import type { BrandStatus } from "@prisma/client";

export type Brand = {
  id: string;
  name: string;
  description: string | null;
  logoUrl: string | null;
  status: BrandStatus;
  createdAt: Date;
  updatedAt: Date;
  createdBy: { id: string; name: string } | null;
  updatedBy: { id: string; name: string } | null;
  categoryCount: number;
  productCount: number;
};

export type BrandStats = {
  total: number;
  active: number;
  inactive: number;
  archived: number;
};

export function toDisplayStatus(status: BrandStatus): string {
  return status.replace(/_/g, " ");
}

export function computeBrandStats(brands: Pick<Brand, "status">[]): BrandStats {
  return {
    total: brands.length,
    active: brands.filter((item) => item.status === "ACTIVE").length,
    inactive: brands.filter((item) => item.status === "INACTIVE").length,
    archived: brands.filter((item) => item.status === "ARCHIVED").length,
  };
}
