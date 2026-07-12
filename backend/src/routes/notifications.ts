import { Router } from "express";
import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";
import { broadcastToShop } from "../utils/socket";

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

// GET /send-test-dummies - Trigger dummy notifications for the current shop
router.get("/send-test-dummies", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);
    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }
    const shopId = auth.payload.shopId;
    if (!shopId) {
      return response.status(400).json({ message: "Shop ID not associated with user." });
    }

    await createNotification(
      shopId,
      "SALE",
      "টেস্ট বিক্রয় সম্পন্ন",
      "রসিদ নং TXN-TEST-101 | মোট বিক্রয় ৳১২০০ | কাস্টমার: কামাল হোসেন"
    );

    await createNotification(
      shopId,
      "INVENTORY",
      "টেস্ট স্টক সতর্কতা",
      "পণ্য: মিনিকেট চাল ৫০ কেজি এর স্টক কমে ৩ এ নেমেছে।"
    );

    await createNotification(
      shopId,
      "GENERAL",
      "নতুন গ্রাহক যুক্ত হয়েছে",
      "গ্রাহক আবির রহমান আপনার কাস্টমার তালিকায় সফলভাবে যুক্ত হয়েছে।"
    );

    return response.json({ message: "Dummy notifications triggered successfully" });
  } catch (error: any) {
    console.error("Failed to trigger dummy notifications:", error);
    return response.status(500).json({ message: error.message || "Failed to trigger dummies." });
  }
});

// GET /send-test-dummies-unauth - Trigger dummy notifications without authentication (for testing)
router.get("/send-test-dummies-unauth", async (request, response) => {
  try {
    const shops = await prisma.shop.findMany();
    if (shops.length === 0) {
      return response.status(404).json({ message: "No shops found in database." });
    }

    // Check if custom message is provided via query
    const customTitle = request.query.title as string;
    const customMessage = request.query.message as string;
    const customCategory = (request.query.category as string) || "GENERAL";

    for (const shop of shops) {
      const shopId = shop.id;

      if (customTitle && customMessage) {
        await createNotification(
          shopId,
          customCategory,
          customTitle,
          customMessage
        );
      } else {
        await createNotification(
          shopId,
          "SALE",
          "টেস্ট বিক্রয় সম্পন্ন",
          "রসিদ নং TXN-TEST-101 | মোট বিক্রয় ৳১২০০ | কাস্টমার: কামাল হোসেন"
        );

        await createNotification(
          shopId,
          "INVENTORY",
          "টেস্ট স্টক সতর্কতা",
          "পণ্য: মিনিকেট চাল ৫০ কেজি এর স্টক কমে ৩ এ নেমেছে।"
        );

        await createNotification(
          shopId,
          "GENERAL",
          "নতুন গ্রাহক যুক্ত হয়েছে",
          "গ্রাহক আবির রহমান আপনার কাস্টমার তালিকায় সফলভাবে যুক্ত হয়েছে।"
        );
      }
    }

    return response.json({ message: `Dummy notifications triggered successfully for ${shops.length} shops.` });
  } catch (error: any) {
    console.error("Failed to trigger dummy notifications:", error);
    return response.status(500).json({ message: error.message || "Failed to trigger dummies." });
  }
});

