import { ConflictError, ValidationError } from "@domain/shared/app-error";
import { normalizeOptionalText } from "@domain/shop-profile/shop-profile.entity";

import type { BankAccountSource, ShopProfileRepository } from "../ports/shop-profile-repository.port";

export type CreateShopBankAccountCommand = {
  shopId: string;
  accountName: string | undefined;
  bankName: string | undefined;
  branchName: string | null | undefined;
  accountNumber: string | undefined;
  accountType: string | undefined;
  openingBalance: number | string | undefined;
  currency: string | undefined;
  status: string | undefined;
  isDefault: unknown;
  notes: string | null | undefined;
};

export class CreateShopBankAccountUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(command: CreateShopBankAccountCommand): Promise<BankAccountSource> {
    const accountName = (command.accountName ?? "").trim();
    const bankName = (command.bankName ?? "").trim();
    const branchName = normalizeOptionalText(command.branchName);
    const accountNumber = (command.accountNumber ?? "").trim();
    const accountType = command.accountType;
    const openingBalance = Number(command.openingBalance ?? 0);
    const currency = (command.currency ?? "BDT").trim().toUpperCase() || "BDT";
    const status = command.status ?? "ACTIVE";
    const isDefault = Boolean(command.isDefault);
    const notes = normalizeOptionalText(command.notes);

    if (!accountName || !bankName || !accountNumber || !accountType) {
      throw new ValidationError("accountName, bankName, accountNumber, and accountType are required.");
    }
    if (!Number.isFinite(openingBalance)) {
      throw new ValidationError("Opening balance must be a valid number.");
    }

    const existingAccount = await this.shopProfileRepository.findBankAccountByBankAndNumber(bankName, accountNumber);

    if (existingAccount) {
      throw new ConflictError("A bank account with this bank and account number already exists.");
    }

    return this.shopProfileRepository.createBankAccount(command.shopId, {
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
