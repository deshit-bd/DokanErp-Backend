import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function run() {
  const start = Date.now();
  console.log("Fetching shop products...");
  try {
    const shopProducts = await prisma.shopProduct.findMany({
      where: { shopId: 'cmrfvgi9n01a00t9vp2qtoosx' },
      include: {
        masterProduct: true,
        approvalRequest: true,
      }
    });
    console.log(`SUCCESS: Fetched ${shopProducts.length} rows in ${Date.now() - start}ms`);
  } catch (err: any) {
    console.error("FAILED to fetch:", err);
  } finally {
    await prisma.$disconnect();
  }
}

run();
