import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function run() {
  console.log("Fetching first 200 master products to keep...");
  const keepProducts = await prisma.masterProduct.findMany({
    take: 200,
    select: { id: true },
    orderBy: { createdAt: "asc" },
  });

  const keepIds = keepProducts.map((p) => p.id);
  console.log(`Keeping ${keepIds.length} products.`);

  console.log("Deleting remaining master products...");
  const deleteResult = await prisma.masterProduct.deleteMany({
    where: {
      id: {
        notIn: keepIds,
      },
    },
  });

  console.log(`Successfully deleted ${deleteResult.count} master products!`);

  // Count remaining products in databases to verify
  const remainingMaster = await prisma.masterProduct.count();
  const remainingShop = await prisma.shopProduct.count();
  console.log({
    remainingMasterProducts: remainingMaster,
    remainingShopProducts: remainingShop,
  });

  await prisma.$disconnect();
}

run();
