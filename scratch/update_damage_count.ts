import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function run() {
  const shopId = "cmrfvgi9n01a00t9vp2qtoosx"; // Sakib's shop 'deshit'
  const ownerId = "cmrfvgi81019y0t9vtl0ov4oz"; // Owner 'sakib'

  console.log("Updating damage products count to exactly 20...");

  // Fetch shop products for deshit
  const shopProducts = await prisma.shopProduct.findMany({
    where: { shopId },
  });

  // Clear existing damage stock movements
  await prisma.stockMovement.deleteMany({
    where: { shopId, movementType: "DAMAGE" },
  });

  // Create damage records for exactly 20 products
  const damageMovementsToCreate = [];
  const limit = Math.min(20, shopProducts.length);

  for (let i = 0; i < limit; i++) {
    const shopProd = shopProducts[i];
    const purchasePrice = Number(shopProd.purchasePrice ?? 80);
    const salePrice = Number(shopProd.salePrice ?? 100);

    damageMovementsToCreate.push({
      shopId,
      shopProductId: shopProd.id,
      masterProductId: shopProd.masterProductId!,
      movementType: "DAMAGE",
      quantityDelta: -2, // Decreased by 2
      stockBefore: 50,
      stockAfter: 48,
      purchasePrice,
      salePrice,
      unitPrice: salePrice,
      referenceType: "MANUAL_ADJUSTMENT",
      note: "নষ্ট পণ্য (ত্রুটিযুক্ত)",
      createdByUserId: ownerId,
    });
  }

  console.log(`Inserting ${damageMovementsToCreate.length} damage records...`);
  await prisma.stockMovement.createMany({
    data: damageMovementsToCreate,
  });

  const damageCount = await prisma.stockMovement.count({
    where: { shopId, movementType: "DAMAGE" },
  });

  console.log(`Verification complete. Total damage products: ${damageCount}`);
  await prisma.$disconnect();
}

run();
