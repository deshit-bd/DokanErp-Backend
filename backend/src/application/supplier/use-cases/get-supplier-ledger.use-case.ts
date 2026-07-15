import { SupplierNotFoundError } from "@domain/supplier/supplier.errors";

import type { ShopScope, SupplierRepository } from "../ports/supplier-repository.port";

export class GetSupplierLedgerUseCase {
  constructor(private readonly supplierRepository: SupplierRepository) {}

  async execute(shop: ShopScope, supplierId: string) {
    const supplier = await this.supplierRepository.resolveSupplierIdentifier(supplierId);
    if (!supplier) {
      throw new SupplierNotFoundError();
    }

    const ledgerEntries = await this.supplierRepository.getSupplierLedger(supplier.id, shop.id);

    let balance = 0;
    const ledger = ledgerEntries.map((entry: any) => {
      balance += Number(entry.debit ?? 0) - Number(entry.credit ?? 0);
      const paymentMethod = entry.purchase?.paymentMethod ?? entry.supplierPayment?.paymentMethod ?? null;

      return {
        id: entry.id,
        entryType: entry.entryType,
        referenceNo: entry.referenceNo,
        debit: Number(entry.debit ?? 0),
        credit: Number(entry.credit ?? 0),
        balance,
        notes: entry.notes,
        entryDate: entry.entryDate,
        purchaseId: entry.purchaseId,
        supplierPaymentId: entry.supplierPaymentId,
        paymentMethod,
      };
    });

    return { supplierId: supplier.id, supplierCode: supplier.supplierCode, shopId: shop.id, shopCode: shop.shopCode, ledger };
  }
}
