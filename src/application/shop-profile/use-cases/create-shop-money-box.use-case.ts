import { ConflictError, ValidationError } from "@domain/shared/app-error";
import { normalizeOptionalText } from "@domain/shop-profile/shop-profile.entity";

import type { MoneyBoxSource, ShopProfileRepository } from "../ports/shop-profile-repository.port";

export type CreateShopMoneyBoxCommand = {
  shopId: string;
  boxName: string | undefined;
  code: string | undefined;
  type: string | undefined;
  openingBalance: number | string | undefined;
  details: string | null | undefined;
  status: string | undefined;
};

export class CreateShopMoneyBoxUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(command: CreateShopMoneyBoxCommand): Promise<MoneyBoxSource> {
    const boxName = command.boxName?.trim() ?? "";
    const code = command.code?.trim() ?? "";
    const type = command.type;
    const details = normalizeOptionalText(command.details);
    const status = command.status ?? "ACTIVE";
    const openingBalance = Number(command.openingBalance ?? 0);

    if (!boxName || !code || !type) {
      throw new ValidationError("boxName, code, and type are required.");
    }
    if (!Number.isFinite(openingBalance)) {
      throw new ValidationError("Opening balance must be a valid number.");
    }

    const existingCode = await this.shopProfileRepository.findMoneyBoxByCode(code);

    if (existingCode) {
      throw new ConflictError("Money box code already exists.");
    }

    return this.shopProfileRepository.createMoneyBox(command.shopId, { boxName, code, type, openingBalance, details, status });
  }
}
