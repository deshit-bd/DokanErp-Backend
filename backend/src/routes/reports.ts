import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

type ReportRange = "today" | "week" | "month" | "year" | "all";

function getRangeBounds(range: ReportRange, source = new Date()) {
  const now = new Date(source);
  const start = new Date(now);
  const end = new Date(now);

  if (range === "today") {
    start.setHours(0, 0, 0, 0);
    end.setHours(23, 59, 59, 999);
    return { start, end };
  }

  if (range === "week") {
    start.setDate(now.getDate() - 6);
    start.setHours(0, 0, 0, 0);
    end.setHours(23, 59, 59, 999);
    return { start, end };
  }

  if (range === "year") {
    start.setMonth(0, 1);
    start.setHours(0, 0, 0, 0);
    end.setMonth(11, 31);
    end.setHours(23, 59, 59, 999);
    return { start, end };
  }

  if (range === "all") {
    return {
      start: new Date(0),
      end: new Date(now.getFullYear() + 100, 11, 31, 23, 59, 59, 999),
    };
  }

  start.setDate(1);
  start.setHours(0, 0, 0, 0);
  end.setMonth(now.getMonth() + 1, 0);
  end.setHours(23, 59, 59, 999);
  return { start, end };
}

function getHourlySlots() {
  return [
    { hour: "8am", sales: 0 },
    { hour: "10am", sales: 0 },
    { hour: "12pm", sales: 0 },
    { hour: "2pm", sales: 0 },
    { hour: "4pm", sales: 0 },
    { hour: "6pm", sales: 0 },
    { hour: "8pm", sales: 0 },
  ];
}

function mapHourToSlot(hour: number) {
  if (hour < 10) return "8am";
  if (hour < 12) return "10am";
  if (hour < 14) return "12pm";
  if (hour < 16) return "2pm";
  if (hour < 18) return "4pm";
  if (hour < 20) return "6pm";
  return "8pm";
}

function getPreviousRangeBounds(range: ReportRange, start: Date, end: Date) {
  if (range === "all") {
    return { start: new Date(0), end: new Date(0) };
  }
  const rangeMs = end.getTime() - start.getTime() + 1;
  const prevEnd = new Date(start.getTime() - 1);
  const prevStart = new Date(prevEnd.getTime() - rangeMs + 1);
  return { start: prevStart, end: prevEnd };
}

function getTrendBuckets(range: ReportRange, start: Date) {
  if (range === "today") {
    return [
      { key: "08", label: "8am" },
      { key: "10", label: "10am" },
      { key: "12", label: "12pm" },
      { key: "14", label: "2pm" },
      { key: "16", label: "4pm" },
      { key: "18", label: "6pm" },
      { key: "20", label: "8pm" },
    ];
  }

  if (range === "week") {
    const dayNames = ["রবি", "সোম", "মঙ্গল", "বুধ", "বৃহ", "শুক্র", "শনি"];
    return Array.from({ length: 7 }, (_, index) => {
      const date = new Date(start);
      date.setDate(start.getDate() + index);
      return {
        key: date.toISOString().slice(0, 10),
        label: dayNames[date.getDay()],
      };
    });
  }

  if (range === "year" || range === "all") {
    const monthNames = ["জানু", "ফেব", "মার্চ", "এপ্রি", "মে", "জুন", "জুল", "আগ", "সেপ", "অক্ট", "নভে", "ডিসে"];
    return Array.from({ length: 12 }, (_, index) => ({
      key: String(index),
      label: monthNames[index],
    }));
  }

  const lastDay = new Date(start.getFullYear(), start.getMonth() + 1, 0).getDate();
  const bucketDays = Array.from(new Set([1, 5, 10, 15, 20, 25, lastDay])).sort((a, b) => a - b);
  return bucketDays.map((day) => ({
    key: String(day),
    label: `${day}`,
  }));
}

function getTrendKey(range: ReportRange, date: Date) {
  if (range === "today") {
    if (date.getHours() < 10) return "08";
    if (date.getHours() < 12) return "10";
    if (date.getHours() < 14) return "12";
    if (date.getHours() < 16) return "14";
    if (date.getHours() < 18) return "16";
    if (date.getHours() < 20) return "18";
    return "20";
  }

  if (range === "week") {
    return date.toISOString().slice(0, 10);
  }

  if (range === "year" || range === "all") {
    return String(date.getMonth());
  }

  const day = date.getDate();
  if (day <= 1) return "1";
  if (day <= 5) return "5";
  if (day <= 10) return "10";
  if (day <= 15) return "15";
  if (day <= 20) return "20";
  if (day <= 25) return "25";
  return String(new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate());
}

function getAgingBucketKey(daysOutstanding: number) {
  if (daysOutstanding <= 7) return "0_7";
  if (daysOutstanding <= 15) return "8_15";
  if (daysOutstanding <= 30) return "16_30";
  return "31_plus";
}

