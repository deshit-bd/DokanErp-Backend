import type { BrandStatus } from "@prisma/client";

import type { Brand } from "@domain/brand/brand.entity";

export type CreateBrandInput = {
  name: string;
  description: string | null;
  logoUrl: string | null;
  status: BrandStatus;
  createdByUserId: string;
};

export type UpdateBrandInput = {
  name: string;
  description: string | null;
  logoUrl: string | null;
  status: BrandStatus;
  updatedByUserId: string;
};

export type BulkDeleteResult = {
  archivedCount: number;
  deletedCount: number;
};

export interface BrandRepository {
  findMany(): Promise<Brand[]>;
  findByName(name: string): Promise<{ id: string } | null>;
  findByNameExcept(name: string, excludeId: string): Promise<{ id: string } | null>;
  findById(id: string): Promise<{ id: string } | null>;
  findByIdWithProductCount(id: string): Promise<{ id: string; productCount: number } | null>;
  create(input: CreateBrandInput): Promise<Brand>;
  update(id: string, input: UpdateBrandInput): Promise<Brand>;
  archive(id: string, updatedByUserId: string): Promise<void>;
  delete(id: string): Promise<void>;
  bulkArchiveOrDelete(ids: string[], updatedByUserId: string): Promise<BulkDeleteResult>;
}
