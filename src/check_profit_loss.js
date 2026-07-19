const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function main() {
  const shopId = "cmr0gdhu7005kw8g06c2lngfc";
  const shop = await prisma.shop.findUnique({ where: { id: shopId } });
  if (!shop) {
    console.log("No shop found");
    return;
  }
  console.log(`=== SHOP: ${shop.name} (${shop.id}) ===`);

  const now = new Date();
  const start = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
  const end = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999);

  const [sales, refunds, expenses] = await Promise.all([
    prisma.customerSale.findMany({
      where: {
        shopId: shop.id,
        status: "ACTIVE",
        saleDate: { gte: start, lte: end },
      },
      include: {
        items: true,
      }
    }),
    prisma.customerSale.findMany({
      where: {
        shopId: shop.id,
        status: "ACTIVE",
        saleDate: { gte: start, lte: end },
      },
      select: { refundAmount: true },
    }),
    prisma.expense.findMany({
      where: {
        shopId: shop.id,
        status: "PAID",
        expenseDate: { gte: start, lte: end },
      },
    }),
  ]);

  console.log("\n=== SALES FOR TODAY ===");
  console.log(sales.map(s => ({
    id: s.id,
    invoiceNo: s.invoiceNo,
    totalAmount: s.totalAmount,
    costOfGoodsSold: s.costOfGoodsSold,
    refundAmount: s.refundAmount,
    saleDate: s.saleDate,
    items: s.items.map(i => ({ name: i.productName, qty: i.quantity, price: i.price, buyingPrice: i.buyingPrice }))
  })));

  console.log("\n=== EXPENSES FOR TODAY ===");
  console.log(expenses.map(e => ({
    id: e.id,
    category: e.category,
    amount: e.amount,
    description: e.description,
    expenseDate: e.expenseDate,
  })));

  const totalSales = sales.reduce((sum, s) => sum + Number(s.totalAmount), 0);
  const costOfGoodsSold = sales.reduce((sum, s) => sum + Number(s.costOfGoodsSold), 0);
  const returns = refunds.reduce((sum, r) => sum + Number(r.refundAmount ?? 0), 0);
  const operatingExpenses = expenses.reduce((sum, e) => sum + Number(e.amount), 0);

  console.log("\n=== COMPUTED SUMMARY ===");
  console.log("Total Sales:", totalSales);
  console.log("Cost of Goods Sold (cogs):", costOfGoodsSold);
  console.log("Returns:", returns);
  console.log("Operating Expenses:", operatingExpenses);
  console.log("Total Cost (COGS + Expenses):", costOfGoodsSold + operatingExpenses);
  console.log("Net Profit:", (totalSales - returns) - (costOfGoodsSold + operatingExpenses));
}

main()
  .catch((e) => console.error(e))
  .finally(() => prisma.$disconnect());
