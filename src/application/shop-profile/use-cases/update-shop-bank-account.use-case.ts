import { ConflictError, NotFoundError, ValidationError } from "@domain/shared/app-error";
import { normalizeOptionalText } from "@domain/shop-profile/shop-profile.entity";

import type { BankAccountSource, ShopProfileRepository } from "../ports/shop-profile-repository.port";

export type UpdateShopBankAccountCommand = {
  id: string;
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

export class UpdateShopBankAccountUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(command: UpdateShopBankAccountCommand): Promise<BankAccountSource> {
    const existing = await this.shopProfileRepository.findShopBankAccount(command.id, command.shopId);

    if (!existing) {
      throw new NotFoundError("Bank account not found in this shop.");
    }

    const accountName = (command.accountName ?? existing.accountName ?? "").trim();
    const bankName = (command.bankName ?? existing.bankName ?? "").trim();
    const branchName = command.branchName === undefined ? existing.branchName : normalizeOptionalText(command.branchName);
    const accountNumber = (command.accountNumber ?? existing.accountNumber ?? "").trim();
    const accountType = command.accountType ?? existing.accountType;
    const openingBalance = command.openingBalance === undefined ? Number(existing.openingBalance ?? 0) : Number(command.openingBalance ?? 0);
    const currency = (command.currency ?? existing.currency ?? "BDT").trim().toUpperCase() || "BDT";
    const status = command.status ?? existing.status;
    const isDefault = command.isDefault === undefined ? Boolean(existing.isDefault) : Boolean(command.isDefault);
    const notes = command.notes === undefined ? existing.notes : normalizeOptionalText(command.notes);

    if (!accountName || !bankName || !accountNumber || !accountType) {
      throw new ValidationError("accountName, bankName, accountNumber, and accountType are required.");
    }
    if (!Number.isFinite(openingBalance)) {
      throw new ValidationError("Opening balance must be a valid number.");
    }

    const duplicateAccount = await this.shopProfileRepository.findBankAccountByBankAndNumberExcept(bankName, accountNumber, existing.id);

    if (duplicateAccount) {
      throw new ConflictError("A bank account with this bank and account number already exists.");
    }

    return this.shopProfileRepository.updateBankAccountWithBalanceDelta(
      existing.id,
      command.shopId,
      { accountName, bankName, branchName, accountNumber, accountType, openingBalance, currency, status, isDefault, notes },
      Number(existing.openingBalance ?? 0),
      Number(existing.currentBalance ?? 0),
    );
  }
}
