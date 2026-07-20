import { deriveBinStatusFromQuantity, normalizeMoney, roundQuantity } from "@domain/inventory/inventory.entity";
import {
  PlacementBinNotFoundError,
  PlacementPurchaseItemNotFoundError,
  ProductNotFoundInShopError,
} from "@domain/inventory/inventory.errors";
import type {
  CreatePlacementItem,
  InventoryBinRecord,
  InventoryRackRecord,
  InventoryRepository,
  InventoryShelfRecord,
  InventoryZoneRecord,
  LayoutTreeZone,
  PlacementResult,
  ShopProductSummary,
} from "@application/inventory/ports/inventory-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";
import { recordStockMovement, resolveShopProductByIdentifier as resolveShopProductTx } from "../../../utils/stock-movement";

/**
 * Ensures a single "general" bin exists for basic (non-rack) inventory mode,
 * auto-creating a zone/rack/shelf the first time it's needed. Moved here from
 * the legacy `routes/purchases.ts` — inventory owns bins/zones/racks/shelves,
 * and `purchases` (not yet migrated) now imports this canonical version
 * instead of the other way around (previously a backwards dependency: see
 * CLAUDE.md's inventory migration notes).
 */
export async function ensureGeneralInventoryBin(
  tx: any,
  shopId: string,
  masterProductId: string | null | undefined,
  productName: string,
) {
  const effectiveId = masterProductId || "GENERAL";
  const binCode = `BASIC-${effectiveId.slice(-8).toUpperCase()}`;

  const existing = await tx.inventoryBin.findFirst({
    where: { shopId, code: binCode },
  });

  if (existing) {
    return existing;
  }

  let zone = await tx.inventoryZone.findFirst({
    where: { shopId },
    orderBy: [{ createdAt: "asc" }],
  });

  if (!zone) {
    zone = await tx.inventoryZone.create({
      data: {
        shopId,
        name: "Main Store",
        subtitle: "Basic inventory stock area",
        icon: "store",
        sortOrder: 0,
      },
    });
  }

  let rack = await tx.inventoryRack.findFirst({
    where: { shopId, zoneId: zone.id },
    orderBy: [{ createdAt: "asc" }],
  });

  if (!rack) {
    rack = await tx.inventoryRack.create({
      data: {
        shopId,
        zoneId: zone.id,
        name: "Main Rack",
        note: "Auto-created for basic inventory stock",
        shelfCount: 1,
        totalBins: 1,
        usedBins: 0,
        sortOrder: 0,
      },
    });
  }

  let shelf = await tx.inventoryShelf.findFirst({
    where: { shopId, rackId: rack.id },
    orderBy: [{ createdAt: "asc" }],
  });

  if (!shelf) {
    shelf = await tx.inventoryShelf.create({
      data: {
        shopId,
        zoneId: zone.id,
        rackId: rack.id,
        name: "Main Shelf",
        totalBins: 1,
        usedBins: 0,
        sortOrder: 0,
      },
    });
  }

  return tx.inventoryBin.create({
    data: {
      shopId,
      zoneId: zone.id,
      rackId: rack.id,
      shelfId: shelf.id,
      code: binCode,
      productName: productName || "Stock",
      status: "FULL",
      quantityLabel: "১ পিস",
      daysLabel: "নতুন স্টক",
      sortOrder: 0,
    },
  });
}

/**
 * Self-healing reconciliation: backfills a missing "initial stock" movement
 * and re-syncs bin-item quantities against `shopProduct.openingStock`. Moved
 * here from `utils/reconciliation.ts` (which imported `ensureGeneralInventoryBin`
 * from `routes/purchases.ts` — the backwards dependency fixed by this move).
 * Still invoked from a GET endpoint as a side effect (see
 * `reconcileAndListStockMovements` below) — that pre-existing quirk is
 * preserved deliberately, not fixed, per this migration's behavior-parity
 * rule; see CLAUDE.md.
 */
