import { Router } from "express";
import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

// GET /settings - Fetch notification settings
router.get("/settings", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);
    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }
    const shopId = auth.payload.shopId;
    if (!shopId) {
      return response.status(400).json({ message: "Shop ID not associated with user." });
    }

    let settings = await prisma.notificationSetting.findUnique({
      where: { shopId },
    });

    if (!settings) {
      // Create default settings if not exists
      settings = await prisma.notificationSetting.create({
        data: {
          shopId,
          lowStock: true,
          binLowStock: true,
          newSale: true,
          dueReminder: true,
          newCustomer: true,
          expiryAlert: true,
          dailyReport: true,
          weeklyReport: true,
          quietHours: false,
        },
      });
    }

    return response.json({ settings });
  } catch (error: any) {
    console.error("Failed to fetch notification settings:", error);
    return response.status(500).json({ message: error.message || "Failed to fetch settings." });
  }
});

// PUT /settings - Update notification settings
router.put("/settings", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);
    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }
    const shopId = auth.payload.shopId;
    if (!shopId) {
      return response.status(400).json({ message: "Shop ID not associated with user." });
    }

    const {
      lowStock,
      binLowStock,
      newSale,
      dueReminder,
      newCustomer,
      expiryAlert,
      dailyReport,
      weeklyReport,
      quietHours,
    } = request.body;

    const settings = await prisma.notificationSetting.upsert({
      where: { shopId },
      update: {
        lowStock: lowStock !== undefined ? !!lowStock : undefined,
        binLowStock: binLowStock !== undefined ? !!binLowStock : undefined,
        newSale: newSale !== undefined ? !!newSale : undefined,
        dueReminder: dueReminder !== undefined ? !!dueReminder : undefined,
        newCustomer: newCustomer !== undefined ? !!newCustomer : undefined,
        expiryAlert: expiryAlert !== undefined ? !!expiryAlert : undefined,
        dailyReport: dailyReport !== undefined ? !!dailyReport : undefined,
        weeklyReport: weeklyReport !== undefined ? !!weeklyReport : undefined,
        quietHours: quietHours !== undefined ? !!quietHours : undefined,
      },
      create: {
        shopId,
        lowStock: lowStock !== undefined ? !!lowStock : true,
        binLowStock: binLowStock !== undefined ? !!binLowStock : true,
        newSale: newSale !== undefined ? !!newSale : true,
        dueReminder: dueReminder !== undefined ? !!dueReminder : true,
        newCustomer: newCustomer !== undefined ? !!newCustomer : true,
        expiryAlert: expiryAlert !== undefined ? !!expiryAlert : true,
        dailyReport: dailyReport !== undefined ? !!dailyReport : true,
        weeklyReport: weeklyReport !== undefined ? !!weeklyReport : true,
        quietHours: quietHours !== undefined ? !!quietHours : false,
      },
    });

    return response.json({ message: "Settings saved successfully", settings });
  } catch (error: any) {
    console.error("Failed to save notification settings:", error);
    return response.status(500).json({ message: error.message || "Failed to save settings." });
  }
});

// GET / - Fetch in-app notifications
router.get("/", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);
    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }
    const shopId = auth.payload.shopId;
    if (!shopId) {
      return response.status(400).json({ message: "Shop ID not associated with user." });
    }

    const notifications = await prisma.inAppNotification.findMany({
      where: { shopId },
      orderBy: { createdAt: "desc" },
      take: 100,
    });

    return response.json({ notifications });
  } catch (error: any) {
    console.error("Failed to fetch notifications:", error);
    return response.status(500).json({ message: error.message || "Failed to fetch notifications." });
  }
});

// POST / - Create in-app notification
router.post("/", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);
    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }
    const shopId = auth.payload.shopId;
    if (!shopId) {
      return response.status(400).json({ message: "Shop ID not associated with user." });
    }

    const { type, title, message, timestamp } = request.body;
    if (!type || !title || !message) {
      return response.status(400).json({ message: "Type, title and message are required." });
    }

    const notification = await prisma.inAppNotification.create({
      data: {
        shopId,
        type,
        title,
        message,
        timestamp: timestamp || new Date().toLocaleTimeString("bn-BD") + " | " + new Date().toLocaleDateString("bn-BD"),
      },
    });

    return response.status(201).json({ notification });
  } catch (error: any) {
    console.error("Failed to create notification:", error);
    return response.status(500).json({ message: error.message || "Failed to create notification." });
  }
});

// PUT /read - Mark notifications as read
router.put("/read", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);
    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }
    const shopId = auth.payload.shopId;
    if (!shopId) {
      return response.status(400).json({ message: "Shop ID not associated with user." });
    }

    const { id } = request.body;

    if (id) {
      // Mark single notification as read
      await prisma.inAppNotification.update({
        where: { id },
        data: { isRead: true },
      });
    } else {
      // Mark all notifications for this shop as read
      await prisma.inAppNotification.updateMany({
        where: { shopId, isRead: false },
        data: { isRead: true },
      });
    }

    return response.json({ message: "Notifications marked as read" });
  } catch (error: any) {
    console.error("Failed to mark notifications as read:", error);
    return response.status(500).json({ message: error.message || "Failed to update notifications." });
  }
});

// DELETE / - Delete notifications
router.delete("/", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);
    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }
    const shopId = auth.payload.shopId;
    if (!shopId) {
      return response.status(400).json({ message: "Shop ID not associated with user." });
    }

    const { id } = request.body;

    if (id) {
      // Delete single notification
      await prisma.inAppNotification.delete({
        where: { id },
      });
    } else {
      // Delete all notifications for this shop
      await prisma.inAppNotification.deleteMany({
        where: { shopId },
      });
    }

    return response.json({ message: "Notifications deleted successfully" });
  } catch (error: any) {
    console.error("Failed to delete notifications:", error);
    return response.status(500).json({ message: error.message || "Failed to delete notifications." });
  }
});

export default router;
