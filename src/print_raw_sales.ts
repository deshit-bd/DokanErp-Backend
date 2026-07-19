import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const sales = await (prisma as any).customerSale.findMany({
    orderBy: { createdAt: 'desc' },
    include: {
      customer: true,
      items: {
        include: {
          masterProduct: true,
        }
      }
    },
    take: 10
  });

  const mapCustomerSaleRecord = (sale: any) => {
    const items = Array.isArray(sale.items) ? sale.items : [];
    const totalQty = items.reduce((sum: number, item: any) => sum + Number(item.quantity ?? 0), 0);
    return {
      id: sale.id,
      customerName: sale.customer?.name ?? null,
      totalAmount: Number(sale.totalAmount ?? 0),
      paidAmount: Number(sale.paidAmount ?? 0),
      dueAmount: Number(sale.dueAmount ?? 0),
      items: items.map((item: any) => ({
        name: item.masterProduct?.name ?? item.productName ?? "",
        quantity: Number(item.quantity ?? 0),
        salePrice: Number(item.salePrice ?? 0),
        purchasePrice: Number(item.purchasePrice || item.salePrice * 0.7),
        totalAmount: Number(item.totalAmount ?? 0),
      })),
    };
  };

  console.log(JSON.stringify(sales.map(mapCustomerSaleRecord), null, 2));
}

main().catch(console.error).finally(() => prisma.$disconnect());