async function loadPurchaseDataset(shopId: string, start: Date, end: Date) {
  const purchases = await prisma.purchase.findMany({
    where: {
      shopId,
      status: "APPROVED",
      purchaseDate: {
        gte: start,
        lte: end,
      },
    },
    include: {
      supplier: {
        select: {
          id: true,
          name: true,
        },
      },
      items: {
        include: {
          masterProduct: {
            select: {
              name: true,
            },
          },
        },
      },
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
      name: purchase.supplier?.name || "সরবরাহকারী ছাড়া",
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

  return {
    purchases,
    totalPurchases: Math.round(totalPurchases),
    totalPaid: Math.round(totalPaid),
    totalDue: Math.round(totalDue),
    paymentBuckets,
    supplierMap,
    productMap,
  };
}

async function loadSalesDataset(shopId: string, start: Date, end: Date) {
  const sales = await prisma.customerSale.findMany({
    where: {
      shopId,
      status: "ACTIVE",
      saleDate: {
        gte: start,
        lte: end,
      },
    },
    include: {
      items: {
        include: {
          masterProduct: {
            select: {
              name: true,
            },
          },
        },
      },
    },
  });

  const allSaleItems = sales.flatMap((sale) => sale.items);
  const uniqueMasterProductIds = [...new Set(allSaleItems.map((item) => item.masterProductId))];
  const [shopProducts, purchaseItems] = uniqueMasterProductIds.length
    ? await Promise.all([
        prisma.shopProduct.findMany({
          where: {
            shopId,
            masterProductId: {
              in: uniqueMasterProductIds,
            },
          },
          select: {
            masterProductId: true,
            purchasePrice: true,
          },
        }),
        prisma.purchaseItem.findMany({
          where: {
            masterProductId: {
              in: uniqueMasterProductIds,
            },
            purchase: {
              shopId,
              status: "APPROVED",
              purchaseDate: {
                lte: end,
              },
            },
          },
          select: {
            masterProductId: true,
            purchasePrice: true,
            purchase: {
              select: {
                purchaseDate: true,
              },
            },
          },
          orderBy: [
            {
              purchase: {
                purchaseDate: "desc",
              },
            },
          ],
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

  const totalSales = sales.reduce((sum, sale) => sum + Number(sale.totalAmount), 0);
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

async function requireReportAccess(request: Parameters<typeof getAuthenticatedUser>[0]): Promise<any> {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN", "SHOP_OWNER", "SALESMAN"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to view reports." },
    };
  }

  const shopId =
    auth.payload.shopId ??
    (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") ??
    ((request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "");

  if (!shopId) {
    return {
      status: 400,
      body: { message: "shopId is required for report operations." },
    };
  }

  if (["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role) && auth.payload.shopId && auth.payload.shopId !== shopId) {
    return {
      status: 403,
      body: { message: "You can only view reports for your own shop." },
    };
  }

  return { auth, shopId };
}

// 1. GET /dashboard
router.get("/dashboard", async (request, response) => {
  try {
    const context = await requireReportAccess(request);

    if (isAuthError(context)) {
      return sendAuthError(response, context);
    }

    const shopId = context.shopId;
    const rangeParam = typeof request.query.range === "string" ? request.query.range.trim() : "month";
    const range: ReportRange = ["today", "week", "month", "year"].includes(rangeParam) ? (rangeParam as ReportRange) : "month";
    const { start, end } = getRangeBounds(range);
    const previousRange = getPreviousRangeBounds(range, start, end);

    const [
      currentSalesData,
      previousSalesData,
      purchases,
      expenses,
      customerLedgerGroups,
      supplierLedgerGroups,
      shopProducts,
    ] = await Promise.all([
      loadSalesDataset(shopId, start, end),
      loadSalesDataset(shopId, previousRange.start, previousRange.end),
      prisma.purchase.findMany({
        where: {
          shopId,
          status: "APPROVED",
          purchaseDate: {
            gte: start,
            lte: end,
          },
        },
        select: { totalAmount: true },
      }),
      prisma.expense.findMany({
        where: {
          shopId,
          status: "PAID",
          expenseDate: {
            gte: start,
            lte: end,
          },
        },
        select: { amount: true },
      }),
      prisma.customerLedger.groupBy({
        by: ["customerId"],
        where: { shopId },
        _sum: { debit: true, credit: true },
      }),
      prisma.supplierLedger.groupBy({
        by: ["supplierId"],
        where: { shopId },
        _sum: { debit: true, credit: true },
      }),
      prisma.shopProduct.findMany({
        where: { shopId },
        select: {
          openingStock: true,
          lowStockLimit: true,
        },
      }),
    ]);

    const sales = currentSalesData.sales;
    const totalSales = currentSalesData.totalSales;
    const totalPurchases = purchases.reduce((sum, item) => sum + Number(item.totalAmount), 0);
    const totalExpenses = expenses.reduce((sum, item) => sum + Number(item.amount), 0);
    const costOfGoodsSold = currentSalesData.costOfGoodsSold;
    const profit = Math.max(0, totalSales - costOfGoodsSold - totalExpenses);
    const previousSalesTotal = previousSalesData.totalSales;
    const paymentBucketTotal = currentSalesData.paymentBuckets.cash
      + currentSalesData.paymentBuckets.bkash
      + currentSalesData.paymentBuckets.nagad
      + currentSalesData.paymentBuckets.card
      + currentSalesData.paymentBuckets.due
      + currentSalesData.paymentBuckets.other;

    const receivable = customerLedgerGroups.reduce(
      (sum, entry) => sum + Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)),
      0
    );
    const payable = supplierLedgerGroups.reduce(
      (sum, entry) => sum + Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)),
      0
    );
    const totalProducts = shopProducts.length;
    const lowStockCount = shopProducts.filter(
      (p) => Number(p.openingStock ?? 0) > 0 && Number(p.openingStock ?? 0) < Number(p.lowStockLimit ?? 0)
    ).length;

    const paymentMethods = [
      {
        method: "CASH",
        amount: Math.round(currentSalesData.paymentBuckets.cash + currentSalesData.paymentBuckets.other),
        percentage:
          paymentBucketTotal > 0
            ? Math.round(((currentSalesData.paymentBuckets.cash + currentSalesData.paymentBuckets.other) / paymentBucketTotal) * 100)
            : 0,
      },
      {
        method: "BKASH",
        amount: Math.round(currentSalesData.paymentBuckets.bkash + currentSalesData.paymentBuckets.nagad + currentSalesData.paymentBuckets.card),
        percentage:
          paymentBucketTotal > 0
            ? Math.round(((currentSalesData.paymentBuckets.bkash + currentSalesData.paymentBuckets.nagad + currentSalesData.paymentBuckets.card) / paymentBucketTotal) * 100)
            : 0,
      },
      {
        method: "DUE",
        amount: Math.round(currentSalesData.paymentBuckets.due),
        percentage: paymentBucketTotal > 0 ? Math.round((currentSalesData.paymentBuckets.due / paymentBucketTotal) * 100) : 0,
      },
    ];

    const trendBuckets = getTrendBuckets(range, start);
    const trendMap = new Map(trendBuckets.map((bucket) => [bucket.key, 0]));
    for (const sale of sales) {
      const key = getTrendKey(range, sale.saleDate);
      trendMap.set(key, (trendMap.get(key) || 0) + Number(sale.totalAmount));
    }
    const trend = trendBuckets.map((bucket) => ({
      date: bucket.label,
      sales: Math.round(trendMap.get(bucket.key) || 0),
    }));
    const salesChangePct =
      previousSalesTotal > 0
        ? Math.round(((totalSales - previousSalesTotal) / previousSalesTotal) * 100)
        : totalSales > 0
          ? 100
          : 0;

    // Query real top selling products from CustomerSaleItem
    const topProductsList = Array.from(currentSalesData.productSalesMap.values())
      .sort((a, b) => b.value - a.value)
      .slice(0, 3)
      .map((item, index) => ({
        rank: index + 1,
        name: item.name,
        sales: `${Math.round(item.qty)}টি`,
        value: Math.round(item.value),
      }));

    const topProducts = topProductsList;

    return response.json({
      summary: {
        sales: Math.round(totalSales),
        profit: Math.round(profit),
        purchases: Math.round(totalPurchases),
        expenses: Math.round(totalExpenses),
        purchaseCount: purchases.length,
        receivable: Math.round(receivable),
        payable: Math.round(payable),
        lowStockCount,
        totalProducts,
        salesGrowthPercent: salesChangePct,
      },
      trend,
      trendSummary: {
        currentTotal: Math.round(totalSales),
        previousTotal: Math.round(previousSalesTotal),
        changePct: salesChangePct,
        direction: salesChangePct >= 0 ? "up" : "down",
      },
      paymentMethods,
      meta: {
        range,
        startDate: start,
        endDate: end,
        generatedAt: new Date(),
      },
      topProducts,
    });
  } catch (error) {
    console.error("Failed to load reports dashboard.", error);
    return response.status(503).json({ message: "Reports dashboard could not be loaded." });
  }
});

// 2. GET /sales/daily
router.get("/sales/daily", async (request, response) => {
  try {
    const context = await requireReportAccess(request);

    if (isAuthError(context)) {
      return sendAuthError(response, context);
    }

    const shopId = context.shopId;
    const dateParam = typeof request.query.date === "string" ? request.query.date.trim() : "";

    const targetDate = dateParam ? new Date(dateParam) : new Date();
    const startOfDay = new Date(targetDate);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(targetDate);
    endOfDay.setHours(23, 59, 59, 999);

    const daySales = await prisma.customerSale.findMany({
      where: {
        shopId,
        status: "ACTIVE",
        saleDate: {
          gte: startOfDay,
          lte: endOfDay,
        },
      },
      include: {
        items: {
          include: {
            masterProduct: {
              select: {
                name: true,
              },
            },
          },
        },
      },
    });

    const totalSales = daySales.reduce((sum, s) => sum + Number(s.totalAmount), 0);
    const transactionCount = daySales.length;
    const averageOrderValue = transactionCount > 0 ? Math.round(totalSales / transactionCount) : 0;

    const allSaleItems = daySales.flatMap((sale) => sale.items);
    const uniqueMasterProductIds = [...new Set(allSaleItems.map((item) => item.masterProductId))];
    const shopProducts = uniqueMasterProductIds.length
      ? await prisma.shopProduct.findMany({
          where: {
            shopId,
            masterProductId: {
              in: uniqueMasterProductIds,
            },
          },
          select: {
            masterProductId: true,
            purchasePrice: true,
          },
        })
      : [];

    const purchasePriceMap = new Map(
      shopProducts.map((product) => [product.masterProductId, Number(product.purchasePrice ?? 0)])
    );

    let profit = 0;
    const productSalesMap = new Map<string, { name: string; qty: number; value: number }>();

    for (const item of allSaleItems) {
      const quantity = Number(item.quantity);
      const salePrice = Number(item.salePrice);
      const lineTotal = Number(item.totalAmount);
      const costPrice = Number(item.purchasePrice ?? purchasePriceMap.get(item.masterProductId) ?? salePrice * 0.7);

      profit += (salePrice - costPrice) * quantity;

      const productKey = item.masterProductId;
      const existing = productSalesMap.get(productKey) || {
        name: item.masterProduct?.name || "অজানা পণ্য",
        qty: 0,
        value: 0,
      };

      existing.qty += quantity;
      existing.value += lineTotal;
      productSalesMap.set(productKey, existing);
    }

    const hourlyTrend = getHourlySlots();
    for (const sale of daySales) {
      const slot = hourlyTrend.find((entry) => entry.hour === mapHourToSlot(sale.saleDate.getHours()));
      if (slot) {
        slot.sales += Math.round(Number(sale.totalAmount));
      }
    }

    const topProducts = Array.from(productSalesMap.values())
      .sort((a, b) => b.value - a.value)
      .slice(0, 5)
      .map((item, index) => ({
        rank: index + 1,
        name: item.name,
        salesCount: Math.round(item.qty),
        salesLabel: `${Math.round(item.qty)}টি বিক্রয়`,
        value: Math.round(item.value),
      }));

    const paymentBuckets = daySales.reduce(
      (acc, sale) => {
        const amount = Number(sale.totalAmount);
        const method = (sale.paymentMethod || "CASH").toUpperCase();

        if (method === "DUE") {
          acc.due += amount;
        } else if (method === "BKASH" || method === "NAGAD") {
          acc.wallet += amount;
        } else {
          acc.cash += amount;
        }

        return acc;
      },
      { cash: 0, wallet: 0, due: 0 }
    );

    const paymentMethods = [
      {
        method: "CASH",
        label: "নগদ",
        amount: Math.round(paymentBuckets.cash),
        percentage: totalSales > 0 ? Math.round((paymentBuckets.cash / totalSales) * 100) : 0,
      },
      {
        method: "WALLET",
        label: "bKash/Nagad",
        amount: Math.round(paymentBuckets.wallet),
        percentage: totalSales > 0 ? Math.round((paymentBuckets.wallet / totalSales) * 100) : 0,
      },
      {
        method: "DUE",
        label: "বাকি",
        amount: Math.round(paymentBuckets.due),
        percentage: totalSales > 0 ? Math.round((paymentBuckets.due / totalSales) * 100) : 0,
      },
    ];

    return response.json({
      summary: {
        sales: Math.round(totalSales),
        profit: Math.max(0, Math.round(profit)),
        count: transactionCount,
        average: averageOrderValue,
      },
      hourlyTrend,
      topProducts,
      paymentMethods,
      meta: {
        date: startOfDay,
      },
    });
  } catch (error) {
    console.error("Failed to load daily sales report.", error);
    return response.status(503).json({ message: "Daily sales report could not be loaded." });
  }
});

// 3. GET /profit-loss
router.get("/purchases/summary", async (request, response) => {
  try {
    const context = await requireReportAccess(request);

    if (isAuthError(context)) {
      return sendAuthError(response, context);
    }

    const shopId = context.shopId;
    const rangeParam = typeof request.query.range === "string" ? request.query.range.trim() : "month";
    const range: ReportRange = ["today", "week", "month", "year"].includes(rangeParam) ? (rangeParam as ReportRange) : "month";
    const { start, end } = getRangeBounds(range);
    const previousRange = getPreviousRangeBounds(range, start, end);

    const [currentPurchaseData, previousPurchaseData] = await Promise.all([
      loadPurchaseDataset(shopId, start, end),
      loadPurchaseDataset(shopId, previousRange.start, previousRange.end),
    ]);

    const trendBuckets = getTrendBuckets(range, start);
    const trendMap = new Map(trendBuckets.map((bucket) => [bucket.key, 0]));
    for (const purchase of currentPurchaseData.purchases) {
      const key = getTrendKey(range, purchase.purchaseDate);
      trendMap.set(key, (trendMap.get(key) || 0) + Number(purchase.totalAmount));
    }

    const trend = trendBuckets.map((bucket) => ({
      date: bucket.label,
      amount: Math.round(trendMap.get(bucket.key) || 0),
    }));

    const previousTotal = previousPurchaseData.totalPurchases;
    const currentTotal = currentPurchaseData.totalPurchases;
    const changePct =
      previousTotal > 0
        ? Math.round(((currentTotal - previousTotal) / previousTotal) * 100)
        : currentTotal > 0
          ? 100
          : 0;

    const paymentTotal =
      currentPurchaseData.paymentBuckets.cash +
      currentPurchaseData.paymentBuckets.wallet +
      currentPurchaseData.paymentBuckets.due;

    const paymentMethods = [
      {
        method: "CASH",
        label: "নগদ/ব্যাংক",
        amount: Math.round(currentPurchaseData.paymentBuckets.cash),
        percentage: paymentTotal > 0 ? Math.round((currentPurchaseData.paymentBuckets.cash / paymentTotal) * 100) : 0,
      },
      {
        method: "WALLET",
        label: "bKash/Nagad/Card",
        amount: Math.round(currentPurchaseData.paymentBuckets.wallet),
        percentage: paymentTotal > 0 ? Math.round((currentPurchaseData.paymentBuckets.wallet / paymentTotal) * 100) : 0,
      },
      {
        method: "DUE",
        label: "বাকি",
        amount: Math.round(currentPurchaseData.paymentBuckets.due),
        percentage: paymentTotal > 0 ? Math.round((currentPurchaseData.paymentBuckets.due / paymentTotal) * 100) : 0,
      },
    ];

    const topSuppliers = Array.from(currentPurchaseData.supplierMap.values())
      .sort((a, b) => b.amount - a.amount)
      .slice(0, 5)
      .map((supplier, index) => ({
        rank: index + 1,
        name: supplier.name,
        amount: Math.round(supplier.amount),
        count: supplier.count,
      }));

    const topProducts = Array.from(currentPurchaseData.productMap.values())
      .sort((a, b) => b.value - a.value)
      .slice(0, 5)
      .map((item, index) => ({
        rank: index + 1,
        name: item.name,
        quantity: Math.round(item.qty),
        value: Math.round(item.value),
      }));

    return response.json({
      summary: {
        totalPurchases: currentTotal,
        purchaseCount: currentPurchaseData.purchases.length,
        averagePurchase:
          currentPurchaseData.purchases.length > 0 ? Math.round(currentTotal / currentPurchaseData.purchases.length) : 0,
        paidAmount: currentPurchaseData.totalPaid,
        dueAmount: currentPurchaseData.totalDue,
      },
      trend,
      trendSummary: {
        currentTotal,
        previousTotal,
        changePct,
        direction: changePct >= 0 ? "up" : "down",
      },
      paymentMethods,
      topSuppliers,
      topProducts,
      meta: {
        range,
        startDate: start,
        endDate: end,
        generatedAt: new Date(),
      },
    });
  } catch (error) {
    console.error("Failed to load purchase summary report.", error);
    return response.status(503).json({ message: "Purchase summary report could not be loaded." });
  }
});

// 4. GET /dues/summary
router.get("/dues/summary", async (request, response) => {
  try {
    const context = await requireReportAccess(request);

    if (isAuthError(context)) {
      return sendAuthError(response, context);
    }

    const shopId = context.shopId;
    const rangeParam = typeof request.query.range === "string" ? request.query.range.trim() : "month";
    const range: ReportRange = ["today", "week", "month", "year"].includes(rangeParam) ? (rangeParam as ReportRange) : "month";
    const { start, end } = getRangeBounds(range);
    const now = new Date();

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
      prisma.customerLedger.groupBy({
        by: ["customerId"],
        where: { shopId },
        _sum: { debit: true, credit: true },
      }),
      prisma.supplierLedger.groupBy({
        by: ["supplierId"],
        where: { shopId },
        _sum: { debit: true, credit: true },
      }),
      prisma.customerLedger.findMany({
        where: {
          shopId,
          debit: { gt: 0 },
        },
        orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
        select: {
          customerId: true,
          entryDate: true,
        },
      }),
      prisma.supplierLedger.findMany({
        where: {
          shopId,
          debit: { gt: 0 },
        },
        orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
        select: {
          supplierId: true,
          entryDate: true,
        },
      }),
      prisma.customerSale.findMany({
        where: {
          shopId,
          status: "ACTIVE",
          saleDate: {
            gte: start,
            lte: end,
          },
          dueAmount: {
            gt: 0,
          },
        },
        select: {
          customerId: true,
          dueAmount: true,
        },
      }),
      prisma.customerLedger.findMany({
        where: {
          shopId,
          entryType: "PAYMENT",
          customerSaleId: null,
          entryDate: {
            gte: start,
            lte: end,
          },
        },
        select: {
          credit: true,
        },
      }),
      prisma.purchase.findMany({
        where: {
          shopId,
          status: "APPROVED",
          purchaseDate: {
            gte: start,
            lte: end,
          },
          dueAmount: {
            gt: 0,
          },
        },
        select: {
          supplierId: true,
          dueAmount: true,
        },
      }),
      (prisma as any).supplierPayment.findMany({
        where: {
          shopId,
          paidAt: {
            gte: start,
            lte: end,
          },
        },
        select: {
          amount: true,
        },
      }),
    ]);

    const [customers, suppliers] = await Promise.all([
      prisma.customer.findMany({
        where: {
          id: {
            in: customerLedgerGroups.map((entry) => entry.customerId),
          },
        },
        select: {
          id: true,
          name: true,
          mobile: true,
        },
      }),
      prisma.supplier.findMany({
        where: {
          id: {
            in: supplierLedgerGroups.map((entry) => entry.supplierId),
          },
        },
        select: {
          id: true,
          name: true,
          mobile: true,
        },
      }),
    ]);

    const customerMap = new Map(customers.map((customer) => [customer.id, customer]));
    const supplierMap = new Map(suppliers.map((supplier) => [supplier.id, supplier]));
    const lastCustomerDebitMap = new Map<string, Date>();
    const lastSupplierDebitMap = new Map<string, Date>();

    for (const entry of customerDebitEntries) {
      if (!lastCustomerDebitMap.has(entry.customerId)) {
        lastCustomerDebitMap.set(entry.customerId, entry.entryDate);
      }
    }

    for (const entry of supplierDebitEntries) {
      if (!lastSupplierDebitMap.has(entry.supplierId)) {
        lastSupplierDebitMap.set(entry.supplierId, entry.entryDate);
      }
    }

    const customerAgingBuckets = {
      "0_7": 0,
      "8_15": 0,
      "16_30": 0,
      "31_plus": 0,
    };
    const supplierAgingBuckets = {
      "0_7": 0,
      "8_15": 0,
      "16_30": 0,
      "31_plus": 0,
    };

    const topReceivables = customerLedgerGroups
      .map((entry) => {
        const due = Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0));
        const customer = customerMap.get(entry.customerId);
        const lastDebitAt = lastCustomerDebitMap.get(entry.customerId) || null;
        const ageDays = lastDebitAt ? Math.max(0, Math.floor((now.getTime() - lastDebitAt.getTime()) / 86400000)) : 0;
        if (due > 0) {
          customerAgingBuckets[getAgingBucketKey(ageDays)] += due;
        }
        return {
          id: entry.customerId,
          name: customer?.name || "অজানা গ্রাহক",
          mobile: customer?.mobile || "",
          due: Math.round(due),
          ageDays,
          lastDebitAt,
        };
      })
      .filter((entry) => entry.due > 0)
      .sort((a, b) => b.due - a.due)
      .slice(0, 5)
      .map((entry, index) => ({
        rank: index + 1,
        ...entry,
      }));

    const topPayables = supplierLedgerGroups
      .map((entry) => {
        const due = Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0));
        const supplier = supplierMap.get(entry.supplierId);
        const lastDebitAt = lastSupplierDebitMap.get(entry.supplierId) || null;
        const ageDays = lastDebitAt ? Math.max(0, Math.floor((now.getTime() - lastDebitAt.getTime()) / 86400000)) : 0;
        if (due > 0) {
          supplierAgingBuckets[getAgingBucketKey(ageDays)] += due;
        }
        return {
          id: entry.supplierId,
          name: supplier?.name || "অজানা সরবরাহকারী",
          mobile: supplier?.mobile || "",
          due: Math.round(due),
          ageDays,
          lastDebitAt,
        };
      })
      .filter((entry) => entry.due > 0)
      .sort((a, b) => b.due - a.due)
      .slice(0, 5)
      .map((entry, index) => ({
        rank: index + 1,
        ...entry,
      }));

    const totalReceivable = Math.round(
      customerLedgerGroups.reduce((sum, entry) => sum + Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)), 0)
    );
    const totalPayable = Math.round(
      supplierLedgerGroups.reduce((sum, entry) => sum + Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)), 0)
    );
    const customerDueCreated = Math.round(rangedDueSales.reduce((sum, sale) => sum + Number(sale.dueAmount ?? 0), 0));
    const customerDueCollected = Math.round(rangedCustomerCollections.reduce((sum, payment) => sum + Number(payment.credit ?? 0), 0));
    const supplierDueCreated = Math.round(rangedDuePurchases.reduce((sum, purchase) => sum + Number(purchase.dueAmount ?? 0), 0));
    const supplierDuePaid = Math.round(rangedSupplierPayments.reduce((sum: number, payment: any) => sum + Number(payment.amount ?? 0), 0));

    return response.json({
      summary: {
        totalReceivable,
        totalPayable,
        netBalance: Math.round(totalReceivable - totalPayable),
        receivableCustomers: customerLedgerGroups.filter((entry) => Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)) > 0).length,
        payableSuppliers: supplierLedgerGroups.filter((entry) => Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)) > 0).length,
      },
      activity: {
        customerDueCreated,
        customerDueCollected,
        supplierDueCreated,
        supplierDuePaid,
      },
      aging: {
        receivable: [
          { key: "0_7", label: "০-৭ দিন", amount: Math.round(customerAgingBuckets["0_7"]) },
          { key: "8_15", label: "৮-১৫ দিন", amount: Math.round(customerAgingBuckets["8_15"]) },
          { key: "16_30", label: "১৬-৩০ দিন", amount: Math.round(customerAgingBuckets["16_30"]) },
          { key: "31_plus", label: "৩১+ দিন", amount: Math.round(customerAgingBuckets["31_plus"]) },
        ],
        payable: [
          { key: "0_7", label: "০-৭ দিন", amount: Math.round(supplierAgingBuckets["0_7"]) },
          { key: "8_15", label: "৮-১৫ দিন", amount: Math.round(supplierAgingBuckets["8_15"]) },
          { key: "16_30", label: "১৬-৩০ দিন", amount: Math.round(supplierAgingBuckets["16_30"]) },
          { key: "31_plus", label: "৩১+ দিন", amount: Math.round(supplierAgingBuckets["31_plus"]) },
        ],
      },
      topReceivables,
      topPayables,
      meta: {
        range,
        startDate: start,
        endDate: end,
        generatedAt: new Date(),
      },
    });
  } catch (error) {
    console.error("Failed to load due summary report.", error);
    return response.status(503).json({ message: "Due summary report could not be loaded." });
  }
});

