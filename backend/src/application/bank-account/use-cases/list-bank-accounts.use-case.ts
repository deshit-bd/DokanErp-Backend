import { computeBankAccountStats, extractDistinctBankNames, type BankAccount, type BankAccountListFilter, type BankAccountStats } from "@domain/bank-account/bank-account.entity";

import type { BankAccountRepository } from "../ports/bank-account-repository.port";

export class ListBankAccountsUseCase {
  constructor(private readonly bankAccountRepository: BankAccountRepository) {}

  async execute(filter: BankAccountListFilter): Promise<{ bankAccounts: BankAccount[]; stats: BankAccountStats; banks: string[] }> {
    const bankAccounts = await this.bankAccountRepository.findMany(filter);

    return {
      bankAccounts,
      stats: computeBankAccountStats(bankAccounts),
      banks: extractDistinctBankNames(bankAccounts),
    };
  }
}
