import type { InventoryRepository } from "../ports/inventory-repository.port";

export class GetInventoryDashboardUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string) {
    const [{ mode, configured }, counts, attentionCount] = await Promise.all([
      this.inventoryRepository.getMode(shopId),
      this.inventoryRepository.getCounts(shopId),
      this.inventoryRepository.countAttentionBins(shopId),
    ]);

    return {
      mode,
      configured,
      summary: {
        zones: counts.zoneCount,
        racks: counts.rackCount,
        shelves: counts.shelfCount,
        bins: counts.binCount,
      },
      alerts: { attentionCount },
    };
  }
}
