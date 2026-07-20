import { PrismaClient, ShopProductSource } from "@prisma/client";

const prisma = new PrismaClient();

async function run() {
  console.log("Starting fast shop product link sync...");
  
  // Clear any existing ShopProduct entries to prevent unique constraint conflicts
  await prisma.shopProduct.deleteMany({});

  // Fetch the first 200 master products
  const keepProducts = await prisma.masterProduct.findMany({
    take: 200,
    orderBy: { createdAt: "asc" },
  });

  const shops = await prisma.shop.findMany();
  console.log(`Preparing batch insert of ${keepProducts.length} products for ${shops.length} shops...`);

  const insertData = [];
  for (const shop of shops) {
    for (const master of keepProducts) {
      insertData.push({
        shopId: shop.id,
        masterProductId: master.id,
        source: ShopProductSource.MASTER,
        purchasePrice: master.price ? Number(master.price) * 0.85 : 80,
        salePrice: master.price ? Number(master.price) : 100,
        openingStock: 100,
        localName: master.name,
        localCategory: "General",
        localUnit: "pcs",
      });
    }
  }

  console.log(`Executing batch createMany for ${insertData.length} records...`);
  const result = await prisma.shopProduct.createMany({
    data: insertData,
    skipDuplicates: true,
  });

  console.log(`Successfully created ${result.count} ShopProduct entries in a single batch!`);

  const totalMaster = await prisma.masterProduct.count();
  const totalShop = await prisma.shopProduct.count();
  console.log(`Database sync complete. Total Master Products: ${totalMaster}, Total Shop Products: ${totalShop}`);

  await prisma.$disconnect();
}

run();
