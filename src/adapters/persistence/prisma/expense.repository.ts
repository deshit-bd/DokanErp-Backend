import type { Expense } from "@domain/expense/expense.entity";
import { BankAccountNotAvailableError, MoneyBoxNotAvailableError } from "@domain/expense/expense.errors";
import type {
  CreateExpenseInput,
  ExpenseRepository,
  ShopScope,
  UpdateExpenseInput,
} from "@application/expense/ports/expense-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

function toExpense(record: any): Expense {
  return {
    id: record.id,
    shopId: record.shopId,
    category: record.category,
    amount: Number(record.amount ?? 0),
    expenseDate: record.expenseDate,
    description: record.description,
    paymentMethod: record.paymentMethod,
    moneyBoxId: record.moneyBoxId,
    bankAccountId: record.bankAccountId,
    status: record.status,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
  };
}

async function resolveDefaultMoneyBoxByType(tx: any, shopId: string, type: string) {
  const boxName = type === "CASH" ? "Cash Box" : type === "BKASH" ? "bKash Wallet" : "Nagad Wallet";
  const code = `${type.toLowerCase()}-${shopId.substring(0, 8)}-${Date.now()}`;

  return tx.moneyBox.create({
    data: { shopId, boxName, code, type, openingBalance: 0, currentBalance: 0, status: "ACTIVE" },
  });
}

async function resolveDefaultBankAccount(tx: any, shopId: string) {
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

async function resolveMoneyBoxForPayment(tx: any, shopId: string, type: "CASH" | "BKASH" | "NAGAD", preferredId: string | undefined, fallbackExistingId: string | null | undefined) {
  let moneyBox = preferredId
    ? await tx.moneyBox.findFirst({ where: { id: preferredId, shopId, type, status: "ACTIVE" } })
    : fallbackExistingId
      ? await tx.moneyBox.findFirst({ where: { id: fallbackExistingId, shopId, type, status: "ACTIVE" } })
      : await tx.moneyBox.findFirst({ where: { shopId, type, status: "ACTIVE" }, orderBy: [{ createdAt: "asc" }] });

  if (!moneyBox) {
    moneyBox = await resolveDefaultMoneyBoxByType(tx, shopId, type);
  }
  if (!moneyBox) {
    throw new MoneyBoxNotAvailableError(type);
  }
  return moneyBox;
}

async function resolveBankAccountForPayment(tx: any, shopId: string, preferredId: string | undefined, fallbackExistingId: string | null | undefined) {
  let bankAccount = preferredId
    ? await tx.bankAccount.findFirst({ where: { id: preferredId, shopId, status: "ACTIVE" } })
    : fallbackExistingId
      ? await tx.bankAccount.findFirst({ where: { id: fallbackExistingId, shopId, status: "ACTIVE" } })
      : await tx.bankAccount.findFirst({ where: { shopId, status: "ACTIVE" }, orderBy: [{ isDefault: "desc" }, { createdAt: "asc" }] });

  if (!bankAccount) {
    bankAccount = await resolveDefaultBankAccount(tx, shopId);
  }
  if (!bankAccount) {
    throw new BankAccountNotAvailableError();
  }
  return bankAccount;
}

export class PrismaExpenseRepository implements ExpenseRepository {
  async findShopByIdentifier(identifier: string): Promise<ShopScope | null> {
    return prisma.shop.findFirst({
      where: { OR: [{ id: identifier }, { shopCode: identifier }] },
      select: { id: true, shopCode: true, shopName: true },
    });
  }

  async findManyByShopAndDateFilter(shopId: string, gte?: Date): Promise<Expense[]> {
    const records = await (prisma as any).expense.findMany({
      where: { shopId, ...(gte ? { expenseDate: { gte } } : {}) },
      orderBy: [{ expenseDate: "desc" }, { createdAt: "desc" }],
    });
    return records.map(toExpense);
  }

  async findManyInRange(shopId: string, start: Date, end: Date): Promise<Expense[]> {
    const records = await (prisma as any).expense.findMany({
      where: { shopId, expenseDate: { gte: start, lte: end } },
      orderBy: [{ expenseDate: "desc" }, { createdAt: "desc" }],
    });
    return records.map(toExpense);
  }

  async findManyPaidInRange(shopId: string, start: Date, end: Date): Promise<Expense[]> {
    const records = await (prisma as any).expense.findMany({
      where: { shopId, status: "PAID", expenseDate: { gte: start, lte: end } },
    });
    return records.map(toExpense);
  }

  async findById(id: string, shopId: string): Promise<Expense | null> {
    const record = await (prisma as any).expense.findFirst({ where: { id, shopId } });
    return record ? toExpense(record) : null;
  }

  async create(input: CreateExpenseInput): Promise<Expense> {
    const record = await prisma.$transaction(async (tx) => {
      const typedTx = tx as any;
      let moneyBoxId: string | null = null;
      let bankAccountId: string | null = null;

      if (input.paymentMethod === "CASH" || input.paymentMethod === "BKASH" || input.paymentMethod === "NAGAD") {
        const moneyBox = await resolveMoneyBoxForPayment(typedTx, input.shopId, input.paymentMethod, input.preferredMoneyBoxId, undefined);
        moneyBoxId = moneyBox.id;
        await typedTx.moneyBox.update({ where: { id: moneyBox.id }, data: { currentBalance: { decrement: input.amount } } });
      }

      if (input.paymentMethod === "BANK") {
        const bankAccount = await resolveBankAccountForPayment(typedTx, input.shopId, input.preferredBankAccountId, undefined);
        bankAccountId = bankAccount.id;
        await typedTx.bankAccount.update({ where: { id: bankAccount.id }, data: { currentBalance: { decrement: input.amount } } });
      }

      return typedTx.expense.create({
        data: {
          shopId: input.shopId,
          category: input.category,
          amount: input.amount,
          expenseDate: input.expenseDate,
          description: input.description,
          paymentMethod: input.paymentMethod,
          moneyBoxId,
          bankAccountId,
          status: "PAID",
        },
      });
    });

    return toExpense(record);
  }

  async update(id: string, input: UpdateExpenseInput): Promise<Expense> {
    const record = await prisma.$transaction(async (tx) => {
      const typedTx = tx as any;
      const expense = await typedTx.expense.findUnique({ where: { id }, select: { shopId: true } });

      let moneyBoxId: string | null = null;
      let bankAccountId: string | null = null;

      if (input.paymentMethod === "CASH" || input.paymentMethod === "BKASH" || input.paymentMethod === "NAGAD") {
        const moneyBox = await resolveMoneyBoxForPayment(typedTx, expense.shopId, input.paymentMethod, input.preferredMoneyBoxId, input.existingMoneyBoxId);
        moneyBoxId = moneyBox.id;
      }

      if (input.paymentMethod === "BANK") {
        const bankAccount = await resolveBankAccountForPayment(typedTx, expense.shopId, input.preferredBankAccountId, input.existingBankAccountId);
        bankAccountId = bankAccount.id;
      }

      return typedTx.expense.update({
        where: { id },
        data: {
          category: input.category,
          amount: input.amount,
          expenseDate: input.expenseDate,
          description: input.description,
          paymentMethod: input.paymentMethod,
          moneyBoxId,
          bankAccountId,
          status: input.status,
        },
      });
    });

    return toExpense(record);
  }

  async delete(id: string): Promise<void> {
    await (prisma as any).expense.delete({ where: { id } });
  }
}
