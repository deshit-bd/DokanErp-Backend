import type { InAppNotification } from "@domain/notification/notification.entity";

import type { NotificationRepository } from "../ports/notification-repository.port";
import type { CheckDeadStockUseCase } from "./check-dead-stock.use-case";

export class ListNotificationsUseCase {
  constructor(
    private readonly notificationRepository: NotificationRepository,
    private readonly checkDeadStockUseCase: CheckDeadStockUseCase,
  ) {}

  async execute(shopId: string): Promise<InAppNotification[]> {
    await this.checkDeadStockUseCase.execute(shopId);
    return this.notificationRepository.findManyByShop(shopId, 100);
  }
}
