const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const shopCount = await prisma.shop.count();
  const productCount = await prisma.shopProduct.count();
  const masterCount = await prisma.masterProduct.count();
  const binItemCount = await prisma.inventoryBinItem.count();
  const purchaseCount = await prisma.purchase.count();

  console.log("Counts:", {
    shopCount,
    productCount,
    masterCount,
    binItemCount,
    purchaseCount
  });

  const shopProducts = await prisma.shopProduct.findMany({
    include: {
      masterProduct: true
    }
  });
  console.log("Shop Products:", shopProducts);

  const binItems = await prisma.inventoryBinItem.findMany();
  console.log("Inventory Bin Items:", binItems);

  await prisma.$disconnect();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
