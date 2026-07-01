import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";
import {
  mapStockMovement,
  normalizeMoney,
  recordStockMovement,
  resolveShopProductByIdentifier,
  roundQuantity,
} from "../utils/stock-movement";

import { reconcileProductStockAndBins } from "../utils/reconciliation";
import { createNotification } from "./notifications";

const router = Router();

type InventoryModeValue = "GENERAL" | "RACK";
type InventoryBinStatusValue = "EMPTY" | "LOW" | "FULL" | "EXPIRED";
type StockAdjustmentAction = "ADD" | "DAMAGE";

function toLabel(value: string | null | undefined, fallback: string) {
  return value?.trim() || fallback;
}

function buildZoneSubtitle(name: string) {
  return `${name} সম্পর্কিত র্যাক, শেলফ ও বিন ব্যবস্থাপনা`;
}

function normalizeInventoryMode(value: unknown): InventoryModeValue {
  return `${value}`.trim().toUpperCase() === "RACK" ? "RACK" : "GENERAL";
}

function normalizeBinStatus(value: unknown): InventoryBinStatusValue {
  const normalized = `${value}`.trim().toUpperCase();
  if (normalized === "LOW") return "LOW";
  if (normalized === "FULL") return "FULL";
  if (normalized === "EXPIRED") return "EXPIRED";
  return "EMPTY";
}

function normalizeStockAdjustmentAction(value: unknown): StockAdjustmentAction | null {
  const normalized = `${value}`.trim().toUpperCase();
  if (["ADD", "IN", "PURCHASE"].includes(normalized)) {
    return "ADD";
  }
  if (["DAMAGE", "LOSS", "WASTAGE", "EXPIRED"].includes(normalized)) {
    return "DAMAGE";
  }
  return null;
}

async function requireOwnerInventoryContext(request: Parameters<typeof getAuthenticatedUser>[0]): Promise<any> {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (auth.payload.appType !== "MOBILE" || auth.payload.role !== "SHOP_OWNER" || !auth.payload.shopId) {
    return {
      status: 403,
      body: { message: "Only shop owners can manage inventory layouts." },
    };
  }

  const shop = await prisma.shop.findUnique({
    where: { id: auth.payload.shopId },
    select: {
      id: true,
      shopCode: true,
      shopName: true,
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

function mapZone(zone: any) {
  return {
    id: zone.id,
    name: zone.name,
    subtitle: toLabel(zone.subtitle, buildZoneSubtitle(zone.name)),
    icon: toLabel(zone.icon, "map"),
    rackCount: zone._count?.racks ?? 0,
    shelfCount: zone._count?.shelves ?? 0,
    binCount: zone._count?.bins ?? 0,
    createdAt: zone.createdAt,
    updatedAt: zone.updatedAt,
  };
}

function mapRack(rack: any) {
  return {
    id: rack.id,
    zoneId: rack.zoneId,
    name: rack.name,
    note: rack.note,
    shelfCount: rack.shelfCount,
    totalBins: rack.totalBins,
    usedBins: rack.usedBins,
    createdAt: rack.createdAt,
    updatedAt: rack.updatedAt,
  };
}

function serializeShelfName(name: string, direction: string): string {
  return `${name.trim()}:::${direction.trim()}`;
}

function deserializeShelfName(serialized: string): { name: string; direction: string } {
  if (serialized.includes(":::")) {
    const parts = serialized.split(":::");
    return { name: parts[0], direction: parts[1] };
  }
  return { name: serialized, direction: "উপরের সারি" };
}

function getBinQuantity(bin: any): number {
  if (bin.items && bin.items.length > 0) {
    return bin.items.reduce((sum: number, item: any) => sum + Number(item.quantity || 0), 0);
  }
  if (bin.quantityLabel) {
    const parsed = parseInt(bin.quantityLabel, 10);
    return isNaN(parsed) ? 0 : parsed;
  }
  return 0;
}

function mapShelf(shelf: any) {
  const deserialized = deserializeShelfName(shelf.name);
  return {
    id: shelf.id,
    zoneId: shelf.zoneId,
    rackId: shelf.rackId,
    name: deserialized.name,
    direction: deserialized.direction,
    totalBins: shelf.totalBins,
    usedBins: shelf.usedBins,
    createdAt: shelf.createdAt,
    updatedAt: shelf.updatedAt,
  };
}

function mapBin(bin: any) {
  const qty = getBinQuantity(bin);
  return {
    id: bin.id,
    zoneId: bin.zoneId,
    rackId: bin.rackId,
    shelfId: bin.shelfId,
    code: bin.code,
    productName: toLabel(bin.productName, "খালি"),
    status: qty <= 0 ? "EMPTY" : qty < 10 ? "LOW" : "FULL",
    quantity: qty,
    quantityLabel: `${qty} পিস`,
    daysLabel: toLabel(bin.daysLabel, qty <= 0 ? "খালি" : "১ দিন"),
    createdAt: bin.createdAt,
    updatedAt: bin.updatedAt,
  };
}

function deriveBinStatusFromQuantity(quantity: number): InventoryBinStatusValue {
  if (quantity <= 0) return "EMPTY";
  if (quantity < 10) return "LOW";
  return "FULL";
}

async function getInventoryCounts(shopId: string) {
  const [zoneCount, rackCount, shelfCount, binCount] = await Promise.all([
    (prisma as any).inventoryZone.count({ where: { shopId } }),
    (prisma as any).inventoryRack.count({ where: { shopId } }),
    (prisma as any).inventoryShelf.count({ where: { shopId } }),
    (prisma as any).inventoryBin.count({ where: { shopId } }),
  ]);

  return { zoneCount, rackCount, shelfCount, binCount };
}

router.get("/mode", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const setting = await (prisma as any).shopInventorySetting.findUnique({
      where: { shopId: context.shop.id },
    });

    return response.json({
      shop: context.shop,
      mode: setting?.mode ?? "GENERAL",
      configured: Boolean(setting),
    });
  } catch (error) {
    console.error("Failed to load inventory mode.", error);
    return response.status(503).json({ message: "Inventory mode could not be loaded right now." });
  }
});

router.post("/mode", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const mode = normalizeInventoryMode((request.body as { mode?: string }).mode);

    const setting = await (prisma as any).shopInventorySetting.upsert({
      where: { shopId: context.shop.id },
      update: { mode },
      create: {
        shopId: context.shop.id,
        mode,
      },
    });

    return response.json({
      message: "Inventory mode saved successfully.",
      setting: {
        id: setting.id,
        shopId: setting.shopId,
        mode: setting.mode,
      },
      configured: true,
    });
  } catch (error) {
    console.error("Failed to save inventory mode.", error);
    return response.status(503).json({ message: "Inventory mode could not be saved right now." });
  }
});

