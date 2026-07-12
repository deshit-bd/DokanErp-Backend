import { ensureGeneralInventoryBin } from "../routes/purchases";
import {
  roundQuantity,
  normalizeMoney,
} from "./stock-movement";

export async function reconcileProductStockAndBins(
  tx: any,
  shopId: string,
  shopProductId: string,
) {
  // 1. Fetch shopProduct details
  const shopProduct = await tx.shopProduct.findFirst({
    where: { id: shopProductId, shopId },
    include: {
      masterProduct: {
        select: {
          id: true,
          name: true,
          sku: true,
          price: true,
          suggestedPrice: true,
        },
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

  // 2. Reconcile Stock Movements (Self-healing history)
  const oldestMovement = await tx.stockMovement.findFirst({
    where: {
      shopId,
      shopProductId,
    },
    orderBy: { createdAt: "asc" },
  });

  if (oldestMovement) {
    const stockBefore = Number(oldestMovement.stockBefore ?? 0);
    if (stockBefore > 0) {
      // Check if there is any movement before this one
      const count = await tx.stockMovement.count({
        where: {
          shopId,
          shopProductId,
          createdAt: { lt: oldestMovement.createdAt },
        },
      });

      if (count === 0) {
        // Create initial stock movement
        const initialDate = new Date(oldestMovement.createdAt.getTime() - 60000); // 1 minute before
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
  } else {
    // No movements exist at all, but product has stock > 0
    if (actualStock > 0) {
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
  }

  // 3. Reconcile Bin Items
  const binItems = await tx.inventoryBinItem.findMany({
    where: {
      shopId,
      masterProductId,
    },
    orderBy: [{ createdAt: "asc" }, { id: "asc" }], // FIFO sorting for deduction
  });

  const totalBinQty = binItems.reduce(
    (sum: number, item: any) => sum + Number(item.quantity ?? 0),
    0,
  );

  if (totalBinQty !== actualStock) {
    if (totalBinQty > actualStock) {
      // Too much stock in bins (e.g. manual reduction was not applied to bins)
      let remainingToDeduct = roundQuantity(totalBinQty - actualStock);
      const touchedBinIds = new Set<string>();

      for (const binItem of binItems) {
        if (remainingToDeduct <= 0) {
          break;
        }

        const binQty = Number(binItem.quantity ?? 0);
        if (binQty <= 0) {
          continue;
        }

        const toDeduct = Math.min(binQty, remainingToDeduct);
        const newQty = roundQuantity(binQty - toDeduct);
        remainingToDeduct = roundQuantity(remainingToDeduct - toDeduct);
        touchedBinIds.add(binItem.binId);

        if (newQty <= 0) {
          await tx.inventoryBinItem.delete({
            where: { id: binItem.id },
          });
        } else {
          await tx.inventoryBinItem.update({
            where: { id: binItem.id },
            data: { quantity: newQty },
          });
        }
      }

      // Update touched bins
      for (const binId of touchedBinIds) {
        const totalBinQtyAgg = await tx.inventoryBinItem.aggregate({
          where: { binId },
          _sum: { quantity: true },
        });
        const quantityValue = Number(totalBinQtyAgg._sum.quantity ?? 0);
        await tx.inventoryBin.update({
          where: { id: binId },
          data: {
            status: quantityValue <= 0 ? "EMPTY" : quantityValue < 10 ? "LOW" : "FULL",
            quantityLabel: quantityValue <= 0 ? "খালি" : `${quantityValue} পিস`,
          },
        });
      }
    } else {
      // Missing stock in bins (e.g. manual addition was not applied to bins)
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
          purchasePrice: normalizeMoney(
            shopProduct.purchasePrice ?? shopProduct.masterProduct?.price ?? null,
          ),
          salePrice: normalizeMoney(
            shopProduct.salePrice ??
              shopProduct.masterProduct?.suggestedPrice ??
              shopProduct.masterProduct?.price ??
              null,
          ),
          notes: "Reconciliation stock adjustment.",
        },
      });

      const totalBinQtyAgg = await tx.inventoryBinItem.aggregate({
        where: { binId: targetBin.id },
        _sum: { quantity: true },
      });
      const quantityValue = Number(totalBinQtyAgg._sum.quantity ?? 0);
      await tx.inventoryBin.update({
        where: { id: targetBin.id },
        data: {
          productName:
            shopProduct.masterProduct?.name ||
            shopProduct.localName ||
            targetBin.productName,
          status: quantityValue <= 0 ? "EMPTY" : quantityValue < 10 ? "LOW" : "FULL",
          quantityLabel: quantityValue <= 0 ? "খালি" : `${quantityValue} পিস`,
        },
      });
    }
  }
}
