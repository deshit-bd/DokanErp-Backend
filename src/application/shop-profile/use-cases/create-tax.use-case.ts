import { ValidationError } from "@domain/shared/app-error";

import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class CreateTaxUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopId: string, name: string | undefined, rate: number | string | undefined, type: string | undefined) {
    if (!name || rate === undefined) {
      throw new ValidationError("Name and rate are required.");
    }
    return this.shopProfileRepository.createTax(shopId, { name, rate: Number(rate), type: type || "PERCENTAGE" });
  }
}