router.get("/dashboard", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const [setting, counts, attentionCount] = await Promise.all([
      (prisma as any).shopInventorySetting.findUnique({
        where: { shopId: context.shop.id },
      }),
      getInventoryCounts(context.shop.id),
      (prisma as any).inventoryBin.count({
        where: {
          shopId: context.shop.id,
          status: { in: ["LOW", "EXPIRED"] },
        },
      }),
    ]);

    return response.json({
      shop: context.shop,
      mode: setting?.mode ?? "GENERAL",
      configured: Boolean(setting),
      summary: {
        zones: counts.zoneCount,
        racks: counts.rackCount,
        shelves: counts.shelfCount,
        bins: counts.binCount,
      },
      alerts: {
        attentionCount,
      },
    });
  } catch (error) {
    console.error("Failed to load inventory dashboard.", error);
    return response.status(503).json({ message: "Inventory dashboard could not be loaded right now." });
  }
});

router.get("/attention", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const bins = await (prisma as any).inventoryBin.findMany({
      where: {
        shopId: context.shop.id,
        status: { in: ["LOW", "EXPIRED"] },
      },
      orderBy: [{ updatedAt: "desc" }],
      take: 20,
    });

    return response.json({
      shop: context.shop,
      bins: bins.map(mapBin),
    });
  } catch (error) {
    console.error("Failed to load inventory attention bins.", error);
    return response.status(503).json({ message: "Inventory alerts could not be loaded right now." });
  }
});

router.get("/general-store", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const products = await (prisma as any).shopProduct.findMany({
      where: { shopId: context.shop.id },
      include: {
        masterProduct: {
          select: {
            id: true,
            sku: true,
            name: true,
            packageSize: true,
            suggestedPrice: true,
            price: true,
          },
        },
      },
      orderBy: [{ createdAt: "asc" }],
    });

    const mappedProducts = products.map((item: any) => {
      const stock = Number(item.openingStock ?? 0);
      const status = stock <= 0 ? "OUT" : stock <= 5 ? "LOW" : "IN_STOCK";

      return {
        id: item.id,
        masterProductId: item.masterProductId,
        name: item.masterProduct.name,
        sku: item.masterProduct.sku,
        packageSize: item.masterProduct.packageSize ?? item.masterProduct.sku,
        stock,
        salePrice: Number(item.salePrice ?? item.masterProduct.suggestedPrice ?? item.masterProduct.price ?? 0),
        status,
      };
    });

    return response.json({
      shop: context.shop,
      store: {
        id: "main-store",
        name: "Main Store",
        mode: "GENERAL",
      },
      summary: {
        totalProducts: mappedProducts.length,
        lowStockProducts: mappedProducts.filter((item: any) => item.status === "LOW").length,
        outOfStockProducts: mappedProducts.filter((item: any) => item.status === "OUT").length,
      },
      products: mappedProducts,
    });
  } catch (error) {
    console.error("Failed to load general inventory store.", error);
    return response.status(503).json({ message: "General inventory store could not be loaded right now." });
  }
});

