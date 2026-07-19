import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class UpdateChargeUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(id: string, shopId: string, input: { isActive?: boolean; name?: string; amount?: number | string; type?: string }) {
    await this.shopProfileRepository.updateCharge(id, shopId, {
      ...(input.isActive !== undefined ? { isActive: input.isActive } : {}),
      ...(input.name ? { name: input.name } : {}),
      ...(input.amount !== undefined ? { amount: Number(input.amount) } : {}),
      ...(input.type ? { type: input.type } : {}),
    });
  }
}
