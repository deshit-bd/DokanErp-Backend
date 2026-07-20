import {
  buildDuplicateSku,
  buildGeneratedSku,
  selectPrimaryBarcode,
  toBarcodeStatusFromProductStatus,
  type MasterProductStatusValue,
} from "@domain/product/product.entity";
import type { ProductRepository } from "@application/product/ports/product-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";
import { recordStockMovement } from "../../../utils/stock-movement";

const productInclude = {
  category: { select: { id: true, name: true } },
  brand: { select: { id: true, name: true, logoUrl: true } },
  unit: { select: { id: true, name: true, shortName: true } },
  barcodes: {
    orderBy: [{ updatedAt: "desc" as const }, { createdAt: "desc" as const }],
    select: { id: true, barcode: true, packSize: true, status: true, createdAt: true, updatedAt: true },
  },
};

const shopProductMasterInclude = {
  category: { select: { id: true, name: true } },
  brand: { select: { id: true, name: true, logoUrl: true } },
  unit: { select: { id: true, name: true, shortName: true } },
  barcodes: {
    orderBy: [{ updatedAt: "desc" as const }, { createdAt: "desc" as const }],
    select: { id: true, barcode: true, packSize: true, status: true },
  },
};

export class PrismaProductRepository implements ProductRepository {
  async listMasterProducts() {
    return (prisma as any).masterProduct.findMany({ orderBy: [{ createdAt: "desc" }, { name: "asc" }], include: productInclude });
  }

  async buildProductFilters() {
    const [categories, brands, units] = await Promise.all([
      (prisma as any).productCategory.findMany({ where: { status: { not: "ARCHIVED" } }, orderBy: { name: "asc" }, select: { id: true, name: true } }),
      (prisma as any).brand.findMany({ where: { status: { not: "ARCHIVED" } }, orderBy: { name: "asc" }, select: { id: true, name: true, logoUrl: true } }),
      (prisma as any).unit.findMany({ where: { status: { not: "ARCHIVED" } }, orderBy: { name: "asc" }, select: { id: true, name: true, shortName: true } }),
    ]);

    return { categories, brands, units };
  }

  async findMasterProductBySku(sku: string, excludeId?: string) {
    if (excludeId) {
      return (prisma as any).masterProduct.findFirst({ where: { sku, NOT: { id: excludeId } }, select: { id: true } });
    }
    return (prisma as any).masterProduct.findUnique({ where: { sku }, select: { id: true } });
  }

  async findBarcodeRecord(barcode: string, excludeMasterProductId?: string) {
    if (excludeMasterProductId) {
      return (prisma as any).masterProductBarcode.findFirst({ where: { barcode, NOT: { masterProductId: excludeMasterProductId } }, select: { id: true } });
    }
    return (prisma as any).masterProductBarcode.findUnique({ where: { barcode }, select: { id: true } });
  }

  async createMasterProduct(data: Record<string, unknown>) {
    return (prisma as any).masterProduct.create({ data, select: { id: true } });
  }

  async updateMasterProduct(id: string, data: Record<string, unknown>) {
    await (prisma as any).masterProduct.update({ where: { id }, data });
  }

  async findMasterProductById(id: string) {
    return (prisma as any).masterProduct.findUnique({ where: { id }, select: { id: true, status: true } });
  }

  async loadProductById(id: string) {
    return (prisma as any).masterProduct.findUnique({ where: { id }, include: productInclude });
  }

  async syncProductBarcodeRecord(params: { barcode: string | null; packageSize: string | null; productId: string; productStatus: MasterProductStatusValue; userId: string }) {
    const existingBarcode = await (prisma as any).masterProductBarcode.findFirst({
      where: { masterProductId: params.productId },
      orderBy: [{ updatedAt: "desc" }, { createdAt: "desc" }],
      select: { id: true, barcode: true },
    });

    if (!params.barcode) {
      await (prisma as any).masterProductBarcode.deleteMany({ where: { masterProductId: params.productId } });
      return;
    }

    if (existingBarcode) {
      await (prisma as any).masterProductBarcode.update({
        where: { id: existingBarcode.id },
        data: {
          barcode: params.barcode,
          packSize: params.packageSize,
          status: toBarcodeStatusFromProductStatus(params.productStatus),
          updatedByUserId: params.userId,
        },
      });
      return;
    }

    await (prisma as any).masterProductBarcode.create({
      data: {
        masterProductId: params.productId,
        barcode: params.barcode,
        packSize: params.packageSize,
        status: toBarcodeStatusFromProductStatus(params.productStatus),
        createdByUserId: params.userId,
        updatedByUserId: params.userId,
      },
    });
  }

