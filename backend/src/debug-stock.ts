import { prisma } from "./config/prisma";

async function main() {
  const barcode = "8940000000006"; // PRAN Litchi Drink 125ml barcode from screenshot
  console.log("Searching for product with barcode:", barcode);

  const barcodeRecord = await (prisma as any).masterProductBarcode.findFirst({
    where: { barcode },
    include: {
      masterProduct: {
        include: {
          shopProducts: true,
          inventoryBinItems: true,
        }
      }
    }
  });

  if (!barcodeRecord) {
    console.log("No product barcode record found!");
    return;
  }

  const mp = barcodeRecord.masterProduct;
  console.log("MasterProduct:", { id: mp.id, name: mp.name, sku: mp.sku });
  console.log("ShopProducts:", mp.shopProducts.map((sp: any) => ({
    id: sp.id,
    shopId: sp.shopId,
    openingStock: sp.openingStock,
    salePrice: sp.salePrice,
    purchasePrice: sp.purchasePrice,
  })));

  const binItems = await (prisma as any).inventoryBinItem.findMany({
    where: { masterProductId: mp.id },
  });
  console.log("InventoryBinItems:", binItems.map((bi: any) => ({
    id: bi.id,
    shopId: bi.shopId,
    quantity: bi.quantity,
    purchasePrice: bi.purchasePrice,
    salePrice: bi.salePrice,
    batchNo: bi.batchNo,
  })));

  const stockMovements = await (prisma as any).stockMovement.findMany({
    where: { masterProductId: mp.id },
    orderBy: { createdAt: "desc" },
  });
  console.log("StockMovements:", stockMovements.map((sm: any) => ({
    id: sm.id,
    movementType: sm.movementType,
    quantityDelta: sm.quantityDelta,
    stockBefore: sm.stockBefore,
    stockAfter: sm.stockAfter,
    note: sm.note,
    createdAt: sm.createdAt,
  })));
}

main().catch(console.error).finally(() => prisma.$disconnect());
