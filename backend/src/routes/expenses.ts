import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

function normalizeText(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function toMoney(value: unknown) {
  return Number(value ?? 0);
}

type ExpenseSummaryRange = "today" | "week" | "month" | "year" | "all";

function getExpenseRangeBounds(range: ExpenseSummaryRange, source = new Date()) {
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

function getPreviousExpenseRangeBounds(range: ExpenseSummaryRange, start: Date, end: Date) {
  if (range === "all") {
    return { start: new Date(0), end: new Date(0) };
  }
  const rangeMs = end.getTime() - start.getTime() + 1;
  const previousEnd = new Date(start.getTime() - 1);
  const previousStart = new Date(previousEnd.getTime() - rangeMs + 1);
  return { start: previousStart, end: previousEnd };
}

function getExpenseTrendBuckets(range: ExpenseSummaryRange, start: Date) {
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

function getExpenseTrendKey(range: ExpenseSummaryRange, date: Date) {
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

async function resolveDefaultMoneyBoxByType(tx: any, shopId: string, type?: string | null) {
  const normalizedType = typeof type === "string" ? type.trim().toUpperCase() : "";

  if (!normalizedType || !["CASH", "BKASH", "NAGAD"].includes(normalizedType)) {
    return null;
  }

  const existing = await tx.moneyBox.findFirst({
    where: {
      shopId,
      type: normalizedType,
      status: "ACTIVE",
    },
    orderBy: [{ createdAt: "asc" }],
  });

  if (existing) {
    return existing;
  }

  const boxName = normalizedType === "CASH" ? "Cash Box" : (normalizedType === "BKASH" ? "bKash Wallet" : "Nagad Wallet");
  const code = `${normalizedType.toLowerCase()}-${shopId.substring(0, 8)}-${Date.now()}`;

  return tx.moneyBox.create({
    data: {
      shopId,
      boxName,
      code,
      type: normalizedType,
      openingBalance: 0,
      currentBalance: 0,
      status: "ACTIVE",
    },
  });
}

async function resolveDefaultBankAccount(tx: any, shopId: string) {
  const existing = await tx.bankAccount.findFirst({
    where: {
      shopId,
      status: "ACTIVE",
    },
    orderBy: [{ isDefault: "desc" }, { createdAt: "asc" }],
  });

  if (existing) {
    return existing;
  }

  return tx.bankAccount.create({
    data: {
      shopId,
      accountName: "Main Business Account",
      bankName: "Default Bank",
      accountNumber: `default-${shopId.substring(0, 8)}-${Date.now()}`,
      accountType: "CURRENT",
      openingBalance: 0,
      currentBalance: 0,
      status: "ACTIVE",
      isDefault: true,
    },
  });
}

async function requireExpenseContext(request: Parameters<typeof getAuthenticatedUser>[0]): Promise<any> {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN", "SHOP_OWNER"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to manage expenses." },
    };
  }

  const rawShopId =
    auth.payload.shopId ??
    (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") ??
    ((request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "");

  if (!rawShopId) {
    return {
      status: 400,
      body: { message: "shopId is required for expense operations." },
    };
  }

  if (auth.payload.role === "SHOP_OWNER" && auth.payload.shopId && auth.payload.shopId !== rawShopId) {
    return {
      status: 403,
      body: { message: "You can only access expenses for your own shop." },
    };
  }

  const shop = await prisma.shop.findFirst({
    where: {
      OR: [{ id: rawShopId }, { shopCode: rawShopId }],
    },
    select: {
      id: true,
      shopCode: true,
      shopName: true,
    },
  });

  if (!shop) {
    return {
      status: 404,
      body: { message: "Shop not found for the provided shopId/shopCode." },
    };
  }

  return { auth, shop };
}

async function requireExpenseReportContext(request: Parameters<typeof getAuthenticatedUser>[0]): Promise<any> {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN", "SHOP_OWNER", "SALESMAN"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to view expense reports." },
    };
  }

  const rawShopId =
    auth.payload.shopId ??
    (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") ??
    ((request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "");

  if (!rawShopId) {
    return {
      status: 400,
      body: { message: "shopId is required for expense report operations." },
    };
  }

  if (["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role) && auth.payload.shopId && auth.payload.shopId !== rawShopId) {
    return {
      status: 403,
      body: { message: "You can only access expense reports for your own shop." },
    };
  }

  const shop = await prisma.shop.findFirst({
    where: {
      OR: [{ id: rawShopId }, { shopCode: rawShopId }],
    },
    select: {
      id: true,
      shopCode: true,
      shopName: true,
    },
  });

  if (!shop) {
    return {
      status: 404,
      body: { message: "Shop not found for the provided shopId/shopCode." },
    };
  }

  return { auth, shop };
}

function mapExpense(expense: any) {
  return {
    id: expense.id,
    shopId: expense.shopId,
    category: expense.category,
    amount: toMoney(expense.amount),
    expenseDate: expense.expenseDate,
    description: expense.description,
    paymentMethod: expense.paymentMethod,
    moneyBoxId: expense.moneyBoxId,
    bankAccountId: expense.bankAccountId,
    status: expense.status,
    createdAt: expense.createdAt,
    updatedAt: expense.updatedAt,
  };
}

router.get("/summary", async (request, response) => {
  try {
    const context = await requireExpenseReportContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const rangeParam = normalizeText(request.query.range).toLowerCase() || "month";
    const range: ExpenseSummaryRange = ["today", "week", "month", "year", "all"].includes(rangeParam)
      ? (rangeParam as ExpenseSummaryRange)
      : "month";
    const requestedLimit = Number(request.query.limit ?? 100);
    const detailLimit = Number.isFinite(requestedLimit)
      ? Math.min(Math.max(Math.round(requestedLimit), 1), 500)
      : 100;
    const requestedFrom = normalizeText(request.query.from);
    const requestedTo = normalizeText(request.query.to);
    const defaultBounds = getExpenseRangeBounds(range);
    const start = requestedFrom ? new Date(requestedFrom) : defaultBounds.start;
    const end = requestedTo ? new Date(requestedTo) : defaultBounds.end;

    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      return response.status(400).json({ message: "from/to must be valid ISO date strings." });
    }

    const previousRange = getPreviousExpenseRangeBounds(range, start, end);

    const [expenses, previousExpenses] = await Promise.all([
      (prisma as any).expense.findMany({
        where: {
          shopId: context.shop.id,
          expenseDate: {
            gte: start,
            lte: end,
          },
        },
        orderBy: [{ expenseDate: "desc" }, { createdAt: "desc" }],
      }),
      (prisma as any).expense.findMany({
        where: {
          shopId: context.shop.id,
          status: "PAID",
          expenseDate: {
            gte: previousRange.start,
            lte: previousRange.end,
          },
        },
      }),
    ]);

    const paidExpenses = expenses.filter((expense: any) => expense.status === "PAID");
    const totalExpenses = Math.round(paidExpenses.reduce((sum: number, item: any) => sum + Number(item.amount ?? 0), 0));
    const previousTotal = Math.round(previousExpenses.reduce((sum: number, item: any) => sum + Number(item.amount ?? 0), 0));
    const expenseCount = expenses.length;
    const paidCount = paidExpenses.length;
    const pendingCount = expenses.filter((expense: any) => expense.status === "PENDING").length;
    const averageExpense = paidCount > 0 ? Math.round(totalExpenses / paidCount) : 0;
    const highestExpense = Math.round(
      paidExpenses.reduce((max: number, item: any) => Math.max(max, Number(item.amount ?? 0)), 0),
    );
    const changePct =
      previousTotal > 0
        ? Math.round(((totalExpenses - previousTotal) / previousTotal) * 100)
        : totalExpenses > 0
          ? 100
          : 0;

    const categoryMap = new Map<string, { amount: number; count: number }>();
    const paymentBuckets = { cash: 0, wallet: 0, bank: 0, other: 0 };
    const trendBuckets = getExpenseTrendBuckets(range, start);
    const trendMap = new Map(trendBuckets.map((bucket) => [bucket.key, 0]));

    for (const expense of paidExpenses) {
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

      const key = getExpenseTrendKey(range, expense.expenseDate);
      trendMap.set(key, (trendMap.get(key) || 0) + amount);
    }

    const categories = Array.from(categoryMap.entries())
      .map(([name, value]) => ({
        name,
        category: name,
        amount: Math.round(value.amount),
        count: value.count,
        percentage: totalExpenses > 0 ? Math.round((value.amount / totalExpenses) * 100) : 0,
      }))
      .sort((a, b) => b.amount - a.amount);

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
      label: bucket.label,
      date: bucket.label,
      amount: Math.round(trendMap.get(bucket.key) || 0),
    }));
    const detailedExpenses = expenses.slice(0, detailLimit).map(mapExpense);

    return response.json({
      shop: context.shop,
      summary: {
        totalExpenses,
        totalAmount: totalExpenses,
        expenseCount,
        paidCount,
        pendingCount,
        averageExpense,
        highestExpense,
        topCategory: categories[0]?.name || "খরচ নেই",
        topCategoryAmount: categories[0]?.amount || 0,
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
      expenses: detailedExpenses,
      recentExpenses: detailedExpenses.slice(0, 5),
      meta: {
        range,
        startDate: start,
        endDate: end,
        returnedExpenseCount: detailedExpenses.length,
        expenseLimit: detailLimit,
        generatedAt: new Date(),
      },
    });
  } catch (error) {
    console.error("Failed to load expense summary.", error);
    return response.status(503).json({ message: "Expense summary could not be loaded right now." });
  }
});

