import { computeMoneyBoxStats, type MoneyBox, type MoneyBoxListFilter, type MoneyBoxStats } from "@domain/money-box/money-box.entity";

import type { MoneyBoxRepository } from "../ports/money-box-repository.port";

export class ListMoneyBoxesUseCase {
  constructor(private readonly moneyBoxRepository: MoneyBoxRepository) {}

  async execute(filter: MoneyBoxListFilter): Promise<{ moneyBoxes: MoneyBox[]; stats: MoneyBoxStats }> {
    const moneyBoxes = await this.moneyBoxRepository.findMany(filter);
    return { moneyBoxes, stats: computeMoneyBoxStats(moneyBoxes) };
  }
}