router.get("/stock-movements", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const productId = typeof request.query.product_id === "string" ? request.query.product_id.trim() : "";
    const limit = Math.max(1, Math.min(Number(request.query.limit ?? 50) || 50, 200));

    if (!productId) {
      return response.status(400).json({ message: "product_id is required." });
    }

    const shopProduct = await resolveShopProductByIdentifier(
      prisma,
      context.shop.id,
      productId,
    );

    if (!shopProduct) {
      return response.status(404).json({ message: "Product not found in this shop." });
    }

    await (prisma as any).$transaction(async (tx: any) => {
      await reconcileProductStockAndBins(tx, context.shop.id, shopProduct.id);
    });

    const movements = await (prisma as any).stockMovement.findMany({
      where: {
        shopId: context.shop.id,
        shopProductId: shopProduct.id,
      },
      orderBy: [{ createdAt: "desc" }, { id: "desc" }],
      take: limit,
    });

    return response.json({
      shop: context.shop,
      product: {
        id: shopProduct.id,
        masterProductId: shopProduct.masterProductId,
        name: shopProduct.masterProduct?.name ?? shopProduct.localName ?? "Unnamed product",
        sku: shopProduct.masterProduct?.sku ?? shopProduct.localBarcode ?? shopProduct.id,
      },
      history: movements.map(mapStockMovement),
    });
  } catch (error) {
    console.error("Failed to load stock movement history.", error);
    return response.status(503).json({ message: "Stock movement history could not be loaded right now." });
  }
});

router.post("/stock-movements", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      product_id?: string;
      quantity?: number | string;
      type?: string;
      reference?: string;
      note?: string;
      purchase_price?: number | string | null;
    };

    const productId = body.product_id?.trim() ?? "";
    const action = normalizeStockAdjustmentAction(body.type);
    const quantity = Number(body.quantity ?? 0);
    const purchasePrice =
      body.purchase_price == null || body.purchase_price === ""
        ? null
        : normalizeMoney(body.purchase_price);

    if (!productId) {
      return response.status(400).json({ message: "product_id is required." });
    }

    if (!action) {
      return response.status(400).json({
        message: "type must be ADD or DAMAGE.",
      });
    }

    if (!Number.isFinite(quantity) || quantity <= 0) {
      return response.status(400).json({ message: "quantity must be a positive number." });
    }

    const result = await (prisma as any).$transaction(async (tx: any) => {
      const shopProduct = await resolveShopProductByIdentifier(
        tx,
        context.shop.id,
        productId,
      );

      if (!shopProduct) {
        throw new Error("PRODUCT_NOT_FOUND");
      }

      const stockBefore = Number(shopProduct.openingStock ?? 0);
      if (action === "DAMAGE" && stockBefore < quantity) {
        throw new Error("INSUFFICIENT_STOCK");
      }

      const nextStock = roundQuantity(
        action === "ADD" ? stockBefore + quantity : stockBefore - quantity,
      );

      const updated = await tx.shopProduct.update({
        where: { id: shopProduct.id },
        data: {
          openingStock: nextStock,
          ...(action === "ADD" && purchasePrice != null
            ? { purchasePrice }
            : {}),
        },
        include: {
          masterProduct: {
            select: {
              id: true,
              sku: true,
              name: true,
              packageSize: true,
              suggestedPrice: true,
              price: true,
            },
          },
        },
      });

      const movement = await recordStockMovement(tx, {
        shopId: context.shop.id,
        shopProductId: shopProduct.id,
        masterProductId: shopProduct.masterProductId,
        movementType: action === "ADD" ? "MANUAL_ADD" : "MANUAL_REDUCE",
        quantityDelta: action === "ADD" ? quantity : -quantity,
        stockBefore,
        stockAfter: nextStock,
        purchasePrice:
          action === "ADD" && purchasePrice != null
            ? purchasePrice
            : normalizeMoney(updated.purchasePrice),
        salePrice: normalizeMoney(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price),
        referenceType: action === "ADD" ? "MANUAL" : "DAMAGE",
        referenceNo: body.reference?.trim() || null,
        note:
          body.note?.trim() ||
          (action === "ADD" ? "Stock added manually." : "Damaged stock removed."),
        createdByUserId: context.auth.user.id,
      });

      await reconcileProductStockAndBins(tx, context.shop.id, shopProduct.id);

      return { updated, movement };
    });

    const productName = result.updated.masterProduct?.name ?? result.updated.localName ?? "Unnamed product";
    const currentStock = Number(result.updated.openingStock ?? 0);
    const lowStockLimit = Number(result.updated.lowStockLimit ?? 0);

    if (action === "ADD") {
      await createNotification(
        context.shop.id,
        "INVENTORY",
        "স্টক আপডেট হয়েছে",
        `পণ্য: ${productName} | নতুন স্টক: ${currentStock} টি যোগ করা হয়েছে।`
      );
    }

    if (currentStock <= lowStockLimit) {
      await createNotification(
        context.shop.id,
        "INVENTORY",
        "কম স্টক সতর্কতা",
        `একটি পণ্যের (${productName}) স্টক নির্ধারিত সীমার (${lowStockLimit}) নিচে নেমে গেছে। বর্তমান স্টক: ${currentStock}`
      );
    }

    return response.json({
      message:
        action === "ADD"
          ? "Stock added successfully."
          : "Damaged stock removed successfully.",
      product: {
        id: result.updated.source === "SHOP_LOCAL" ? result.updated.id : result.updated.masterProductId,
        shopProductId: result.updated.id,
        masterProductId: result.updated.masterProductId,
        sku: result.updated.masterProduct?.sku ?? result.updated.localBarcode ?? result.updated.id,
        name: result.updated.masterProduct?.name ?? result.updated.localName ?? "Unnamed product",
        packageSize: result.updated.masterProduct?.packageSize ?? result.updated.localUnit ?? result.updated.id,
        stock: Number(result.updated.openingStock ?? 0),
        salePrice: Number(result.updated.salePrice ?? result.updated.masterProduct?.suggestedPrice ?? result.updated.masterProduct?.price ?? 0),
        purchasePrice: Number(result.updated.purchasePrice ?? result.updated.masterProduct?.price ?? 0),
      },
      movement: mapStockMovement(result.movement),
    });
  } catch (error) {
    if (error instanceof Error && error.message === "PRODUCT_NOT_FOUND") {
      return response.status(404).json({ message: "Product not found in this shop." });
    }

    if (error instanceof Error && error.message === "INSUFFICIENT_STOCK") {
      return response.status(400).json({ message: "Cannot reduce more than available stock." });
    }

    console.error("Failed to save stock movement.", error);
    return response.status(503).json({ message: "Stock movement could not be saved right now." });
  }
});