router.get("/", async (request, response) => {
  try {
    const context = await requireExpenseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const period = normalizeText(request.query.period).toUpperCase() || "TODAY";
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfWeek = new Date(startOfToday);
    startOfWeek.setDate(startOfToday.getDate() - startOfToday.getDay());
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const dateFilter =
      period === "WEEK"
        ? { gte: startOfWeek }
        : period === "MONTH"
          ? { gte: startOfMonth }
          : period === "ALL"
            ? undefined
            : { gte: startOfToday };

    const expenses = await (prisma as any).expense.findMany({
      where: {
        shopId: context.shop.id,
        ...(dateFilter ? { expenseDate: dateFilter } : {}),
      },
      orderBy: [{ expenseDate: "desc" }, { createdAt: "desc" }],
    });

    const allExpenses = await (prisma as any).expense.findMany({
      where: { shopId: context.shop.id },
      orderBy: [{ expenseDate: "desc" }, { createdAt: "desc" }],
    });

    const sumSince = (startDate: Date) =>
      Number(
        allExpenses
          .filter((item: any) => new Date(item.expenseDate) >= startDate)
          .reduce((sum: number, item: any) => sum + Number(item.amount ?? 0), 0)
          .toFixed(2),
      );

    return response.json({
      shop: context.shop,
      summary: {
        today: sumSince(startOfToday),
        week: sumSince(startOfWeek),
        month: sumSince(startOfMonth),
        count: expenses.length,
      },
      expenses: expenses.map(mapExpense),
    });
  } catch (error) {
    console.error("Failed to load expenses.", error);
    return response.status(503).json({ message: "Expenses could not be loaded right now." });
  }
});

