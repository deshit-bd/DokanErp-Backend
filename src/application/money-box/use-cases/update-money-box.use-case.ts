import type { MoneyBoxStatus, MoneyBoxType } from "@prisma/client";

import type { MoneyBox } from "@domain/money-box/money-box.entity";
import {
  DuplicateMoneyBoxCodeError,
  InvalidOpeningBalanceError,
  MoneyBoxFieldsRequiredError,
  MoneyBoxNotFoundError,
  ShopNotFoundError,
} from "@domain/money-box/money-box.errors";

import type { MoneyBoxRepository } from "../ports/money-box-repository.port";

export type UpdateMoneyBoxCommand = {
  id: string;
  shopId: string | undefined;
  boxName: string | undefined;
  code: string | undefined;
  type: MoneyBoxType | undefined;
  openingBalance: number | string | undefined;
  details: string | null | undefined;
  status: MoneyBoxStatus | undefined;
};

export class UpdateMoneyBoxUseCase {
  constructor(private readonly moneyBoxRepository: MoneyBoxRepository) {}

  async execute(command: UpdateMoneyBoxCommand): Promise<MoneyBox> {
    const existing = await this.moneyBoxRepository.findById(command.id);

    if (!existing) {
      throw new MoneyBoxNotFoundError();
    }

    const shopId = command.shopId?.trim();
    const boxName = command.boxName?.trim();
    const code = command.code?.trim();
    const type = command.type;
    const details = command.details?.trim() || null;
    const status: MoneyBoxStatus = command.status ?? "ACTIVE";
    const openingBalance = Number(command.openingBalance ?? 0);

    if (!shopId || !boxName || !code || !type) {
      throw new MoneyBoxFieldsRequiredError();
    }
    if (Number.isNaN(openingBalance)) {
      throw new InvalidOpeningBalanceError();
    }

    const [shop, duplicateCode] = await Promise.all([
      this.moneyBoxRepository.findShopById(shopId),
      this.moneyBoxRepository.findByCode(code, command.id),
    ]);

    if (!shop) {
      throw new ShopNotFoundError();
    }
    if (duplicateCode) {
      throw new DuplicateMoneyBoxCodeError();
    }

    return this.moneyBoxRepository.update(command.id, { shopId, boxName, code, type, openingBalance, details, status });
  }
}
