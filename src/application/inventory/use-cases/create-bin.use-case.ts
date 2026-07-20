import { normalizeBinStatus } from "@domain/inventory/inventory.entity";
import { BinFieldsRequiredError, ShelfNotFoundForLocationError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class CreateBinUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(
    shopId: string,
    body: {
      zoneId?: string;
      rackId?: string;
      shelfId?: string;
      code?: string;
      productName?: string;
      status?: string;
      quantityLabel?: string;
      daysLabel?: string;
    },
  ) {
    const zoneId = body.zoneId?.trim();
    const rackId = body.rackId?.trim();
    const shelfId = body.shelfId?.trim();
    const code = body.code?.trim();

    if (!zoneId || !rackId || !shelfId || !code) {
      throw new BinFieldsRequiredError();
    }

    const shelf = await this.inventoryRepository.findShelfById(shopId, shelfId);
    if (!shelf || shelf.rackId !== rackId || shelf.zoneId !== zoneId) {
      throw new ShelfNotFoundForLocationError();
    }

    return this.inventoryRepository.createBin({
      shopId,
      zoneId,
      rackId,
      shelfId,
      code,
      productName: body.productName?.trim() || null,
      status: normalizeBinStatus(body.status),
      quantityLabel: body.quantityLabel?.trim() || "খালি",
      daysLabel: body.daysLabel?.trim() || "খালি",
    });
  }
}