async function reconcileProductStockAndBins(tx: any, shopId: string, shopProductId: string) {
  const shopProduct = await tx.shopProduct.findFirst({
    where: { id: shopProductId, shopId },
    include: {
      masterProduct: {
        select: { id: true, name: true, sku: true, price: true, suggestedPrice: true },
      },
    },
  });

  if (!shopProduct) {
    return;
  }

  const masterProductId = shopProduct.masterProductId;
  if (!masterProductId) {
    return;
  }

  const actualStock = Number(shopProduct.openingStock ?? 0);

  const oldestMovement = await tx.stockMovement.findFirst({
    where: { shopId, shopProductId },
    orderBy: { createdAt: "asc" },
  });

  if (oldestMovement) {
    const stockBefore = Number(oldestMovement.stockBefore ?? 0);
    if (stockBefore > 0) {
      const count = await tx.stockMovement.count({
        where: { shopId, shopProductId, createdAt: { lt: oldestMovement.createdAt } },
      });

      if (count === 0) {
        const initialDate = new Date(oldestMovement.createdAt.getTime() - 60000);
        await tx.stockMovement.create({
          data: {
            shopId,
            shopProductId,
            masterProductId,
            movementType: "MANUAL_ADD",
            quantityDelta: stockBefore,
            stockBefore: 0,
            stockAfter: stockBefore,
            purchasePrice: normalizeMoney(shopProduct.purchasePrice),
            salePrice: normalizeMoney(shopProduct.salePrice),
            referenceType: "INITIAL_STOCK",
            note: "প্রারম্ভিক স্টক (Initial Stock)",
            createdAt: initialDate,
          },
        });
      }
    }
  } else if (actualStock > 0) {
    await tx.stockMovement.create({
      data: {
        shopId,
        shopProductId,
        masterProductId,
        movementType: "MANUAL_ADD",
        quantityDelta: actualStock,
        stockBefore: 0,
        stockAfter: actualStock,
        purchasePrice: normalizeMoney(shopProduct.purchasePrice),
        salePrice: normalizeMoney(shopProduct.salePrice),
        referenceType: "INITIAL_STOCK",
        note: "প্রারম্ভিক স্টক (Initial Stock)",
        createdAt: shopProduct.createdAt || new Date(),
      },
    });
  }

  const binItems = await tx.inventoryBinItem.findMany({
    where: { shopId, masterProductId },
    orderBy: [{ createdAt: "asc" }, { id: "asc" }],
  });

  const totalBinQty = binItems.reduce((sum: number, item: any) => sum + Number(item.quantity ?? 0), 0);

  if (totalBinQty === actualStock) {
    return;
  }

  if (totalBinQty > actualStock) {
    let remainingToDeduct = roundQuantity(totalBinQty - actualStock);
    const touchedBinIds = new Set<string>();

    for (const binItem of binItems) {
      if (remainingToDeduct <= 0) break;

      const binQty = Number(binItem.quantity ?? 0);
      if (binQty <= 0) continue;

      const toDeduct = Math.min(binQty, remainingToDeduct);
      const newQty = roundQuantity(binQty - toDeduct);
      remainingToDeduct = roundQuantity(remainingToDeduct - toDeduct);
      touchedBinIds.add(binItem.binId);

      if (newQty <= 0) {
        await tx.inventoryBinItem.delete({ where: { id: binItem.id } });
      } else {
        await tx.inventoryBinItem.update({ where: { id: binItem.id }, data: { quantity: newQty } });
      }
    }

    for (const binId of touchedBinIds) {
      const totalBinQtyAgg = await tx.inventoryBinItem.aggregate({ where: { binId }, _sum: { quantity: true } });
      const quantityValue = Number(totalBinQtyAgg._sum.quantity ?? 0);
      await tx.inventoryBin.update({
        where: { id: binId },
        data: {
          status: deriveBinStatusFromQuantity(quantityValue),
          quantityLabel: quantityValue <= 0 ? "খালি" : `${quantityValue} পিস`,
        },
      });
    }
  } else {
    const diff = roundQuantity(actualStock - totalBinQty);
    const targetBin = await ensureGeneralInventoryBin(
      tx,
      shopId,
      masterProductId,
      shopProduct.masterProduct?.name || shopProduct.localName || "Stock",
    );

    await tx.inventoryBinItem.create({
      data: {
        shopId,
        binId: targetBin.id,
        masterProductId,
        quantity: diff,
        purchasePrice: normalizeMoney(shopProduct.purchasePrice ?? shopProduct.masterProduct?.price ?? null),
        salePrice: normalizeMoney(
          shopProduct.salePrice ?? shopProduct.masterProduct?.suggestedPrice ?? shopProduct.masterProduct?.price ?? null,
        ),
        notes: "Reconciliation stock adjustment.",
      },
    });

    const totalBinQtyAgg = await tx.inventoryBinItem.aggregate({ where: { binId: targetBin.id }, _sum: { quantity: true } });
    const quantityValue = Number(totalBinQtyAgg._sum.quantity ?? 0);
    await tx.inventoryBin.update({
      where: { id: targetBin.id },
      data: {
        productName: shopProduct.masterProduct?.name || shopProduct.localName || targetBin.productName,
        status: deriveBinStatusFromQuantity(quantityValue),
        quantityLabel: quantityValue <= 0 ? "খালি" : `${quantityValue} পিস`,
      },
    });
  }
}

