const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function buildCustomerFinanceSummary(customerId, shopId) {
  const ledgerEntries = await prisma.customerLedger.findMany({
    where: { customerId, shopId },
    select: { debit: true, credit: true, entryType: true },
  });

  const totalDebit = ledgerEntries.reduce((sum, entry) => sum + Number(entry.debit ?? 0), 0);
  const totalCredit = ledgerEntries.reduce((sum, entry) => sum + Number(entry.credit ?? 0), 0);

  const totalSales = ledgerEntries
    .filter((entry) => entry.entryType === "SALE")
    .reduce((sum, entry) => sum + Number(entry.debit ?? 0), 0);

  const totalPaid = ledgerEntries
    .filter((entry) => entry.entryType === "PAYMENT")
    .reduce((sum, entry) => sum + Number(entry.credit ?? 0), 0);

  const due = Math.max(0, totalDebit - totalCredit);

  return {
    totalSales,
    totalPaid,
    due,
  };
}

async function main() {
  const customerId = "cmqw8h8o9003glx9fsnajo23e";
  const shopId = "cmqtek0us0002lxj6zzrnqalp";
  const summary = await buildCustomerFinanceSummary(customerId, shopId);
  console.log("Summary result:", summary);
}

main()
  .catch((e) => console.error(e))
  .finally(() => prisma.$disconnect());
