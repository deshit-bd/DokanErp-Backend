import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";
import { persistStoreDocument, storeDocumentField, type StoreDocumentKind } from "../utils/store-document-upload";

const router = Router();

async function requireShopContext(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (auth.payload.appType !== "MOBILE" || !auth.payload.shopId) {
    return {
      status: 403,
      body: { message: "Invalid application scope." },
    };
  }

    const shop = await prisma.shop.findUnique({
      where: { id: auth.payload.shopId },
      select: {
        id: true,
        shopCode: true,
        shopName: true,
        ownerUserId: true,
        phone: true,
        address: true,
      area: true,
      businessType: true,
      tradeLicenseNo: true,
      tinNo: true,
      vatRegNo: true,
      logoUrl: true,
      status: true,
      },
    });

  if (!shop) {
    return {
      status: 404,
      body: { message: "Shop not found." },
    };
  }

  return { auth, shop };
}

// GET /store
router.get("/store", async (request, response) => {
  try {
    const context = await requireShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const shop = context.shop;

    // Get owner name if owner exists
    let ownerName = "";
    if (shop.ownerUserId) {
      const owner = await prisma.user.findUnique({
        where: { id: shop.ownerUserId },
        select: { name: true },
      });
      if (owner) {
        ownerName = owner.name;
      }
    }

    return response.json({
      store_name: shop.shopName,
      owner_name: ownerName,
      mobile: shop.phone || "",
      address: shop.address || "",
      store_type: shop.businessType || "",
      trade_license_no: shop.tradeLicenseNo || "",
      tin_no: shop.tinNo || "",
      bin_no: shop.vatRegNo || "",
      live_location: shop.area || "",
      latitude: null,
      longitude: null,
      logo_url: shop.logoUrl || "",
    });
  } catch (error) {
    console.error("Failed to load store settings.", error);
    return response.status(503).json({
      message: "Store settings could not be loaded right now.",
    });
  }
});

// PUT /store
router.put("/store", async (request, response) => {
  try {
    const context = await requireShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      store_name?: string;
      owner_name?: string;
      mobile?: string | null;
      address?: string | null;
      store_type?: string | null;
      trade_license_no?: string | null;
      tin_no?: string | null;
      bin_no?: string | null;
      live_location?: string | null;
      latitude?: number | null;
      longitude?: number | null;
      logo_url?: string | null;
    };

    const store_name = body.store_name?.trim();
    const owner_name = body.owner_name?.trim();
    const mobile = body.mobile?.trim() || null;
    const address = body.address?.trim() || null;
    const store_type = body.store_type?.trim() || null;
    const trade_license_no = body.trade_license_no?.trim() || null;
    const tin_no = body.tin_no?.trim() || null;
    const bin_no = body.bin_no?.trim() || null;
    const live_location = body.live_location?.trim() || null;

    if (!store_name) {
      return response.status(400).json({ message: "Store name is required." });
    }

    const shopId = context.shop.id;

    // Update Shop model
    await prisma.shop.update({
      where: { id: shopId },
      data: {
        shopName: store_name,
        phone: mobile,
        address: address,
        area: live_location,
        businessType: store_type,
        tradeLicenseNo: trade_license_no,
        tinNo: tin_no,
        vatRegNo: bin_no,
      },
    });

    // Update Owner user model if present
    if (owner_name && context.shop.ownerUserId) {
      await prisma.user.update({
        where: { id: context.shop.ownerUserId },
        data: { name: owner_name },
      });
    }

    return response.json({
      store_name,
      owner_name: owner_name || "",
      mobile: mobile || "",
      address: address || "",
      store_type: store_type || "",
      trade_license_no: trade_license_no || "",
      tin_no: tin_no || "",
      bin_no: bin_no || "",
      live_location: live_location || "",
      latitude: body.latitude ?? null,
      longitude: body.longitude ?? null,
      logo_url: context.shop.logoUrl || "",
    });
  } catch (error) {
    console.error("Failed to save store settings.", error);
    return response.status(503).json({
      message: "Store settings could not be saved right now.",
    });
  }
});

