import type { Expense } from "@domain/expense/expense.entity";

export type ShopScope = { id: string; shopCode: string | null; shopName: string };

export type CreateExpenseInput = {
  shopId: string;
  category: string;
  amount: number;
  expenseDate: Date;
  description: string | null;
  paymentMethod: string;
  preferredMoneyBoxId?: string;
  preferredBankAccountId?: string;
};

export type UpdateExpenseInput = {
  category: string;
  amount: number;
  expenseDate: Date;
  description: string | null;
  paymentMethod: string;
  status: string;
  preferredMoneyBoxId?: string;
  existingMoneyBoxId: string | null;
  preferredBankAccountId?: string;
  existingBankAccountId: string | null;
};

export interface ExpenseRepository {
  findShopByIdentifier(identifier: string): Promise<ShopScope | null>;
  findManyByShopAndDateFilter(shopId: string, gte?: Date): Promise<Expense[]>;
  findManyInRange(shopId: string, start: Date, end: Date): Promise<Expense[]>;
  findManyPaidInRange(shopId: string, start: Date, end: Date): Promise<Expense[]>;
  findById(id: string, shopId: string): Promise<Expense | null>;
  /** Resolves (or creates a default) money box / bank account for the payment method, decrements its balance, and creates the expense — all in one transaction. */
  create(input: CreateExpenseInput): Promise<Expense>;
  /** Resolves (or creates a default) money box / bank account for the payment method — without touching balances, matching the original PATCH route exactly — and updates the expense. */
  update(id: string, input: UpdateExpenseInput): Promise<Expense>;
  delete(id: string): Promise<void>;
}