const ZONE_COUNT_INCLUDE = { _count: { select: { racks: true, shelves: true, bins: true } } } as const;

export class PrismaInventoryRepository implements InventoryRepository {
  async findOwnerShop(shopId: string) {
    return prisma.shop.findUnique({
      where: { id: shopId },
      select: { id: true, shopCode: true, shopName: true, status: true },
    });
  }

  async getMode(shopId: string) {
    const setting = await (prisma as any).shopInventorySetting.findUnique({ where: { shopId } });
    return { mode: setting?.mode ?? "GENERAL", configured: Boolean(setting) };
  }

  async saveMode(shopId: string, mode: string) {
    const setting = await (prisma as any).shopInventorySetting.upsert({
      where: { shopId },
      update: { mode },
      create: { shopId, mode },
    });
    return { id: setting.id, shopId: setting.shopId, mode: setting.mode };
  }

  async getCounts(shopId: string) {
    const [zoneCount, rackCount, shelfCount, binCount] = await Promise.all([
      (prisma as any).inventoryZone.count({ where: { shopId } }),
      (prisma as any).inventoryRack.count({ where: { shopId } }),
      (prisma as any).inventoryShelf.count({ where: { shopId } }),
      (prisma as any).inventoryBin.count({ where: { shopId } }),
    ]);

    return { zoneCount, rackCount, shelfCount, binCount };
  }

  async countAttentionBins(shopId: string) {
    return (prisma as any).inventoryBin.count({ where: { shopId, status: { in: ["LOW", "EXPIRED"] } } });
  }

  async listAttentionBins(shopId: string): Promise<InventoryBinRecord[]> {
    return (prisma as any).inventoryBin.findMany({
      where: { shopId, status: { in: ["LOW", "EXPIRED"] } },
      orderBy: [{ updatedAt: "desc" }],
      take: 20,
    });
  }

  async listGeneralStoreProducts(shopId: string): Promise<ShopProductSummary[]> {
    return (prisma as any).shopProduct.findMany({
      where: { shopId },
      include: {
        masterProduct: {
          select: { id: true, sku: true, name: true, packageSize: true, suggestedPrice: true, price: true },
        },
      },
      orderBy: [{ createdAt: "asc" }],
    });
  }

  async resolveShopProductByIdentifier(shopId: string, identifier: string): Promise<ShopProductSummary | null> {
    return resolveShopProductTx(prisma, shopId, identifier);
  }