  async duplicateMasterProduct(sourceProduct: any, userId: string) {
    return (prisma as any).masterProduct.create({
      data: {
        sku: buildDuplicateSku(sourceProduct.sku),
        name: `${sourceProduct.name} Copy`,
        description: sourceProduct.description,
        categoryId: sourceProduct.category?.id ?? null,
        brandId: sourceProduct.brand?.id ?? null,
        unitId: sourceProduct.unit?.id ?? null,
        price: sourceProduct.price,
        suggestedPrice: sourceProduct.suggestedPrice,
        packageSize: selectPrimaryBarcode(sourceProduct.barcodes)?.packSize ?? sourceProduct.packageSize,
        pictureUrl: sourceProduct.pictureUrl,
        status: sourceProduct.status,
        createdByUserId: userId,
        updatedByUserId: userId,
      },
      include: productInclude,
    });
  }

  async updateMasterProductStatus(id: string, status: MasterProductStatusValue, userId: string) {
    const product = await (prisma as any).masterProduct.update({
      where: { id },
      data: { status, updatedByUserId: userId },
      include: productInclude,
    });

    await (prisma as any).masterProductBarcode.updateMany({
      where: { masterProductId: id },
      data: { status: toBarcodeStatusFromProductStatus(status), updatedByUserId: userId },
    });

    return product;
  }

  async deleteMasterProduct(id: string) {
    await (prisma as any).masterProductBarcode.deleteMany({ where: { masterProductId: id } });
    await (prisma as any).masterProduct.delete({ where: { id } });
  }

  async countDistinctShopProducts(shopId: string) {
    const { countDistinctShopProducts } = await import("../../../subscription/access");
    return countDistinctShopProducts(shopId);
  }

  async evaluateShopSubscriptionAccess(shopId: string) {
    const { evaluateShopSubscriptionAccess } = await import("../../../subscription/access");
    return evaluateShopSubscriptionAccess(shopId);
  }

  async findShopInventoryStockMethod(shopId: string) {
    const setting = await (prisma as any).shopInventorySetting.findUnique({ where: { shopId }, select: { stockMethod: true } });
    return setting?.stockMethod;
  }

  async findShopProductsWithFilters(shopId: string, filters: { page: number; perPage: number; search: string; category: string }) {
    const whereClause: any = { shopId };

    if (filters.category && filters.category !== "সব" && filters.category !== "Uncategorized") {
      whereClause.OR = [
        { localCategory: { contains: filters.category, mode: "insensitive" } },
        { masterProduct: { category: { name: { contains: filters.category, mode: "insensitive" } } } },
      ];
    }
    if (filters.search) {
      whereClause.AND = [
        ...(whereClause.AND || []),
        {
          OR: [
            { localName: { contains: filters.search, mode: "insensitive" } },
            { localBarcode: { contains: filters.search, mode: "insensitive" } },
            { masterProduct: { name: { contains: filters.search, mode: "insensitive" } } },
            { masterProduct: { sku: { contains: filters.search, mode: "insensitive" } } },
            { masterProduct: { barcodes: { some: { barcode: { contains: filters.search, mode: "insensitive" } } } } },
          ],
        },
      ];
    }

    return (prisma as any).shopProduct.findMany({
      where: whereClause,
      include: {
        masterProduct: { include: shopProductMasterInclude },
        approvalRequest: { select: { id: true, status: true } },
      },
      orderBy: { createdAt: "desc" },
      skip: (filters.page - 1) * filters.perPage,
      take: filters.perPage,
    });
  }

  async findInventoryBinItemsForProducts(shopId: string, masterProductIds: string[]) {
    if (masterProductIds.length === 0) return [];

    return (prisma as any).inventoryBinItem.findMany({
      where: { shopId, masterProductId: { in: masterProductIds }, quantity: { gt: 0 } },
      orderBy: [{ createdAt: "asc" }, { id: "asc" }],
      select: { id: true, masterProductId: true, purchaseItemId: true, quantity: true, purchasePrice: true, salePrice: true, batchNo: true, expiryDate: true, createdAt: true },
    });
  }

  async findShopLocalBarcodeConflict(shopId: string, barcode: string) {
    return (prisma as any).shopProduct.findFirst({
      where: { shopId, OR: [{ localBarcode: barcode }, { masterProduct: { barcodes: { some: { barcode } } } }] },
      select: { id: true },
    });
  }

  async createShopLocalProductRequest(params: {
    shopId: string;
    createdByUserId: string;
    name: string;
    category: string;
    brand: string | null;
    unit: string;
    barcode: string | null;
    pictureUrl: string | null;
    purchasePrice: number | null;
    salePrice: number | null;
    openingStock: number;
    lowStockLimit: number;
  }) {
    return (prisma as any).$transaction(async (tx: any) => {
      const requestRow = await tx.masterProductRequest.create({
        data: {
          shopId: params.shopId,
          createdByUserId: params.createdByUserId,
          name: params.name,
          category: params.category,
          brand: params.brand,
          unit: params.unit,
          barcode: params.barcode,
          pictureUrl: params.pictureUrl,
          purchasePrice: params.purchasePrice,
          salePrice: params.salePrice,
          openingStock: params.openingStock,
          lowStockLimit: params.lowStockLimit,
          status: "PENDING",
        },
      });

      const shopProduct = await tx.shopProduct.create({
        data: {
          shopId: params.shopId,
          source: "SHOP_LOCAL",
          localName: params.name,
          localCategory: params.category,
          localBrand: params.brand,
          localUnit: params.unit,
          localBarcode: params.barcode,
          localPictureUrl: params.pictureUrl,
          openingStock: params.openingStock,
          lowStockLimit: params.lowStockLimit,
          salePrice: params.salePrice,
          purchasePrice: params.purchasePrice,
          approvalRequestId: requestRow.id,
        },
      });

      await tx.masterProductRequest.update({ where: { id: requestRow.id }, data: { shopProductId: shopProduct.id } });

      return shopProduct;
    });
  }

