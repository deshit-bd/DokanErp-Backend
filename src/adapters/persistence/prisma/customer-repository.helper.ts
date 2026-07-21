import { normalizeBatchOrder, buildCustomerCodeBase } from "../../../domain/customer/customer.entity";
import { ensureGeneralInventoryBin } from "./inventory.repository";
import { prisma } from "../../../infrastructure/prisma/client";

export async function resolveShopProductTx(tx: any, shopId: string, identifier: string) {
  if (!identifier) return null;

  let shopProduct = await tx.shopProduct.findUnique({ where: { id: identifier }, include: { masterProduct: true } });
  if (shopProduct && shopProduct.shopId === shopId) {
    return shopProduct;
  }

  shopProduct = await tx.shopProduct.findFirst({ where: { shopId, localBarcode: identifier }, include: { masterProduct: true } });
  if (shopProduct) return shopProduct;

  shopProduct = await tx.shopProduct.findUnique({
    where: { shopId_masterProductId: { shopId, masterProductId: identifier } },
    include: { masterProduct: true },
  });
  if (shopProduct) return shopProduct;

  const masterBarcode = await tx.masterProductBarcode.findUnique({
    where: { barcode: identifier },
    include: { masterProduct: { include: { shopProducts: { where: { shopId } } } } },
  });
  if (masterBarcode?.masterProduct?.shopProducts?.[0]) {
    return { ...masterBarcode.masterProduct.shopProducts[0], masterProduct: masterBarcode.masterProduct };
  }

  const masterSku = await tx.masterProduct.findUnique({ where: { sku: identifier }, include: { shopProducts: { where: { shopId } } } });
  if (masterSku?.shopProducts?.[0]) {
    return { ...masterSku.shopProducts[0], masterProduct: masterSku };
  }

  return null;
}

export function resolveCustomerLinkedWhere(customerIdentifier: string) {
  let normalized = customerIdentifier.trim();
  if (normalized.startsWith("num:")) {
    normalized = normalized.substring(4).trim();
  } else if (normalized.startsWith("name:")) {
    normalized = normalized.substring(5).trim();
  }
  return { deletedAt: null, OR: [{ id: normalized }, { mobile: normalized }, { name: normalized }] };
}

export async function resolveShopMoneyBoxHelper(tx: any, shopId: string, moneyBoxId?: string | null) {
  const normalized = moneyBoxId?.trim();
  if (!normalized) return null;

  return tx.moneyBox.findFirst({
    where: { id: normalized, shopId },
    select: { id: true, boxName: true, code: true, type: true },
  });
}

export async function resolveDefaultMoneyBoxByTypeHelper(tx: any, shopId: string, type?: string | null) {
  const normalizedType = (type ?? "").toString().trim().toUpperCase();
  if (!normalizedType || !["CASH", "BKASH", "NAGAD"].includes(normalizedType)) return null;

  const existing = await tx.moneyBox.findFirst({
    where: { shopId, type: normalizedType, status: "ACTIVE" },
    orderBy: [{ createdAt: "asc" }],
    select: { id: true, boxName: true, code: true, type: true, currentBalance: true },
  });

  if (existing) return existing;

  const boxName = normalizedType === "CASH" ? "Cash Box" : normalizedType === "BKASH" ? "bKash Wallet" : "Nagad Wallet";
  const code = `${normalizedType.toLowerCase()}-${shopId.substring(0, 8)}-${Date.now()}`;

  return tx.moneyBox.create({
    data: { shopId, boxName, code, type: normalizedType, openingBalance: 0, currentBalance: 0, status: "ACTIVE" },
    select: { id: true, boxName: true, code: true, type: true, currentBalance: true },
  });
}

export async function resolveShopIdentifierHelper(identifier: string) {
  const normalized = identifier?.trim();
  if (!normalized) return null;

  return prisma.shop.findFirst({
    where: { OR: [{ id: normalized }, { shopCode: normalized }] },
    select: { id: true, shopCode: true, shopName: true, phone: true, address: true, area: true, district: true, status: true },
  });
}

export async function resolveCustomerIdentifierHelper(identifier: string) {
  const normalized = identifier?.trim();
  if (!normalized) return null;

  return (prisma as any).customer.findFirst({
    where: { deletedAt: null, OR: [{ id: normalized }, { customerCode: normalized }] },
  });
}

export async function buildCustomerFinanceSummaryHelper(customerId: string, shopId: string) {
  const ledgerEntries = await (prisma as any).customerLedger.findMany({
    where: { customerId, shopId },
    select: { debit: true, credit: true, entryType: true },
  });

  const totalDebit = ledgerEntries.reduce((sum: number, entry: any) => sum + Number(entry.debit ?? 0), 0);
  const totalCredit = ledgerEntries.reduce((sum: number, entry: any) => sum + Number(entry.credit ?? 0), 0);
  const totalSales = ledgerEntries
    .filter((entry: any) => entry.entryType === "SALE")
    .reduce((sum: number, entry: any) => sum + Number(entry.debit ?? 0), 0);
  const totalPaid = ledgerEntries
    .filter((entry: any) => entry.entryType === "PAYMENT")
    .reduce((sum: number, entry: any) => sum + Number(entry.credit ?? 0), 0);

  return { totalSales, totalPaid, due: Math.max(0, totalDebit - totalCredit) };
}

export async function createUniqueCustomerCodeHelper(name: string) {
  const base = buildCustomerCodeBase(name);

  for (let attempt = 0; attempt < 10; attempt += 1) {
    const suffix = `${Date.now()}`.slice(-4) + `${Math.floor(Math.random() * 100)}`.padStart(2, "0");
    const candidate = `${base}-${suffix}`;
    const existing = await (prisma as any).customer.findFirst({ where: { customerCode: candidate }, select: { id: true } });
    if (!existing) return candidate;
  }

  return `${base}-${Math.floor(Date.now() / 1000)}`;
}

export async function findCustomerForLinkCheckHelper(params: { customerCode: string; mobile: string | null; name: string }) {
  return (prisma as any).customer.findFirst({
    where: {
      deletedAt: null,
      OR: [{ customerCode: params.customerCode }, ...(params.mobile ? [{ mobile: params.mobile }] : []), { name: params.name }],
    },
    select: { id: true, customerCode: true, name: true, mobile: true },
  });
}

export async function createShopCustomerLedgerEntryHelper(params: { shopId: string; customerId: string; referenceNo: string | null; debit: number; credit: number; notes: string | null }) {
  return (prisma as any).customerLedger.create({
    data: {
      shopId: params.shopId,
      customerId: params.customerId,
      entryType: "OPENING_DUE",
      referenceNo: params.referenceNo,
      debit: params.debit,
      credit: params.credit,
      notes: params.notes,
      entryDate: new Date(),
    },
  });
}

export async function createGlobalCustomerHelper(data: any) {
  return (prisma as any).customer.create({ data });
}

export async function findCustomerByIdHelper(id: string) {
  return (prisma as any).customer.findFirst({ where: { id, deletedAt: null } });
}
