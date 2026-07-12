const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function main() {
  const customerId = "cmqw8h8o9003glx9fsnajo23e";
  const shopId = "cmqtek0us0002lxj6zzrnqalp";
  const amount = 100;

  console.log("Starting mock payment transaction...");
  try {
    const result = await prisma.$transaction(async (tx) => {
      const createdPayment = await tx.customerPayment.create({
        data: {
          shopId,
          customerId,
          amount,
          paymentMethod: "CASH",
          paidAt: new Date(),
        },
      });

      console.log("Created Payment:", createdPayment.id);

      // Update customer sales from oldest to newest to reduce their individual due amounts
      let remainingPayment = amount;
      const unpaidSales = await tx.customerSale.findMany({
        where: {
          customerId,
          shopId,
          dueAmount: { gt: 0 },
          status: "ACTIVE",
        },
        orderBy: { saleDate: "asc" },
      });

      console.log("Found unpaid sales:", unpaidSales.length);

      for (const sale of unpaidSales) {
        if (remainingPayment <= 0) break;
        const due = Number(sale.dueAmount);
        const allocation = Math.min(remainingPayment, due);

        console.log(`Allocating ${allocation} to sale ${sale.id} (due before: ${due})`);

        await tx.customerSale.update({
          where: { id: sale.id },
          data: {
            paidAmount: { increment: allocation },
            dueAmount: { decrement: allocation },
          },
        });

        remainingPayment -= allocation;
      }

      const createdLedger = await tx.customerLedger.create({
        data: {
          shopId,
          customerId,
          customerPaymentId: createdPayment.id,
          entryType: "PAYMENT",
          referenceNo: "TEST-PAY",
          debit: 0,
          credit: amount,
          entryDate: new Date(),
        },
      });

      console.log("Created Ledger entry:", createdLedger.id);
      return { createdPayment, createdLedger };
    });

    console.log("Mock payment completed successfully!", result);
  } catch (error) {
    console.error("Mock payment failed:", error);
  }
}

main()
  .catch((e) => console.error(e))
  .finally(() => prisma.$disconnect());
