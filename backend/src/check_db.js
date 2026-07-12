const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

async function main() {
  const customer = await prisma.customer.findFirst({
    where: { name: { contains: "Sajib", mode: "insensitive" } },
  });

  if (!customer) {
    console.log("Customer Sajib not found");
    return;
  }

  console.log("=== CUSTOMER ===");
  console.log(customer);

  const sales = await prisma.customerSale.findMany({
    where: { customerId: customer.id },
  });

  console.log("\n=== SALES ===");
  console.log(sales);

  const payments = await prisma.customerPayment.findMany({
    where: { customerId: customer.id },
  });

  console.log("\n=== PAYMENTS ===");
  console.log(payments);

  const ledger = await prisma.customerLedger.findMany({
    where: { customerId: customer.id },
    orderBy: { entryDate: "asc" },
  });

  console.log("\n=== LEDGER ===");
  console.log(ledger);
}

main()
  .catch((e) => console.error(e))
  .finally(() => prisma.$disconnect());
