import type { NotificationRepository } from "../ports/notification-repository.port";

export class DeleteNotificationsUseCase {
  constructor(private readonly notificationRepository: NotificationRepository) {}

  async execute(shopId: string, id: string | undefined): Promise<void> {
    if (id) {
      await this.notificationRepository.deleteById(id);
      return;
    }
    await this.notificationRepository.deleteAllForShop(shopId);
  }
}
