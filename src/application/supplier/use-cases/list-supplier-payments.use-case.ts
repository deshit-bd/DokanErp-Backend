import { SupplierNotFoundError } from "@domain/supplier/supplier.errors";

import type { ShopScope, SupplierRepository } from "../ports/supplier-repository.port";

export class ListSupplierPaymentsUseCase {
  constructor(private readonly supplierRepository: SupplierRepository) {}

  async execute(shop: ShopScope, supplierId: string) {
    const supplier = await this.supplierRepository.resolveSupplierIdentifier(supplierId);
    if (!supplier) {
      throw new SupplierNotFoundError();
    }

    const payments = await this.supplierRepository.listSupplierPayments(supplier.id, shop.id);

    return {
      supplierId: supplier.id,
      supplierCode: supplier.supplierCode,
      shopId: shop.id,
      shopCode: shop.shopCode,
      payments: payments.map((payment: any) => ({
        id: payment.id,
        amount: Number(payment.amount),
        paymentMethod: payment.paymentMethod,
        paymentDetails: payment.paymentMeta ?? null,
        moneyBoxId: payment.moneyBoxId,
        notes: payment.notes,
        paidAt: payment.paidAt,
        createdAt: payment.createdAt,
      })),
    };
  }
}
