import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
async function main() {
  const sales = await prisma.customerSale.findMany({
    where: {
      shopId: "cmr0gdhu7005kw8g06c2lngfc",
      dueAmount: { gt: 0 }
    }
  });
  console.log("Due sales count:", sales.length);
  for (const s of sales) {
    console.log(`Sale ID: ${s.id}, totalAmount: ${s.totalAmount}, dueAmount: ${s.dueAmount}, status: ${s.status}, date: ${s.saleDate}`);
  }
}
main().finally(() => prisma.$disconnect());
