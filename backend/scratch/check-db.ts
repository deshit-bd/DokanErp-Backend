import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  const sales = await prisma.customerSale.findMany();
  const purchases = await prisma.purchase.findMany();
  const expenses = await prisma.expense.findMany();
  const shopProducts = await prisma.shopProduct.findMany();
  const customerSalesItems = await prisma.customerSaleItem.findMany();

  const shops = await prisma.shop.findMany();
  console.log("Shops count:", shops.length);
  for (const shop of shops) {
    const shopSales = await prisma.customerSale.findMany({ where: { shopId: shop.id } });
    const shopPurchases = await prisma.purchase.findMany({ where: { shopId: shop.id } });
    const shopExpenses = await prisma.expense.findMany({ where: { shopId: shop.id } });
    console.log(`Shop ID: ${shop.id}`);
    console.log(`  Sales count: ${shopSales.length}, total:`, shopSales.reduce((sum, s) => sum + Number(s.totalAmount), 0));
    console.log(`  Purchases count: ${shopPurchases.length}, total:`, shopPurchases.reduce((sum, p) => sum + Number(p.totalAmount), 0));
    console.log(`  Expenses count: ${shopExpenses.length}, total:`, shopExpenses.reduce((sum, e) => sum + Number(e.amount), 0));
    if (shopPurchases.length > 0) {
      console.log(`  Purchases:`, shopPurchases.map(p => ({ date: p.purchaseDate, amount: p.totalAmount })));
    }
    if (shopSales.length > 0) {
      console.log(`  Sales:`, shopSales.map(s => ({ date: s.saleDate, amount: s.totalAmount })));
    }
  }

  console.log("Expenses count:", expenses.length);
  if (expenses.length > 0) {
    console.log("Expenses sample:", expenses.slice(0, 3).map(e => ({
      id: e.id,
      amount: e.amount,
      expenseDate: e.expenseDate,
      status: e.status
    })));
  }

  console.log("ShopProducts count:", shopProducts.length);
  console.log("CustomerSalesItems count:", customerSalesItems.length);
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
