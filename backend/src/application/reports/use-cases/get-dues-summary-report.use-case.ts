import { getAgingBucketKey, getRangeBounds, parseRangeParam } from "@domain/reports/reports.entity";

import type { ReportsRepository } from "../ports/reports-repository.port";

export class GetDuesSummaryReportUseCase {
  constructor(private readonly reportsRepository: ReportsRepository) {}

  async execute(shopId: string, query: { range?: unknown }) {
    const range = parseRangeParam(query.range);
    const { start, end } = getRangeBounds(range);
    const now = new Date();

    const {
      customerLedgerGroups,
      supplierLedgerGroups,
      customerDebitEntries,
      supplierDebitEntries,
      rangedDueSales,
      rangedCustomerCollections,
      rangedDuePurchases,
      rangedSupplierPayments,
      customers,
      suppliers,
    } = await this.reportsRepository.getDuesSummaryRawData(shopId, start, end);

    const customerMap = new Map(customers.map((customer: any) => [customer.id, customer]));
    const supplierMap = new Map(suppliers.map((supplier: any) => [supplier.id, supplier]));
    const lastCustomerDebitMap = new Map<string, Date>();
    const lastSupplierDebitMap = new Map<string, Date>();

    for (const entry of customerDebitEntries) {
      if (!lastCustomerDebitMap.has(entry.customerId)) {
        lastCustomerDebitMap.set(entry.customerId, entry.entryDate);
      }
    }

    for (const entry of supplierDebitEntries) {
      if (!lastSupplierDebitMap.has(entry.supplierId)) {
        lastSupplierDebitMap.set(entry.supplierId, entry.entryDate);
      }
    }

    const customerAgingBuckets = { "0_7": 0, "8_15": 0, "16_30": 0, "31_plus": 0 };
    const supplierAgingBuckets = { "0_7": 0, "8_15": 0, "16_30": 0, "31_plus": 0 };

    const topReceivables = customerLedgerGroups
      .map((entry: any) => {
        const due = Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0));
        const customer: any = customerMap.get(entry.customerId);
        const lastDebitAt = lastCustomerDebitMap.get(entry.customerId) || null;
        const ageDays = lastDebitAt ? Math.max(0, Math.floor((now.getTime() - lastDebitAt.getTime()) / 86400000)) : 0;
        if (due > 0) {
          customerAgingBuckets[getAgingBucketKey(ageDays)] += due;
        }
        return {
          id: entry.customerId,
          name: customer?.name || "অজানা গ্রাহক",
          mobile: customer?.mobile || "",
          due: Math.round(due),
          ageDays,
          lastDebitAt,
        };
      })
      .filter((entry) => entry.due > 0)
      .sort((a, b) => b.due - a.due)
      .slice(0, 5)
      .map((entry, index) => ({ rank: index + 1, ...entry }));

    const topPayables = supplierLedgerGroups
      .map((entry: any) => {
        const due = Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0));
        const supplier: any = supplierMap.get(entry.supplierId);
        const lastDebitAt = lastSupplierDebitMap.get(entry.supplierId) || null;
        const ageDays = lastDebitAt ? Math.max(0, Math.floor((now.getTime() - lastDebitAt.getTime()) / 86400000)) : 0;
        if (due > 0) {
          supplierAgingBuckets[getAgingBucketKey(ageDays)] += due;
        }
        return {
          id: entry.supplierId,
          name: supplier?.name || "অজানা সরবরাহকারী",
          mobile: supplier?.mobile || "",
          due: Math.round(due),
          ageDays,
          lastDebitAt,
        };
      })
      .filter((entry) => entry.due > 0)
      .sort((a, b) => b.due - a.due)
      .slice(0, 5)
      .map((entry, index) => ({ rank: index + 1, ...entry }));

    const totalReceivable = Math.round(
      customerLedgerGroups.reduce(
        (sum: number, entry: any) => sum + Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)),
        0,
      ),
    );
    const totalPayable = Math.round(
      supplierLedgerGroups.reduce(
        (sum: number, entry: any) => sum + Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)),
        0,
      ),
    );
    const customerDueCreated = Math.round(rangedDueSales.reduce((sum: number, sale: any) => sum + Number(sale.dueAmount ?? 0), 0));
    const customerDueCollected = Math.round(
      rangedCustomerCollections.reduce((sum: number, payment: any) => sum + Number(payment.credit ?? 0), 0),
    );
    const supplierDueCreated = Math.round(
      rangedDuePurchases.reduce((sum: number, purchase: any) => sum + Number(purchase.dueAmount ?? 0), 0),
    );
    const supplierDuePaid = Math.round(
      rangedSupplierPayments.reduce((sum: number, payment: any) => sum + Number(payment.amount ?? 0), 0),
    );

    return {
      summary: {
        totalReceivable,
        totalPayable,
        netBalance: Math.round(totalReceivable - totalPayable),
        receivableCustomers: customerLedgerGroups.filter(
          (entry: any) => Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)) > 0,
        ).length,
        payableSuppliers: supplierLedgerGroups.filter(
          (entry: any) => Math.max(0, Number(entry._sum.debit ?? 0) - Number(entry._sum.credit ?? 0)) > 0,
        ).length,
      },
      activity: { customerDueCreated, customerDueCollected, supplierDueCreated, supplierDuePaid },
      aging: {
        receivable: [
          { key: "0_7", label: "০-৭ দিন", amount: Math.round(customerAgingBuckets["0_7"]) },
          { key: "8_15", label: "৮-১৫ দিন", amount: Math.round(customerAgingBuckets["8_15"]) },
          { key: "16_30", label: "১৬-৩০ দিন", amount: Math.round(customerAgingBuckets["16_30"]) },
          { key: "31_plus", label: "৩১+ দিন", amount: Math.round(customerAgingBuckets["31_plus"]) },
        ],
        payable: [
          { key: "0_7", label: "০-৭ দিন", amount: Math.round(supplierAgingBuckets["0_7"]) },
          { key: "8_15", label: "৮-১৫ দিন", amount: Math.round(supplierAgingBuckets["8_15"]) },
          { key: "16_30", label: "১৬-৩০ দিন", amount: Math.round(supplierAgingBuckets["16_30"]) },
          { key: "31_plus", label: "৩১+ দিন", amount: Math.round(supplierAgingBuckets["31_plus"]) },
        ],
      },
      topReceivables,
      topPayables,
      meta: { range, startDate: start, endDate: end, generatedAt: new Date() },
    };
  }
}
