import { ValidationError } from "@domain/shared/app-error";

import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class CreateChargeUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopId: string, name: string | undefined, amount: number | string | undefined, type: string | undefined) {
    if (!name || amount === undefined) {
      throw new ValidationError("Name and amount are required.");
    }
    return this.shopProfileRepository.createCharge(shopId, { name, amount: Number(amount), type: type || "FIXED" });
  }
}
