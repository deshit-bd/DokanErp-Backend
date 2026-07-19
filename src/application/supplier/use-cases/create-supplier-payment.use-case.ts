import { normalizeSupplierPayment } from "@domain/supplier/supplier.entity";
import { SupplierInvalidPaymentAmountError, SupplierNotFoundError, SupplierPaymentValidationError } from "@domain/supplier/supplier.errors";

import type { ShopScope, SupplierRepository } from "../ports/supplier-repository.port";

export class CreateSupplierPaymentUseCase {
  constructor(private readonly supplierRepository: SupplierRepository) {}

  async execute(
    shop: ShopScope,
    supplierId: string,
    body: {
      amount?: number | string;
      paymentMethod?: string | null;
      paymentDetails?: any;
      moneyBoxId?: string | null;
      notes?: string | null;
      paidAt?: string | null;
    },
  ) {
    const amount = Number(body.amount);
    const moneyBoxId = body.moneyBoxId?.trim() || null;
    const notes = body.notes?.trim() || null;
    const paidAt = body.paidAt ? new Date(body.paidAt) : new Date();

    if (!Number.isFinite(amount) || amount <= 0) {
      throw new SupplierInvalidPaymentAmountError();
    }

    const paymentInfo = normalizeSupplierPayment(body.paymentMethod, body.paymentDetails);

    if ("error" in paymentInfo) {
      throw new SupplierPaymentValidationError(paymentInfo.error);
    }

    const supplier = await this.supplierRepository.resolveSupplierIdentifier(supplierId);
    if (!supplier) {
      throw new SupplierNotFoundError();
    }

    const payment = await this.supplierRepository.createSupplierPayment({
      shopId: shop.id,
      supplierId: supplier.id,
      supplierCode: supplier.supplierCode,
      amount,
      paymentMethod: paymentInfo.paymentMethod,
      paymentMeta: paymentInfo.paymentMeta,
      moneyBoxId,
      notes,
      paidAt,
    });

    return {
      id: payment.id,
      shopId: payment.shopId,
      supplierId: payment.supplierId,
      amount: Number(payment.amount),
      paymentMethod: payment.paymentMethod,
      paymentDetails: payment.paymentMeta ?? null,
      moneyBoxId: payment.moneyBoxId,
      notes: payment.notes,
      paidAt: payment.paidAt,
    };
  }
}
