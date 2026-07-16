import { normalizeText, toCustomerSaleSummary } from "@domain/customer/customer.entity";
import { CancellationReasonRequiredError, SaleAlreadyCancelledError, SaleNotFoundError } from "@domain/customer/customer.errors";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export class CancelSaleUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async execute(
    shop: ShopScope,
    saleId: string,
    createdByUserId: string,
    body: { refundMethod?: string | null; reason?: string | null; notes?: string | null },
  ) {
    const refundMethod = normalizeText(body.refundMethod).toUpperCase() || "CASH_REFUND";
    const reason = normalizeText(body.reason);
    const notes = normalizeText(body.notes);

    if (!reason) {
      throw new CancellationReasonRequiredError();
    }

    const result = await this.customerRepository.cancelSale({ saleId, shopId: shop.id, refundMethod, reason, notes: notes || null, createdByUserId });

    if ("errorStatus" in result) {
      if (result.errorStatus === 404) throw new SaleNotFoundError();
      throw new SaleAlreadyCancelledError();
    }

    return toCustomerSaleSummary(result.sale);
  }
}
