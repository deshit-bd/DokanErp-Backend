import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const shopProducts = await prisma.shopProduct.findMany({
    where: { shopId: 'cmr0gdhu7005kw8g06c2lngfc' },
    include: { masterProduct: true }
  });
  console.log('--- PRODUCTS count:', shopProducts.length);
  for (const sp of shopProducts) {
    console.log(`ID: ${sp.id}, LocalName: ${sp.localName}, MasterName: ${sp.masterProduct?.name}, Stock: ${sp.openingStock}, Price: ${sp.salePrice}`);
  }
}

main().catch(console.error).finally(() => prisma.$disconnect());
