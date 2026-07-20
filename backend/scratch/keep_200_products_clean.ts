import { PrismaClient, ShopProductSource } from "@prisma/client";

const prisma = new PrismaClient();

async function run() {
  console.log("Clearing all historical transaction tables to prevent foreign key restrict violations...");

  // Delete transaction-dependent records first
  await prisma.customerLedger.deleteMany({});
  await prisma.supplierLedger.deleteMany({});
  await prisma.stockMovement.deleteMany({});
  await prisma.customerSaleItem.deleteMany({});
  await prisma.customerSale.deleteMany({});
  await prisma.customerPayment.deleteMany({});
  await prisma.supplierPayment.deleteMany({});
  await prisma.purchaseReturnItem.deleteMany({});
  await prisma.purchaseReturn.deleteMany({});
  await prisma.purchaseItem.deleteMany({});
  await prisma.purchase.deleteMany({});
  await prisma.expense.deleteMany({});
  await prisma.inAppNotification.deleteMany({});
  await prisma.categoryLog.deleteMany({});
  await prisma.inventoryBinItem.deleteMany({});
  await prisma.inventoryBin.deleteMany({});
  
  // Clear existing ShopProduct links to do a clean recreate
  await prisma.shopProduct.deleteMany({});

  console.log("Fetching first 200 master products to keep...");
  const keepProducts = await prisma.masterProduct.findMany({
    take: 200,
    orderBy: { createdAt: "asc" },
  });

  const keepIds = keepProducts.map((p) => p.id);
  console.log(`Keeping ${keepIds.length} master products.`);

  console.log("Deleting remaining master products...");
  const deleteResult = await prisma.masterProduct.deleteMany({
    where: {
      id: {
        notIn: keepIds,
      },
    },
  });
  console.log(`Successfully deleted ${deleteResult.count} master products.`);

  // Link the kept 200 master products to all active shops
  const shops = await prisma.shop.findMany();
  console.log(`Linking ${keepProducts.length} products to ${shops.length} shops...`);

  let shopProductCount = 0;
  for (const shop of shops) {
    for (const master of keepProducts) {
      await prisma.shopProduct.create({
        data: {
          shopId: shop.id,
          masterProductId: master.id,
          source: ShopProductSource.MASTER,
          purchasePrice: master.price ? Number(master.price) * 0.85 : 80,
          salePrice: master.price ? Number(master.price) : 100,
          openingStock: 100,
          localName: master.name,
          localCategory: "General",
          localUnit: "pcs",
        },
      });
      shopProductCount++;
    }
  }

  console.log(`Successfully created ${shopProductCount} ShopProduct entries for active shops!`);

  const totalMaster = await prisma.masterProduct.count();
  const totalShop = await prisma.shopProduct.count();
  console.log(`Database sync complete. Total Master Products: ${totalMaster}, Total Shop Products: ${totalShop}`);

  await prisma.$disconnect();
}

run();
