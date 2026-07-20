import { ConflictError, ValidationError } from "@domain/shared/app-error";

import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export type CreateLocalShopProductCommand = {
  shopId: string;
  ownerId: string;
  name: string | undefined;
  category: string | null | undefined;
  brand: string | null | undefined;
  unit: string | null | undefined;
  barcode: string | null | undefined;
  pictureUrl: string | null | undefined;
  salePrice: number | string | null | undefined;
  purchasePrice: number | string | null | undefined;
  openingStock: number | string | null | undefined;
  lowStockLimit: number | string | null | undefined;
};

export class CreateLocalShopProductUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(command: CreateLocalShopProductCommand) {
    const name = command.name?.trim();
    const category = command.category?.trim() || null;
    const brand = command.brand?.trim() || null;
    const unit = command.unit?.trim() || null;
    const barcode = command.barcode?.trim() || null;
    const pictureUrl = command.pictureUrl?.trim() || null;
    const salePrice = command.salePrice == null || command.salePrice === "" ? null : Number(command.salePrice);
    const purchasePrice = command.purchasePrice == null || command.purchasePrice === "" ? null : Number(command.purchasePrice);
    const openingStock = command.openingStock == null || command.openingStock === "" ? 0 : Number(command.openingStock);
    const lowStockLimit = command.lowStockLimit == null || command.lowStockLimit === "" ? 0 : Number(command.lowStockLimit);

    if (!name) {
      throw new ValidationError("Product name is required.");
    }
    if (!category) {
      throw new ValidationError("Category is required.");
    }
    if (!unit) {
      throw new ValidationError("Unit is required.");
    }
    if (!Number.isFinite(openingStock) || openingStock < 0) {
      throw new ValidationError("Opening stock must be a valid number.");
    }
    if (!Number.isFinite(lowStockLimit) || lowStockLimit < 0) {
      throw new ValidationError("Low stock limit must be a valid number.");
    }
    if (salePrice != null && (!Number.isFinite(salePrice) || salePrice < 0)) {
      throw new ValidationError("Sale price must be a valid number.");
    }
    if (purchasePrice != null && (!Number.isFinite(purchasePrice) || purchasePrice < 0)) {
      throw new ValidationError("Purchase price must be a valid number.");
    }

    if (barcode) {
      const existingLocalBarcode = await this.shopProfileRepository.findExistingLocalBarcode(command.shopId, barcode);
      if (existingLocalBarcode) {
        throw new ConflictError("Barcode already exists in this shop.");
      }
    }

    const created = await this.shopProfileRepository.createLocalShopProduct(command.shopId, command.ownerId, {
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

    return {
      product: {
        id: created.shopProduct.id,
        shopProductId: created.shopProduct.id,
        masterProductId: null,
        name,
        sku: barcode || created.shopProduct.id,
        packageSize: unit,
        pictureUrl,
        price: salePrice,
        purchasePrice,
        suggestedPrice: salePrice,
        stock: openingStock,
        lowStockLimit,
        category,
        brand,
        unit,
        barcode,
        source: "SHOP_LOCAL",
        approvalStatus: "PENDING",
      },
      approvalRequest: { id: created.request.id, status: created.request.status },
    };
  }
}
