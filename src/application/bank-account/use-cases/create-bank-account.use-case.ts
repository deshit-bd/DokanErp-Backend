import type { BankAccountStatus, BankAccountType } from "@prisma/client";

import type { BankAccount } from "@domain/bank-account/bank-account.entity";
import { BankAccountFieldsRequiredError, DuplicateBankAccountError, InvalidOpeningBalanceError, ShopNotFoundError } from "@domain/bank-account/bank-account.errors";

import type { BankAccountRepository } from "../ports/bank-account-repository.port";

export type CreateBankAccountCommand = {
  shopId: string | undefined;
  accountName: string | undefined;
  bankName: string | undefined;
  branchName: string | null | undefined;
  accountNumber: string | undefined;
  accountType: BankAccountType | undefined;
  openingBalance: number | string | undefined;
  currency: string | undefined;
  status: BankAccountStatus | undefined;
  isDefault: unknown;
  notes: string | null | undefined;
};

export class CreateBankAccountUseCase {
  constructor(private readonly bankAccountRepository: BankAccountRepository) {}

  async execute(command: CreateBankAccountCommand): Promise<BankAccount> {
    const shopId = command.shopId?.trim();
    const accountName = command.accountName?.trim();
    const bankName = command.bankName?.trim();
    const branchName = command.branchName?.trim() || null;
    const accountNumber = command.accountNumber?.trim();
    const accountType = command.accountType;
    const openingBalance = Number(command.openingBalance ?? 0);
    const currency = command.currency?.trim().toUpperCase() || "BDT";
    const status: BankAccountStatus = command.status ?? "ACTIVE";
    const isDefault = Boolean(command.isDefault);
    const notes = command.notes?.trim() || null;

    if (!shopId || !accountName || !bankName || !accountNumber || !accountType) {
      throw new BankAccountFieldsRequiredError();
    }
    if (Number.isNaN(openingBalance)) {
      throw new InvalidOpeningBalanceError();
    }

    const [shop, existingAccount] = await Promise.all([
      this.bankAccountRepository.findShopById(shopId),
      this.bankAccountRepository.findDuplicate(bankName, accountNumber),
    ]);

    if (!shop) {
      throw new ShopNotFoundError();
    }
    if (existingAccount) {
      throw new DuplicateBankAccountError();
    }

    return this.bankAccountRepository.create({
      shopId,
      accountName,
      bankName,
      branchName,
      accountNumber,
      accountType,
      openingBalance,
      currency,
      status,
      isDefault,
      notes,
    });
  }
}