router.get("/layout-tree", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const zones = await (prisma as any).inventoryZone.findMany({
      where: { shopId: context.shop.id },
      include: {
        racks: {
          orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
          include: {
            shelves: {
              orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
              include: {
                bins: {
                  orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
                  include: {
                    items: true,
                  },
                },
              },
            },
          },
        },
      },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
    });

    const tree = zones.map((zone: any) => ({
      id: zone.id,
      name: zone.name,
      racks: zone.racks.map((rack: any) => ({
        id: rack.id,
        name: rack.name,
        shelves: rack.shelves.map((shelf: any) => {
          const deserialized = deserializeShelfName(shelf.name);
          return {
            id: shelf.id,
            name: deserialized.name,
            direction: deserialized.direction,
            bins: shelf.bins.map((bin: any) => {
              const qty = getBinQuantity(bin);
              return {
                id: bin.id,
                code: bin.code,
                quantity: qty,
                rackName: rack.name,
                shelfName: deserialized.name,
              };
            }),
          };
        }),
      })),
    }));

    return response.json({
      shop: context.shop,
      zones: tree,
    });
  } catch (error) {
    console.error("Failed to load layout tree.", error);
    return response.status(503).json({ message: "Layout tree could not be loaded right now." });
  }
});

router.get("/zones", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const zones = await (prisma as any).inventoryZone.findMany({
      where: { shopId: context.shop.id },
      include: {
        _count: {
          select: {
            racks: true,
            shelves: true,
            bins: true,
          },
        },
      },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
    });

    return response.json({
      shop: context.shop,
      zones: zones.map(mapZone),
    });
  } catch (error) {
    console.error("Failed to load inventory zones.", error);
    return response.status(503).json({ message: "Inventory zones could not be loaded right now." });
  }
});

router.post("/zones", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      name?: string;
      subtitle?: string;
      icon?: string;
    };

    const name = body.name?.trim();

    if (!name) {
      return response.status(400).json({ message: "Zone name is required." });
    }

    const existing = await (prisma as any).inventoryZone.findFirst({
      where: {
        shopId: context.shop.id,
        name,
      },
      select: { id: true },
    });

    if (existing) {
      return response.status(409).json({ message: "A zone with this name already exists." });
    }

    const nextSortOrder = await (prisma as any).inventoryZone.count({
      where: { shopId: context.shop.id },
    });

    const zone = await (prisma as any).inventoryZone.create({
      data: {
        shopId: context.shop.id,
        name,
        subtitle: toLabel(body.subtitle, buildZoneSubtitle(name)),
        icon: toLabel(body.icon, "map"),
        sortOrder: nextSortOrder,
      },
      include: {
        _count: {
          select: {
            racks: true,
            shelves: true,
            bins: true,
          },
        },
      },
    });

    return response.status(201).json({
      message: "Inventory zone created successfully.",
      zone: mapZone(zone),
    });
  } catch (error) {
    console.error("Failed to create inventory zone.", error);
    return response.status(503).json({ message: "Inventory zone could not be created right now." });
  }
});

router.get("/racks", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const zoneId = typeof request.query.zoneId === "string" ? request.query.zoneId.trim() : undefined;

    const racks = await (prisma as any).inventoryRack.findMany({
      where: {
        shopId: context.shop.id,
        ...(zoneId ? { zoneId } : {}),
      },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
    });

    return response.json({
      shop: context.shop,
      racks: racks.map(mapRack),
    });
  } catch (error) {
    console.error("Failed to load inventory racks.", error);
    return response.status(503).json({ message: "Inventory racks could not be loaded right now." });
  }
});

