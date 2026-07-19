import type { Expense } from "@domain/expense/expense.entity";

import type { ExpenseRepository, ShopScope } from "../ports/expense-repository.port";

export class ListExpensesUseCase {
  constructor(private readonly expenseRepository: ExpenseRepository) {}

  async execute(shop: ShopScope, period: string | undefined) {
    const normalizedPeriod = (period ?? "").trim().toUpperCase() || "TODAY";
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfWeek = new Date(startOfToday);
    startOfWeek.setDate(startOfToday.getDate() - startOfToday.getDay());
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const dateFilterStart =
      normalizedPeriod === "WEEK" ? startOfWeek : normalizedPeriod === "MONTH" ? startOfMonth : normalizedPeriod === "ALL" ? undefined : startOfToday;

    const [expenses, allExpenses] = await Promise.all([
      this.expenseRepository.findManyByShopAndDateFilter(shop.id, dateFilterStart),
      this.expenseRepository.findManyByShopAndDateFilter(shop.id, undefined),
    ]);

    const sumSince = (startDate: Date) =>
      Number(
        allExpenses
          .filter((item: Expense) => new Date(item.expenseDate) >= startDate)
          .reduce((sum, item) => sum + Number(item.amount ?? 0), 0)
          .toFixed(2),
      );

    return {
      shop,
      summary: {
        today: sumSince(startOfToday),
        week: sumSince(startOfWeek),
        month: sumSince(startOfMonth),
        count: expenses.length,
      },
      expenses,
    };
  }
}
