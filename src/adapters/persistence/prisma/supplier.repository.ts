import { buildSupplierCodeBase } from "@domain/supplier/supplier.entity";
import type { SupplierRepository } from "@application/supplier/ports/supplier-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

export class PrismaSupplierRepository implements SupplierRepository {
  async resolveShopIdentifier(identifier: string) {
    const normalized = identifier?.trim();
    if (!normalized) return null;

    return prisma.shop.findFirst({
      where: { OR: [{ id: normalized }, { shopCode: normalized }] },
      select: { id: true, shopCode: true, shopName: true, phone: true, address: true, area: true, district: true, status: true },
    });
  }

  async resolveSupplierIdentifier(identifier: string) {
    const normalized = identifier?.trim();
    if (!normalized) return null;

    return (prisma as any).supplier.findFirst({
      where: { deletedAt: null, OR: [{ id: normalized }, { supplierCode: normalized }] },
      select: {
        id: true,
        supplierCode: true,
        name: true,
        mobile: true,
        email: true,
        address: true,
        contactPerson: true,
        contactPersonMobile: true,
        notes: true,
        status: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async buildSupplierFinanceSummary(supplierId: string, shopId: string) {
    const ledgerEntries = await (prisma as any).supplierLedger.findMany({
      where: { supplierId, shopId },
      select: { debit: true, credit: true, entryType: true },
    });

    const totalDebit = ledgerEntries.reduce((sum: number, entry: any) => sum + Number(entry.debit ?? 0), 0);
    const totalCredit = ledgerEntries.reduce((sum: number, entry: any) => sum + Number(entry.credit ?? 0), 0);
    const totalPurchase = ledgerEntries
      .filter((entry: any) => entry.entryType === "PURCHASE")
      .reduce((sum: number, entry: any) => sum + Number(entry.debit ?? 0), 0);
    const totalPaid = ledgerEntries
      .filter((entry: any) => entry.entryType === "PAYMENT")
      .reduce((sum: number, entry: any) => sum + Number(entry.credit ?? 0), 0);

    return { totalPurchase, totalPaid, due: Math.max(0, totalDebit - totalCredit) };
  }

  async listSuppliersForShopFinance(shopId: string, filters: { search: string; status: string; financeOnly: boolean }) {
    return (prisma as any).supplier.findMany({
      where: {
        deletedAt: null,
        ...(filters.status ? { status: filters.status } : {}),
        AND: [
          ...(filters.financeOnly
            ? [
                {
                  OR: [
                    { purchases: { some: { shopId } } },
                    { supplierPayments: { some: { shopId } } },
                    { supplierLedgers: { some: { shopId } } },
                  ],
                },
              ]
            : []),
          ...(filters.search
            ? [
                {
                  OR: [
                    { supplierCode: { contains: filters.search, mode: "insensitive" } },
                    { name: { contains: filters.search, mode: "insensitive" } },
                    { mobile: { contains: filters.search, mode: "insensitive" } },
                    { email: { contains: filters.search, mode: "insensitive" } },
                    { contactPerson: { contains: filters.search, mode: "insensitive" } },
                    { contactPersonMobile: { contains: filters.search, mode: "insensitive" } },
                  ],
                },
              ]
            : []),
        ],
      },
      include: {
        supplierLedgers: {
          where: { shopId },
          orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
          take: 1,
          select: { id: true, entryType: true, referenceNo: true, debit: true, credit: true, notes: true, entryDate: true },
        },
      },
      orderBy: [{ name: "asc" }],
    });
  }

  async listSuppliersPlatform(filters: { search: string; status: string }) {
    return (prisma as any).supplier.findMany({
      where: {
        deletedAt: null,
        ...(filters.status ? { status: filters.status } : {}),
        ...(filters.search
          ? {
              OR: [
                { supplierCode: { contains: filters.search, mode: "insensitive" } },
                { name: { contains: filters.search, mode: "insensitive" } },
                { mobile: { contains: filters.search, mode: "insensitive" } },
                { email: { contains: filters.search, mode: "insensitive" } },
                { contactPerson: { contains: filters.search, mode: "insensitive" } },
                { contactPersonMobile: { contains: filters.search, mode: "insensitive" } },
              ],
            }
          : {}),
      },
      include: { _count: { select: { purchases: true } } },
      orderBy: [{ createdAt: "desc" }, { name: "asc" }],
    });
  }

  async createUniqueSupplierCode(name: string) {
    const base = buildSupplierCodeBase(name);

    for (let attempt = 0; attempt < 10; attempt += 1) {
      const suffix = `${Date.now()}`.slice(-4) + `${Math.floor(Math.random() * 100)}`.padStart(2, "0");
      const candidate = `${base}-${suffix}`;
      const existing = await (prisma as any).supplier.findFirst({ where: { supplierCode: candidate }, select: { id: true } });
      if (!existing) return candidate;
    }

    return `${base}-${Math.floor(Date.now() / 1000)}`;
  }

  async findSupplierForLinkCheck(params: { supplierCode: string; mobile: string | null; name: string }) {
    return (prisma as any).supplier.findFirst({
      where: {
        deletedAt: null,
        OR: [{ supplierCode: params.supplierCode }, ...(params.mobile ? [{ mobile: params.mobile }] : []), { name: params.name }],
      },
      select: {
        id: true,
        supplierCode: true,
        name: true,
        mobile: true,
        email: true,
        address: true,
        contactPerson: true,
        contactPersonMobile: true,
        notes: true,
        status: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async isSupplierLinkedToShop(supplierId: string, shopId: string) {
    const linked = await (prisma as any).supplier.findFirst({
      where: {
        id: supplierId,
        OR: [
          { purchases: { some: { shopId } } },
          { supplierPayments: { some: { shopId } } },
          { supplierLedgers: { some: { shopId } } },
        ],
      },
      select: { id: true },
    });
    return Boolean(linked);
  }

  async createShopSupplierOpeningDue(params: { shopId: string; supplierId: string; referenceNo: string | null; dueAmount: number; notes: string | null }) {
    return (prisma as any).supplierLedger.create({
      data: {
        shopId: params.shopId,
        supplierId: params.supplierId,
        entryType: "OPENING_DUE",
        referenceNo: params.referenceNo,
        debit: params.dueAmount,
        credit: 0,
        notes: params.notes,
        entryDate: new Date(),
      },
    });
  }

  async createGlobalSupplier(data: any) {
    return (prisma as any).supplier.create({ data });
  }

  async findSupplierForPlatformDuplicateCheck(params: { supplierCode?: string; name: string; excludeId?: string }) {
    return (prisma as any).supplier.findFirst({
      where: {
        deletedAt: null,
        ...(params.excludeId ? { id: { not: params.excludeId } } : {}),
        OR: [...(params.supplierCode ? [{ supplierCode: params.supplierCode }] : []), { name: params.name }],
      },
      select: { id: true, supplierCode: true, name: true },
    });
  }

  async getSupplierByIdPlatform(id: string) {
    return (prisma as any).supplier.findFirst({
      where: { id, deletedAt: null },
      include: { _count: { select: { purchases: true } } },
    });
  }

  async updateSupplier(id: string, data: any) {
    return (prisma as any).supplier.update({ where: { id }, data });
  }

  async softDeleteSupplier(id: string) {
    await (prisma as any).supplier.update({ where: { id }, data: { status: "ARCHIVED", deletedAt: new Date() } });
  }

  async updateSupplierStatus(id: string, status: string) {
    return (prisma as any).supplier.update({ where: { id }, data: { status } });
  }

  async getSupplierFinanceDetail(supplierId: string, shopId: string) {
    const [summary, purchases, payments, ledgerEntries] = await Promise.all([
      this.buildSupplierFinanceSummary(supplierId, shopId),
      (prisma as any).purchase.findMany({
        where: { shopId, supplierId },
        orderBy: [{ purchaseDate: "desc" }, { createdAt: "desc" }],
        take: 5,
        select: { id: true, invoiceNo: true, purchaseDate: true, totalAmount: true, paidAmount: true, dueAmount: true, notes: true },
      }),
      (prisma as any).supplierPayment.findMany({
        where: { shopId, supplierId },
        orderBy: [{ paidAt: "desc" }, { createdAt: "desc" }],
        take: 5,
        select: { id: true, amount: true, paymentMethod: true, paymentMeta: true, notes: true, paidAt: true },
      }),
      (prisma as any).supplierLedger.findMany({
        where: { shopId, supplierId },
        orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
        take: 10,
        select: {
          id: true,
          entryType: true,
          referenceNo: true,
          debit: true,
          credit: true,
          notes: true,
          entryDate: true,
          purchaseId: true,
          supplierPaymentId: true,
          purchase: { select: { paymentMethod: true } },
          supplierPayment: { select: { paymentMethod: true } },
        },
      }),
    ]);

    return { summary, purchases, payments, ledgerEntries };
  }

  async getSupplierLedger(supplierId: string, shopId: string) {
    return (prisma as any).supplierLedger.findMany({
      where: { supplierId, shopId },
      include: { purchase: { select: { paymentMethod: true } }, supplierPayment: { select: { paymentMethod: true } } },
      orderBy: [{ entryDate: "asc" }, { createdAt: "asc" }],
    });
  }

  async createSupplierPayment(params: {
    shopId: string;
    supplierId: string;
    supplierCode: string | null;
    amount: number;
    paymentMethod: string;
    paymentMeta: Record<string, unknown> | null;
    moneyBoxId: string | null;
    notes: string | null;
    paidAt: Date;
  }) {
    const payment = await (prisma as any).supplierPayment.create({
      data: {
        shopId: params.shopId,
        supplierId: params.supplierId,
        amount: params.amount,
        paymentMethod: params.paymentMethod,
        paymentMeta: params.paymentMeta,
        moneyBoxId: params.moneyBoxId,
        notes: params.notes,
        paidAt: params.paidAt,
      },
    });

    await (prisma as any).supplierLedger.create({
      data: {
        shopId: params.shopId,
        supplierId: params.supplierId,
        supplierPaymentId: payment.id,
        entryType: "PAYMENT",
        referenceNo: params.supplierCode,
        debit: 0,
        credit: params.amount,
        notes: params.notes,
        entryDate: params.paidAt,
      },
    });

    return payment;
  }

  async listSupplierPayments(supplierId: string, shopId: string) {
    return (prisma as any).supplierPayment.findMany({
      where: { supplierId, shopId },
      orderBy: [{ paidAt: "desc" }, { createdAt: "desc" }],
    });
  }

  async listSupplierPurchases(supplierId: string, shopId: string) {
    return (prisma as any).purchase.findMany({
      where: { supplierId, shopId },
      include: { items: { include: { masterProduct: { select: { id: true, name: true, sku: true } } } } },
      orderBy: [{ purchaseDate: "desc" }, { createdAt: "desc" }],
    });
  }
}
