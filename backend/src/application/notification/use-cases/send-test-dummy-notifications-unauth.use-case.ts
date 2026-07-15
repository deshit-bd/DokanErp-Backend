import type { NotificationRepository } from "../ports/notification-repository.port";
import type { CreateNotificationUseCase } from "./create-notification.use-case";
import { SendTestDummyNotificationsUseCase } from "./send-test-dummy-notifications.use-case";

export class SendTestDummyNotificationsUnauthUseCase {
  private readonly sendTestDummyNotificationsUseCase: SendTestDummyNotificationsUseCase;

  constructor(
    private readonly notificationRepository: NotificationRepository,
    private readonly createNotificationUseCase: CreateNotificationUseCase,
  ) {
    this.sendTestDummyNotificationsUseCase = new SendTestDummyNotificationsUseCase(createNotificationUseCase);
  }

  async execute(custom: { title?: string; message?: string; category?: string }): Promise<number> {
    const shopIds = await this.notificationRepository.findAllShopIds();

    for (const shopId of shopIds) {
      if (custom.title && custom.message) {
        await this.createNotificationUseCase.execute(shopId, custom.category || "GENERAL", custom.title, custom.message);
      } else {
        await this.sendTestDummyNotificationsUseCase.execute(shopId);
      }
    }

    return shopIds.length;
  }
}
