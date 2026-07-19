import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class UpdateTaxUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(id: string, shopId: string, input: { isActive?: boolean; name?: string; rate?: number | string }) {
    await this.shopProfileRepository.updateTax(id, shopId, {
      ...(input.isActive !== undefined ? { isActive: input.isActive } : {}),
      ...(input.name ? { name: input.name } : {}),
      ...(input.rate !== undefined ? { rate: Number(input.rate) } : {}),
    });
  }
}
