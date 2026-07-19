import { toBalanceType, toCustomerSummary, toMoney } from "@domain/customer/customer.entity";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export class ListCustomersUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async executeFinance(shop: ShopScope, query: { search?: unknown; status?: unknown }) {
    const search = typeof query.search === "string" ? query.search.trim() : "";
    const status = typeof query.status === "string" ? query.status.trim().toUpperCase() : "";

    const customers = await this.customerRepository.listCustomersForShopFinance(shop.id, { search, status });

    const customerSummaries = await Promise.all(
      customers.map(async (customer: any) => {
        const summary = await this.customerRepository.buildCustomerFinanceSummary(customer.id, shop.id);
        const due = toMoney(summary.due);
        const totalSales = toMoney(summary.totalSales);
        const totalPaid = toMoney(summary.totalPaid);
        const lastLedgerEntry = customer.ledgerEntries[0] ?? null;

        return {
          ...toCustomerSummary(customer),
          avatarLabel: customer.name?.charAt(0)?.toUpperCase() ?? "C",
          totalSales,
          totalPaid,
          due,
          balanceType: toBalanceType(due),
          dueLabel: due > 0 ? `Due ${due}` : "Paid",
          lastActivityAt: lastLedgerEntry?.entryDate ?? null,
          lastActivity: lastLedgerEntry
            ? {
                id: lastLedgerEntry.id,
                entryType: lastLedgerEntry.entryType,
                referenceNo: lastLedgerEntry.referenceNo,
                debit: toMoney(lastLedgerEntry.debit),
                credit: toMoney(lastLedgerEntry.credit),
                notes: lastLedgerEntry.notes,
                entryDate: lastLedgerEntry.entryDate,
              }
            : null,
        };
      }),
    );

    return {
      shop,
      stats: {
        total: customerSummaries.length,
        active: customerSummaries.filter((item) => item.status === "ACTIVE").length,
        inactive: customerSummaries.filter((item) => item.status === "INACTIVE").length,
        archived: customerSummaries.filter((item) => item.status === "ARCHIVED").length,
        totalSales: customerSummaries.reduce((sum, item) => sum + item.totalSales, 0),
        totalPaid: customerSummaries.reduce((sum, item) => sum + item.totalPaid, 0),
        totalDue: customerSummaries.reduce((sum, item) => sum + item.due, 0),
      },
      customers: customerSummaries,
    };
  }

  async executePlain(query: { search?: unknown; status?: unknown }) {
    const search = typeof query.search === "string" ? query.search.trim() : "";
    const status = typeof query.status === "string" ? query.status.trim().toUpperCase() : "";

    const customers = await this.customerRepository.listCustomersPlain({ search, status });

    return {
      stats: {
        total: customers.length,
        active: customers.filter((item: any) => item.status === "ACTIVE").length,
        inactive: customers.filter((item: any) => item.status === "INACTIVE").length,
        archived: customers.filter((item: any) => item.status === "ARCHIVED").length,
      },
      customers: customers.map(toCustomerSummary),
    };
  }
}
