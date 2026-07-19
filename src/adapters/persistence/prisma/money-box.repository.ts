import type { MoneyBox, MoneyBoxListFilter } from "@domain/money-box/money-box.entity";
import type { MoneyBoxInput, MoneyBoxRepository } from "@application/money-box/ports/money-box-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

const INCLUDE_SHOP = { shop: { select: { id: true, shopName: true } } } as const;

function toMoneyBox(record: any): MoneyBox {
  return {
    id: record.id,
    shopId: record.shopId,
    shopName: record.shop?.shopName ?? "Unknown Shop",
    boxName: record.boxName,
    code: record.code,
    type: record.type,
    openingBalance: Number(record.openingBalance ?? 0),
    currentBalance: Number(record.currentBalance ?? 0),
    details: record.details,
    status: record.status,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
  };
}

export class PrismaMoneyBoxRepository implements MoneyBoxRepository {
  async findMany(filter: MoneyBoxListFilter): Promise<MoneyBox[]> {
    const records = await (prisma as any).moneyBox.findMany({
      where: {
        ...(filter.shopId ? { shopId: filter.shopId } : {}),
        ...(filter.status ? { status: filter.status } : {}),
        ...(filter.search
          ? {
              OR: [
                { boxName: { contains: filter.search, mode: "insensitive" } },
                { code: { contains: filter.search, mode: "insensitive" } },
                { shop: { shopName: { contains: filter.search, mode: "insensitive" } } },
              ],
            }
          : {}),
      },
      include: INCLUDE_SHOP,
      orderBy: [{ createdAt: "desc" }, { boxName: "asc" }],
    });

    return records.map(toMoneyBox);
  }

  async findShopById(id: string) {
    return prisma.shop.findUnique({ where: { id }, select: { id: true } });
  }

  async findByCode(code: string, excludeId?: string) {
    if (excludeId) {
      return (prisma as any).moneyBox.findFirst({ where: { code, id: { not: excludeId } }, select: { id: true } });
    }
    return (prisma as any).moneyBox.findUnique({ where: { code }, select: { id: true } });
  }

  async findById(id: string) {
    return (prisma as any).moneyBox.findUnique({ where: { id }, select: { id: true } });
  }

  async create(input: MoneyBoxInput): Promise<MoneyBox> {
    const record = await (prisma as any).moneyBox.create({
      data: {
        shopId: input.shopId,
        boxName: input.boxName,
        code: input.code,
        type: input.type,
        openingBalance: input.openingBalance,
        currentBalance: input.openingBalance,
        details: input.details,
        status: input.status,
      },
      include: INCLUDE_SHOP,
    });

    return toMoneyBox(record);
  }

  async update(id: string, input: MoneyBoxInput): Promise<MoneyBox> {
    const record = await (prisma as any).moneyBox.update({
      where: { id },
      data: {
        shopId: input.shopId,
        boxName: input.boxName,
        code: input.code,
        type: input.type,
        openingBalance: input.openingBalance,
        details: input.details,
        status: input.status,
      },
      include: INCLUDE_SHOP,
    });

    return toMoneyBox(record);
  }
}
