import type { BrandStatus } from "@prisma/client";

import type { Brand } from "@domain/brand/brand.entity";
import { BrandNameRequiredError, BrandNotFoundError, DuplicateBrandNameError } from "@domain/brand/brand.errors";

import type { BrandRepository } from "../ports/brand-repository.port";
import type { LogoStoragePort } from "../ports/logo-storage.port";

export type UpdateBrandCommand = {
  id: string;
  name: string | undefined;
  description: string | null | undefined;
  logoUrl: string | null | undefined;
  status: BrandStatus | undefined;
  requestOrigin: string;
  performedById: string;
};

export class UpdateBrandUseCase {
  constructor(
    private readonly brandRepository: BrandRepository,
    private readonly logoStorage: LogoStoragePort,
  ) {}

  async execute(command: UpdateBrandCommand): Promise<Brand> {
    const name = command.name?.trim();
    const description = command.description?.trim() || null;
    const rawLogoUrl = command.logoUrl?.trim() || null;
    const status: BrandStatus = command.status ?? "ACTIVE";

    if (!name) {
      throw new BrandNameRequiredError();
    }

    const existingBrand = await this.brandRepository.findById(command.id);

    if (!existingBrand) {
      throw new BrandNotFoundError();
    }

    const duplicate = await this.brandRepository.findByNameExcept(name, command.id);

    if (duplicate) {
      throw new DuplicateBrandNameError();
    }

    // Unlike create, update persists the logo only after the duplicate check
    // passes — matches the original route's ordering exactly.
    const logoUrl = rawLogoUrl ? await this.logoStorage.store(rawLogoUrl, command.requestOrigin) : null;

    return this.brandRepository.update(command.id, {
      name,
      description,
      logoUrl,
      status,
      updatedByUserId: command.performedById,
    });
  }
}