router.post("/racks", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      zoneId?: string;
      name?: string;
      note?: string;
      shelfCount?: number;
      binsPerShelf?: number;
      autoGenerate?: boolean;
    };

    const zoneId = body.zoneId?.trim();
    const name = body.name?.trim();
    const shelfCount = Number(body.shelfCount ?? 0);
    const binsPerShelf = Number(body.binsPerShelf ?? 0);
    const autoGenerate = Boolean(body.autoGenerate);

    if (!zoneId || !name) {
      return response.status(400).json({ message: "zoneId and rack name are required." });
    }

    if (autoGenerate && (!Number.isFinite(shelfCount) || shelfCount <= 0 || !Number.isFinite(binsPerShelf) || binsPerShelf <= 0)) {
      return response.status(400).json({ message: "shelfCount and binsPerShelf must be greater than 0 when autoGenerate is true." });
    }

    const zone = await (prisma as any).inventoryZone.findFirst({
      where: {
        id: zoneId,
        shopId: context.shop.id,
      },
    });

    if (!zone) {
      return response.status(404).json({ message: "Zone not found." });
    }

    const nextRackSortOrder = await (prisma as any).inventoryRack.count({
      where: {
        shopId: context.shop.id,
        zoneId,
      },
    });

    const result = await (prisma as any).$transaction(async (tx: any) => {
      const rack = await tx.inventoryRack.create({
        data: {
          shopId: context.shop.id,
          zoneId,
          name,
          note: body.note?.trim() || null,
          shelfCount,
          totalBins: shelfCount * binsPerShelf,
          usedBins: 0,
          sortOrder: nextRackSortOrder,
        },
      });

      const shelves = [];
      const bins = [];

      if (autoGenerate) {
        for (let shelfIndex = 0; shelfIndex < shelfCount; shelfIndex += 1) {
          const shelfName = `${name} - Shelf ${shelfIndex + 1}`;
          const shelf = await tx.inventoryShelf.create({
            data: {
              shopId: context.shop.id,
              zoneId,
              rackId: rack.id,
              name: shelfName,
              totalBins: binsPerShelf,
              usedBins: 0,
              sortOrder: shelfIndex,
            },
          });

          shelves.push(shelf);

          for (let binIndex = 0; binIndex < binsPerShelf; binIndex += 1) {
            const binCode = `${zone.name.charAt(0).toUpperCase()}-${name.replace(/\s+/g, "").slice(-1).toUpperCase()}-S${shelfIndex + 1}-B${binIndex + 1}`;
            const bin = await tx.inventoryBin.create({
              data: {
                shopId: context.shop.id,
                zoneId,
                rackId: rack.id,
                shelfId: shelf.id,
                code: binCode,
                productName: null,
                status: "EMPTY",
                quantityLabel: "খালি",
                daysLabel: "খালি",
                sortOrder: binIndex,
              },
            });

            bins.push(bin);
          }
        }
      }

      return { rack, shelves, bins };
    });

    return response.status(201).json({
      message: "Inventory rack created successfully.",
      rack: mapRack(result.rack),
      shelves: result.shelves.map(mapShelf),
      bins: result.bins.map(mapBin),
    });
  } catch (error) {
    console.error("Failed to create inventory rack.", error);
    return response.status(503).json({ message: "Inventory rack could not be created right now." });
  }
});

router.get("/shelves", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const zoneId = typeof request.query.zoneId === "string" ? request.query.zoneId.trim() : undefined;
    const rackId = typeof request.query.rackId === "string" ? request.query.rackId.trim() : undefined;

    const shelves = await (prisma as any).inventoryShelf.findMany({
      where: {
        shopId: context.shop.id,
        ...(zoneId ? { zoneId } : {}),
        ...(rackId ? { rackId } : {}),
      },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
    });

    return response.json({
      shop: context.shop,
      shelves: shelves.map(mapShelf),
    });
  } catch (error) {
    console.error("Failed to load inventory shelves.", error);
    return response.status(503).json({ message: "Inventory shelves could not be loaded right now." });
  }
});

router.get("/bins", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const zoneId = typeof request.query.zoneId === "string" ? request.query.zoneId.trim() : undefined;
    const rackId = typeof request.query.rackId === "string" ? request.query.rackId.trim() : undefined;
    const shelfId = typeof request.query.shelfId === "string" ? request.query.shelfId.trim() : undefined;

    const bins = await (prisma as any).inventoryBin.findMany({
      where: {
        shopId: context.shop.id,
        ...(zoneId ? { zoneId } : {}),
        ...(rackId ? { rackId } : {}),
        ...(shelfId ? { shelfId } : {}),
      },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
    });

    return response.json({
      shop: context.shop,
      bins: bins.map(mapBin),
    });
  } catch (error) {
    console.error("Failed to load inventory bins.", error);
    return response.status(503).json({ message: "Inventory bins could not be loaded right now." });
  }
});

