import { PrismaClient, ShopProductSource } from "@prisma/client";

const prisma = new PrismaClient();

async function run() {
  const shops = await prisma.shop.findMany();
  const masterProducts = await prisma.masterProduct.findMany();

  console.log(`Linking ${masterProducts.length} master products to ${shops.length} shops...`);

  let count = 0;
  for (const shop of shops) {
    for (const master of masterProducts) {
      // Determine demo prices
      let purchasePrice = 50;
      let salePrice = 75;

      if (master.name.toLowerCase().includes("juice")) {
        purchasePrice = 80;
        salePrice = 120;
      } else if (master.name.toLowerCase().includes("chips")) {
        purchasePrice = 15;
        salePrice = 25;
      } else if (master.name.toLowerCase().includes("box")) {
        purchasePrice = 450;
        salePrice = 590;
      }

      await prisma.shopProduct.upsert({
        where: {
          shopId_masterProductId: {
            shopId: shop.id,
            masterProductId: master.id,
          },
        },
        update: {},
        create: {
          shopId: shop.id,
          masterProductId: master.id,
          source: ShopProductSource.MASTER,
          purchasePrice,
          salePrice,
          openingStock: 100,
          localName: master.name,
          localCategory: "General",
          localUnit: "pcs",
        },
      });
      count++;
    }
  }

  console.log(`Successfully created/updated ${count} ShopProduct entries!`);
  await prisma.$disconnect();
}

run();
