import type { BankAccount, BankAccountListFilter } from "@domain/bank-account/bank-account.entity";
import type { BankAccountInput, BankAccountRepository } from "@application/bank-account/ports/bank-account-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

const INCLUDE_SHOP = { shop: { select: { id: true, shopName: true } } } as const;

function toBankAccount(record: any): BankAccount {
  return {
    id: record.id,
    shopId: record.shopId,
    shopName: record.shop?.shopName ?? "Unknown Shop",
    accountName: record.accountName,
    bankName: record.bankName,
    branchName: record.branchName,
    accountNumber: record.accountNumber,
    accountType: record.accountType,
    openingBalance: Number(record.openingBalance ?? 0),
    currentBalance: Number(record.currentBalance ?? 0),
    currency: record.currency,
    status: record.status,
    isDefault: Boolean(record.isDefault),
    notes: record.notes,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
  };
}

export class PrismaBankAccountRepository implements BankAccountRepository {
  async findMany(filter: BankAccountListFilter): Promise<BankAccount[]> {
    const records = await (prisma as any).bankAccount.findMany({
      where: {
        ...(filter.shopId ? { shopId: filter.shopId } : {}),
        ...(filter.bankName ? { bankName: filter.bankName } : {}),
        ...(filter.status ? { status: filter.status } : {}),
        ...(filter.search
          ? {
              OR: [
                { accountName: { contains: filter.search, mode: "insensitive" } },
                { bankName: { contains: filter.search, mode: "insensitive" } },
                { branchName: { contains: filter.search, mode: "insensitive" } },
                { accountNumber: { contains: filter.search, mode: "insensitive" } },
                { shop: { shopName: { contains: filter.search, mode: "insensitive" } } },
              ],
            }
          : {}),
      },
      include: INCLUDE_SHOP,
      orderBy: [{ isDefault: "desc" }, { updatedAt: "desc" }, { accountName: "asc" }],
    });

    return records.map(toBankAccount);
  }

  async findShopById(id: string) {
    return prisma.shop.findUnique({ where: { id }, select: { id: true } });
  }

  async findDuplicate(bankName: string, accountNumber: string, excludeId?: string) {
    return (prisma as any).bankAccount.findFirst({
      where: { bankName, accountNumber, ...(excludeId ? { id: { not: excludeId } } : {}) },
      select: { id: true },
    });
  }

  async findByIdWithBalances(id: string) {
    const record = await (prisma as any).bankAccount.findUnique({
      where: { id },
      select: { id: true, shopId: true, openingBalance: true, currentBalance: true },
    });

    if (!record) {
      return null;
    }

    return {
      id: record.id,
      shopId: record.shopId,
      openingBalance: Number(record.openingBalance ?? 0),
      currentBalance: Number(record.currentBalance ?? 0),
    };
  }

  async create(input: BankAccountInput): Promise<BankAccount> {
    const record = await prisma.$transaction(async (transaction) => {
      if (input.isDefault) {
        await (transaction as any).bankAccount.updateMany({
          where: { shopId: input.shopId },
          data: { isDefault: false },
        });
      }

      return (transaction as any).bankAccount.create({
        data: {
          shopId: input.shopId,
          accountName: input.accountName,
          bankName: input.bankName,
          branchName: input.branchName,
          accountNumber: input.accountNumber,
          accountType: input.accountType,
          openingBalance: input.openingBalance,
          currentBalance: input.openingBalance,
          currency: input.currency,
          status: input.status,
          isDefault: input.isDefault,
          notes: input.notes,
        },
        include: INCLUDE_SHOP,
      });
    });

    return toBankAccount(record);
  }

  async update(id: string, input: BankAccountInput, previousOpeningBalance: number, previousCurrentBalance: number): Promise<BankAccount> {
    const record = await prisma.$transaction(async (transaction) => {
      if (input.isDefault) {
        await (transaction as any).bankAccount.updateMany({
          where: { shopId: input.shopId },
          data: { isDefault: false },
        });
      }

      const openingDelta = input.openingBalance - previousOpeningBalance;

      return (transaction as any).bankAccount.update({
        where: { id },
        data: {
          shopId: input.shopId,
          accountName: input.accountName,
          bankName: input.bankName,
          branchName: input.branchName,
          accountNumber: input.accountNumber,
          accountType: input.accountType,
          openingBalance: input.openingBalance,
          currentBalance: previousCurrentBalance + openingDelta,
          currency: input.currency,
          status: input.status,
          isDefault: input.isDefault,
          notes: input.notes,
        },
        include: INCLUDE_SHOP,
      });
    });

    return toBankAccount(record);
  }
}
