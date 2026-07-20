import type { MoneyBoxStatus, MoneyBoxType } from "@prisma/client";

import type { MoneyBox, MoneyBoxListFilter } from "@domain/money-box/money-box.entity";

export type MoneyBoxInput = {
  shopId: string;
  boxName: string;
  code: string;
  type: MoneyBoxType;
  openingBalance: number;
  details: string | null;
  status: MoneyBoxStatus;
};

export interface MoneyBoxRepository {
  findMany(filter: MoneyBoxListFilter): Promise<MoneyBox[]>;
  findShopById(id: string): Promise<{ id: string } | null>;
  findByCode(code: string, excludeId?: string): Promise<{ id: string } | null>;
  findById(id: string): Promise<{ id: string } | null>;
  create(input: MoneyBoxInput): Promise<MoneyBox>;
  update(id: string, input: MoneyBoxInput): Promise<MoneyBox>;
}
