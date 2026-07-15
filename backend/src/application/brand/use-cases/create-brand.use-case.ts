import type { BrandStatus } from "@prisma/client";

import type { Brand } from "@domain/brand/brand.entity";
import { BrandNameRequiredError, DuplicateBrandNameError } from "@domain/brand/brand.errors";

import type { BrandRepository } from "../ports/brand-repository.port";
import type { LogoStoragePort } from "../ports/logo-storage.port";

export type CreateBrandCommand = {
  name: string | undefined;
  description: string | null | undefined;
  logoUrl: string | null | undefined;
  status: BrandStatus | undefined;
  requestOrigin: string;
  performedById: string;
};

export class CreateBrandUseCase {
  constructor(
    private readonly brandRepository: BrandRepository,
    private readonly logoStorage: LogoStoragePort,
  ) {}

  async execute(command: CreateBrandCommand): Promise<Brand> {
    const name = command.name?.trim();
    const description = command.description?.trim() || null;
    const rawLogoUrl = command.logoUrl?.trim() || null;
    const status: BrandStatus = command.status ?? "ACTIVE";

    if (!name) {
      throw new BrandNameRequiredError();
    }

    // Matches the original route's order exactly: the logo is persisted to
    // disk before the duplicate-name check runs, so a duplicate submission
    // still results in a wasted file write (a pre-existing quirk, preserved).
    const logoUrl = rawLogoUrl ? await this.logoStorage.store(rawLogoUrl, command.requestOrigin) : null;

    const existing = await this.brandRepository.findByName(name);

    if (existing) {
      throw new DuplicateBrandNameError();
    }

    return this.brandRepository.create({
      name,
      description,
      logoUrl,
      status,
      createdByUserId: command.performedById,
    });
  }
}
