import type { NotificationRepository } from "../ports/notification-repository.port";

export class MarkNotificationReadUseCase {
  constructor(private readonly notificationRepository: NotificationRepository) {}

  async execute(shopId: string, id: string | undefined): Promise<void> {
    if (id) {
      await this.notificationRepository.markAsRead(id);
      return;
    }
    await this.notificationRepository.markAllAsReadForShop(shopId);
  }
}