// POST /store/documents/:type
router.post("/store/documents/:type", async (request, response) => {
  try {
    const context = await requireShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const type = request.params.type as StoreDocumentKind;
    if (!["trade", "tin", "bin"].includes(type)) {
      return response.status(400).json({ message: "Unsupported document type." });
    }

    const documentUrl = await persistStoreDocument(type, request.body ?? {}, request);
    const field = storeDocumentField(type);

    const shop = await prisma.shop.update({
      where: { id: context.shop.id },
      data: { [field]: documentUrl },
      select: {
        shopName: true,
        phone: true,
        address: true,
        area: true,
        businessType: true,
        tradeLicenseNo: true,
        tinNo: true,
        vatRegNo: true,
        ownerUserId: true,
      },
    });

    let ownerName = "";
    if (shop.ownerUserId) {
      const owner = await prisma.user.findUnique({
        where: { id: shop.ownerUserId },
        select: { name: true },
      });
      ownerName = owner?.name ?? "";
    }

    return response.json({
      store_name: shop.shopName,
      owner_name: ownerName,
      mobile: shop.phone || "",
      address: shop.address || "",
      store_type: shop.businessType || "",
      trade_license_no: shop.tradeLicenseNo || "",
      tin_no: shop.tinNo || "",
      bin_no: shop.vatRegNo || "",
      live_location: shop.area || "",
      latitude: null,
      longitude: null,
    });
  } catch (error) {
    console.error("Failed to upload store document.", error);
    return response.status(503).json({
      message: error instanceof Error ? error.message : "Store document could not be uploaded right now.",
    });
  }
});

// GET /inventory
router.get("/inventory", async (request, response) => {
  try {
    const context = await requireShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const shopId = context.shop.id;

    let setting = await prisma.shopInventorySetting.findUnique({
      where: { shopId },
    });

    if (!setting) {
      setting = await prisma.shopInventorySetting.create({
        data: {
          shopId,
        },
      });
    }

    return response.json({
      low_stock_limit: setting.lowStockDefault,
      critical_stock_limit: setting.lowStockGrocery,
      auto_low_stock_alert: setting.autoLowStockAlert,
      auto_deduct_on_sale: setting.reduceStockOnSale,
      allow_negative_stock: setting.allowNegativeStock,
      bin_assignment_required: setting.requireBinAssignment,
      show_bin_on_sale: setting.showBinDuringSale,
      track_expiry: setting.demandBasedReorder,
      costing_method: setting.stockMethod,
    });
  } catch (error) {
    console.error("Failed to load inventory settings.", error);
    return response.status(503).json({
      message: "Inventory settings could not be loaded right now.",
    });
  }
});

// PATCH /inventory
router.patch("/inventory", async (request, response) => {
  try {
    const context = await requireShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const shopId = context.shop.id;
    const body = request.body as {
      low_stock_limit?: number;
      critical_stock_limit?: number;
      auto_low_stock_alert?: boolean;
      auto_deduct_on_sale?: boolean;
      allow_negative_stock?: boolean;
      bin_assignment_required?: boolean;
      show_bin_on_sale?: boolean;
      track_expiry?: boolean;
      costing_method?: string;
    };

    const setting = await prisma.shopInventorySetting.upsert({
      where: { shopId },
      create: {
        shopId,
        lowStockDefault: body.low_stock_limit ?? 10,
        lowStockGrocery: body.critical_stock_limit ?? 5,
        autoLowStockAlert: body.auto_low_stock_alert ?? true,
        reduceStockOnSale: body.auto_deduct_on_sale ?? true,
        allowNegativeStock: body.allow_negative_stock ?? false,
        requireBinAssignment: body.bin_assignment_required ?? false,
        showBinDuringSale: body.show_bin_on_sale ?? true,
        demandBasedReorder: body.track_expiry ?? false,
        stockMethod: body.costing_method ?? "FIFO",
      },
      update: {
        lowStockDefault: body.low_stock_limit,
        lowStockGrocery: body.critical_stock_limit,
        autoLowStockAlert: body.auto_low_stock_alert,
        reduceStockOnSale: body.auto_deduct_on_sale,
        allowNegativeStock: body.allow_negative_stock,
        requireBinAssignment: body.bin_assignment_required,
        showBinDuringSale: body.show_bin_on_sale,
        demandBasedReorder: body.track_expiry,
        stockMethod: body.costing_method,
      },
    });

    return response.json({
      low_stock_limit: setting.lowStockDefault,
      critical_stock_limit: setting.lowStockGrocery,
      auto_low_stock_alert: setting.autoLowStockAlert,
      auto_deduct_on_sale: setting.reduceStockOnSale,
      allow_negative_stock: setting.allowNegativeStock,
      bin_assignment_required: setting.requireBinAssignment,
      show_bin_on_sale: setting.showBinDuringSale,
      track_expiry: setting.demandBasedReorder,
      costing_method: setting.stockMethod,
    });
  } catch (error) {
    console.error("Failed to save inventory settings.", error);
    return response.status(503).json({
      message: "Inventory settings could not be saved right now.",
    });
  }
});

export default router;