// 5. GET /expenses/summary
router.get("/expenses/summary", async (request, response) => {
  try {
    const context = await requireReportAccess(request);

    if (isAuthError(context)) {
      return sendAuthError(response, context);
    }

    const shopId = context.shopId;
    const rangeParam = typeof request.query.range === "string" ? request.query.range.trim() : "month";
    const range: ReportRange = ["today", "week", "month", "year", "all"].includes(rangeParam) ? (rangeParam as ReportRange) : "month";
    const { start, end } = getRangeBounds(range);
    const previousRange = getPreviousRangeBounds(range, start, end);

    const [expenses, previousExpenses] = await Promise.all([
      prisma.expense.findMany({
        where: {
          shopId,
          status: "PAID",
          expenseDate: {
            gte: start,
            lte: end,
          },
        },
        orderBy: [{ expenseDate: "desc" }, { createdAt: "desc" }],
      }),
      prisma.expense.findMany({
        where: {
          shopId,
          status: "PAID",
          expenseDate: {
            gte: previousRange.start,
            lte: previousRange.end,
          },
        },
      }),
    ]);

    const totalExpenses = Math.round(expenses.reduce((sum, item) => sum + Number(item.amount ?? 0), 0));
    const previousTotal = Math.round(previousExpenses.reduce((sum, item) => sum + Number(item.amount ?? 0), 0));
    const expenseCount = expenses.length;
    const averageExpense = expenseCount > 0 ? Math.round(totalExpenses / expenseCount) : 0;
    const highestExpense = Math.round(
      expenses.reduce((max, item) => Math.max(max, Number(item.amount ?? 0)), 0)
    );
    const changePct =
      previousTotal > 0
        ? Math.round(((totalExpenses - previousTotal) / previousTotal) * 100)
        : totalExpenses > 0
          ? 100
          : 0;

    const categoryMap = new Map<string, { amount: number; count: number }>();
    const paymentBuckets = { cash: 0, wallet: 0, bank: 0, other: 0 };
    const trendBuckets = getTrendBuckets(range, start);
    const trendMap = new Map(trendBuckets.map((bucket) => [bucket.key, 0]));

    for (const expense of expenses) {
      const amount = Number(expense.amount ?? 0);
      const category = expense.category || "অন্যান্য";
      const paymentMethod = (expense.paymentMethod || "CASH").toUpperCase();
      const currentCategory = categoryMap.get(category) || { amount: 0, count: 0 };
      currentCategory.amount += amount;
      currentCategory.count += 1;
      categoryMap.set(category, currentCategory);

      if (paymentMethod === "BANK") paymentBuckets.bank += amount;
      else if (paymentMethod === "BKASH" || paymentMethod === "NAGAD" || paymentMethod === "CARD") paymentBuckets.wallet += amount;
      else if (paymentMethod === "CASH") paymentBuckets.cash += amount;
      else paymentBuckets.other += amount;

      const key = getTrendKey(range, expense.expenseDate);
      trendMap.set(key, (trendMap.get(key) || 0) + amount);
    }

    const categories = Array.from(categoryMap.entries())
      .map(([name, value]) => ({
        name,
        amount: Math.round(value.amount),
        count: value.count,
        percentage: totalExpenses > 0 ? Math.round((value.amount / totalExpenses) * 100) : 0,
      }))
      .sort((a, b) => b.amount - a.amount)
      .slice(0, 6);

    const paymentTotal = paymentBuckets.cash + paymentBuckets.wallet + paymentBuckets.bank + paymentBuckets.other;
    const paymentMethods = [
      {
        method: "CASH",
        label: "নগদ",
        amount: Math.round(paymentBuckets.cash),
        percentage: paymentTotal > 0 ? Math.round((paymentBuckets.cash / paymentTotal) * 100) : 0,
      },
      {
        method: "WALLET",
        label: "bKash/Nagad",
        amount: Math.round(paymentBuckets.wallet),
        percentage: paymentTotal > 0 ? Math.round((paymentBuckets.wallet / paymentTotal) * 100) : 0,
      },
      {
        method: "BANK",
        label: "ব্যাংক",
        amount: Math.round(paymentBuckets.bank),
        percentage: paymentTotal > 0 ? Math.round((paymentBuckets.bank / paymentTotal) * 100) : 0,
      },
      {
        method: "OTHER",
        label: "অন্যান্য",
        amount: Math.round(paymentBuckets.other),
        percentage: paymentTotal > 0 ? Math.round((paymentBuckets.other / paymentTotal) * 100) : 0,
      },
    ];

    const trend = trendBuckets.map((bucket) => ({
      date: bucket.label,
      amount: Math.round(trendMap.get(bucket.key) || 0),
    }));

    const recentExpenses = expenses.slice(0, 5).map((expense) => ({
      id: expense.id,
      category: expense.category,
      amount: Math.round(Number(expense.amount ?? 0)),
      expenseDate: expense.expenseDate,
      description: expense.description,
      paymentMethod: expense.paymentMethod,
      status: expense.status,
    }));

    return response.json({
      summary: {
        totalExpenses,
        expenseCount,
        averageExpense,
        highestExpense,
        topCategory: categories[0]?.name || "খরচ নেই",
      },
      trend,
      trendSummary: {
        currentTotal: totalExpenses,
        previousTotal,
        changePct,
        direction: changePct >= 0 ? "up" : "down",
      },
      categories,
      paymentMethods,
      recentExpenses,
      meta: {
        range,
        startDate: start,
        endDate: end,
        generatedAt: new Date(),
      },
    });
  } catch (error) {
    console.error("Failed to load expense summary report.", error);
    return response.status(503).json({ message: "Expense summary report could not be loaded." });
  }
});

