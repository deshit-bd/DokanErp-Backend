import { toBalanceType, toDisplayStatus, toMoney } from "@domain/supplier/supplier.entity";
import { SupplierNotFoundError } from "@domain/supplier/supplier.errors";

import type { ShopScope, SupplierRepository } from "../ports/supplier-repository.port";

export class GetSupplierUseCase {
  constructor(private readonly supplierRepository: SupplierRepository) {}

  async executeFinance(shop: ShopScope, supplierId: string) {
    const supplier = await this.supplierRepository.resolveSupplierIdentifier(supplierId);

    if (!supplier) {
      throw new SupplierNotFoundError();
    }

    const { summary, purchases, payments, ledgerEntries } = await this.supplierRepository.getSupplierFinanceDetail(supplier.id, shop.id);
    const due = toMoney(summary.due);

    return {
      shop,
      supplier: {
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
        summary: { totalPurchase: toMoney(summary.totalPurchase), totalPaid: toMoney(summary.totalPaid), due, balanceType: toBalanceType(due) },
        recentPurchases: purchases.map((purchase: any) => ({
          id: purchase.id,
          invoiceNo: purchase.invoiceNo,
          purchaseDate: purchase.purchaseDate,
          totalAmount: toMoney(purchase.totalAmount),
          paidAmount: toMoney(purchase.paidAmount),
          dueAmount: toMoney(purchase.dueAmount),
          notes: purchase.notes,
        })),
        recentPayments: payments.map((payment: any) => ({
          id: payment.id,
          amount: toMoney(payment.amount),
          paymentMethod: payment.paymentMethod,
          paymentDetails: payment.paymentMeta ?? null,
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
          purchaseId: entry.purchaseId,
          supplierPaymentId: entry.supplierPaymentId,
          paymentMethod: entry.purchase?.paymentMethod ?? entry.supplierPayment?.paymentMethod ?? null,
        })),
        createdAt: supplier.createdAt,
        updatedAt: supplier.updatedAt,
      },
    };
  }

  async executePlatform(supplierId: string) {
    const supplier = await this.supplierRepository.getSupplierByIdPlatform(supplierId);

    if (!supplier) {
      throw new SupplierNotFoundError();
    }

    return {
      supplier: {
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
      },
    };
  }
}
