import type { PurchaseDataset, ReportsRepository, SalesDataset } from "@application/reports/ports/reports-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

export class PrismaReportsRepository implements ReportsRepository {
  async loadPurchaseDataset(shopId: string, start: Date, end: Date): Promise<PurchaseDataset> {
    const purchases = await prisma.purchase.findMany({
      where: { shopId, status: "APPROVED", purchaseDate: { gte: start, lte: end } },
      include: {
        supplier: { select: { id: true, name: true } },
        items: { include: { masterProduct: { select: { name: true } } } },
      },
    });

    const totalPurchases = purchases.reduce((sum, purchase) => sum + Number(purchase.totalAmount), 0);
    const totalPaid = purchases.reduce((sum, purchase) => sum + Number(purchase.paidAmount), 0);
    const totalDue = purchases.reduce((sum, purchase) => sum + Number(purchase.dueAmount), 0);

    const paymentBuckets = { cash: 0, wallet: 0, due: 0 };
    const supplierMap = new Map<string, { name: string; amount: number; count: number }>();
    const productMap = new Map<string, { name: string; qty: number; value: number }>();

    for (const purchase of purchases) {
      const method = (purchase.paymentMethod || "CASH").toUpperCase();
      const amount = Number(purchase.totalAmount);

      if (method === "DUE") paymentBuckets.due += amount;
      else if (["BKASH", "NAGAD", "CARD"].includes(method)) paymentBuckets.wallet += amount;
      else paymentBuckets.cash += amount;

      const supplierKey = purchase.supplier?.id || purchase.supplierId || "unknown";
      const supplierCurrent = supplierMap.get(supplierKey) || {
        name: purchase.supplier?.name || "সরবরাহকারী ছাড়া",
        amount: 0,
        count: 0,
      };
      supplierCurrent.amount += amount;
      supplierCurrent.count += 1;
      supplierMap.set(supplierKey, supplierCurrent);

      for (const item of purchase.items) {
        const productKey = item.masterProductId;
        const current = productMap.get(productKey) || {
          name: item.masterProduct?.name || "অজানা পণ্য",
          qty: 0,
          value: 0,
        };
        current.qty += Number(item.quantity);
        current.value += Number(item.totalAmount);
        productMap.set(productKey, current);
      }
    }

    const totalProducts = purchases.reduce((sum, purchase) => {
      return sum + purchase.items.reduce((itemSum, item) => itemSum + Number(item.quantity ?? 0), 0);
    }, 0);

    return {
      purchases,
      totalPurchases: Math.round(totalPurchases),
      totalPaid: Math.round(totalPaid),
      totalDue: Math.round(totalDue),
      totalProducts: Math.round(totalProducts),
      paymentBuckets,
      supplierMap,
      productMap,
    };
  }