// 6. GET /profit-loss
router.get("/profit-loss", async (request, response) => {
  try {
    const context = await requireReportAccess(request);

    if (isAuthError(context)) {
      return sendAuthError(response, context);
    }

    const shopId = context.shopId;
    const rangeParam = typeof request.query.range === "string" ? request.query.range.trim() : "month";
    const startDateParam = typeof request.query.startDate === "string" ? request.query.startDate.trim() : "";
    const endDateParam = typeof request.query.endDate === "string" ? request.query.endDate.trim() : "";
    const hasCustomDateRange = startDateParam.length > 0 && endDateParam.length > 0;
    const now = new Date();

    let range: ReportRange | "custom" = ["today", "week", "month", "year"].includes(rangeParam) ? (rangeParam as ReportRange) : "month";
    let start: Date;
    let end: Date;

    if (hasCustomDateRange) {
      const parsedStart = new Date(`${startDateParam}T00:00:00`);
      const parsedEnd = new Date(`${endDateParam}T23:59:59.999`);

      if (Number.isNaN(parsedStart.getTime()) || Number.isNaN(parsedEnd.getTime()) || parsedStart > parsedEnd) {
        return response.status(400).json({ message: "Invalid custom date range." });
      }

      range = "custom";
      start = parsedStart;
      end = parsedEnd;
    } else {
      const resolvedRange = getRangeBounds(range as ReportRange, now);
      start = resolvedRange.start;
      end = resolvedRange.end;
    }

    const [currentSalesData, refunds, expenses] = await Promise.all([
      loadSalesDataset(shopId, start, end),
      prisma.customerSale.findMany({
        where: {
          shopId,
          status: "ACTIVE",
          saleDate: {
            gte: start,
            lte: end,
          },
        },
        select: { refundAmount: true },
      }),
      prisma.expense.findMany({
        where: {
          shopId,
          status: "PAID",
          expenseDate: {
            gte: start,
            lte: end,
          },
        },
        select: { amount: true },
      }),
    ]);

    const totalSales = currentSalesData.totalSales;
    const purchaseCost = currentSalesData.costOfGoodsSold;
    const operatingExpenses = expenses.reduce((sum, item) => sum + Number(item.amount), 0);
    const costOfGoodsSold = currentSalesData.costOfGoodsSold;
    const returns = Math.round(refunds.reduce((sum, item) => sum + Number(item.refundAmount ?? 0), 0));
    const netSales = Math.max(0, totalSales - returns);
    const grossProfit = netSales - costOfGoodsSold;
    const grossMargin = netSales > 0 ? Math.round((grossProfit / netSales) * 100) : 0;

    const totalCost = costOfGoodsSold + operatingExpenses;
    const netProfit = netSales - totalCost;
    const netMargin = netSales > 0 ? Math.round((netProfit / netSales) * 100) : 0;

    return response.json({
      summary: {
        grossProfit: Math.round(grossProfit),
        grossMargin,
        netProfit: Math.round(netProfit),
        netMargin,
      },
      revenue: {
        totalSales: Math.round(totalSales),
        returns,
        netSales: Math.round(netSales),
      },
      cost: {
        purchaseCost: Math.round(purchaseCost),
        operatingExpenses: Math.round(operatingExpenses),
        totalCost: Math.round(totalCost),
      },
      meta: {
        range,
        startDate: start,
        endDate: end,
        generatedAt: new Date(),
      },
    });
  } catch (error) {
    console.error("Failed to load profit-loss report.", error);
    return response.status(503).json({ message: "Profit-loss report could not be loaded." });
  }
});

