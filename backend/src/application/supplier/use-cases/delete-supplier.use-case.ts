import { SupplierNotFoundError } from "@domain/supplier/supplier.errors";

import type { SupplierRepository } from "../ports/supplier-repository.port";

export class DeleteSupplierUseCase {
  constructor(private readonly supplierRepository: SupplierRepository) {}

  async execute(id: string) {
    const supplier = await this.supplierRepository.getSupplierByIdPlatform(id);
    if (!supplier) {
      throw new SupplierNotFoundError();
    }

    await this.supplierRepository.softDeleteSupplier(id);
  }
}
