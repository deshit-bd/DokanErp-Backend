import { maskAccountNumber, toDisplayLabel, type BankAccount } from "@domain/bank-account/bank-account.entity";

export function toBankAccountDto(bankAccount: BankAccount) {
  return {
    id: bankAccount.id,
    shopId: bankAccount.shopId,
    shopName: bankAccount.shopName,
    accountName: bankAccount.accountName,
    bankName: bankAccount.bankName,
    branchName: bankAccount.branchName,
    accountNumber: bankAccount.accountNumber,
    accountNumberMasked: maskAccountNumber(bankAccount.accountNumber),
    accountType: bankAccount.accountType,
    accountTypeLabel: toDisplayLabel(bankAccount.accountType),
    openingBalance: bankAccount.openingBalance,
    currentBalance: bankAccount.currentBalance,
    currency: bankAccount.currency,
    status: bankAccount.status,
    statusLabel: toDisplayLabel(bankAccount.status),
    isDefault: bankAccount.isDefault,
    notes: bankAccount.notes,
    createdAt: bankAccount.createdAt,
    updatedAt: bankAccount.updatedAt,
  };
}
