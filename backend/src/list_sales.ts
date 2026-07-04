import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const todayStart = new Date('2026-07-04T00:00:00.000Z');
  const todayEnd = new Date('2026-07-04T23:59:59.999Z');

  const sales = await prisma.customerSale.findMany({
    where: {
      saleDate: {
        gte: todayStart,
        lte: todayEnd,
      }
    },
    include: {
      customer: true,
      items: {
        include: {
          masterProduct: true,
        }
      }
    },
    orderBy: { createdAt: 'desc' },
  });
  console.log('--- TODAY DATABASE SALES COUNT:', sales.length);
  for (const s of sales) {
    console.log(`Sale ID: ${s.id}, Date: ${s.saleDate.toISOString()}, Total: ${s.totalAmount}, Paid: ${s.paidAmount}, Due: ${s.dueAmount}`);
    console.log(`Customer: ${s.customer?.name} (${s.customer?.mobile})`);
    for (const item of s.items) {
      console.log(`  - Item: ${item.masterProduct?.name}, Qty: ${item.quantity}, Price: ${item.salePrice}`);
    }
  }
}

main().catch(console.error).finally(() => prisma.$disconnect());
