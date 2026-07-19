import { toCreatedShopProductResponse } from "@domain/product/product.entity";
import { DuplicateShopBarcodeError, FreeTierProductLimitError, InvalidLowStockLimitError, InvalidStockError, ProductNameRequiredError } from "@domain/product/product.errors";

import type { ProductRepository } from "../ports/product-repository.port";

export type CreateShopProductRequestCommand = {
  shopId: string;
  createdByUserId: string;
  body: {
    name?: string;
    barcode?: string | null;
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

export class CreateShopProductRequestUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(command: CreateShopProductRequestCommand) {
    const { body, shopId, createdByUserId } = command;

    const name = body.name?.trim();
    const category = body.category?.trim() || "Uncategorized";
    const brand = body.brand?.trim() || null;
    const unit = body.unit?.trim() || "pcs";
    const barcode = body.barcode?.trim() || null;
    const pictureUrl = body.image_url?.trim() || null;
    const salePrice = body.sale_price == null || body.sale_price === "" ? null : Number(body.sale_price);
    const purchasePrice = body.purchase_price == null || body.purchase_price === "" ? null : Number(body.purchase_price);
    const openingStock = body.stock == null || body.stock === "" ? 0 : Number(body.stock);
    const lowStockLimit = body.low_stock_threshold == null || body.low_stock_threshold === "" ? 0 : Number(body.low_stock_threshold);

    if (!name) throw new ProductNameRequiredError();
    if (!Number.isFinite(openingStock) || openingStock < 0) throw new InvalidStockError();
    if (!Number.isFinite(lowStockLimit) || lowStockLimit < 0) throw new InvalidLowStockLimitError();

    const existingLocalBarcode = barcode ? await this.productRepository.findShopLocalBarcodeConflict(shopId, barcode) : null;

    if (existingLocalBarcode) {
      throw new DuplicateShopBarcodeError();
    }

    const currentProductCount = await this.productRepository.countDistinctShopProducts(shopId);
    const access = await this.productRepository.evaluateShopSubscriptionAccess(shopId);

    if (access.tier === "TRIAL" && currentProductCount >= 50) {
      throw new FreeTierProductLimitError({ subscription: access });
    }

    const created = await this.productRepository.createShopLocalProductRequest({
      shopId,
      createdByUserId,
      name,
      category,
      brand,
      unit,
      barcode,
      pictureUrl,
      purchasePrice,
      salePrice,
      openingStock,
      lowStockLimit,
    });

    return toCreatedShopProductResponse(created);
  }
}
