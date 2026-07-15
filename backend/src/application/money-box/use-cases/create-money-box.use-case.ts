import type { MoneyBoxStatus, MoneyBoxType } from "@prisma/client";

import type { MoneyBox } from "@domain/money-box/money-box.entity";
import {
  DuplicateMoneyBoxCodeError,
  InvalidOpeningBalanceError,
  MoneyBoxCodeRequiredError,
  MoneyBoxNameRequiredError,
  MoneyBoxTypeRequiredError,
  ShopNotFoundError,
  ShopRequiredError,
} from "@domain/money-box/money-box.errors";

import type { MoneyBoxRepository } from "../ports/money-box-repository.port";

export type CreateMoneyBoxCommand = {
  shopId: string | undefined;
  boxName: string | undefined;
  code: string | undefined;
  type: MoneyBoxType | undefined;
  openingBalance: number | string | undefined;
  details: string | null | undefined;
  status: MoneyBoxStatus | undefined;
};

export class CreateMoneyBoxUseCase {
  constructor(private readonly moneyBoxRepository: MoneyBoxRepository) {}

  async execute(command: CreateMoneyBoxCommand): Promise<MoneyBox> {
    const shopId = command.shopId?.trim();
    const boxName = command.boxName?.trim();
    const code = command.code?.trim();
    const type = command.type;
    const details = command.details?.trim() || null;
    const status: MoneyBoxStatus = command.status ?? "ACTIVE";
    const openingBalance = Number(command.openingBalance ?? 0);

    if (!shopId) {
      throw new ShopRequiredError();
    }
    if (!boxName) {
      throw new MoneyBoxNameRequiredError();
    }
    if (!code) {
      throw new MoneyBoxCodeRequiredError();
    }
    if (!type) {
      throw new MoneyBoxTypeRequiredError();
    }
    if (Number.isNaN(openingBalance)) {
      throw new InvalidOpeningBalanceError();
    }

    const [shop, existingCode] = await Promise.all([
      this.moneyBoxRepository.findShopById(shopId),
      this.moneyBoxRepository.findByCode(code),
    ]);

    if (!shop) {
      throw new ShopNotFoundError();
    }
    if (existingCode) {
      throw new DuplicateMoneyBoxCodeError();
    }

    return this.moneyBoxRepository.create({ shopId, boxName, code, type, openingBalance, details, status });
  }
}
