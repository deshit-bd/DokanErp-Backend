import { DEFAULT_NOTIFICATION_SETTINGS, type NotificationSettings } from "@domain/notification/notification.entity";

import type { NotificationRepository } from "../ports/notification-repository.port";

export class GetNotificationSettingsUseCase {
  constructor(private readonly notificationRepository: NotificationRepository) {}

  async execute(shopId: string): Promise<NotificationSettings> {
    const existing = await this.notificationRepository.findSettingsByShopId(shopId);

    if (existing) {
      return existing;
    }

    return this.notificationRepository.createSettings(shopId, DEFAULT_NOTIFICATION_SETTINGS);
  }
}
