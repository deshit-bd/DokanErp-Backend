import { buildDeadStockNotification, identifyDeadStockProductNames } from "@domain/notification/dead-stock.entity";

import type { NotificationRepository } from "../ports/notification-repository.port";
import type { CreateNotificationUseCase } from "./create-notification.use-case";

const DEAD_STOCK_LOOKBACK_MS = 10 * 24 * 60 * 60 * 1000;
const DEAD_STOCK_COOLDOWN_MS = 24 * 60 * 60 * 1000;

// Also never throws — called as a side effect of listing notifications (see
// notification.controller.ts), matching the original route's try/catch that
// only logs on failure.
export class CheckDeadStockUseCase {
  constructor(
    private readonly notificationRepository: NotificationRepository,
    private readonly createNotificationUseCase: CreateNotificationUseCase,
  ) {}

  async execute(shopId: string): Promise<void> {
    try {
      const alreadyNotified = await this.notificationRepository.hasRecentNotificationOfType(
        shopId,
        "DEAD_STOCK",
        new Date(Date.now() - DEAD_STOCK_COOLDOWN_MS),
      );

      if (alreadyNotified) {
        return;
      }

      const cutoff = new Date(Date.now() - DEAD_STOCK_LOOKBACK_MS);
      const staleProducts = await this.notificationRepository.findStaleProductsWithStock(shopId, cutoff);

      if (staleProducts.length === 0) {
        return;
      }

      const soldMasterProductIds = await this.notificationRepository.findSoldMasterProductIds(shopId, cutoff);
      const deadProductNames = identifyDeadStockProductNames(staleProducts, soldMasterProductIds);

      if (deadProductNames.length === 0) {
        return;
      }

      const { title, message } = buildDeadStockNotification(deadProductNames);
      await this.createNotificationUseCase.execute(shopId, "DEAD_STOCK", title, message);
    } catch (error) {
      console.error("Failed to run checkDeadStock:", error);
    }
  }
}
