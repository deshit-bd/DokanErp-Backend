import { toBalanceType, toCustomerSummary, toMoney } from "@domain/customer/customer.entity";
import { CustomerNotFoundError, CustomerNotFoundForShopError } from "@domain/customer/customer.errors";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export class GetCustomerUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async executeFinance(shop: ShopScope, customerIdentifier: string) {
    const customer = await this.customerRepository.resolveCustomerLinkedToShop(customerIdentifier, shop.id);

    if (!customer) {
      throw new CustomerNotFoundForShopError();
    }

    const { summary, sales, payments, ledgerEntries } = await this.customerRepository.getCustomerFinanceDetail(customer.id, shop.id);
    const due = toMoney(summary.due);

    return {
      shop,
      customer: {
        ...toCustomerSummary(customer),
        finance: {
          totalSales: toMoney(summary.totalSales),
          totalPaid: toMoney(summary.totalPaid),
          due,
          balanceType: toBalanceType(due),
          dueLabel: due > 0 ? `Due ${due}` : "Paid",
        },
        recentSales: sales.map((sale: any) => ({
          id: sale.id,
          invoiceNo: sale.invoiceNo,
          saleDate: sale.saleDate,
          totalAmount: toMoney(sale.totalAmount),
          paidAmount: toMoney(sale.paidAmount),
          dueAmount: toMoney(sale.dueAmount),
          paymentMethod: sale.paymentMethod,
          notes: sale.notes,
        })),
        recentPayments: payments.map((payment: any) => ({
          id: payment.id,
          amount: toMoney(payment.amount),
          paymentMethod: payment.paymentMethod,
          paymentDetails: payment.paymentMeta ?? null,
          referenceNo: payment.referenceNo,
          notes: payment.notes,
          paidAt: payment.paidAt,
        })),
        recentTransactions: ledgerEntries.map((entry: any) => ({
          id: entry.id,
          entryType: entry.entryType,
          referenceNo: entry.referenceNo,
          debit: toMoney(entry.debit),
          credit: toMoney(entry.credit),
          notes: entry.notes,
          entryDate: entry.entryDate,
        })),
      },
    };
  }

  async executePlain(customerIdentifier: string) {
    const customer = await this.customerRepository.resolveCustomerIdentifier(customerIdentifier);

    if (!customer) {
      throw new CustomerNotFoundError();
    }

    return { customer: toCustomerSummary(customer) };
  }
}
