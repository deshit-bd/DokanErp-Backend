import { computeBrandStats, type Brand, type BrandStats } from "@domain/brand/brand.entity";

import type { BrandRepository } from "../ports/brand-repository.port";

export class ListBrandsUseCase {
  constructor(private readonly brandRepository: BrandRepository) {}

  async execute(): Promise<{ brands: Brand[]; stats: BrandStats }> {
    const brands = await this.brandRepository.findMany();
    return { brands, stats: computeBrandStats(brands) };
  }
}