// 4. GET /stock-value
router.get("/stock-value", async (request, response) => {
  try {
    const context = await requireReportAccess(request);

    if (isAuthError(context)) {
      return sendAuthError(response, context);
    }

    const shopId = context.shopId;

    const shopProducts = await prisma.shopProduct.findMany({
      where: { shopId },
      include: {
        masterProduct: {
          select: {
            name: true,
            category: {
              select: {
                name: true,
              },
            },
          },
        },
      },
    });

    let totalStockValue = 0;
    const totalProducts = shopProducts.length;
    let lowStock = 0;
    let outOfStock = 0;

    const categoryValues: Record<string, number> = {};

    for (const p of shopProducts) {
      const stock = Number(p.openingStock ?? 0);
      const purchasePrice = Number(p.purchasePrice ?? p.salePrice ?? 0);
      const value = stock * purchasePrice;
      totalStockValue += value;

      if (stock <= 0) {
        outOfStock++;
      } else if (stock <= Number(p.lowStockLimit ?? 5)) {
        lowStock++;
      }

      const catName = p.masterProduct?.category?.name || p.localCategory || "অন্যান্য";
      categoryValues[catName] = (categoryValues[catName] || 0) + value;
    }

    const allCategoriesBreakdown = Object.entries(categoryValues)
      .map(([name, val]) => ({
        name,
        value: Math.round(val),
      }))
      .sort((a, b) => b.value - a.value);

    let categoriesBreakdown: Array<{ name: string; value: number; percentage: number }> = [];
    if (allCategoriesBreakdown.length > 4) {
      const top4 = allCategoriesBreakdown.slice(0, 4);
      const rest = allCategoriesBreakdown.slice(4);
      const restValue = rest.reduce((sum, item) => sum + item.value, 0);
      
      categoriesBreakdown = [
        ...top4.map((c) => ({
          name: c.name,
          value: c.value,
          percentage: totalStockValue > 0 ? Math.round((c.value / totalStockValue) * 100) : 0,
        })),
        {
          name: "অন্যান্য",
          value: Math.round(restValue),
          percentage: totalStockValue > 0 ? Math.round((restValue / totalStockValue) * 100) : 0,
        }
      ];
    } else {
      categoriesBreakdown = allCategoriesBreakdown.map((c) => ({
        name: c.name,
        value: c.value,
        percentage: totalStockValue > 0 ? Math.round((c.value / totalStockValue) * 100) : 0,
      }));
    }

    if (totalStockValue > 0 && categoriesBreakdown.length > 0) {
      const sumPercentage = categoriesBreakdown.reduce((sum, c) => sum + c.percentage, 0);
      if (sumPercentage !== 100 && sumPercentage > 0) {
        let maxIndex = 0;
        for (let i = 1; i < categoriesBreakdown.length; i++) {
          if (categoriesBreakdown[i].percentage > categoriesBreakdown[maxIndex].percentage) {
            maxIndex = i;
          }
        }
        categoriesBreakdown[maxIndex].percentage += (100 - sumPercentage);
      }
    }

    if (totalStockValue === 0 && categoriesBreakdown.length > 0) {
      categoriesBreakdown[0].percentage = 100;
    }

    // Top 5 products by total stock value
    const topProductsList = shopProducts
      .map((p) => {
        const stock = Number(p.openingStock ?? 0);
        const purchasePrice = Number(p.purchasePrice ?? p.salePrice ?? 0);
        const value = stock * purchasePrice;
        return {
          name: p.masterProduct?.name || p.localName || "অজানা পণ্য",
          quantity: Math.round(stock),
          value: Math.round(value),
        };
      })
      .filter((item) => item.quantity > 0)
      .sort((a, b) => b.value - a.value)
      .slice(0, 5)
      .map((item, index) => ({
        rank: index + 1,
        ...item,
      }));

    const now = new Date();
    const masterProductIds = shopProducts
      .map((p) => p.masterProductId)
      .filter((id): id is string => id !== null);

    const saleItems = masterProductIds.length > 0
      ? await prisma.customerSaleItem.findMany({
          where: {
            masterProductId: { in: masterProductIds },
            customerSale: {
              shopId,
              status: "ACTIVE",
            },
          },
          select: {
            masterProductId: true,
            customerSale: {
              select: {
                saleDate: true,
              },
            },
          },
        })
      : [];

    const latestSaleMap = new Map<string, Date>();
    for (const item of saleItems) {
      const saleDate = item.customerSale.saleDate;
      const currentLatest = latestSaleMap.get(item.masterProductId);
      if (!currentLatest || saleDate > currentLatest) {
        latestSaleMap.set(item.masterProductId, saleDate);
      }
    }

    const deadProductsList = shopProducts
      .filter((p) => Number(p.openingStock ?? 0) > 0)
      .map((p) => {
        let daysInactive = 0;
        let lastSoldAt: Date | null = null;
        if (p.masterProductId && latestSaleMap.has(p.masterProductId)) {
          const lastSaleDate = latestSaleMap.get(p.masterProductId)!;
          lastSoldAt = lastSaleDate;
          daysInactive = Math.max(0, Math.floor((now.getTime() - lastSaleDate.getTime()) / (1000 * 60 * 60 * 24)));
        } else {
          daysInactive = Math.max(0, Math.floor((now.getTime() - p.createdAt.getTime()) / (1000 * 60 * 60 * 24)));
        }
        return {
          name: p.masterProduct?.name || p.localName || "অজানা পণ্য",
          quantity: Math.round(Number(p.openingStock ?? 0)),
          value: Math.round(Number(p.openingStock ?? 0) * Number(p.purchasePrice ?? p.salePrice ?? 0)),
          daysInactive,
          lastSoldAt,
        };
      })
      .filter((item) => item.daysInactive >= 100)
      .sort((a, b) => b.daysInactive - a.daysInactive)
      .slice(0, 5)
      .map((item, index) => ({
        rank: index + 1,
        ...item,
      }));

    return response.json({
      summary: {
        totalStockValue: Math.round(totalStockValue),
        totalProducts,
        lowStock,
        outOfStock,
      },
      categories: categoriesBreakdown,
      topProducts: topProductsList,
      deadStock: deadProductsList,
      meta: {
        deadStockThresholdDays: 100,
        generatedAt: new Date(),
      },
    });
  } catch (error) {
    console.error("Failed to load stock value report.", error);
    return response.status(503).json({ message: "Stock value report could not be loaded." });
  }
});

export default router;
