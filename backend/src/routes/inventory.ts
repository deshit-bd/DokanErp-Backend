import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

type InventoryModeValue = "GENERAL" | "RACK";
type InventoryBinStatusValue = "EMPTY" | "LOW" | "FULL" | "EXPIRED";

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

function mapShelf(shelf: any) {
  return {
    id: shelf.id,
    zoneId: shelf.zoneId,
    rackId: shelf.rackId,
    name: shelf.name,
    totalBins: shelf.totalBins,
    usedBins: shelf.usedBins,
    createdAt: shelf.createdAt,
    updatedAt: shelf.updatedAt,
  };
}

function mapBin(bin: any) {
  return {
    id: bin.id,
    zoneId: bin.zoneId,
    rackId: bin.rackId,
    shelfId: bin.shelfId,
    code: bin.code,
    productName: toLabel(bin.productName, "খালি"),
    status: bin.status,
    quantityLabel: toLabel(bin.quantityLabel, bin.status === "EMPTY" ? "খালি" : "১ পিস"),
    daysLabel: toLabel(bin.daysLabel, bin.status === "EMPTY" ? "খালি" : "১ দিন"),
    createdAt: bin.createdAt,
    updatedAt: bin.updatedAt,
  };
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

    if (!Number.isFinite(shelfCount) || shelfCount <= 0 || !Number.isFinite(binsPerShelf) || binsPerShelf <= 0) {
      return response.status(400).json({ message: "shelfCount and binsPerShelf must be greater than 0." });
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

export default router;
