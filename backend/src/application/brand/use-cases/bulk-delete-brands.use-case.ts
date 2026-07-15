import { InvalidBrandIdsError } from "@domain/brand/brand.errors";

import type { BrandRepository, BulkDeleteResult } from "../ports/brand-repository.port";

export class BulkDeleteBrandsUseCase {
  constructor(private readonly brandRepository: BrandRepository) {}

  async execute(ids: unknown, performedById: string): Promise<BulkDeleteResult> {
    if (!Array.isArray(ids) || ids.length === 0) {
      throw new InvalidBrandIdsError();
    }

    return this.brandRepository.bulkArchiveOrDelete(ids as string[], performedById);
  }
}