router.post("/", async (request, response) => {
  try {
    const context = await requireExpenseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      category?: string;
      amount?: number | string;
      expenseDate?: string | null;
      date?: string | null;
      description?: string | null;
      note?: string | null;
      paymentMethod?: string | null;
      moneyBoxId?: string | null;
      bankAccountId?: string | null;
    };

    const category = normalizeText(body.category);
    const amount = Number(body.amount ?? 0);
    const paymentMethod = normalizeText(body.paymentMethod).toUpperCase() || "CASH";
    const description = normalizeText(body.description ?? body.note) || null;
    const expenseDateRaw = body.expenseDate ?? body.date;
    const expenseDate = expenseDateRaw ? new Date(expenseDateRaw) : new Date();

    if (!category) {
      return response.status(400).json({ message: "Expense category is required." });
    }

    if (!Number.isFinite(amount) || amount <= 0) {
      return response.status(400).json({ message: "Expense amount must be a valid positive number." });
    }

    if (!["CASH", "BKASH", "NAGAD", "BANK"].includes(paymentMethod)) {
      return response.status(400).json({ message: "Payment method must be CASH, BKASH, NAGAD, or BANK." });
    }

    const createdExpense = await prisma.$transaction(async (tx) => {
      const typedTx = tx as any;
      let moneyBoxId: string | null = null;
      let bankAccountId: string | null = null;

      if (paymentMethod === "CASH" || paymentMethod === "BKASH" || paymentMethod === "NAGAD") {
        let moneyBox = body.moneyBoxId
          ? await typedTx.moneyBox.findFirst({
              where: {
                id: body.moneyBoxId,
                shopId: context.shop.id,
                type: paymentMethod,
                status: "ACTIVE",
              },
            })
          : await typedTx.moneyBox.findFirst({
              where: {
                shopId: context.shop.id,
                type: paymentMethod,
                status: "ACTIVE",
              },
              orderBy: [{ createdAt: "asc" }],
            });

        if (!moneyBox) {
          moneyBox = await resolveDefaultMoneyBoxByType(typedTx, context.shop.id, paymentMethod);
        }

        if (!moneyBox) {
          throw new Error(`${paymentMethod}_BOX_NOT_FOUND`);
        }

        moneyBoxId = moneyBox.id;

        await typedTx.moneyBox.update({
          where: { id: moneyBox.id },
          data: {
            currentBalance: {
              decrement: amount,
            },
          },
        });
      }

      if (paymentMethod === "BANK") {
        let bankAccount = body.bankAccountId
          ? await typedTx.bankAccount.findFirst({
              where: {
                id: body.bankAccountId,
                shopId: context.shop.id,
                status: "ACTIVE",
              },
            })
          : await typedTx.bankAccount.findFirst({
              where: {
                shopId: context.shop.id,
                status: "ACTIVE",
              },
              orderBy: [{ isDefault: "desc" }, { createdAt: "asc" }],
            });

        if (!bankAccount) {
          bankAccount = await resolveDefaultBankAccount(typedTx, context.shop.id);
        }

        if (!bankAccount) {
          throw new Error("BANK_ACCOUNT_NOT_FOUND");
        }

        bankAccountId = bankAccount.id;

        await typedTx.bankAccount.update({
          where: { id: bankAccount.id },
          data: {
            currentBalance: {
              decrement: amount,
            },
          },
        });
      }

      return typedTx.expense.create({
        data: {
          shopId: context.shop.id,
          category,
          amount,
          expenseDate,
          description,
          paymentMethod,
          moneyBoxId,
          bankAccountId,
          status: "PAID",
        },
      });
    });

    return response.status(201).json({
      message: "Expense recorded successfully.",
      expense: mapExpense(createdExpense),
    });
  } catch (error: any) {
    console.error("Failed to create expense.", error);

    if (error instanceof Error && error.message === "CASH_BOX_NOT_FOUND") {
      return response.status(400).json({ message: "No active cash money box found for this shop." });
    }

    if (error instanceof Error && error.message === "BKASH_BOX_NOT_FOUND") {
      return response.status(400).json({ message: "No active bKash money box found for this shop." });
    }

    if (error instanceof Error && error.message === "NAGAD_BOX_NOT_FOUND") {
      return response.status(400).json({ message: "No active Nagad money box found for this shop." });
    }

    if (error instanceof Error && error.message === "BANK_ACCOUNT_NOT_FOUND") {
      return response.status(400).json({ message: "No active bank account found for this shop." });
    }

    return response.status(503).json({ message: "Expense could not be recorded right now." });
  }
});