  async reconcileAndListStockMovements(shopId: string, shopProductId: string, limit: number) {
    if (shopProductId) {
      await (prisma as any).$transaction(async (tx: any) => {
        await reconcileProductStockAndBins(tx, shopId, shopProductId);
      });
    }

    const whereCondition: any = { shopId };
    if (shopProductId) {
      whereCondition.shopProductId = shopProductId;
    }

    return (prisma as any).stockMovement.findMany({
      where: whereCondition,
      orderBy: [{ createdAt: "desc" }, { id: "desc" }],
      take: limit,
    });
  }

  async addStockMovement(params: {
    shopId: string;
    productId: string;
    action: "ADD" | "DAMAGE";
    quantity: number;
    purchasePrice: number | null;
    reference: string | null;
    note: string | null;
    createdByUserId: string;
  }) {
    return (prisma as any).$transaction(async (tx: any) => {
      const shopProduct = await resolveShopProductTx(tx, params.shopId, params.productId);

      if (!shopProduct) {
        throw new ProductNotFoundInShopError();
      }

      const stockBefore = Number(shopProduct.openingStock ?? 0);
      const nextStock = roundQuantity(params.action === "ADD" ? stockBefore + params.quantity : stockBefore - params.quantity);

      const updated = await tx.shopProduct.update({
        where: { id: shopProduct.id },
        data: {
          openingStock: nextStock,
          ...(params.action === "ADD" && params.purchasePrice != null ? { purchasePrice: params.purchasePrice } : {}),
        },
        include: {
          masterProduct: {
            select: { id: true, sku: true, name: true, packageSize: true, suggestedPrice: true, price: true },
          },
        },
      });

      const movement = await recordStockMovement(tx, {
        shopId: params.shopId,
        shopProductId: shopProduct.id,
        masterProductId: shopProduct.masterProductId,
        movementType: params.action === "ADD" ? "MANUAL_ADD" : "MANUAL_REDUCE",
        quantityDelta: params.action === "ADD" ? params.quantity : -params.quantity,
        stockBefore,
        stockAfter: nextStock,
        purchasePrice: params.action === "ADD" && params.purchasePrice != null ? params.purchasePrice : normalizeMoney(updated.purchasePrice),
        salePrice: normalizeMoney(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price),
        referenceType: params.action === "ADD" ? "MANUAL" : "DAMAGE",
        referenceNo: params.reference,
        note: params.note || (params.action === "ADD" ? "Stock added manually." : "Damaged stock removed."),
        createdByUserId: params.createdByUserId,
      });

      await reconcileProductStockAndBins(tx, params.shopId, shopProduct.id);

      return { updated, movement };
    });
  }

  async getLayoutTree(shopId: string): Promise<LayoutTreeZone[]> {
    const zones = await (prisma as any).inventoryZone.findMany({
      where: { shopId },
      include: {
        racks: {
          orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
          include: {
            shelves: {
              orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
              include: {
                bins: {
                  orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
                  include: { items: true },
                },
              },
            },
          },
        },
      },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
    });

    return zones;
  }

  async listZones(shopId: string): Promise<InventoryZoneRecord[]> {
    return (prisma as any).inventoryZone.findMany({
      where: { shopId },
      include: ZONE_COUNT_INCLUDE,
      orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
    });
  }

  async findZoneByName(shopId: string, name: string) {
    return (prisma as any).inventoryZone.findFirst({ where: { shopId, name }, select: { id: true } });
  }

  async createZone(shopId: string, data: { name: string; subtitle: string; icon: string }): Promise<InventoryZoneRecord> {
    const nextSortOrder = await (prisma as any).inventoryZone.count({ where: { shopId } });

    return (prisma as any).inventoryZone.create({
      data: { shopId, ...data, sortOrder: nextSortOrder },
      include: ZONE_COUNT_INCLUDE,
    });
  }

  async findZoneById(shopId: string, id: string): Promise<InventoryZoneRecord | null> {
    return (prisma as any).inventoryZone.findFirst({ where: { id, shopId } });
  }