  async findShopProductByIdentifier(shopId: string, identifier: string) {
    return (prisma as any).shopProduct.findFirst({
      where: {
        shopId,
        OR: [{ id: identifier }, { localBarcode: identifier }, { masterProduct: { barcodes: { some: { barcode: identifier } } } }, { masterProduct: { sku: identifier } }],
      },
      include: { masterProduct: true },
    });
  }

  async updateShopProduct(id: string, data: Record<string, unknown>) {
    return (prisma as any).shopProduct.update({
      where: { id },
      data,
      include: {
        masterProduct: { include: shopProductMasterInclude },
        approvalRequest: { select: { id: true, status: true } },
      },
    });
  }

  async deleteShopProduct(id: string) {
    await (prisma as any).shopProduct.delete({ where: { id } });
  }

  async recordStockMovementForProductUpdate(params: {
    shopId: string;
    shopProductId: string;
    masterProductId: string | null;
    movementType: "MANUAL_ADD" | "MANUAL_REDUCE" | "PRICE_CHANGE";
    quantityDelta: number;
    stockBefore: number;
    stockAfter: number;
    purchasePrice: number | null;
    salePrice: number | null;
    note: string;
    metadata?: Record<string, unknown> | null;
    createdByUserId: string;
  }) {
    await recordStockMovement(prisma, {
      shopId: params.shopId,
      shopProductId: params.shopProductId,
      masterProductId: params.masterProductId,
      movementType: params.movementType,
      quantityDelta: params.quantityDelta,
      stockBefore: params.stockBefore,
      stockAfter: params.stockAfter,
      purchasePrice: params.purchasePrice,
      salePrice: params.salePrice,
      referenceType: "PRODUCT_UPDATE",
      referenceId: params.shopProductId,
      note: params.note,
      metadata: params.metadata ?? undefined,
      createdByUserId: params.createdByUserId,
    });
  }

  async listApprovalRequests(status: string) {
    return (prisma as any).masterProductRequest.findMany({
      where: status && ["PENDING", "APPROVED", "REJECTED"].includes(status) ? { status } : {},
      include: { shop: { select: { id: true, shopName: true, shopCode: true } } },
      orderBy: [{ createdAt: "desc" }],
    });
  }

  async findApprovalRequestById(id: string) {
    return (prisma as any).masterProductRequest.findUnique({ where: { id } });
  }

  async approveApprovalRequest(approvalRequest: any, userId: string) {
    return (prisma as any).$transaction(async (tx: any) => {
      const sku = buildGeneratedSku(approvalRequest.name);
      const createdProduct = await tx.masterProduct.create({
        data: {
          sku,
          name: approvalRequest.name,
          packageSize: approvalRequest.unit,
          description: approvalRequest.category,
          pictureUrl: approvalRequest.pictureUrl,
          price: approvalRequest.purchasePrice,
          suggestedPrice: approvalRequest.salePrice,
          status: "ACTIVE",
          createdByUserId: userId,
          updatedByUserId: userId,
        },
        select: { id: true },
      });

      // A freshly created master product never has an existing barcode row,
      // so this always takes the "create" path of syncProductBarcodeRecord's
      // logic (or the no-op delete path if approvalRequest.barcode is falsy).
      if (approvalRequest.barcode) {
        await tx.masterProductBarcode.create({
          data: {
            masterProductId: createdProduct.id,
            barcode: approvalRequest.barcode,
            packSize: approvalRequest.unit,
            status: "MAPPED",
            createdByUserId: userId,
            updatedByUserId: userId,
          },
        });
      }

      await tx.masterProductRequest.update({
        where: { id: approvalRequest.id },
        data: { status: "APPROVED", reviewedByUserId: userId, masterProductId: createdProduct.id, rejectionReason: null },
      });

      if (approvalRequest.shopProductId) {
        await tx.shopProduct.update({ where: { id: approvalRequest.shopProductId }, data: { masterProductId: createdProduct.id, source: "MASTER" } });
      }

      return tx.masterProduct.findUnique({ where: { id: createdProduct.id }, include: productInclude });
    });
  }

  async rejectApprovalRequest(id: string, userId: string, reason: string | null) {
    return (prisma as any).masterProductRequest.update({
      where: { id },
      data: { status: "REJECTED", reviewedByUserId: userId, rejectionReason: reason },
    });
  }
}
