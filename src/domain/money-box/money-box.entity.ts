import type { MoneyBoxStatus, MoneyBoxType } from "@prisma/client";

export type MoneyBox = {
  id: string;
  shopId: string;
  shopName: string;
  boxName: string;
  code: string;
  type: MoneyBoxType;
  openingBalance: number;
  currentBalance: number;
  details: string | null;
  status: MoneyBoxStatus;
  createdAt: Date;
  updatedAt: Date;
};

export type MoneyBoxStats = {
  total: number;
  active: number;
  inactive: number;
  totalBalance: number;
};

export type MoneyBoxListFilter = {
  search?: string;
  shopId?: string;
  status?: string;
};

export function toDisplayLabel(value: string): string {
  return value.replace(/_/g, " ");
}

export function computeMoneyBoxStats(boxes: Pick<MoneyBox, "status" | "currentBalance">[]): MoneyBoxStats {
  return {
    total: boxes.length,
    active: boxes.filter((item) => item.status === "ACTIVE").length,
    inactive: boxes.filter((item) => item.status === "INACTIVE").length,
    totalBalance: boxes.reduce((sum, item) => sum + Number(item.currentBalance ?? 0), 0),
  };
}
