import type { Expense } from "@domain/expense/expense.entity";

export function toExpenseDto(expense: Expense) {
  return {
    id: expense.id,
    shopId: expense.shopId,
    category: expense.category,
    amount: expense.amount,
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