  async loadSalesDataset(shopId: string, start: Date, end: Date): Promise<SalesDataset> {
    const sales = await prisma.customerSale.findMany({
      where: { shopId, status: "ACTIVE", saleDate: { gte: start, lte: end } },
      include: { items: { include: { masterProduct: { select: { name: true } } } } },
    });

    const allSaleItems = sales.flatMap((sale) => sale.items);
    const uniqueMasterProductIds = [...new Set(allSaleItems.map((item) => item.masterProductId))];
    const [shopProducts, purchaseItems] = uniqueMasterProductIds.length
      ? await Promise.all([
          prisma.shopProduct.findMany({
            where: { shopId, masterProductId: { in: uniqueMasterProductIds } },
            select: { masterProductId: true, purchasePrice: true },
          }),
          prisma.purchaseItem.findMany({
            where: {
              masterProductId: { in: uniqueMasterProductIds },
              purchase: { shopId, status: "APPROVED", purchaseDate: { lte: end } },
            },
            select: {
              masterProductId: true,
              purchasePrice: true,
              purchase: { select: { purchaseDate: true } },
            },
            orderBy: [{ purchase: { purchaseDate: "desc" } }],
          }),
        ])
      : [[], []];

    const purchasePriceMap = new Map<string, number>();

    for (const item of purchaseItems) {
      if (!purchasePriceMap.has(item.masterProductId)) {
        purchasePriceMap.set(item.masterProductId, Number(item.purchasePrice ?? 0));
      }
    }

    for (const product of shopProducts) {
      if (product.masterProductId && !purchasePriceMap.has(product.masterProductId)) {
        purchasePriceMap.set(product.masterProductId, Number(product.purchasePrice ?? 0));
      }
    }

    const totalSales = sales.reduce((sum, sale) => sum + sale.items.reduce((itemSum, item) => itemSum + Number(item.totalAmount), 0), 0);
    const paymentBuckets = { cash: 0, bkash: 0, nagad: 0, card: 0, due: 0, other: 0 };
    const productSalesMap = new Map<string, { name: string; qty: number; value: number }>();
    let costOfGoodsSold = 0;

    for (const sale of sales) {
      const method = (sale.paymentMethod || "CASH").toUpperCase();
      const amount = Number(sale.totalAmount);

      if (method === "CASH") paymentBuckets.cash += amount;
      else if (method === "BKASH") paymentBuckets.bkash += amount;
      else if (method === "NAGAD") paymentBuckets.nagad += amount;
      else if (method === "CARD") paymentBuckets.card += amount;
      else if (method === "DUE") paymentBuckets.due += amount;
      else paymentBuckets.other += amount;

      for (const item of sale.items) {
        const quantity = Number(item.quantity);
        const salePrice = Number(item.salePrice);
        const lineTotal = Number(item.totalAmount);
        const costPrice = Number(item.purchasePrice ?? purchasePriceMap.get(item.masterProductId) ?? salePrice);

        costOfGoodsSold += costPrice * quantity;

        const productKey = item.masterProductId;
        const current = productSalesMap.get(productKey) || {
          name: item.masterProduct?.name || "অজানা পণ্য",
          qty: 0,
          value: 0,
        };

        current.qty += quantity;
        current.value += lineTotal;
        productSalesMap.set(productKey, current);
      }
    }

    return {
      sales,
      totalSales,
      costOfGoodsSold: Math.round(costOfGoodsSold),
      paymentBuckets,
      productSalesMap,
    };
  }

  async getDashboardRawData(shopId: string, start: Date, end: Date) {
    const [purchases, expenses, customerLedgerGroups, supplierLedgerGroups, shopProducts] = await Promise.all([
      prisma.purchase.findMany({
        where: { shopId, status: "APPROVED", purchaseDate: { gte: start, lte: end } },
        select: { totalAmount: true, paymentMethod: true },
      }),
      prisma.expense.findMany({
        where: { shopId, status: "PAID", expenseDate: { gte: start, lte: end } },
        select: { amount: true },
      }),
      prisma.customerLedger.groupBy({ by: ["customerId"], where: { shopId }, _sum: { debit: true, credit: true } }),
      prisma.supplierLedger.groupBy({ by: ["supplierId"], where: { shopId }, _sum: { debit: true, credit: true } }),
      prisma.shopProduct.findMany({ where: { shopId }, select: { openingStock: true, lowStockLimit: true } }),
    ]);

    return { purchases, expenses, customerLedgerGroups, supplierLedgerGroups, shopProducts };
  }

  async getDailySalesRawData(shopId: string, startOfDay: Date, endOfDay: Date) {
    const daySales = await prisma.customerSale.findMany({
      where: { shopId, status: "ACTIVE", saleDate: { gte: startOfDay, lte: endOfDay } },
      include: { items: { include: { masterProduct: { select: { name: true } } } } },
    });

    const allSaleItems = daySales.flatMap((sale) => sale.items);
    const uniqueMasterProductIds = [...new Set(allSaleItems.map((item) => item.masterProductId))];
    const shopProducts = uniqueMasterProductIds.length
      ? await prisma.shopProduct.findMany({
          where: { shopId, masterProductId: { in: uniqueMasterProductIds } },
          select: { masterProductId: true, purchasePrice: true },
        })
      : [];

    const purchasePriceByMasterProductId = new Map(
      shopProducts.map((product) => [product.masterProductId as string, Number(product.purchasePrice ?? 0)]),
    );

    return { daySales, purchasePriceByMasterProductId };
  }

  async getExpensesInRange(shopId: string, start: Date, end: Date) {
    return prisma.expense.findMany({
      where: { shopId, expenseDate: { gte: start, lte: end } },
      select: { amount: true },
    });
  }

