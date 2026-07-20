import type { DeadStockCandidate } from "@domain/notification/dead-stock.entity";
import type { InAppNotification, NotificationSettings } from "@domain/notification/notification.entity";

export interface NotificationRepository {
  findSettingsByShopId(shopId: string): Promise<NotificationSettings | null>;
  createSettings(shopId: string, settings: NotificationSettings): Promise<NotificationSettings>;
  upsertSettings(shopId: string, update: Partial<NotificationSettings>, createDefaults: NotificationSettings): Promise<NotificationSettings>;

  hasRecentNotificationOfType(shopId: string, type: string, since: Date): Promise<boolean>;
  findStaleProductsWithStock(shopId: string, olderThan: Date): Promise<DeadStockCandidate[]>;
  findSoldMasterProductIds(shopId: string, since: Date): Promise<Set<string>>;

  create(shopId: string, type: string, title: string, message: string, timestamp?: string): Promise<InAppNotification>;
  findManyByShop(shopId: string, take: number): Promise<InAppNotification[]>;
  markAsRead(id: string): Promise<void>;
  markAllAsReadForShop(shopId: string): Promise<void>;
  deleteById(id: string): Promise<void>;
  deleteAllForShop(shopId: string): Promise<void>;

  findAllShopIds(): Promise<string[]>;
}
