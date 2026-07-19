import type { BankAccountStatus, BankAccountType } from "@prisma/client";

export type BankAccount = {
  id: string;
  shopId: string;
  shopName: string;
  accountName: string;
  bankName: string;
  branchName: string | null;
  accountNumber: string;
  accountType: BankAccountType;
  openingBalance: number;
  currentBalance: number;
  currency: string;
  status: BankAccountStatus;
  isDefault: boolean;
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
};

export type BankAccountStats = {
  total: number;
  active: number;
  inactive: number;
  totalBalance: number;
};

export type BankAccountListFilter = {
  search?: string;
  shopId?: string;
  bankName?: string;
  status?: string;
};

export function toDisplayLabel(value: string): string {
  return value.replace(/_/g, " ");
}

export function maskAccountNumber(value: string): string {
  const trimmed = value.trim();

  if (trimmed.length <= 4) {
    return trimmed;
  }

  return `${"*".repeat(Math.max(trimmed.length - 4, 0))}${trimmed.slice(-4)}`;
}

export function computeBankAccountStats(accounts: Pick<BankAccount, "status" | "currentBalance">[]): BankAccountStats {
  return {
    total: accounts.length,
    active: accounts.filter((item) => item.status === "ACTIVE").length,
    inactive: accounts.filter((item) => item.status === "INACTIVE").length,
    totalBalance: accounts.reduce((sum, item) => sum + Number(item.currentBalance ?? 0), 0),
  };
}

export function extractDistinctBankNames(accounts: Pick<BankAccount, "bankName">[]): string[] {
  const banks = Array.from(new Set(accounts.map((item) => item.bankName?.trim()).filter((value): value is string => Boolean(value))));
  banks.sort((left, right) => left.localeCompare(right));
  return banks;
}
