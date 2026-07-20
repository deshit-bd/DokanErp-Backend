import { buildNotificationSettingsForCreate, mergeNotificationSettingsUpdate, type NotificationSettings } from "@domain/notification/notification.entity";

import type { NotificationRepository } from "../ports/notification-repository.port";

export class UpdateNotificationSettingsUseCase {
  constructor(private readonly notificationRepository: NotificationRepository) {}

  async execute(shopId: string, input: Partial<Record<keyof NotificationSettings, unknown>>): Promise<NotificationSettings> {
    return this.notificationRepository.upsertSettings(
      shopId,
      mergeNotificationSettingsUpdate(input),
      buildNotificationSettingsForCreate(input),
    );
  }
}
