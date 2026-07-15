import { selectPrimaryBarcode, type ProductTemplate } from "@domain/product-template/product-template.entity";
import type { ProductTemplateInput, ProductTemplateRepository } from "@application/product-template/ports/product-template-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

const TEMPLATE_INCLUDE = {
  products: {
    orderBy: [{ masterProduct: { name: "asc" } }],
    include: {
      masterProduct: {
        include: {
          category: { select: { id: true, name: true } },
          brand: { select: { id: true, name: true } },
          unit: { select: { id: true, name: true, shortName: true } },
          barcodes: {
            orderBy: [{ updatedAt: "desc" }, { createdAt: "desc" }],
            select: { barcode: true, status: true },
          },
        },
      },
    },
  },
} as const;

function toProductTemplate(record: any): ProductTemplate {
  return {
    id: record.id,
    code: record.code,
    name: record.name,
    description: record.description,
    status: record.status,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
    products: record.products.map((item: any) => {
      const primaryBarcode = selectPrimaryBarcode(item.masterProduct.barcodes ?? []);
      return {
        id: item.id,
        masterProductId: item.masterProductId,
        name: item.masterProduct.name,
        sku: item.masterProduct.sku,
        barcode: primaryBarcode?.barcode ?? null,
        pictureUrl: item.masterProduct.pictureUrl,
        category: item.masterProduct.category?.name ?? "Uncategorized",
        brand: item.masterProduct.brand?.name ?? "No Brand",
        unit: item.masterProduct.unit?.shortName?.toUpperCase() ?? item.masterProduct.unit?.name ?? "No Unit",
      };
    }),
  };
}

export class PrismaProductTemplateRepository implements ProductTemplateRepository {
  async findMany(): Promise<ProductTemplate[]> {
    const records = await (prisma as any).productTemplate.findMany({
      orderBy: [{ createdAt: "desc" }, { name: "asc" }],
      include: TEMPLATE_INCLUDE,
    });
    return records.map(toProductTemplate);
  }

  async findById(id: string): Promise<ProductTemplate | null> {
    const record = await (prisma as any).productTemplate.findUnique({ where: { id }, include: TEMPLATE_INCLUDE });
    return record ? toProductTemplate(record) : null;
  }

  async findRawById(id: string) {
    return (prisma as any).productTemplate.findUnique({ where: { id }, select: { id: true } });
  }

  async findDuplicate(code: string, name: string, excludeId?: string) {
    return (prisma as any).productTemplate.findFirst({
      where: { ...(excludeId ? { id: { not: excludeId } } : {}), OR: [{ code }, { name }] },
      select: { id: true, code: true, name: true },
    });
  }

  async create(input: ProductTemplateInput): Promise<ProductTemplate> {
    const record = await (prisma as any).productTemplate.create({ data: input, include: TEMPLATE_INCLUDE });
    return toProductTemplate(record);
  }

  async update(id: string, input: ProductTemplateInput): Promise<ProductTemplate> {
    const record = await (prisma as any).productTemplate.update({ where: { id }, data: input, include: TEMPLATE_INCLUDE });
    return toProductTemplate(record);
  }

  async delete(id: string): Promise<void> {
    await (prisma as any).productTemplate.delete({ where: { id } });
  }

  async countExistingMasterProducts(ids: string[]): Promise<number> {
    return (prisma as any).masterProduct.count({ where: { id: { in: ids } } });
  }

  async replaceProducts(templateId: string, masterProductIds: string[]): Promise<ProductTemplate> {
    await (prisma as any).$transaction([
      (prisma as any).productTemplateItem.deleteMany({ where: { templateId } }),
      ...(masterProductIds.length
        ? [(prisma as any).productTemplateItem.createMany({ data: masterProductIds.map((masterProductId) => ({ templateId, masterProductId })) })]
        : []),
    ]);

    const updated = await this.findById(templateId);
    return updated!;
  }

  async removeProduct(templateId: string, masterProductId: string): Promise<ProductTemplate | null> {
    await (prisma as any).productTemplateItem.deleteMany({ where: { templateId, masterProductId } });
    return this.findById(templateId);
  }
}
