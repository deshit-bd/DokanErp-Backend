import { toDisplayStatus, type SupplierStatusValue } from "@domain/supplier/supplier.entity";
import { InvalidSupplierStatusError, SupplierNotFoundError } from "@domain/supplier/supplier.errors";

import type { SupplierRepository } from "../ports/supplier-repository.port";

const VALID_STATUSES: SupplierStatusValue[] = ["ACTIVE", "INACTIVE", "ARCHIVED"];

export class UpdateSupplierStatusUseCase {
  constructor(private readonly supplierRepository: SupplierRepository) {}

  async execute(id: string, status: unknown) {
    if (!status || !VALID_STATUSES.includes(status as SupplierStatusValue)) {
      throw new InvalidSupplierStatusError();
    }

    const supplier = await this.supplierRepository.getSupplierByIdPlatform(id);
    if (!supplier) {
      throw new SupplierNotFoundError();
    }

    const updated = await this.supplierRepository.updateSupplierStatus(id, status as SupplierStatusValue);

    return { id: updated.id, status: updated.status, statusLabel: toDisplayStatus(updated.status) };
  }
}