router.post("/bins", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      zoneId?: string;
      rackId?: string;
      shelfId?: string;
      code?: string;
      productName?: string;
      status?: string;
      quantityLabel?: string;
      daysLabel?: string;
    };

    const zoneId = body.zoneId?.trim();
    const rackId = body.rackId?.trim();
    const shelfId = body.shelfId?.trim();
    const code = body.code?.trim();

    if (!zoneId || !rackId || !shelfId || !code) {
      return response.status(400).json({ message: "zoneId, rackId, shelfId, and code are required." });
    }

    const shelf = await (prisma as any).inventoryShelf.findFirst({
      where: {
        id: shelfId,
        rackId,
        zoneId,
        shopId: context.shop.id,
      },
    });

    if (!shelf) {
      return response.status(404).json({ message: "Shelf not found for the provided location." });
    }

    const nextSortOrder = await (prisma as any).inventoryBin.count({
      where: {
        shopId: context.shop.id,
        shelfId,
      },
    });

    const bin = await (prisma as any).inventoryBin.create({
      data: {
        shopId: context.shop.id,
        zoneId,
        rackId,
        shelfId,
        code,
        productName: body.productName?.trim() || null,
        status: normalizeBinStatus(body.status),
        quantityLabel: body.quantityLabel?.trim() || "খালি",
        daysLabel: body.daysLabel?.trim() || "খালি",
        sortOrder: nextSortOrder,
      },
    });

    return response.status(201).json({
      message: "Inventory bin created successfully.",
      bin: mapBin(bin),
    });
  } catch (error) {
    console.error("Failed to create inventory bin.", error);
    return response.status(503).json({ message: "Inventory bin could not be created right now." });
  }
});

router.post("/placements", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      items?: Array<{
        purchaseItemId?: string;
        masterProductId?: string;
        quantity?: number | string;
        salePrice?: number | string | null;
        zoneId?: string;
        rackId?: string;
        shelfId?: string;
        binId?: string;
        batchNo?: string | null;
        expiryDate?: string | null;
        productName?: string | null;
      }>;
    };

    const items = Array.isArray(body.items) ? body.items : [];

    if (items.length === 0) {
      return response.status(400).json({ message: "At least one placement item is required." });
    }

    const normalizedItems = items.map((item) => ({
      purchaseItemId: item.purchaseItemId?.trim() || null,
      masterProductId: item.masterProductId?.trim() || "",
      quantity: Number(item.quantity ?? 0),
      salePrice:
        item.salePrice == null || item.salePrice === ""
            ? null
            : Number(item.salePrice),
      zoneId: item.zoneId?.trim() || "",
      rackId: item.rackId?.trim() || "",
      shelfId: item.shelfId?.trim() || "",
      binId: item.binId?.trim() || "",
      batchNo: item.batchNo?.trim() || null,
      expiryDate: item.expiryDate ? new Date(item.expiryDate) : null,
      productName: item.productName?.trim() || null,
    }));

    if (
      normalizedItems.some(
        (item) =>
          !item.masterProductId ||
          !item.zoneId ||
          !item.rackId ||
          !item.shelfId ||
          !item.binId ||
          !Number.isFinite(item.quantity) ||
          item.quantity <= 0,
      )
    ) {
      return response.status(400).json({ message: "Each placement requires product, quantity, zone, rack, shelf, and bin." });
    }

    const placements = await (prisma as any).$transaction(async (tx: any) => {
      const results = [];

      for (const item of normalizedItems) {
        const bin = await tx.inventoryBin.findFirst({
          where: {
            id: item.binId,
            shopId: context.shop.id,
            zoneId: item.zoneId,
            rackId: item.rackId,
            shelfId: item.shelfId,
          },
        });

        if (!bin) {
          throw new Error("Selected bin was not found in this shop location.");
        }

        let purchaseItem = null;
        if (item.purchaseItemId) {
          purchaseItem = await tx.purchaseItem.findFirst({
            where: {
              id: item.purchaseItemId,
              masterProductId: item.masterProductId,
              purchase: {
                shopId: context.shop.id,
              },
            },
            include: {
              masterProduct: {
                select: { name: true },
              },
            },
          });

          if (!purchaseItem) {
            throw new Error("Purchase item was not found for this shop.");
          }
        }

        const placement = await tx.inventoryBinItem.create({
          data: {
            shopId: context.shop.id,
            binId: item.binId,
            masterProductId: item.masterProductId,
            purchaseItemId: item.purchaseItemId,
            quantity: item.quantity,
            purchasePrice: purchaseItem ? purchaseItem.purchasePrice : null,
            salePrice: item.salePrice,
            batchNo: item.batchNo,
            expiryDate: item.expiryDate,
            notes: "Assigned after purchase approval.",
          },
        });

        const quantityLabel = `${item.quantity} পিস`;
        const productName = item.productName || purchaseItem?.masterProduct?.name || bin.productName || "স্টক";
        const nextStatus = deriveBinStatusFromQuantity(item.quantity);

        await tx.inventoryBin.update({
          where: { id: item.binId },
          data: {
            productName,
            quantityLabel,
            status: nextStatus,
            daysLabel: item.expiryDate ? "মেয়াদ সেট" : "নতুন স্টক",
          },
        });

        if (bin.status === "EMPTY") {
          await tx.inventoryRack.update({
            where: { id: item.rackId },
            data: { usedBins: { increment: 1 } },
          });
          await tx.inventoryShelf.update({
            where: { id: item.shelfId },
            data: { usedBins: { increment: 1 } },
          });
        }

        results.push({
          id: placement.id,
          binId: item.binId,
          purchaseItemId: item.purchaseItemId,
          masterProductId: item.masterProductId,
          quantity: Number(placement.quantity),
          batchNo: placement.batchNo,
          expiryDate: placement.expiryDate,
          productName,
        });
      }

      return results;
    });

    return response.status(201).json({
      message: "Purchase items assigned to inventory successfully.",
      placements,
    });
  } catch (error) {
    console.error("Failed to assign purchase items to inventory.", error);
    return response.status(503).json({
      message: error instanceof Error ? error.message : "Inventory placement could not be saved right now.",
    });
  }
});

