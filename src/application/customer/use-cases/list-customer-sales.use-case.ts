import { toCustomerSummary, toMoney } from "@domain/customer/customer.entity";
import { CustomerNotFoundForShopError } from "@domain/customer/customer.errors";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export class ListCustomerSalesUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async execute(shop: ShopScope, customerIdentifier: string) {
    const customer = await this.customerRepository.resolveCustomerLinkedToShop(customerIdentifier, shop.id);

    if (!customer) {
      throw new CustomerNotFoundForShopError();
    }

    const sales = await this.customerRepository.listCustomerSales(customer.id, shop.id);

    return {
      shop,
      customer: toCustomerSummary(customer),
      sales: sales.map((sale: any) => ({
        id: sale.id,
        invoiceNo: sale.invoiceNo,
        saleDate: sale.saleDate,
        totalAmount: toMoney(sale.totalAmount),
        paidAmount: toMoney(sale.paidAmount),
        dueAmount: toMoney(sale.dueAmount),
        paymentMethod: sale.paymentMethod,
        notes: sale.notes,
        salesmanPhone: sale.createdBy?.phone ?? null,
        salesmanName: sale.createdBy?.name ?? null,
        items: sale.items.map((item: any) => ({
          id: item.id,
          masterProductId: item.masterProductId,
          name: item.masterProduct.name,
          sku: item.masterProduct.sku,
          quantity: toMoney(item.quantity),
          salePrice: toMoney(item.salePrice),
          totalAmount: toMoney(item.totalAmount),
        })),
      })),
    };
  }
}
