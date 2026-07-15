import { ExpenseNotFoundError } from "@domain/expense/expense.errors";

import type { ExpenseRepository } from "../ports/expense-repository.port";

export class DeleteExpenseUseCase {
  constructor(private readonly expenseRepository: ExpenseRepository) {}

  async execute(id: string, shopId: string): Promise<void> {
    const existing = await this.expenseRepository.findById(id, shopId);

    if (!existing) {
      throw new ExpenseNotFoundError();
    }

    await this.expenseRepository.delete(id);
  }
}
