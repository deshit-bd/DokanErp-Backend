import type { Request, Response } from "express";

import { AppError, InternalError, ValidationError } from "@domain/shared/app-error";
import { CheckDeadStockUseCase } from "@application/notification/use-cases/check-dead-stock.use-case";
import { CreateInAppNotificationUseCase } from "@application/notification/use-cases/create-in-app-notification.use-case";
import { CreateNotificationUseCase } from "@application/notification/use-cases/create-notification.use-case";
import { DeleteNotificationsUseCase } from "@application/notification/use-cases/delete-notifications.use-case";
import { GetNotificationSettingsUseCase } from "@application/notification/use-cases/get-notification-settings.use-case";
import { ListNotificationsUseCase } from "@application/notification/use-cases/list-notifications.use-case";
import { MarkNotificationReadUseCase } from "@application/notification/use-cases/mark-notification-read.use-case";
import { SendTestDummyNotificationsUnauthUseCase } from "@application/notification/use-cases/send-test-dummy-notifications-unauth.use-case";
import { SendTestDummyNotificationsUseCase } from "@application/notification/use-cases/send-test-dummy-notifications.use-case";
import { UpdateNotificationSettingsUseCase } from "@application/notification/use-cases/update-notification-settings.use-case";

import { PrismaNotificationRepository } from "../../persistence/prisma/notification.repository";
import { SocketNotifierAdapter } from "../../realtime/socket-notifier.adapter";

const notificationRepository = new PrismaNotificationRepository();
const realtimeNotifier = new SocketNotifierAdapter();

const createNotificationUseCase = new CreateNotificationUseCase(notificationRepository, realtimeNotifier);
const checkDeadStockUseCase = new CheckDeadStockUseCase(notificationRepository, createNotificationUseCase);
const getNotificationSettingsUseCase = new GetNotificationSettingsUseCase(notificationRepository);
const updateNotificationSettingsUseCase = new UpdateNotificationSettingsUseCase(notificationRepository);
const listNotificationsUseCase = new ListNotificationsUseCase(notificationRepository, checkDeadStockUseCase);
const createInAppNotificationUseCase = new CreateInAppNotificationUseCase(notificationRepository, realtimeNotifier);
const markNotificationReadUseCase = new MarkNotificationReadUseCase(notificationRepository);
const deleteNotificationsUseCase = new DeleteNotificationsUseCase(notificationRepository);
const sendTestDummyNotificationsUseCase = new SendTestDummyNotificationsUseCase(createNotificationUseCase);
const sendTestDummyNotificationsUnauthUseCase = new SendTestDummyNotificationsUnauthUseCase(notificationRepository, createNotificationUseCase);

// Exported for the two not-yet-migrated legacy route files (customers.ts,
// inventory.ts) that still call `createNotification(shopId, type, title,
// message)` as a fire-and-forget helper — see CLAUDE.md's notification
// migration note. Import from here instead of the deleted routes/notifications.ts.
export async function createNotification(shopId: string, type: string, title: string, message: string): Promise<void> {
  return createNotificationUseCase.execute(shopId, type, title, message);
}

function requireShopId(request: Request): string {
  const shopId = request.context?.shopId;
  if (!shopId) {
    throw new ValidationError("Shop ID not associated with user.");
  }
  return shopId;
}

function rethrowOr(error: unknown, fallbackMessage: string): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(fallbackMessage, error);
  throw new InternalError((error as any)?.message || fallbackMessage);
}

export const notificationController = {
  async getSettings(request: Request, response: Response) {
    try {
      const shopId = requireShopId(request);
      const settings = await getNotificationSettingsUseCase.execute(shopId);
      response.json({ settings });
    } catch (error) {
      rethrowOr(error, "Failed to fetch settings.");
    }
  },

  async updateSettings(request: Request, response: Response) {
    try {
      const shopId = requireShopId(request);
      const settings = await updateNotificationSettingsUseCase.execute(shopId, request.body ?? {});
      response.json({ message: "Settings saved successfully", settings });
    } catch (error) {
      rethrowOr(error, "Failed to save settings.");
    }
  },

  async sendTestDummies(request: Request, response: Response) {
    try {
      const shopId = requireShopId(request);
      await sendTestDummyNotificationsUseCase.execute(shopId);
      response.json({ message: "Dummy notifications triggered successfully" });
    } catch (error) {
      rethrowOr(error, "Failed to trigger dummies.");
    }
  },

  async sendTestDummiesUnauth(request: Request, response: Response) {
    try {
      const customTitle = typeof request.query.title === "string" ? request.query.title : undefined;
      const customMessage = typeof request.query.message === "string" ? request.query.message : undefined;
      const customCategory = typeof request.query.category === "string" ? request.query.category : undefined;

      const count = await sendTestDummyNotificationsUnauthUseCase.execute({ title: customTitle, message: customMessage, category: customCategory });

      if (count === 0) {
        throw new ValidationError("No shops found in database.");
      }

      response.json({ message: `Dummy notifications triggered successfully for ${count} shops.` });
    } catch (error) {
      rethrowOr(error, "Failed to trigger dummies.");
    }
  },

  async list(request: Request, response: Response) {
    try {
      const shopId = requireShopId(request);
      const notifications = await listNotificationsUseCase.execute(shopId);
      response.json({ notifications });
    } catch (error) {
      rethrowOr(error, "Failed to fetch notifications.");
    }
  },

  async create(request: Request, response: Response) {
    try {
      const shopId = requireShopId(request);
      const body = request.body as { type?: string; title?: string; message?: string; timestamp?: string };
      const notification = await createInAppNotificationUseCase.execute(shopId, body.type, body.title, body.message, body.timestamp);
      response.status(201).json({ notification });
    } catch (error) {
      rethrowOr(error, "Failed to create notification.");
    }
  },

  async markRead(request: Request, response: Response) {
    try {
      const shopId = requireShopId(request);
      const body = request.body as { id?: string };
      await markNotificationReadUseCase.execute(shopId, body.id);
      response.json({ message: "Notifications marked as read" });
    } catch (error) {
      rethrowOr(error, "Failed to update notifications.");
    }
  },

  async markSingleRead(request: Request, response: Response) {
    try {
      requireShopId(request);
      await markNotificationReadUseCase.execute("", String(request.params.id));
      response.json({ message: "Notification marked as read" });
    } catch (error) {
      rethrowOr(error, "Failed to update notification.");
    }
  },

  async markAllRead(request: Request, response: Response) {
    try {
      const shopId = requireShopId(request);
      await markNotificationReadUseCase.execute(shopId, undefined);
      response.json({ message: "All notifications marked as read" });
    } catch (error) {
      rethrowOr(error, "Failed to update notifications.");
    }
  },

  async remove(request: Request, response: Response) {
    try {
      const shopId = requireShopId(request);
      const body = request.body as { id?: string };
      await deleteNotificationsUseCase.execute(shopId, body.id);
      response.json({ message: "Notifications deleted successfully" });
    } catch (error) {
      rethrowOr(error, "Failed to delete notifications.");
    }
  },

  async removeSingle(request: Request, response: Response) {
    try {
      requireShopId(request);
      await deleteNotificationsUseCase.execute("", String(request.params.id));
      response.json({ message: "Notification deleted successfully" });
    } catch (error) {
      rethrowOr(error, "Failed to delete notification.");
    }
  },
};
