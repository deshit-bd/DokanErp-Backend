import { toCustomerSaleSummary } from "@domain/customer/customer.entity";
import { SaleNotFoundError } from "@domain/customer/customer.errors";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export class GetSaleUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async execute(shop: ShopScope, saleId: string) {
    const sale = await this.customerRepository.findSaleById(saleId, shop.id);

    if (!sale) {
      throw new SaleNotFoundError();
    }

    const payment = await this.customerRepository.findLatestPaymentByReference(shop.id, sale.invoiceNo);

    return {
      shop,
      sale: {
        ...toCustomerSaleSummary(sale),
        customer: sale.customer ? { id: sale.customer.id, name: sale.customer.name, mobile: sale.customer.mobile, address: sale.customer.address } : null,
        paymentDetails: payment?.paymentMeta ?? null,
      },
    };
  }
}
