import { toCustomerSummary, toMoney } from "@domain/customer/customer.entity";
import { CustomerNotFoundForShopError } from "@domain/customer/customer.errors";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export class GetCustomerLedgerUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async execute(shop: ShopScope, customerIdentifier: string) {
    const customer = await this.customerRepository.resolveCustomerLinkedToShop(customerIdentifier, shop.id);

    if (!customer) {
      throw new CustomerNotFoundForShopError();
    }

    const ledgerEntries = await this.customerRepository.getCustomerLedger(customer.id, shop.id);

    let balance = 0;
    const ledger = ledgerEntries.map((entry: any) => {
      balance += toMoney(entry.debit) - toMoney(entry.credit);

      return {
        id: entry.id,
        entryType: entry.entryType,
        referenceNo: entry.referenceNo,
        debit: toMoney(entry.debit),
        credit: toMoney(entry.credit),
        balance,
        notes: entry.notes,
        entryDate: entry.entryDate,
        sale: entry.customerSale
          ? {
              id: entry.customerSale.id,
              invoiceNo: entry.customerSale.invoiceNo,
              saleDate: entry.customerSale.saleDate,
              totalAmount: toMoney(entry.customerSale.totalAmount),
              paidAmount: toMoney(entry.customerSale.paidAmount),
              dueAmount: toMoney(entry.customerSale.dueAmount),
            }
          : null,
        payment: entry.customerPayment
          ? {
              id: entry.customerPayment.id,
              amount: toMoney(entry.customerPayment.amount),
              paymentMethod: entry.customerPayment.paymentMethod,
              paymentDetails: entry.customerPayment.paymentMeta ?? null,
              referenceNo: entry.customerPayment.referenceNo,
              paidAt: entry.customerPayment.paidAt,
            }
          : null,
      };
    });

    return { shop, customer: toCustomerSummary(customer), ledger, due: balance };
  }
}