  async getDuesSummaryRawData(shopId: string, start: Date, end: Date) {
    const [
      customerLedgerGroups,
      supplierLedgerGroups,
      customerDebitEntries,
      supplierDebitEntries,
      rangedDueSales,
      rangedCustomerCollections,
      rangedDuePurchases,
      rangedSupplierPayments,
    ] = await Promise.all([
      prisma.customerLedger.groupBy({ by: ["customerId"], where: { shopId }, _sum: { debit: true, credit: true } }),
      prisma.supplierLedger.groupBy({ by: ["supplierId"], where: { shopId }, _sum: { debit: true, credit: true } }),
      prisma.customerLedger.findMany({
        where: { shopId, debit: { gt: 0 } },
        orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
        select: { customerId: true, entryDate: true },
      }),
      prisma.supplierLedger.findMany({
        where: { shopId, debit: { gt: 0 } },
        orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
        select: { supplierId: true, entryDate: true },
      }),
      prisma.customerSale.findMany({
        where: { shopId, status: "ACTIVE", saleDate: { gte: start, lte: end }, dueAmount: { gt: 0 } },
        select: { customerId: true, dueAmount: true },
      }),
      prisma.customerLedger.findMany({
        where: { shopId, entryType: "PAYMENT", customerSaleId: null, entryDate: { gte: start, lte: end } },
        select: { credit: true },
      }),
      prisma.purchase.findMany({
        where: { shopId, status: "APPROVED", purchaseDate: { gte: start, lte: end }, dueAmount: { gt: 0 } },
        select: { supplierId: true, dueAmount: true },
      }),
      (prisma as any).supplierPayment.findMany({
        where: { shopId, paidAt: { gte: start, lte: end } },
        select: { amount: true },
      }),
    ]);

    const [customers, suppliers] = await Promise.all([
      prisma.customer.findMany({
        where: { id: { in: customerLedgerGroups.map((entry) => entry.customerId) } },
        select: { id: true, name: true, mobile: true },
      }),
      prisma.supplier.findMany({
        where: { id: { in: supplierLedgerGroups.map((entry) => entry.supplierId) } },
        select: { id: true, name: true, mobile: true },
      }),
    ]);

    return {
      customerLedgerGroups,
      supplierLedgerGroups,
      customerDebitEntries,
      supplierDebitEntries,
      rangedDueSales,
      rangedCustomerCollections,
      rangedDuePurchases,
      rangedSupplierPayments,
      customers,
      suppliers,
    };
  }

  async getExpenseSummaryRawData(shopId: string, start: Date, end: Date, previousStart: Date, previousEnd: Date) {
    const [expenses, previousExpenses] = await Promise.all([
      prisma.expense.findMany({
        where: { shopId, status: "PAID", expenseDate: { gte: start, lte: end } },
        orderBy: [{ expenseDate: "desc" }, { createdAt: "desc" }],
      }),
      prisma.expense.findMany({
        where: { shopId, status: "PAID", expenseDate: { gte: previousStart, lte: previousEnd } },
      }),
    ]);

    return { expenses, previousExpenses };
  }

  async getProfitLossRawData(shopId: string, start: Date, end: Date) {
    const [refunds, expenses] = await Promise.all([
      prisma.customerSale.findMany({
        where: { shopId, status: "ACTIVE", saleDate: { gte: start, lte: end } },
        select: { refundAmount: true },
      }),
      prisma.expense.findMany({
        where: { shopId, status: "PAID", expenseDate: { gte: start, lte: end } },
        select: { amount: true },
      }),
    ]);

    return { refunds, expenses };
  }

  async getStockValueRawData(shopId: string) {
    const shopProducts = await prisma.shopProduct.findMany({
      where: { shopId },
      include: { masterProduct: { select: { name: true, category: { select: { name: true } } } } },
    });

    const masterProductIds = shopProducts.map((p) => p.masterProductId).filter((id): id is string => id !== null);

    const saleItems = masterProductIds.length
      ? await prisma.customerSaleItem.findMany({
          where: { masterProductId: { in: masterProductIds }, customerSale: { shopId, status: "ACTIVE" } },
          select: { masterProductId: true, customerSale: { select: { saleDate: true } } },
        })
      : [];

    const latestSaleDateByMasterProductId = new Map<string, Date>();
    for (const item of saleItems) {
      const saleDate = item.customerSale.saleDate;
      const currentLatest = latestSaleDateByMasterProductId.get(item.masterProductId);
      if (!currentLatest || saleDate > currentLatest) {
        latestSaleDateByMasterProductId.set(item.masterProductId, saleDate);
      }
    }

    return { shopProducts, latestSaleDateByMasterProductId };
  }
}
