import { ConflictError, NotFoundError, ValidationError } from "@domain/shared/app-error";
import { normalizeOptionalText } from "@domain/shop-profile/shop-profile.entity";

import type { MoneyBoxSource, ShopProfileRepository } from "../ports/shop-profile-repository.port";

export type UpdateShopMoneyBoxCommand = {
  id: string;
  shopId: string;
  boxName: string | undefined;
  code: string | undefined;
  type: string | undefined;
  openingBalance: number | string | undefined;
  details: string | null | undefined;
  status: string | undefined;
};

export class UpdateShopMoneyBoxUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(command: UpdateShopMoneyBoxCommand): Promise<MoneyBoxSource> {
    const existing = await this.shopProfileRepository.findShopMoneyBox(command.id, command.shopId);

    if (!existing) {
      throw new NotFoundError("Money box not found in this shop.");
    }

    const boxName = (command.boxName ?? existing.boxName ?? "").trim();
    const code = (command.code ?? existing.code ?? "").trim();
    const type = command.type ?? existing.type;
    const details = command.details === undefined ? existing.details : normalizeOptionalText(command.details);
    const status = command.status ?? existing.status;
    const openingBalance = command.openingBalance === undefined ? Number(existing.openingBalance ?? 0) : Number(command.openingBalance ?? 0);

    if (!boxName || !code || !type) {
      throw new ValidationError("boxName, code, and type are required.");
    }
    if (!Number.isFinite(openingBalance)) {
      throw new ValidationError("Opening balance must be a valid number.");
    }

    const duplicateCode = await this.shopProfileRepository.findMoneyBoxByCodeExcept(code, existing.id);

    if (duplicateCode) {
      throw new ConflictError("Money box code already exists.");
    }

    return this.shopProfileRepository.updateMoneyBoxWithBalanceDelta(
      existing.id,
      { boxName, code, type, openingBalance, details, status },
      Number(existing.openingBalance ?? 0),
      Number(existing.currentBalance ?? 0),
    );
  }
}
