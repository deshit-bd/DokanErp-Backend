const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

function mapCustomerMaster(customer) {
  return {
    id: customer.id,
    customerCode: customer.customerCode,
    name: customer.name,
    companyOrPersonName: customer.name,
    mobile: customer.mobile,
    email: customer.email,
    address: customer.address,
    notes: customer.notes,
    createdAt: customer.createdAt,
    updatedAt: customer.updatedAt,
  };
}

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
  const shopId = "cmqtek0us0002lxj6zzrnqalp";
  const customer = await prisma.customer.findFirst({
    where: { name: { contains: "Sajib", mode: "insensitive" } },
    include: {
      ledgerEntries: {
        where: { shopId },
        orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
        take: 1,
      },
    },
  });

  if (!customer) {
    console.log("Sajib not found");
    return;
  }

  const summary = await buildCustomerFinanceSummary(customer.id, shopId);
  const responseObj = {
    ...mapCustomerMaster(customer),
    totalSales: summary.totalSales,
    totalPaid: summary.totalPaid,
    due: summary.due,
  };

  console.log("Mock Response Object:", responseObj);
}

main()
  .catch((e) => console.error(e))
  .finally(() => prisma.$disconnect());
