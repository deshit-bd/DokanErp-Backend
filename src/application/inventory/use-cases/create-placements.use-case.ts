import { PlacementItemInvalidError, PlacementItemsRequiredError } from "@domain/inventory/inventory.errors";

import type { CreatePlacementItem, InventoryRepository } from "../ports/inventory-repository.port";

export type CreatePlacementsBodyItem = {
  purchaseItemId?: string;
  masterProductId?: string;
  quantity?: number | string;
  salePrice?: number | string | null;
  zoneId?: string;
  rackId?: string;
  shelfId?: string;
  binId?: string;
  batchNo?: string | null;
  expiryDate?: string | null;
  productName?: string | null;
};

export class CreatePlacementsUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, rawItems: CreatePlacementsBodyItem[] | undefined) {
    const items = Array.isArray(rawItems) ? rawItems : [];

    if (items.length === 0) {
      throw new PlacementItemsRequiredError();
    }

    const normalizedItems: CreatePlacementItem[] = items.map((item) => ({
      purchaseItemId: item.purchaseItemId?.trim() || null,
      masterProductId: item.masterProductId?.trim() || "",
      quantity: Number(item.quantity ?? 0),
      salePrice: item.salePrice == null || item.salePrice === "" ? null : Number(item.salePrice),
      zoneId: item.zoneId?.trim() || "",
      rackId: item.rackId?.trim() || "",
      shelfId: item.shelfId?.trim() || "",
      binId: item.binId?.trim() || "",
      batchNo: item.batchNo?.trim() || null,
      expiryDate: item.expiryDate ? new Date(item.expiryDate) : null,
      productName: item.productName?.trim() || null,
    }));

    const hasInvalidItem = normalizedItems.some(
      (item) =>
        !item.masterProductId ||
        !item.zoneId ||
        !item.rackId ||
        !item.shelfId ||
        !item.binId ||
        !Number.isFinite(item.quantity) ||
        item.quantity <= 0,
    );

    if (hasInvalidItem) {
      throw new PlacementItemInvalidError();
    }

    return this.inventoryRepository.createPlacements(shopId, normalizedItems);
  }
}