// PATCH /zones/:id
router.patch("/zones/:id", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);
    if (isAuthError(context)) return sendAuthError(response, context);
    if ("status" in context) return response.status(context.status).json(context.body);

    const { id } = request.params;
    const { name, subtitle, icon } = request.body as { name?: string; subtitle?: string; icon?: string };

    const zone = await (prisma as any).inventoryZone.findFirst({
      where: { id, shopId: context.shop.id }
    });

    if (!zone) {
      return response.status(404).json({ message: "Zone not found." });
    }

    const updated = await (prisma as any).inventoryZone.update({
      where: { id },
      data: {
        ...(name ? { name: name.trim() } : {}),
        ...(subtitle !== undefined ? { subtitle: subtitle.trim() || null } : {}),
        ...(icon !== undefined ? { icon: icon.trim() || null } : {}),
      }
    });

    return response.json({
      message: "Zone updated successfully.",
      zone: mapZone(updated)
    });
  } catch (error) {
    console.error("Failed to update zone:", error);
    return response.status(500).json({ message: "Failed to update zone." });
  }
});

// DELETE /zones/:id
router.delete("/zones/:id", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);
    if (isAuthError(context)) return sendAuthError(response, context);
    if ("status" in context) return response.status(context.status).json(context.body);

    const { id } = request.params;

    const zone = await (prisma as any).inventoryZone.findFirst({
      where: { id, shopId: context.shop.id }
    });

    if (!zone) {
      return response.status(404).json({ message: "Zone not found." });
    }

    await (prisma as any).inventoryZone.delete({
      where: { id }
    });

    return response.json({ message: "Zone deleted successfully." });
  } catch (error) {
    console.error("Failed to delete zone:", error);
    return response.status(500).json({ message: "Failed to delete zone." });
  }
});

// PATCH /racks/:id
router.patch("/racks/:id", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);
    if (isAuthError(context)) return sendAuthError(response, context);
    if ("status" in context) return response.status(context.status).json(context.body);

    const { id } = request.params;
    const { name, note } = request.body as { name?: string; note?: string };

    const rack = await (prisma as any).inventoryRack.findFirst({
      where: { id, shopId: context.shop.id }
    });

    if (!rack) {
      return response.status(404).json({ message: "Rack not found." });
    }

    const updated = await (prisma as any).inventoryRack.update({
      where: { id },
      data: {
        ...(name ? { name: name.trim() } : {}),
        ...(note !== undefined ? { note: note.trim() || null } : {}),
      }
    });

    return response.json({
      message: "Rack updated successfully.",
      rack: mapRack(updated)
    });
  } catch (error) {
    console.error("Failed to update rack:", error);
    return response.status(500).json({ message: "Failed to update rack." });
  }
});

// DELETE /racks/:id
router.delete("/racks/:id", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);
    if (isAuthError(context)) return sendAuthError(response, context);
    if ("status" in context) return response.status(context.status).json(context.body);

    const { id } = request.params;

    const rack = await (prisma as any).inventoryRack.findFirst({
      where: { id, shopId: context.shop.id }
    });

    if (!rack) {
      return response.status(404).json({ message: "Rack not found." });
    }

    await (prisma as any).inventoryRack.delete({
      where: { id }
    });

    return response.json({ message: "Rack deleted successfully." });
  } catch (error) {
    console.error("Failed to delete rack:", error);
    return response.status(500).json({ message: "Failed to delete rack." });
  }
});

