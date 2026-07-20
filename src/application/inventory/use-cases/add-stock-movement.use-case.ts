import {
  InsufficientStockError,
  InvalidStockAdjustmentQuantityError,
  InvalidStockAdjustmentTypeError,
  ProductIdRequiredError,
  ProductNotFoundInShopError,
} from "@domain/inventory/inventory.errors";
import { normalizeMoney, normalizeStockAdjustmentAction } from "@domain/inventory/inventory.entity";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export type AddStockMovementCommand = {
  shopId: string;
  createdByUserId: string;
  productId: unknown;
  quantity: unknown;
  type: unknown;
  reference: unknown;
  note: unknown;
  purchasePrice: unknown;
};

export class AddStockMovementUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(command: AddStockMovementCommand) {
    const productId = typeof command.productId === "string" ? command.productId.trim() : "";
    const action = normalizeStockAdjustmentAction(command.type);
    const quantity = Number(command.quantity ?? 0);
    const purchasePrice =
      command.purchasePrice == null || command.purchasePrice === "" ? null : normalizeMoney(command.purchasePrice);

    if (!productId) {
      throw new ProductIdRequiredError();
    }

    if (!action) {
      throw new InvalidStockAdjustmentTypeError();
    }

    if (!Number.isFinite(quantity) || quantity <= 0) {
      throw new InvalidStockAdjustmentQuantityError();
    }

    const shopProduct = await this.inventoryRepository.resolveShopProductByIdentifier(command.shopId, productId);
    if (!shopProduct) {
      throw new ProductNotFoundInShopError();
    }

    const stockBefore = Number(shopProduct.openingStock ?? 0);
    if (action === "DAMAGE" && stockBefore < quantity) {
      throw new InsufficientStockError();
    }

    const { updated, movement } = await this.inventoryRepository.addStockMovement({
      shopId: command.shopId,
      productId,
      action,
      quantity,
      purchasePrice,
      reference: typeof command.reference === "string" ? command.reference.trim() || null : null,
      note: typeof command.note === "string" ? command.note.trim() || null : null,
      createdByUserId: command.createdByUserId,
    });

    return { action, updated, movement };
  }
}
