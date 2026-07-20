import { deriveBinStatusFromQuantity } from "@domain/inventory/inventory.entity";
import { BinNotFoundError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class UpdateBinUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, id: string, body: { code?: string; quantity?: number }) {
    const bin = await this.inventoryRepository.findBinById(shopId, id);
    if (!bin) {
      throw new BinNotFoundError();
    }

    const newCode = body.code !== undefined ? body.code.trim() : bin.code;
    let nextStatus = bin.status;
    let quantityLabel = bin.quantityLabel;

    if (body.quantity !== undefined) {
      nextStatus = deriveBinStatusFromQuantity(body.quantity);
      quantityLabel = `${body.quantity} পিস`;
    }

    return this.inventoryRepository.updateBin(id, {
      code: newCode,
      status: nextStatus,
      quantityLabel,
      daysLabel: body.quantity !== undefined && body.quantity > 0 ? "মেয়াদ সেট" : "খালি",
    });
  }
}