// POST /shelves
router.post("/shelves", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);
    if (isAuthError(context)) return sendAuthError(response, context);
    if ("status" in context) return response.status(context.status).json(context.body);

    const { zoneId, rackId, name, direction } = request.body as {
      zoneId?: string;
      rackId?: string;
      name?: string;
      direction?: string;
    };

    if (!zoneId || !rackId || !name) {
      return response.status(400).json({ message: "zoneId, rackId, and shelf name are required." });
    }

    const rack = await (prisma as any).inventoryRack.findFirst({
      where: { id: rackId, zoneId, shopId: context.shop.id }
    });

    if (!rack) {
      return response.status(404).json({ message: "Rack not found." });
    }

    const nextSortOrder = await (prisma as any).inventoryShelf.count({
      where: { shopId: context.shop.id, rackId }
    });

    const serializedName = serializeShelfName(name, direction || "উপরের সারি");

    const shelf = await (prisma as any).inventoryShelf.create({
      data: {
        shopId: context.shop.id,
        zoneId,
        rackId,
        name: serializedName,
        sortOrder: nextSortOrder,
      }
    });

    await (prisma as any).inventoryRack.update({
      where: { id: rackId },
      data: { shelfCount: { increment: 1 } }
    });

    return response.status(201).json({
      message: "Shelf created successfully.",
      shelf: mapShelf(shelf)
    });
  } catch (error) {
    console.error("Failed to create shelf:", error);
    return response.status(500).json({ message: "Failed to create shelf." });
  }
});

// PATCH /shelves/:id
router.patch("/shelves/:id", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);
    if (isAuthError(context)) return sendAuthError(response, context);
    if ("status" in context) return response.status(context.status).json(context.body);

    const { id } = request.params;
    const { name, direction } = request.body as { name?: string; direction?: string };

    const shelf = await (prisma as any).inventoryShelf.findFirst({
      where: { id, shopId: context.shop.id }
    });

    if (!shelf) {
      return response.status(404).json({ message: "Shelf not found." });
    }

    const parsed = deserializeShelfName(shelf.name);
    const newName = name !== undefined ? name.trim() : parsed.name;
    const newDir = direction !== undefined ? direction.trim() : parsed.direction;

    const updated = await (prisma as any).inventoryShelf.update({
      where: { id },
      data: {
        name: serializeShelfName(newName, newDir)
      }
    });

    return response.json({
      message: "Shelf updated successfully.",
      shelf: mapShelf(updated)
    });
  } catch (error) {
    console.error("Failed to update shelf:", error);
    return response.status(500).json({ message: "Failed to update shelf." });
  }
});

// DELETE /shelves/:id
router.delete("/shelves/:id", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);
    if (isAuthError(context)) return sendAuthError(response, context);
    if ("status" in context) return response.status(context.status).json(context.body);

    const { id } = request.params;

    const shelf = await (prisma as any).inventoryShelf.findFirst({
      where: { id, shopId: context.shop.id }
    });

    if (!shelf) {
      return response.status(404).json({ message: "Shelf not found." });
    }

    await (prisma as any).$transaction([
      (prisma as any).inventoryShelf.delete({ where: { id } }),
      (prisma as any).inventoryRack.update({
        where: { id: shelf.rackId },
        data: { shelfCount: { decrement: 1 } }
      })
    ]);

    return response.json({ message: "Shelf deleted successfully." });
  } catch (error) {
    console.error("Failed to delete shelf:", error);
    return response.status(500).json({ message: "Failed to delete shelf." });
  }
});

// PATCH /bins/:id
router.patch("/bins/:id", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);
    if (isAuthError(context)) return sendAuthError(response, context);
    if ("status" in context) return response.status(context.status).json(context.body);

    const { id } = request.params;
    const { code, quantity } = request.body as { code?: string; quantity?: number };

    const bin = await (prisma as any).inventoryBin.findFirst({
      where: { id, shopId: context.shop.id }
    });

    if (!bin) {
      return response.status(404).json({ message: "Bin not found." });
    }

    const newCode = code !== undefined ? code.trim() : bin.code;
    let nextStatus = bin.status;
    let quantityLabel = bin.quantityLabel;

    if (quantity !== undefined) {
      nextStatus = deriveBinStatusFromQuantity(quantity);
      quantityLabel = `${quantity} পিস`;
    }

    const updated = await (prisma as any).inventoryBin.update({
      where: { id },
      data: {
        code: newCode,
        status: nextStatus,
        quantityLabel,
        daysLabel: quantity !== undefined && quantity > 0 ? "মেয়াদ সেট" : "খালি",
      }
    });

    return response.json({
      message: "Bin updated successfully.",
      bin: mapBin(updated)
    });
  } catch (error) {
    console.error("Failed to update bin:", error);
    return response.status(500).json({ message: "Failed to update bin." });
  }
});

// DELETE /bins/:id
router.delete("/bins/:id", async (request, response) => {
  try {
    const context = await requireOwnerInventoryContext(request);
    if (isAuthError(context)) return sendAuthError(response, context);
    if ("status" in context) return response.status(context.status).json(context.body);

    const { id } = request.params;

    const bin = await (prisma as any).inventoryBin.findFirst({
      where: { id, shopId: context.shop.id }
    });

    if (!bin) {
      return response.status(404).json({ message: "Bin not found." });
    }

    await (prisma as any).inventoryBin.delete({
      where: { id }
    });

    return response.json({ message: "Bin deleted successfully." });
  } catch (error) {
    console.error("Failed to delete bin:", error);
    return response.status(500).json({ message: "Failed to delete bin." });
  }
});

export default router;
