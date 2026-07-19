import { toBalanceType, toDisplayStatus, toMoney } from "@domain/supplier/supplier.entity";

import type { ShopScope, SupplierRepository } from "../ports/supplier-repository.port";

export class ListSuppliersUseCase {
  constructor(private readonly supplierRepository: SupplierRepository) {}

  async executeFinance(shop: ShopScope, query: { search?: unknown; status?: unknown; scope?: unknown }) {
    const search = typeof query.search === "string" ? query.search.trim() : "";
    const status = typeof query.status === "string" ? query.status.trim().toUpperCase() : "";
    const scope = typeof query.scope === "string" ? query.scope.trim().toLowerCase() : "finance";
    const financeOnly = scope !== "all";

    const suppliers = await this.supplierRepository.listSuppliersForShopFinance(shop.id, { search, status, financeOnly });

    const supplierSummaries = await Promise.all(
      suppliers.map(async (supplier: any) => {
        const summary = await this.supplierRepository.buildSupplierFinanceSummary(supplier.id, shop.id);
        const due = toMoney(summary.due);
        const totalPurchase = toMoney(summary.totalPurchase);
        const totalPaid = toMoney(summary.totalPaid);
        const lastLedgerEntry = supplier.supplierLedgers[0] ?? null;

        return {
          id: supplier.id,
          supplierCode: supplier.supplierCode,
          name: supplier.name,
          mobile: supplier.mobile,
          email: supplier.email,
          address: supplier.address,
          contactPerson: supplier.contactPerson,
          contactPersonMobile: supplier.contactPersonMobile,
          notes: supplier.notes,
          status: supplier.status,
          statusLabel: toDisplayStatus(supplier.status),
          avatarLabel: supplier.name?.charAt(0)?.toUpperCase() ?? "S",
          totalPurchase,
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
        total: supplierSummaries.length,
        active: supplierSummaries.filter((item) => item.status === "ACTIVE").length,
        inactive: supplierSummaries.filter((item) => item.status === "INACTIVE").length,
        archived: supplierSummaries.filter((item) => item.status === "ARCHIVED").length,
        totalDue: supplierSummaries.reduce((sum, item) => sum + item.due, 0),
      },
      suppliers: supplierSummaries,
    };
  }

  async executePlatform(query: { search?: unknown; status?: unknown }) {
    const search = typeof query.search === "string" ? query.search.trim() : "";
    const status = typeof query.status === "string" ? query.status.trim().toUpperCase() : "";

    const suppliers = await this.supplierRepository.listSuppliersPlatform({ search, status });

    return {
      stats: {
        total: suppliers.length,
        active: suppliers.filter((item: any) => item.status === "ACTIVE").length,
        inactive: suppliers.filter((item: any) => item.status === "INACTIVE").length,
        archived: suppliers.filter((item: any) => item.status === "ARCHIVED").length,
      },
      suppliers: suppliers.map((supplier: any) => ({
        id: supplier.id,
        supplierCode: supplier.supplierCode,
        name: supplier.name,
        mobile: supplier.mobile,
        email: supplier.email,
        address: supplier.address,
        contactPerson: supplier.contactPerson,
        contactPersonMobile: supplier.contactPersonMobile,
        notes: supplier.notes,
        status: supplier.status,
        statusLabel: toDisplayStatus(supplier.status),
        purchases: supplier._count.purchases,
        createdAt: supplier.createdAt,
        updatedAt: supplier.updatedAt,
      })),
    };
  }
}
