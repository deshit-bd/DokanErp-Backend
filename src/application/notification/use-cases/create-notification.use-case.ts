import type { NotificationRepository } from "../ports/notification-repository.port";
import type { RealtimeNotifier } from "../ports/realtime-notifier.port";

// Deliberately never throws (matches the original createNotification helper
// exactly): it's a fire-and-forget side effect called from many business
// flows (sales, low-stock, dead-stock, dummy-data generators) that must never
// fail the caller's own transaction/response just because a notification
// couldn't be recorded or broadcast.
export class CreateNotificationUseCase {
  constructor(
    private readonly notificationRepository: NotificationRepository,
    private readonly realtimeNotifier: RealtimeNotifier,
  ) {}

  async execute(shopId: string, type: string, title: string, message: string): Promise<void> {
    try {
      const notification = await this.notificationRepository.create(shopId, type, title, message);
      this.realtimeNotifier.broadcastToShop(shopId, "new-notification", notification);
    } catch (error) {
      console.error("Failed to create in-app notification:", error);
    }
  }
}
