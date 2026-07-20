import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: 'postgresql://neondb_owner:npg_rs3epvHMUf4F@ep-patient-king-av0kwu0c.c-11.us-east-1.aws.neon.tech/neondb?sslmode=require',
    },
  },
});

async function main() {
  const shopIds = ['cmr0gdhu7005kw8g06c2lngfc', 'cmrfvgi9n01a00t9vp2qtoosx'];
  const user = await prisma.user.findFirst({ where: { phone: '01762161370' } });

  for (const shopId of shopIds) {
    await prisma.stockMovement.deleteMany({
      where: { shopId, movementType: 'DAMAGE' },
    });

    const shopProducts = await prisma.shopProduct.findMany({
      where: { shopId },
      take: 30,
    });

    if (shopProducts.length < 30) continue;

    const damageData = [];
    const now = new Date('2026-07-20T04:00:00Z');
    const yesterday = new Date('2026-07-19T11:00:00Z');

    // 1. 10 items from 19th July (Device 1)
    for (let i = 0; i < 10; i++) {
      const sp = shopProducts[i];
      const price = Number(sp.salePrice || sp.purchasePrice || 50);
      damageData.push({
        shopId,
        shopProductId: sp.id,
        masterProductId: sp.masterProductId,
        movementType: 'DAMAGE',
        quantityDelta: '-1',
        stockBefore: '50',
        stockAfter: '49',
        purchasePrice: String(sp.purchasePrice || price),
        salePrice: String(sp.salePrice || price),
        unitPrice: String(price),
        referenceType: 'DAMAGE',
        note: 'মেয়াদোত্তীর্ণ (যন্ত্র ১)',
        createdByUserId: user?.id,
        createdAt: yesterday,
      });
    }

    // 2. 10 items from 19th July (Device 2)
    for (let i = 10; i < 20; i++) {
      const sp = shopProducts[i];
      const price = Number(sp.salePrice || sp.purchasePrice || 50);
      damageData.push({
        shopId,
        shopProductId: sp.id,
        masterProductId: sp.masterProductId,
        movementType: 'DAMAGE',
        quantityDelta: '-1',
        stockBefore: '50',
        stockAfter: '49',
        purchasePrice: String(sp.purchasePrice || price),
        salePrice: String(sp.salePrice || price),
        unitPrice: String(price),
        referenceType: 'DAMAGE',
        note: 'ক্ষতিগ্রস্ত (যন্ত্র ২)',
        createdByUserId: user?.id,
        createdAt: yesterday,
      });
    }

    // 3. 10 items from 20th July (Today)
    for (let i = 20; i < 30; i++) {
      const sp = shopProducts[i];
      const price = Number(sp.salePrice || sp.purchasePrice || 50);
      damageData.push({
        shopId,
        shopProductId: sp.id,
        masterProductId: sp.masterProductId,
        movementType: 'DAMAGE',
        quantityDelta: '-1',
        stockBefore: '50',
        stockAfter: '49',
        purchasePrice: String(sp.purchasePrice || price),
        salePrice: String(sp.salePrice || price),
        unitPrice: String(price),
        referenceType: 'DAMAGE',
        note: 'ভাঙা পণ্য (আজকের এন্ট্রি)',
        createdByUserId: user?.id,
        createdAt: now,
      });
    }

    await prisma.stockMovement.createMany({
      data: damageData,
    });

    console.log('Seeded 30 DAMAGE records for shop:', shopId);
  }
}

main().catch(console.error).finally(() => prisma.$disconnect());
