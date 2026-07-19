import type { BankAccountStatus, BankAccountType } from "@prisma/client";

import type { BankAccount, BankAccountListFilter } from "@domain/bank-account/bank-account.entity";

export type BankAccountInput = {
  shopId: string;
  accountName: string;
  bankName: string;
  branchName: string | null;
  accountNumber: string;
  accountType: BankAccountType;
  openingBalance: number;
  currency: string;
  status: BankAccountStatus;
  isDefault: boolean;
  notes: string | null;
};

export interface BankAccountRepository {
  findMany(filter: BankAccountListFilter): Promise<BankAccount[]>;
  findShopById(id: string): Promise<{ id: string } | null>;
  findDuplicate(bankName: string, accountNumber: string, excludeId?: string): Promise<{ id: string } | null>;
  findByIdWithBalances(id: string): Promise<{ id: string; shopId: string; openingBalance: number; currentBalance: number } | null>;
  create(input: BankAccountInput): Promise<BankAccount>;
  update(id: string, input: BankAccountInput, previousOpeningBalance: number, previousCurrentBalance: number): Promise<BankAccount>;
}
