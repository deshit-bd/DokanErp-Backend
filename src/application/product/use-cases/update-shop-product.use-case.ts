import { normalizeMoney, toUpdatedShopProductResponse } from "@domain/product/product.entity";
import { ManualStockDeductionDisabledError, ProductNotFoundError } from "@domain/product/product.errors";

import type { ProductRepository } from "../ports/product-repository.port";

export type UpdateShopProductCommand = {
  shopId: string;
  updatedByUserId: string;
  identifier: string;
  body: {
    name?: string;
    category?: string | null;
    brand?: string | null;
    unit?: string | null;
    image_url?: string | null;
    sale_price?: number | string | null;
    purchase_price?: number | string | null;
    stock?: number | string | null;
    low_stock_threshold?: number | string | null;
  };
};

export class UpdateShopProductUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(command: UpdateShopProductCommand) {
    const { body, shopId, identifier } = command;

    const shopProduct = await this.productRepository.findShopProductByIdentifier(shopId, identifier);

    if (!shopProduct) {
      throw new ProductNotFoundError();
    }

    const updateData: Record<string, unknown> = {};
    if (body.stock !== undefined) {
      updateData.openingStock = body.stock == null || body.stock === "" ? 0 : Number(body.stock);
    }
    if (body.sale_price !== undefined) {
      updateData.salePrice = body.sale_price == null || body.sale_price === "" ? null : Number(body.sale_price);
    }
    if (body.purchase_price !== undefined) {
      updateData.purchasePrice = body.purchase_price == null || body.purchase_price === "" ? null : Number(body.purchase_price);
    }
    if (body.low_stock_threshold !== undefined) {
      updateData.lowStockLimit = body.low_stock_threshold == null || body.low_stock_threshold === "" ? 0 : Number(body.low_stock_threshold);
    }

    if (shopProduct.source === "SHOP_LOCAL") {
      if (body.name !== undefined) updateData.localName = body.name?.trim();
      if (body.category !== undefined) updateData.localCategory = body.category?.trim() || null;
      if (body.brand !== undefined) updateData.localBrand = body.brand?.trim() || null;
      if (body.unit !== undefined) updateData.localUnit = body.unit?.trim() || null;
      if (body.image_url !== undefined) updateData.localPictureUrl = body.image_url?.trim() || null;
    }

    const updated = await this.productRepository.updateShopProduct(shopProduct.id, updateData);

    const previousStock = Number(shopProduct.openingStock ?? 0);
    const nextStock = Number(updated.openingStock ?? 0);
    const previousPurchasePrice = normalizeMoney(shopProduct.purchasePrice ?? shopProduct.masterProduct?.price ?? null);
    const previousSalePrice = normalizeMoney(shopProduct.salePrice ?? shopProduct.masterProduct?.suggestedPrice ?? shopProduct.masterProduct?.price ?? null);
    const nextPurchasePrice = normalizeMoney(updated.purchasePrice ?? updated.masterProduct?.price ?? null);
    const nextSalePrice = normalizeMoney(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price ?? null);

    if (nextStock < previousStock) {
      throw new ManualStockDeductionDisabledError();
    }

    if (previousStock !== nextStock) {
      const delta = Number((nextStock - previousStock).toFixed(3));
      await this.productRepository.recordStockMovementForProductUpdate({
        shopId,
        shopProductId: updated.id,
        masterProductId: updated.masterProductId,
        movementType: delta >= 0 ? "MANUAL_ADD" : "MANUAL_REDUCE",
        quantityDelta: delta,
        stockBefore: previousStock,
        stockAfter: nextStock,
        purchasePrice: nextPurchasePrice,
        salePrice: nextSalePrice,
        note: delta >= 0 ? "Manual stock increase." : "Manual stock reduction.",
        createdByUserId: command.updatedByUserId,
      });
    }

    if (previousPurchasePrice !== nextPurchasePrice || previousSalePrice !== nextSalePrice) {
      await this.productRepository.recordStockMovementForProductUpdate({
        shopId,
        shopProductId: updated.id,
        masterProductId: updated.masterProductId,
        movementType: "PRICE_CHANGE",
        quantityDelta: 0,
        stockBefore: nextStock,
        stockAfter: nextStock,
        purchasePrice: nextPurchasePrice,
        salePrice: nextSalePrice,
        note: "Product price updated.",
        metadata: { previousPurchasePrice, previousSalePrice, nextPurchasePrice, nextSalePrice },
        createdByUserId: command.updatedByUserId,
      });
    }

    return toUpdatedShopProductResponse(updated);
  }
}