router.patch("/:id", async (request, response) => {
  try {
    const context = await requireExpenseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const existingExpense = await (prisma as any).expense.findFirst({
      where: {
        id: request.params.id,
        shopId: context.shop.id,
      },
    });

    if (!existingExpense) {
      return response.status(404).json({ message: "Expense not found." });
    }

    const body = request.body as {
      title?: string | null;
      category?: string;
      amount?: number | string;
      expenseDate?: string | null;
      date?: string | null;
      description?: string | null;
      note?: string | null;
      paymentMethod?: string | null;
      moneyBoxId?: string | null;
      bankAccountId?: string | null;
      status?: string | null;
    };

    const category = normalizeText(body.category) || existingExpense.category;
    const amount = body.amount == null ? Number(existingExpense.amount) : Number(body.amount);
    const paymentMethod = normalizeText(body.paymentMethod || existingExpense.paymentMethod).toUpperCase() || "CASH";
    const description = normalizeText(body.description ?? body.note) || existingExpense.description || null;
    const expenseDateRaw = body.expenseDate ?? body.date;
    const expenseDate = expenseDateRaw ? new Date(expenseDateRaw) : existingExpense.expenseDate;
    const status = normalizeText(body.status) || existingExpense.status;

    if (!category) {
      return response.status(400).json({ message: "Expense category is required." });
    }

    if (!Number.isFinite(amount) || amount <= 0) {
      return response.status(400).json({ message: "Expense amount must be a valid positive number." });
    }

    if (!["CASH", "BKASH", "NAGAD", "BANK"].includes(paymentMethod)) {
      return response.status(400).json({ message: "Payment method must be CASH, BKASH, NAGAD, or BANK." });
    }

    if (Number.isNaN(expenseDate.getTime())) {
      return response.status(400).json({ message: "Expense date must be a valid date." });
    }

    const updatedExpense = await prisma.$transaction(async (tx) => {
      const typedTx = tx as any;

      let moneyBoxId: string | null = null;
      let bankAccountId: string | null = null;

      if (paymentMethod === "CASH" || paymentMethod === "BKASH" || paymentMethod === "NAGAD") {
        let moneyBox = body.moneyBoxId
          ? await typedTx.moneyBox.findFirst({
              where: {
                id: body.moneyBoxId,
                shopId: context.shop.id,
                type: paymentMethod,
                status: "ACTIVE",
              },
            })
          : existingExpense.moneyBoxId
            ? await typedTx.moneyBox.findFirst({
                where: {
                  id: existingExpense.moneyBoxId,
                  shopId: context.shop.id,
                  type: paymentMethod,
                  status: "ACTIVE",
                },
              })
            : await typedTx.moneyBox.findFirst({
                where: {
                  shopId: context.shop.id,
                  type: paymentMethod,
                  status: "ACTIVE",
                },
                orderBy: [{ createdAt: "asc" }],
              });

        if (!moneyBox) {
          moneyBox = await resolveDefaultMoneyBoxByType(typedTx, context.shop.id, paymentMethod);
        }

        if (!moneyBox) {
          throw new Error(`${paymentMethod}_BOX_NOT_FOUND`);
        }

        moneyBoxId = moneyBox.id;
      }

      if (paymentMethod === "BANK") {
        let bankAccount = body.bankAccountId
          ? await typedTx.bankAccount.findFirst({
              where: {
                id: body.bankAccountId,
                shopId: context.shop.id,
                status: "ACTIVE",
              },
            })
          : existingExpense.bankAccountId
            ? await typedTx.bankAccount.findFirst({
                where: {
                  id: existingExpense.bankAccountId,
                  shopId: context.shop.id,
                  status: "ACTIVE",
                },
              })
            : await typedTx.bankAccount.findFirst({
                where: {
                  shopId: context.shop.id,
                  status: "ACTIVE",
                },
                orderBy: [{ isDefault: "desc" }, { createdAt: "asc" }],
              });

        if (!bankAccount) {
          bankAccount = await resolveDefaultBankAccount(typedTx, context.shop.id);
        }

        if (!bankAccount) {
          throw new Error("BANK_ACCOUNT_NOT_FOUND");
        }

        bankAccountId = bankAccount.id;
      }

      return typedTx.expense.update({
        where: { id: existingExpense.id },
        data: {
          category,
          amount,
          expenseDate,
          description,
          paymentMethod,
          moneyBoxId,
          bankAccountId,
          status,
        },
      });
    });

    return response.json({
      message: "Expense updated successfully.",
      expense: mapExpense(updatedExpense),
    });
  } catch (error) {
    console.error("Failed to update expense.", error);

    if (error instanceof Error && error.message === "CASH_BOX_NOT_FOUND") {
      return response.status(400).json({ message: "No active cash money box found for this shop." });
    }

    if (error instanceof Error && error.message === "BKASH_BOX_NOT_FOUND") {
      return response.status(400).json({ message: "No active bKash money box found for this shop." });
    }

    if (error instanceof Error && error.message === "NAGAD_BOX_NOT_FOUND") {
      return response.status(400).json({ message: "No active Nagad money box found for this shop." });
    }

    if (error instanceof Error && error.message === "BANK_ACCOUNT_NOT_FOUND") {
      return response.status(400).json({ message: "No active bank account found for this shop." });
    }

    return response.status(503).json({ message: "Expense could not be updated right now." });
  }
});

router.delete("/:id", async (request, response) => {
  try {
    const context = await requireExpenseContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const existingExpense = await (prisma as any).expense.findFirst({
      where: {
        id: request.params.id,
        shopId: context.shop.id,
      },
      select: { id: true },
    });

    if (!existingExpense) {
      return response.status(404).json({ message: "Expense not found." });
    }

    await (prisma as any).expense.delete({
      where: { id: existingExpense.id },
    });

    return response.status(204).send();
  } catch (error) {
    console.error("Failed to delete expense.", error);
    return response.status(503).json({ message: "Expense could not be deleted right now." });
  }
});

export default router;
