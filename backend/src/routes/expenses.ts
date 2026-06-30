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
