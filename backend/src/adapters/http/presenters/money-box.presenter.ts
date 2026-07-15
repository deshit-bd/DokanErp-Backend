import { toDisplayLabel, type MoneyBox } from "@domain/money-box/money-box.entity";

export function toMoneyBoxDto(moneyBox: MoneyBox) {
  return {
    id: moneyBox.id,
    shopId: moneyBox.shopId,
    shopName: moneyBox.shopName,
    boxName: moneyBox.boxName,
    code: moneyBox.code,
    type: moneyBox.type,
    typeLabel: toDisplayLabel(moneyBox.type),
    openingBalance: moneyBox.openingBalance,
    currentBalance: moneyBox.currentBalance,
    details: moneyBox.details,
    status: moneyBox.status,
    statusLabel: toDisplayLabel(moneyBox.status),
    createdAt: moneyBox.createdAt,
    updatedAt: moneyBox.updatedAt,
  };
}
