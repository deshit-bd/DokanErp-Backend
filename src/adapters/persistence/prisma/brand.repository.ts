import type { Brand } from "@domain/brand/brand.entity";
import type {
  BrandRepository,
  BulkDeleteResult,
  CreateBrandInput,
  UpdateBrandInput,
} from "@application/brand/ports/brand-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

const BRAND_INCLUDE = {
  createdBy: { select: { id: true, name: true } },
  updatedBy: { select: { id: true, name: true } },
  masterProducts: { select: { id: true, categoryId: true } },
} as const;

type PrismaBrandWithMeta = {
  id: string;
  name: string;
  description: string | null;
  logoUrl: string | null;
  status: Brand["status"];
  createdAt: Date;
  updatedAt: Date;
  createdBy: { id: string; name: string } | null;
  updatedBy: { id: string; name: string } | null;
  masterProducts: Array<{ id: string; categoryId: string | null }>;
};

function toBrand(record: PrismaBrandWithMeta): Brand {
  return {
    id: record.id,
    name: record.name,
    description: record.description,
    logoUrl: record.logoUrl,
    status: record.status,
    categoryCount: new Set(record.masterProducts.map((item) => item.categoryId).filter(Boolean)).size,
    productCount: record.masterProducts.length,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
    createdBy: record.createdBy,
    updatedBy: record.updatedBy,
  };
}

export class PrismaBrandRepository implements BrandRepository {
  async findMany(): Promise<Brand[]> {
    const records = await (prisma as any).brand.findMany({
      orderBy: [{ createdAt: "desc" }, { name: "asc" }],
      include: BRAND_INCLUDE,
    });

    return records.map(toBrand);
  }

  async findByName(name: string) {
    return (prisma as any).brand.findUnique({ where: { name }, select: { id: true } });
  }

  async findByNameExcept(name: string, excludeId: string) {
    return (prisma as any).brand.findFirst({ where: { id: { not: excludeId }, name }, select: { id: true } });
  }

  async findById(id: string) {
    return (prisma as any).brand.findUnique({ where: { id }, select: { id: true } });
  }

  async findByIdWithProductCount(id: string) {
    const record = await (prisma as any).brand.findUnique({
      where: { id },
      include: { masterProducts: { select: { id: true } } },
    });

    if (!record) {
      return null;
    }

    return { id: record.id, productCount: record.masterProducts.length };
  }

  async create(input: CreateBrandInput): Promise<Brand> {
    const record = await (prisma as any).brand.create({
      data: {
        name: input.name,
        description: input.description,
        logoUrl: input.logoUrl,
        status: input.status,
        createdByUserId: input.createdByUserId,
        updatedByUserId: input.createdByUserId,
      },
      include: BRAND_INCLUDE,
    });

    return toBrand(record);
  }

  async update(id: string, input: UpdateBrandInput): Promise<Brand> {
    const record = await (prisma as any).brand.update({
      where: { id },
      data: {
        name: input.name,
        description: input.description,
        logoUrl: input.logoUrl,
        status: input.status,
        updatedByUserId: input.updatedByUserId,
      },
      include: BRAND_INCLUDE,
    });

    return toBrand(record);
  }

  async archive(id: string, updatedByUserId: string): Promise<void> {
    await (prisma as any).brand.update({
      where: { id },
      data: { status: "ARCHIVED", updatedByUserId },
    });
  }

  async delete(id: string): Promise<void> {
    await (prisma as any).brand.delete({ where: { id } });
  }

  async bulkArchiveOrDelete(ids: string[], updatedByUserId: string): Promise<BulkDeleteResult> {
    const brands = await (prisma as any).brand.findMany({
      where: { id: { in: ids } },
      include: { masterProducts: { select: { id: true } } },
    });

    const toArchive = brands.filter((b: any) => b.masterProducts.length > 0).map((b: any) => b.id);
    const toDelete = brands.filter((b: any) => b.masterProducts.length === 0).map((b: any) => b.id);

    if (toArchive.length > 0) {
      await (prisma as any).brand.updateMany({
        where: { id: { in: toArchive } },
        data: { status: "ARCHIVED", updatedByUserId },
      });
    }

    if (toDelete.length > 0) {
      await (prisma as any).brand.deleteMany({ where: { id: { in: toDelete } } });
    }

    return { archivedCount: toArchive.length, deletedCount: toDelete.length };
  }
}
