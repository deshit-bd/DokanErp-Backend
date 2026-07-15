import { toDisplayStatus, type SupplierStatusValue } from "@domain/supplier/supplier.entity";
import { DuplicateSupplierCodeError, DuplicateSupplierNameError, SupplierCodeRequiredError, SupplierNameRequiredError, SupplierNotFoundError } from "@domain/supplier/supplier.errors";

import type { SupplierRepository } from "../ports/supplier-repository.port";

export class UpdateSupplierUseCase {
  constructor(private readonly supplierRepository: SupplierRepository) {}

  async execute(
    id: string,
    body: {
      supplierCode?: string;
      name?: string;
      mobile?: string | null;
      email?: string | null;
      address?: string | null;
      contactPerson?: string | null;
      contactPersonMobile?: string | null;
      notes?: string | null;
      status?: SupplierStatusValue;
    },
  ) {
    const supplier = await this.supplierRepository.getSupplierByIdPlatform(id);
    if (!supplier) {
      throw new SupplierNotFoundError();
    }

    const supplierCode = body.supplierCode?.trim();
    const name = body.name?.trim();
    const mobile = body.mobile?.trim() || null;
    const email = body.email?.trim() || null;
    const address = body.address?.trim() || null;
    const contactPerson = body.contactPerson?.trim() || null;
    const contactPersonMobile = body.contactPersonMobile?.trim() || null;
    const notes = body.notes?.trim() || null;
    const status = body.status ?? supplier.status;

    if (!supplierCode) throw new SupplierCodeRequiredError();
    if (!name) throw new SupplierNameRequiredError();

    const duplicateSupplier = await this.supplierRepository.findSupplierForPlatformDuplicateCheck({ supplierCode, name, excludeId: id });

    if (duplicateSupplier) {
      throw duplicateSupplier.supplierCode === supplierCode ? new DuplicateSupplierCodeError() : new DuplicateSupplierNameError();
    }

    const updated = await this.supplierRepository.updateSupplier(id, {
      supplierCode,
      name,
      mobile,
      email,
      address,
      contactPerson,
      contactPersonMobile,
      notes,
      status,
    });

    return {
      id: updated.id,
      supplierCode: updated.supplierCode,
      name: updated.name,
      mobile: updated.mobile,
      email: updated.email,
      address: updated.address,
      contactPerson: updated.contactPerson,
      contactPersonMobile: updated.contactPersonMobile,
      notes: updated.notes,
      status: updated.status,
      statusLabel: toDisplayStatus(updated.status),
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
    };
  }
}