  async updateZone(id: string, data: { name?: string; subtitle?: string | null; icon?: string | null }): Promise<InventoryZoneRecord> {
    return (prisma as any).inventoryZone.update({ where: { id }, data });
  }

  async deleteZone(id: string): Promise<void> {
    await (prisma as any).inventoryZone.delete({ where: { id } });
  }

  async listRacks(shopId: string, zoneId?: string): Promise<InventoryRackRecord[]> {
    return (prisma as any).inventoryRack.findMany({
      where: { shopId, ...(zoneId ? { zoneId } : {}) },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
    });
  }

  async createRack(params: {
    shopId: string;
    zoneId: string;
    zoneName: string;
    name: string;
    note: string | null;
    shelfCount: number;
    binsPerShelf: number;
    autoGenerate: boolean;
  }) {
    const nextRackSortOrder = await (prisma as any).inventoryRack.count({ where: { shopId: params.shopId, zoneId: params.zoneId } });

    return (prisma as any).$transaction(async (tx: any) => {
      const rack = await tx.inventoryRack.create({
        data: {
          shopId: params.shopId,
          zoneId: params.zoneId,
          name: params.name,
          note: params.note,
          shelfCount: params.shelfCount,
          totalBins: params.shelfCount * params.binsPerShelf,
          usedBins: 0,
          sortOrder: nextRackSortOrder,
        },
      });

      const shelves: InventoryShelfRecord[] = [];
      const bins: InventoryBinRecord[] = [];

      if (params.autoGenerate) {
        for (let shelfIndex = 0; shelfIndex < params.shelfCount; shelfIndex += 1) {
          const shelfName = `${params.name} - Shelf ${shelfIndex + 1}`;
          const shelf = await tx.inventoryShelf.create({
            data: {
              shopId: params.shopId,
              zoneId: params.zoneId,
              rackId: rack.id,
              name: shelfName,
              totalBins: params.binsPerShelf,
              usedBins: 0,
              sortOrder: shelfIndex,
            },
          });

          shelves.push(shelf);

          for (let binIndex = 0; binIndex < params.binsPerShelf; binIndex += 1) {
            const binCode = `${params.zoneName.charAt(0).toUpperCase()}-${params.name.replace(/\s+/g, "").slice(-1).toUpperCase()}-S${shelfIndex + 1}-B${binIndex + 1}`;
            const bin = await tx.inventoryBin.create({
              data: {
                shopId: params.shopId,
                zoneId: params.zoneId,
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
  }

  async findRackById(shopId: string, id: string): Promise<InventoryRackRecord | null> {
    return (prisma as any).inventoryRack.findFirst({ where: { id, shopId } });
  }

  async findRackByIdInZone(shopId: string, zoneId: string, id: string): Promise<InventoryRackRecord | null> {
    return (prisma as any).inventoryRack.findFirst({ where: { id, zoneId, shopId } });
  }

  async updateRack(id: string, data: { name?: string; note?: string | null }): Promise<InventoryRackRecord> {
    return (prisma as any).inventoryRack.update({ where: { id }, data });
  }

  async deleteRack(id: string): Promise<void> {
    await (prisma as any).inventoryRack.delete({ where: { id } });
  }

  async listShelves(shopId: string, zoneId?: string, rackId?: string): Promise<InventoryShelfRecord[]> {
    return (prisma as any).inventoryShelf.findMany({
      where: { shopId, ...(zoneId ? { zoneId } : {}), ...(rackId ? { rackId } : {}) },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
    });
  }

  async createShelf(params: { shopId: string; zoneId: string; rackId: string; serializedName: string }): Promise<InventoryShelfRecord> {
    const nextSortOrder = await (prisma as any).inventoryShelf.count({ where: { shopId: params.shopId, rackId: params.rackId } });

    return (prisma as any).$transaction(async (tx: any) => {
      const shelf = await tx.inventoryShelf.create({
        data: {
          shopId: params.shopId,
          zoneId: params.zoneId,
          rackId: params.rackId,
          name: params.serializedName,
          sortOrder: nextSortOrder,
        },
      });

      await tx.inventoryRack.update({ where: { id: params.rackId }, data: { shelfCount: { increment: 1 } } });

      return shelf;
    });
  }

  async findShelfById(shopId: string, id: string): Promise<(InventoryShelfRecord & { name: string }) | null> {
    return (prisma as any).inventoryShelf.findFirst({ where: { id, shopId } });
  }

  async updateShelf(id: string, data: { name: string }): Promise<InventoryShelfRecord> {
    return (prisma as any).inventoryShelf.update({ where: { id }, data });
  }

  async deleteShelf(id: string, rackId: string): Promise<void> {
    await (prisma as any).$transaction([
      (prisma as any).inventoryShelf.delete({ where: { id } }),
      (prisma as any).inventoryRack.update({ where: { id: rackId }, data: { shelfCount: { decrement: 1 } } }),
    ]);
  }

  async listBins(shopId: string, zoneId?: string, rackId?: string, shelfId?: string): Promise<InventoryBinRecord[]> {
    return (prisma as any).inventoryBin.findMany({
      where: {
        shopId,
        ...(zoneId ? { zoneId } : {}),
        ...(rackId ? { rackId } : {}),
        ...(shelfId ? { shelfId } : {}),
      },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
    });
  }

  async createBin(params: {
    shopId: string;
    zoneId: string;
    rackId: string;
    shelfId: string;
    code: string;
    productName: string | null;
    status: string;
    quantityLabel: string;
    daysLabel: string;
  }): Promise<InventoryBinRecord> {
    const nextSortOrder = await (prisma as any).inventoryBin.count({ where: { shopId: params.shopId, shelfId: params.shelfId } });

    return (prisma as any).inventoryBin.create({
      data: { ...params, sortOrder: nextSortOrder },
    });
  }

  async findBinById(shopId: string, id: string): Promise<InventoryBinRecord | null> {
    return (prisma as any).inventoryBin.findFirst({ where: { id, shopId } });
  }

  async updateBin(id: string, data: { code: string; status: string; quantityLabel: string | null; daysLabel: string }): Promise<InventoryBinRecord> {
    return (prisma as any).inventoryBin.update({ where: { id }, data });
  }

  async deleteBin(id: string): Promise<void> {
    await (prisma as any).inventoryBin.delete({ where: { id } });
  }

  async createPlacements(shopId: string, items: CreatePlacementItem[]): Promise<PlacementResult[]> {
    return (prisma as any).$transaction(async (tx: any) => {
      const results: PlacementResult[] = [];

      for (const item of items) {
        const bin = await tx.inventoryBin.findFirst({
          where: { id: item.binId, shopId, zoneId: item.zoneId, rackId: item.rackId, shelfId: item.shelfId },
        });

        if (!bin) {
          throw new PlacementBinNotFoundError();
        }

        let purchaseItem: any = null;
        if (item.purchaseItemId) {
          purchaseItem = await tx.purchaseItem.findFirst({
            where: { id: item.purchaseItemId, masterProductId: item.masterProductId, purchase: { shopId } },
            include: { masterProduct: { select: { name: true } } },
          });

          if (!purchaseItem) {
            throw new PlacementPurchaseItemNotFoundError();
          }
        }

        const placement = await tx.inventoryBinItem.create({
          data: {
            shopId,
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
            daysLabel: item.expiryDate ? "মেয়াদ সেট" : "নতুন স্টক",
          },
        });

        if (bin.status === "EMPTY") {
          await tx.inventoryRack.update({ where: { id: item.rackId }, data: { usedBins: { increment: 1 } } });
          await tx.inventoryShelf.update({ where: { id: item.shelfId }, data: { usedBins: { increment: 1 } } });
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
  }
}
