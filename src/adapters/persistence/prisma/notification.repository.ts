import type { DeadStockCandidate } from "@domain/notification/dead-stock.entity";
import type { InAppNotification, NotificationSettings } from "@domain/notification/notification.entity";
import { formatBanglaTimestamp } from "@domain/notification/notification.entity";
import type { NotificationRepository } from "@application/notification/ports/notification-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

function toSettings(record: any): NotificationSettings {
  return {
    lowStock: record.lowStock,
    binLowStock: record.binLowStock,
    newSale: record.newSale,
    dueReminder: record.dueReminder,
    newCustomer: record.newCustomer,
    expiryAlert: record.expiryAlert,
    dailyReport: record.dailyReport,
    weeklyReport: record.weeklyReport,
    quietHours: record.quietHours,
  };
}

export class PrismaNotificationRepository implements NotificationRepository {
  async findSettingsByShopId(shopId: string): Promise<NotificationSettings | null> {
    const record = await prisma.notificationSetting.findUnique({ where: { shopId } });
    return record ? toSettings(record) : null;
  }

  async createSettings(shopId: string, settings: NotificationSettings): Promise<NotificationSettings> {
    const record = await prisma.notificationSetting.create({ data: { shopId, ...settings } });
    return toSettings(record);
  }

  async upsertSettings(shopId: string, update: Partial<NotificationSettings>, createDefaults: NotificationSettings): Promise<NotificationSettings> {
    const record = await prisma.notificationSetting.upsert({
      where: { shopId },
      update,
      create: { shopId, ...createDefaults },
    });
    return toSettings(record);
  }

  async hasRecentNotificationOfType(shopId: string, type: string, since: Date): Promise<boolean> {
    const record = await (prisma as any).inAppNotification.findFirst({
      where: { shopId, type, createdAt: { gte: since } },
    });
    return Boolean(record);
  }

  async findStaleProductsWithStock(shopId: string, olderThan: Date): Promise<DeadStockCandidate[]> {
    const products = await prisma.shopProduct.findMany({
      where: { shopId, createdAt: { lte: olderThan } },
      include: { masterProduct: true },
    });

    return products.map((product) => ({
      masterProductId: product.masterProductId,
      localName: product.localName,
      masterProductName: product.masterProduct?.name ?? null,
      openingStock: Number(product.openingStock ?? 0),
    }));
  }

  async findSoldMasterProductIds(shopId: string, since: Date): Promise<Set<string>> {
    const items = await prisma.customerSaleItem.findMany({
      where: { customerSale: { shopId, saleDate: { gte: since } } },
      select: { masterProductId: true },
    });

    return new Set(items.map((item) => item.masterProductId));
  }

  async create(shopId: string, type: string, title: string, message: string, timestamp?: string): Promise<InAppNotification> {
    return (prisma as any).inAppNotification.create({
      data: { shopId, type, title, message, timestamp: timestamp ?? formatBanglaTimestamp() },
    });
  }

  async findManyByShop(shopId: string, take: number): Promise<InAppNotification[]> {
    return (prisma as any).inAppNotification.findMany({
      where: { shopId },
      orderBy: { createdAt: "desc" },
      take,
    });
  }

  async markAsRead(id: string): Promise<void> {
    await (prisma as any).inAppNotification.update({ where: { id }, data: { isRead: true } });
  }

  async markAllAsReadForShop(shopId: string): Promise<void> {
    await (prisma as any).inAppNotification.updateMany({ where: { shopId, isRead: false }, data: { isRead: true } });
  }

  async deleteById(id: string): Promise<void> {
    await (prisma as any).inAppNotification.delete({ where: { id } });
  }

  async deleteAllForShop(shopId: string): Promise<void> {
    await (prisma as any).inAppNotification.deleteMany({ where: { shopId } });
  }

  async findAllShopIds(): Promise<string[]> {
    const shops = await prisma.shop.findMany({ select: { id: true } });
    return shops.map((shop) => shop.id);
  }
}
