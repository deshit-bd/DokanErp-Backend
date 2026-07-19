import { formatBanglaTimestamp, type InAppNotification } from "@domain/notification/notification.entity";
import { ValidationError } from "@domain/shared/app-error";

import type { NotificationRepository } from "../ports/notification-repository.port";
import type { RealtimeNotifier } from "../ports/realtime-notifier.port";

export class CreateInAppNotificationUseCase {
  constructor(
    private readonly notificationRepository: NotificationRepository,
    private readonly realtimeNotifier: RealtimeNotifier,
  ) {}

  async execute(shopId: string, type: string | undefined, title: string | undefined, message: string | undefined, timestamp: string | undefined): Promise<InAppNotification> {
    if (!type || !title || !message) {
      throw new ValidationError("Type, title and message are required.");
    }

    const notification = await this.notificationRepository.create(shopId, type, title, message, timestamp || formatBanglaTimestamp());
    this.realtimeNotifier.broadcastToShop(shopId, "new-notification", notification);
    return notification;
  }
}
