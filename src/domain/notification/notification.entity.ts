export type NotificationSettings = {
  lowStock: boolean;
  binLowStock: boolean;
  newSale: boolean;
  dueReminder: boolean;
  newCustomer: boolean;
  expiryAlert: boolean;
  dailyReport: boolean;
  weeklyReport: boolean;
  quietHours: boolean;
};

export const DEFAULT_NOTIFICATION_SETTINGS: NotificationSettings = {
  lowStock: true,
  binLowStock: true,
  newSale: true,
  dueReminder: true,
  newCustomer: true,
  expiryAlert: true,
  dailyReport: true,
  weeklyReport: true,
  quietHours: false,
};

export type InAppNotification = {
  id: string;
  shopId: string;
  type: string;
  title: string;
  message: string;
  timestamp: string;
  createdAt: Date;
  isRead: boolean;
};

export function formatBanglaTimestamp(now = new Date()): string {
  return `${now.toLocaleTimeString("bn-BD")} | ${now.toLocaleDateString("bn-BD")}`;
}

/** Merges partial boolean-flag input over existing settings, treating `undefined` as "leave unchanged" (matches the original route's `!== undefined ? !!x : undefined` pattern). */
export function mergeNotificationSettingsUpdate(input: Partial<Record<keyof NotificationSettings, unknown>>): Partial<NotificationSettings> {
  const result: Partial<NotificationSettings> = {};
  for (const key of Object.keys(DEFAULT_NOTIFICATION_SETTINGS) as (keyof NotificationSettings)[]) {
    if (input[key] !== undefined) {
      result[key] = Boolean(input[key]);
    }
  }
  return result;
}

/** Same as mergeNotificationSettingsUpdate but falls back to the default value (not "unchanged") for the create branch. */
export function buildNotificationSettingsForCreate(input: Partial<Record<keyof NotificationSettings, unknown>>): NotificationSettings {
  const result = { ...DEFAULT_NOTIFICATION_SETTINGS };
  for (const key of Object.keys(DEFAULT_NOTIFICATION_SETTINGS) as (keyof NotificationSettings)[]) {
    if (input[key] !== undefined) {
      result[key] = Boolean(input[key]);
    }
  }
  return result;
}