async function checkDeadStock(shopId: string) {
  try {
    // 1. Check if a DEAD_STOCK notification was created in the last 24 hours to prevent spam
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const recentNotification = await prisma.inAppNotification.findFirst({
      where: {
        shopId,
        type: "DEAD_STOCK",
        createdAt: { gte: oneDayAgo },
      },
    });

    if (recentNotification) {
      return; // Already notified in the last 24 hours
    }

    // 2. Fetch all products older than 10 days
    const tenDaysAgo = new Date(Date.now() - 10 * 24 * 60 * 60 * 1000);
    const products = await prisma.shopProduct.findMany({
      where: {
        shopId,
        createdAt: { lte: tenDaysAgo },
      },
      include: {
        masterProduct: true,
      },
    });

    // Filter products with stock > 0
    const productsWithStock = products.filter(p => Number(p.openingStock ?? 0) > 0);

    if (productsWithStock.length === 0) {
      return;
    }

    // 3. Find all sales items in the last 10 days
    const recentSalesItems = await prisma.customerSaleItem.findMany({
      where: {
        customerSale: {
          shopId,
          saleDate: { gte: tenDaysAgo },
        },
      },
      select: {
        masterProductId: true,
      },
    });

    const soldMasterProductIds = new Set(recentSalesItems.map(item => item.masterProductId));

    // 4. Identify dead products (products with stock > 0 but no sales in 10 days)
    const deadProducts = new Set<string>();
    for (const p of productsWithStock) {
      if (p.masterProductId && !soldMasterProductIds.has(p.masterProductId)) {
        const name = p.localName || p.masterProduct?.name || "Unknown Product";
        deadProducts.add(name);
      }
    }

    if (deadProducts.size > 0) {
      const deadProductsList = Array.from(deadProducts);
      const limitList = deadProductsList.slice(0, 3).join(", ");
      const suffix = deadProductsList.length > 3 ? ` এবং আরও ${deadProductsList.length - 3}টি পণ্য` : "";
      const title = "অচল স্টক সতর্কতা (Dead Stock Alert)";
      const message = `গত ১০ দিনে আপনার এই পণ্যগুলো কোনো বিক্রি হয়নি: ${limitList}${suffix}। অচল স্টক কমাতে দ্রুত ব্যবস্থা নিন।`;
      
      await createNotification(shopId, "DEAD_STOCK", title, message);
    }
  } catch (error) {
    console.error("Failed to run checkDeadStock:", error);
  }
}

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

    await checkDeadStock(shopId);

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

    broadcastToShop(shopId, "new-notification", notification);

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

// PATCH /:id/read - Mark single notification as read
router.patch("/:id/read", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);
    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }
    const shopId = auth.payload.shopId;
    if (!shopId) {
      return response.status(400).json({ message: "Shop ID not associated with user." });
    }

    const { id } = request.params;
    await (prisma as any).inAppNotification.update({
      where: { id },
      data: { isRead: true },
    });

    return response.json({ message: "Notification marked as read" });
  } catch (error: any) {
    console.error("Failed to mark notification as read:", error);
    return response.status(500).json({ message: error.message || "Failed to update notification." });
  }
});

// POST /read-all - Mark all notifications as read
router.post("/read-all", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);
    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }
    const shopId = auth.payload.shopId;
    if (!shopId) {
      return response.status(400).json({ message: "Shop ID not associated with user." });
    }

    await (prisma as any).inAppNotification.updateMany({
      where: { shopId, isRead: false },
      data: { isRead: true },
    });

    return response.json({ message: "All notifications marked as read" });
  } catch (error: any) {
    console.error("Failed to mark all notifications as read:", error);
    return response.status(500).json({ message: error.message || "Failed to update notifications." });
  }
});

// DELETE /:id - Delete single notification
router.delete("/:id", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);
    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }
    const shopId = auth.payload.shopId;
    if (!shopId) {
      return response.status(400).json({ message: "Shop ID not associated with user." });
    }

    const { id } = request.params;
    await (prisma as any).inAppNotification.delete({
      where: { id },
    });

    return response.json({ message: "Notification deleted successfully" });
  } catch (error: any) {
    console.error("Failed to delete notification:", error);
    return response.status(500).json({ message: error.message || "Failed to delete notification." });
  }
});

// Helper function to create notification from business events
export async function createNotification(
  shopId: string,
  type: string,
  title: string,
  message: string,
) {
  try {
    const timestamp = new Date().toLocaleTimeString("bn-BD") + " | " + new Date().toLocaleDateString("bn-BD");
    const notification = await (prisma as any).inAppNotification.create({
      data: {
        shopId,
        type,
        title,
        message,
        timestamp,
      },
    });

    // Broadcast newly created notification in real time!
    broadcastToShop(shopId, "new-notification", notification);
  } catch (error) {
    console.error("Failed to create in-app notification:", error);
  }
}

export default router;
