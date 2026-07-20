import { buildCustomerCodeBase, normalizeBatchOrder, roundCurrency, roundQuantity, toMoney } from "@domain/customer/customer.entity";
import {
  InsufficientBatchStockError,
  InsufficientStockError,
  PaidPlusStoreCreditExceedsTotalError,
  ProductNotFoundInShopInventoryError,
} from "@domain/customer/customer.errors";
import type { CustomerRepository, ShopScope } from "@application/customer/ports/customer-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";
import { normalizeMoney as normalizeStockMoney, recordStockMovement } from "../../../utils/stock-movement";
import { ensureGeneralInventoryBin } from "./inventory.repository";

async function resolveShopProductTx(tx: any, shopId: string, identifier: string) {
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

function resolveCustomerLinkedWhere(customerIdentifier: string) {
  let normalized = customerIdentifier.trim();
  if (normalized.startsWith("num:")) {
    normalized = normalized.substring(4).trim();
  } else if (normalized.startsWith("name:")) {
    normalized = normalized.substring(5).trim();
  }
  return { deletedAt: null, OR: [{ id: normalized }, { mobile: normalized }, { name: normalized }] };
}

export class PrismaCustomerRepository implements CustomerRepository {
  async resolveShopIdentifier(identifier: string) {
    const normalized = identifier?.trim();
    if (!normalized) return null;

    return prisma.shop.findFirst({
      where: { OR: [{ id: normalized }, { shopCode: normalized }] },
      select: { id: true, shopCode: true, shopName: true, phone: true, address: true, area: true, district: true, status: true },
    });
  }

  async resolveCustomerIdentifier(identifier: string) {
    const normalized = identifier?.trim();
    if (!normalized) return null;

    return (prisma as any).customer.findFirst({ where: { deletedAt: null, OR: [{ id: normalized }, { customerCode: normalized }] } });
  }

  async resolveCustomerLinkedToShop(customerIdentifier: string, shopId: string) {
    return (prisma as any).customer.findFirst({ where: resolveCustomerLinkedWhere(customerIdentifier) });
  }

  async buildCustomerFinanceSummary(customerId: string, shopId: string) {
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

  async listCustomersForShopFinance(shopId: string, filters: { search: string; status: string }) {
    return (prisma as any).customer.findMany({
      where: {
        deletedAt: null,
        name: { notIn: ["Guest Customer", "guest customer", "হাঁটা বিক্রয়", "অতিথি গ্রাহক"] },
        ...(filters.status ? { status: filters.status } : {}),
        AND: [
          ...(filters.search
            ? [
                {
                  OR: [
                    { customerCode: { contains: filters.search, mode: "insensitive" } },
                    { name: { contains: filters.search, mode: "insensitive" } },
                    { mobile: { contains: filters.search, mode: "insensitive" } },
                    { email: { contains: filters.search, mode: "insensitive" } },
                  ],
                },
              ]
            : []),
        ],
      },
      include: {
        ledgerEntries: {
          where: { shopId },
          orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
          take: 1,
          select: { id: true, entryType: true, referenceNo: true, debit: true, credit: true, notes: true, entryDate: true },
        },
      },
      orderBy: [{ name: "asc" }],
    });
  }

  async listCustomersPlain(filters: { search: string; status: string }) {
    return (prisma as any).customer.findMany({
      where: {
        deletedAt: null,
        name: { notIn: ["Guest Customer", "guest customer", "হাঁটা বিক্রয়", "অতিথি গ্রাহক"] },
        ...(filters.status ? { status: filters.status } : {}),
        ...(filters.search
          ? {
              OR: [
                { customerCode: { contains: filters.search, mode: "insensitive" } },
                { name: { contains: filters.search, mode: "insensitive" } },
                { mobile: { contains: filters.search, mode: "insensitive" } },
                { email: { contains: filters.search, mode: "insensitive" } },
              ],
            }
          : {}),
      },
      orderBy: [{ createdAt: "desc" }, { name: "asc" }],
    });
  }

  async createUniqueCustomerCode(name: string) {
    const base = buildCustomerCodeBase(name);

    for (let attempt = 0; attempt < 10; attempt += 1) {
      const suffix = `${Date.now()}`.slice(-4) + `${Math.floor(Math.random() * 100)}`.padStart(2, "0");
      const candidate = `${base}-${suffix}`;
      const existing = await (prisma as any).customer.findFirst({ where: { customerCode: candidate }, select: { id: true } });
      if (!existing) return candidate;
    }

    return `${base}-${Math.floor(Date.now() / 1000)}`;
  }

  async findCustomerForLinkCheck(params: { customerCode: string; mobile: string | null; name: string }) {
    return (prisma as any).customer.findFirst({
      where: {
        deletedAt: null,
        OR: [{ customerCode: params.customerCode }, ...(params.mobile ? [{ mobile: params.mobile }] : []), { name: params.name }],
      },
      select: { id: true, customerCode: true, name: true, mobile: true },
    });
  }

  async createShopCustomerLedgerEntry(params: { shopId: string; customerId: string; referenceNo: string | null; debit: number; credit: number; notes: string | null }) {
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

  async createGlobalCustomer(data: any) {
    return (prisma as any).customer.create({ data });
  }

  async findCustomerById(id: string) {
    return (prisma as any).customer.findUnique({ where: { id } });
  }

  async listShopSales(shopId: string, filters: { status: string; startDate: Date | null; endDate: Date | null }) {
    return (prisma as any).customerSale.findMany({
      where: {
        shopId,
        ...(filters.status ? { status: filters.status } : {}),
        ...(filters.startDate && filters.endDate ? { saleDate: { gte: filters.startDate, lte: filters.endDate } } : {}),
      },
      include: {
        customer: { select: { id: true, name: true, mobile: true } },
        createdBy: { select: { id: true, name: true, phone: true } },
        items: { include: { masterProduct: { select: { id: true, sku: true, name: true } } } },
      },
      orderBy: [{ saleDate: "desc" }, { createdAt: "desc" }],
    });
  }

  async getSalesClosingSummaryData(shopId: string, startDate: Date, endDate: Date) {
    return (prisma as any).customerSale.findMany({
      where: { shopId, saleDate: { gte: startDate, lte: endDate }, status: "ACTIVE" },
      include: {
        createdBy: { select: { id: true, name: true, phone: true } },
        items: { include: { masterProduct: { select: { id: true, name: true } } } },
      },
      orderBy: [{ saleDate: "desc" }],
    });
  }

  async findSaleById(saleId: string, shopId: string) {
    return (prisma as any).customerSale.findFirst({
      where: { id: saleId, shopId },
      include: {
        customer: { select: { id: true, name: true, mobile: true, address: true } },
        createdBy: { select: { id: true, name: true, phone: true } },
        items: { include: { masterProduct: { select: { id: true, sku: true, name: true } } } },
      },
    });
  }

  async findLatestPaymentByReference(shopId: string, referenceNo: string | null | undefined) {
    return (prisma as any).customerPayment.findFirst({
      where: { shopId, referenceNo: referenceNo ?? undefined },
      orderBy: [{ paidAt: "desc" }, { createdAt: "desc" }],
    });
  }

  async cancelSale(params: { saleId: string; shopId: string; refundMethod: string; reason: string; notes: string | null; createdByUserId: string }) {
    return (prisma as any).$transaction(async (tx: any) => {
      const sale = await tx.customerSale.findFirst({
        where: { id: params.saleId, shopId: params.shopId },
        include: { items: true, customer: true, createdBy: { select: { id: true, name: true, phone: true } } },
      });

      if (!sale) {
        return { errorStatus: 404, errorMessage: "Sale not found." };
      }

      if ((sale.status ?? "ACTIVE") === "CANCELLED") {
        return { errorStatus: 400, errorMessage: "This sale is already cancelled." };
      }

      const salePayment = Number(sale.paidAmount ?? 0);
      const paymentType = (sale.paymentMethod ?? "").toString().trim().toUpperCase();
      const refundMoneyBox =
        params.refundMethod === "CASH_REFUND"
          ? await tx.moneyBox.findFirst({ where: { shopId: params.shopId, type: "CASH", status: "ACTIVE" }, orderBy: [{ createdAt: "asc" }] })
          : params.refundMethod === "WALLET_REFUND"
            ? await tx.moneyBox.findFirst({
                where: { shopId: params.shopId, type: paymentType === "NAGAD" ? "NAGAD" : "BKASH", status: "ACTIVE" },
                orderBy: [{ createdAt: "asc" }],
              })
            : null;

      for (const item of sale.items) {
        const shopProduct = await tx.shopProduct.findUnique({
          where: { shopId_masterProductId: { shopId: params.shopId, masterProductId: item.masterProductId } },
          select: { id: true, masterProductId: true, openingStock: true, purchasePrice: true, salePrice: true },
        });

        const previousStock = Number(shopProduct?.openingStock ?? 0);
        const nextStock = previousStock + Number(item.quantity ?? 0);

        await tx.shopProduct.update({
          where: { shopId_masterProductId: { shopId: params.shopId, masterProductId: item.masterProductId } },
          data: { openingStock: { increment: item.quantity } },
        });

        if (shopProduct) {
          await recordStockMovement(tx, {
            shopId: params.shopId,
            shopProductId: shopProduct.id,
            masterProductId: shopProduct.masterProductId,
            movementType: "SALE_CANCEL",
            quantityDelta: Number(item.quantity ?? 0),
            stockBefore: previousStock,
            stockAfter: nextStock,
            purchasePrice: normalizeStockMoney(shopProduct.purchasePrice),
            salePrice: normalizeStockMoney(shopProduct.salePrice),
            unitPrice: Number(item.salePrice ?? 0),
            referenceType: "SALE_CANCEL",
            referenceId: sale.id,
            referenceNo: sale.invoiceNo || null,
            note: params.reason,
            createdByUserId: params.createdByUserId,
          });
        }
      }

      const cancelledSale = await tx.customerSale.update({
        where: { id: sale.id },
        data: {
          status: "CANCELLED",
          cancelledAt: new Date(),
          cancelReason: params.reason,
          refundMethod: params.refundMethod,
          refundAmount: sale.paidAmount,
          cancelNotes: params.notes || null,
        },
        include: {
          customer: { select: { id: true, name: true, mobile: true } },
          items: { include: { masterProduct: { select: { id: true, sku: true, name: true } } } },
        },
      });

      await tx.customerLedger.create({
        data: {
          shopId: params.shopId,
          customerId: sale.customerId,
          customerSaleId: sale.id,
          entryType: "ADJUSTMENT",
          referenceNo: sale.invoiceNo || sale.customer.customerCode || null,
          debit: 0,
          credit: sale.totalAmount,
          notes: `SALE_CANCELLED | ${params.reason}${params.notes ? ` | ${params.notes}` : ""}`,
          entryDate: new Date(),
        },
      });

      if (salePayment > 0 && params.refundMethod === "LATER_ADJUSTMENT") {
        await tx.customer.update({ where: { id: sale.customerId }, data: { storeCredit: { increment: salePayment } } });

        await tx.customerLedger.create({
          data: {
            shopId: params.shopId,
            customerId: sale.customerId,
            customerSaleId: sale.id,
            entryType: "ADJUSTMENT",
            referenceNo: sale.invoiceNo || sale.customer.customerCode || null,
            debit: salePayment,
            credit: 0,
            notes: `STORE_CREDIT_GRANTED | ${params.notes || params.reason}`,
            entryDate: new Date(),
          },
        });
      }

      if (salePayment > 0 && params.refundMethod !== "LATER_ADJUSTMENT") {
        if (refundMoneyBox) {
          await tx.moneyBox.update({ where: { id: refundMoneyBox.id }, data: { currentBalance: { decrement: salePayment } } });
        }

        await tx.customerLedger.create({
          data: {
            shopId: params.shopId,
            customerId: sale.customerId,
            customerSaleId: sale.id,
            entryType: "ADJUSTMENT",
            referenceNo: sale.invoiceNo || sale.customer.customerCode || null,
            debit: salePayment,
            credit: 0,
            notes: `SALE_REFUND | ${params.refundMethod}${params.notes ? ` | ${params.notes}` : ""}`,
            entryDate: new Date(),
          },
        });
      }

      return { sale: cancelledSale };
    });
  }

  async resolveShopProduct(shopId: string, identifier: string) {
    return resolveShopProductTx(prisma, shopId, identifier);
  }

  async resolveShopMoneyBox(shopId: string, moneyBoxId?: string | null) {
    const normalized = moneyBoxId?.trim();
    if (!normalized) return null;

    return (prisma as any).moneyBox.findFirst({ where: { id: normalized, shopId }, select: { id: true, boxName: true, code: true, type: true } });
  }

  async resolveDefaultMoneyBoxByType(shopId: string, type?: string | null) {
    const normalizedType = (type ?? "").toString().trim().toUpperCase();
    if (!normalizedType || !["CASH", "BKASH", "NAGAD"].includes(normalizedType)) return null;

    const existing = await (prisma as any).moneyBox.findFirst({
      where: { shopId, type: normalizedType, status: "ACTIVE" },
      orderBy: [{ createdAt: "asc" }],
      select: { id: true, boxName: true, code: true, type: true, currentBalance: true },
    });

    if (existing) return existing;

    const boxName = normalizedType === "CASH" ? "Cash Box" : normalizedType === "BKASH" ? "bKash Wallet" : "Nagad Wallet";
    const code = `${normalizedType.toLowerCase()}-${shopId.substring(0, 8)}-${Date.now()}`;

    return (prisma as any).moneyBox.create({
      data: { shopId, boxName, code, type: normalizedType, openingBalance: 0, currentBalance: 0, status: "ACTIVE" },
      select: { id: true, boxName: true, code: true, type: true, currentBalance: true },
    });
  }

  async createSale(params: Parameters<CustomerRepository["createSale"]>[0]) {
    const { shop, customer, createdByUserId } = params;

    return (prisma as any).$transaction(async (tx: any) => {
      const inventorySetting = await tx.shopInventorySetting.findUnique({ where: { shopId: shop.id } });
      const reduceStock = inventorySetting ? inventorySetting.reduceStockOnSale : true;
      const allowNegative = inventorySetting ? inventorySetting.allowNegativeStock : false;
      const requireBinAssignment = inventorySetting ? inventorySetting.requireBinAssignment : false;
      const stockMethod = normalizeBatchOrder(inventorySetting?.stockMethod);

      const saleItemRecords: Array<{ masterProductId: string; quantity: number; salePrice: number; purchasePrice: number; totalAmount: number; batchNo: string | null }> = [];
      const saleMovementRecords: Array<{
        shopProductId: string;
        masterProductId: string;
        quantity: number;
        stockBefore: number;
        stockAfter: number;
        salePrice: number;
        purchasePrice: number | null;
        batchNo: string | null;
      }> = [];

      for (const item of params.items) {
        let shopProduct = await resolveShopProductTx(tx, shop.id, item.masterProductId);

        if (!shopProduct) {
          throw new ProductNotFoundInShopInventoryError(item.masterProductId);
        }

        if (!shopProduct.masterProductId) {
          const sku = `LOCAL-${shopProduct.id}`;
          const shadowMaster = await tx.masterProduct.create({
            data: {
              name: shopProduct.localName || "Unnamed Local Product",
              sku,
              price: shopProduct.salePrice,
              suggestedPrice: shopProduct.salePrice,
              status: "ACTIVE",
              createdByUserId,
              updatedByUserId: createdByUserId,
            },
          });

          shopProduct = await tx.shopProduct.update({
            where: { id: shopProduct.id },
            data: { masterProductId: shadowMaster.id, source: "MASTER" },
            include: { masterProduct: true },
          });
        }

        const effectiveMasterProductId = shopProduct.masterProductId!;
        const currentStock = Number(shopProduct.openingStock ?? 0);
        if (reduceStock && !allowNegative && currentStock < item.quantity) {
          throw new InsufficientStockError(currentStock, item.quantity);
        }

        let binItems = await tx.inventoryBinItem.findMany({
          where: { shopId: shop.id, masterProductId: effectiveMasterProductId, quantity: { gt: 0 }, ...(item.batchNo ? { batchNo: item.batchNo } : {}) },
          orderBy: [{ createdAt: stockMethod === "LIFO" ? "desc" : "asc" }, { id: "asc" }],
        });

        if (binItems.length === 0 && currentStock > 0) {
          const targetBin = await ensureGeneralInventoryBin(tx, shop.id, effectiveMasterProductId, shopProduct.masterProduct?.name ?? "Stock");
          await tx.inventoryBinItem.create({
            data: {
              shopId: shop.id,
              binId: targetBin.id,
              masterProductId: effectiveMasterProductId,
              quantity: currentStock,
              purchasePrice: shopProduct.purchasePrice,
              salePrice: shopProduct.salePrice,
              batchNo: "1",
              notes: "Auto-generated bin item for checkout",
            },
          });
          binItems = await tx.inventoryBinItem.findMany({
            where: { shopId: shop.id, masterProductId: effectiveMasterProductId, quantity: { gt: 0 }, ...(item.batchNo ? { batchNo: item.batchNo } : {}) },
            orderBy: [{ createdAt: stockMethod === "LIFO" ? "desc" : "asc" }, { id: "asc" }],
          });
        }

        const touchedBinIds = new Set<string>();
        let remainingToAllocate = item.quantity;

        for (const binItem of binItems) {
          if (remainingToAllocate <= 0) break;

          const binQty = Number(binItem.quantity ?? 0);
          if (binQty <= 0) continue;

          const allocatedQty = Math.min(binQty, remainingToAllocate);
          const batchSalePrice = roundCurrency(Number(binItem.salePrice ?? shopProduct.salePrice ?? item.salePrice) || 0);

          saleItemRecords.push({
            masterProductId: effectiveMasterProductId,
            quantity: allocatedQty,
            salePrice: batchSalePrice,
            purchasePrice: Number(binItem.purchasePrice ?? shopProduct.purchasePrice ?? 0),
            totalAmount: roundCurrency(allocatedQty * batchSalePrice),
            batchNo: binItem.batchNo ?? item.batchNo ?? null,
          });

          if (reduceStock) {
            saleMovementRecords.push({
              shopProductId: shopProduct.id,
              masterProductId: effectiveMasterProductId,
              quantity: allocatedQty,
              stockBefore: roundQuantity(currentStock - (item.quantity - remainingToAllocate)),
              stockAfter: roundQuantity(currentStock - (item.quantity - remainingToAllocate) - allocatedQty),
              salePrice: batchSalePrice,
              purchasePrice: normalizeStockMoney(binItem.purchasePrice ?? shopProduct.purchasePrice),
              batchNo: binItem.batchNo ?? item.batchNo ?? null,
            });
          }

          remainingToAllocate = roundQuantity(remainingToAllocate - allocatedQty);

          if (reduceStock) {
            const newBinQty = roundQuantity(binQty - allocatedQty);
            touchedBinIds.add(binItem.binId);

            if (newBinQty <= 0) {
              await tx.inventoryBinItem.delete({ where: { id: binItem.id } });
            } else {
              await tx.inventoryBinItem.update({ where: { id: binItem.id }, data: { quantity: newBinQty } });
            }
          }
        }

        if (remainingToAllocate > 0) {
          if (reduceStock && !allowNegative && requireBinAssignment) {
            throw new InsufficientBatchStockError(item.quantity, roundQuantity(item.quantity - remainingToAllocate));
          }

          const fallbackSalePrice = roundCurrency(Number(shopProduct.salePrice ?? item.salePrice) || 0);

          saleItemRecords.push({
            masterProductId: effectiveMasterProductId,
            quantity: remainingToAllocate,
            salePrice: fallbackSalePrice,
            purchasePrice: Number(shopProduct.purchasePrice ?? 0),
            totalAmount: roundCurrency(remainingToAllocate * fallbackSalePrice),
            batchNo: item.batchNo,
          });

          if (reduceStock) {
            saleMovementRecords.push({
              shopProductId: shopProduct.id,
              masterProductId: effectiveMasterProductId,
              quantity: remainingToAllocate,
              stockBefore: roundQuantity(currentStock - (item.quantity - remainingToAllocate)),
              stockAfter: roundQuantity(currentStock - item.quantity),
              salePrice: fallbackSalePrice,
              purchasePrice: normalizeStockMoney(shopProduct.purchasePrice),
              batchNo: item.batchNo,
            });
          }
        }

        if (reduceStock) {
          const nextStock = roundQuantity(currentStock - item.quantity);
          for (const binId of touchedBinIds) {
            const [bin, totalBinQty] = await Promise.all([
              tx.inventoryBin.findUnique({ where: { id: binId } }),
              tx.inventoryBinItem.aggregate({ where: { binId }, _sum: { quantity: true } }),
            ]);

            if (!bin) continue;

            const quantityValue = Number(totalBinQty._sum.quantity ?? 0);
            await tx.inventoryBin.update({
              where: { id: binId },
              data: {
                status: quantityValue <= 0 ? "EMPTY" : quantityValue < 10 ? "LOW" : "FULL",
                quantityLabel: quantityValue <= 0 ? "খালি" : `${quantityValue} পিস`,
                productName: quantityValue <= 0 ? "" : bin.productName,
                daysLabel: quantityValue <= 0 ? "খালি" : bin.daysLabel,
              },
            });
          }

          await tx.shopProduct.update({ where: { id: shopProduct.id }, data: { openingStock: { decrement: item.quantity } } });

          if (saleMovementRecords.every((entry) => entry.shopProductId != shopProduct.id || entry.masterProductId != effectiveMasterProductId)) {
            saleMovementRecords.push({
              shopProductId: shopProduct.id,
              masterProductId: effectiveMasterProductId,
              quantity: item.quantity,
              stockBefore: currentStock,
              stockAfter: nextStock,
              salePrice: roundCurrency(Number(shopProduct.salePrice ?? item.salePrice) || 0),
              purchasePrice: normalizeStockMoney(shopProduct.purchasePrice),
              batchNo: item.batchNo,
            });
          }
        }
      }

      const totalAmount = roundCurrency(saleItemRecords.reduce((sum, item) => sum + item.totalAmount, 0));
      const grandTotal = roundCurrency(totalAmount - params.discountAmount + params.taxAmount + params.chargeAmount);

      if (params.paidAmount + params.requestedStoreCreditUsed > grandTotal) {
        throw new PaidPlusStoreCreditExceedsTotalError();
      }

      const availableStoreCredit = toMoney(customer.storeCredit);
      const storeCreditUsed = Math.min(availableStoreCredit, params.requestedStoreCreditUsed);
      const dueAmount = roundCurrency(grandTotal - params.paidAmount - storeCreditUsed);

      const createdSale = await tx.customerSale.create({
        data: {
          shopId: shop.id,
          customerId: customer.id,
          createdByUserId,
          invoiceNo: params.invoiceNo,
          saleDate: params.saleDate,
          totalAmount,
          paidAmount: params.paidAmount,
          dueAmount,
          discountAmount: params.discountAmount,
          taxAmount: params.taxAmount,
          chargeAmount: params.chargeAmount,
          paymentMethod: params.paymentMethod,
          notes: params.notes,
          items: {
            create: saleItemRecords.map((item) => ({
              masterProductId: item.masterProductId,
              quantity: item.quantity,
              salePrice: item.salePrice,
              purchasePrice: item.purchasePrice,
              totalAmount: item.totalAmount,
              batchNo: item.batchNo,
            })),
          },
        },
        include: {
          createdBy: { select: { id: true, name: true, phone: true } },
          items: { include: { masterProduct: { select: { id: true, sku: true, name: true } } } },
        },
      });

      for (const entry of saleMovementRecords) {
        await recordStockMovement(tx, {
          shopId: shop.id,
          shopProductId: entry.shopProductId,
          masterProductId: entry.masterProductId,
          movementType: "SALE",
          quantityDelta: -entry.quantity,
          stockBefore: entry.stockBefore,
          stockAfter: entry.stockAfter,
          purchasePrice: entry.purchasePrice,
          salePrice: entry.salePrice,
          unitPrice: entry.salePrice,
          referenceType: "SALE",
          referenceId: createdSale.id,
          referenceNo: createdSale.invoiceNo || null,
          note: entry.batchNo ? `${createdSale.notes || "Stock reduced from sale."} | Batch ${entry.batchNo}` : createdSale.notes || "Stock reduced from sale.",
          createdByUserId,
        });
      }

      await tx.customerLedger.create({
        data: {
          shopId: shop.id,
          customerId: customer.id,
          customerSaleId: createdSale.id,
          entryType: "SALE",
          referenceNo: createdSale.invoiceNo || customer.customerCode || null,
          debit: grandTotal,
          credit: 0,
          notes: createdSale.notes,
          entryDate: params.saleDate,
        },
      });

      if (storeCreditUsed > 0) {
        await tx.customer.update({ where: { id: customer.id }, data: { storeCredit: { decrement: storeCreditUsed } } });

        await tx.customerLedger.create({
          data: {
            shopId: shop.id,
            customerId: customer.id,
            customerSaleId: createdSale.id,
            entryType: "ADJUSTMENT",
            referenceNo: createdSale.invoiceNo || customer.customerCode || null,
            debit: 0,
            credit: storeCreditUsed,
            notes: `STORE_CREDIT_USED | ${createdSale.notes ?? ""}`.trim(),
            entryDate: params.saleDate,
          },
        });
      }

      let payment: any = null;

      if (params.paidAmount > 0) {
        payment = await tx.customerPayment.create({
          data: {
            shopId: shop.id,
            customerId: customer.id,
            amount: params.paidAmount,
            paymentMethod: params.paymentMethod,
            paymentMeta: params.paymentMeta,
            moneyBoxId: params.effectiveMoneyBoxId,
            referenceNo: createdSale.invoiceNo || null,
            notes: params.notes,
            paidAt: params.saleDate,
          },
        });

        if (params.effectiveMoneyBoxId && ["CASH", "BKASH", "NAGAD"].includes(params.paymentMethod || "")) {
          await tx.moneyBox.update({ where: { id: params.effectiveMoneyBoxId }, data: { currentBalance: { increment: params.paidAmount } } });
        }

        await tx.customerLedger.create({
          data: {
            shopId: shop.id,
            customerId: customer.id,
            customerSaleId: createdSale.id,
            customerPaymentId: payment.id,
            entryType: "PAYMENT",
            referenceNo: createdSale.invoiceNo || customer.customerCode || null,
            debit: 0,
            credit: params.paidAmount,
            notes: createdSale.notes,
            entryDate: params.saleDate,
          },
        });
      }

      return { createdSale, payment, storeCreditUsed };
    });
  }

  async listCustomerSales(customerId: string, shopId: string) {
    return (prisma as any).customerSale.findMany({
      where: { shopId, customerId },
      include: {
        createdBy: { select: { id: true, name: true, phone: true } },
        items: { include: { masterProduct: { select: { id: true, sku: true, name: true } } } },
      },
      orderBy: [{ saleDate: "desc" }, { createdAt: "desc" }],
    });
  }

  async createCustomerPayment(params: {
    shopId: string;
    customer: any;
    amount: number;
    paymentMethod: string | null;
    paymentMeta: Record<string, unknown> | null;
    effectiveMoneyBoxId: string | null;
    referenceNo: string | null;
    notes: string | null;
    paidAt: Date;
  }) {
    return (prisma as any).$transaction(async (tx: any) => {
      const createdPayment = await tx.customerPayment.create({
        data: {
          shopId: params.shopId,
          customerId: params.customer.id,
          amount: params.amount,
          paymentMethod: params.paymentMethod,
          paymentMeta: params.paymentMeta,
          moneyBoxId: params.effectiveMoneyBoxId,
          referenceNo: params.referenceNo,
          notes: params.notes,
          paidAt: params.paidAt,
        },
      });

      let remainingPayment = params.amount;
      const unpaidSales = await tx.customerSale.findMany({
        where: { customerId: params.customer.id, shopId: params.shopId, dueAmount: { gt: 0 }, status: "ACTIVE" },
        orderBy: { saleDate: "asc" },
      });

      for (const sale of unpaidSales) {
        if (remainingPayment <= 0) break;
        const due = Number(sale.dueAmount);
        const allocation = Math.min(remainingPayment, due);

        await tx.customerSale.update({
          where: { id: sale.id },
          data: { paidAmount: { increment: allocation }, dueAmount: { decrement: allocation } },
        });

        remainingPayment -= allocation;
      }

      if (params.effectiveMoneyBoxId && ["CASH", "BKASH", "NAGAD"].includes(params.paymentMethod || "")) {
        await tx.moneyBox.update({ where: { id: params.effectiveMoneyBoxId }, data: { currentBalance: { increment: params.amount } } });
      }

      await tx.customerLedger.create({
        data: {
          shopId: params.shopId,
          customerId: params.customer.id,
          customerPaymentId: createdPayment.id,
          entryType: "PAYMENT",
          referenceNo: createdPayment.referenceNo || params.customer.customerCode || null,
          debit: 0,
          credit: params.amount,
          notes: createdPayment.notes,
          entryDate: params.paidAt,
        },
      });

      return createdPayment;
    });
  }

  async getCustomerLedger(customerId: string, shopId: string) {
    return (prisma as any).customerLedger.findMany({
      where: { shopId, customerId },
      include: {
        customerSale: { select: { id: true, invoiceNo: true, saleDate: true, totalAmount: true, paidAmount: true, dueAmount: true } },
        customerPayment: { select: { id: true, amount: true, paymentMethod: true, paymentMeta: true, referenceNo: true, paidAt: true } },
      },
      orderBy: [{ entryDate: "asc" }, { createdAt: "asc" }],
    });
  }

  async getCustomerFinanceDetail(customerId: string, shopId: string) {
    const [summary, sales, payments, ledgerEntries] = await Promise.all([
      this.buildCustomerFinanceSummary(customerId, shopId),
      (prisma as any).customerSale.findMany({
        where: { shopId, customerId },
        orderBy: [{ saleDate: "desc" }, { createdAt: "desc" }],
        take: 10,
        select: { id: true, invoiceNo: true, saleDate: true, totalAmount: true, paidAmount: true, dueAmount: true, paymentMethod: true, notes: true },
      }),
      (prisma as any).customerPayment.findMany({
        where: { shopId, customerId },
        orderBy: [{ paidAt: "desc" }, { createdAt: "desc" }],
        take: 10,
        select: { id: true, amount: true, paymentMethod: true, paymentMeta: true, referenceNo: true, notes: true, paidAt: true },
      }),
      (prisma as any).customerLedger.findMany({
        where: { shopId, customerId },
        orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
        take: 20,
        select: { id: true, entryType: true, referenceNo: true, debit: true, credit: true, notes: true, entryDate: true },
      }),
    ]);

    return { summary, sales, payments, ledgerEntries };
  }

  async findOrCreateGuestOrNamedCustomer(name: string, mobile: string | null) {
    let existingCustomer = null;
    if (mobile) {
      existingCustomer = await (prisma as any).customer.findFirst({ where: { mobile, deletedAt: null } });
    }
    if (!existingCustomer) {
      existingCustomer = await (prisma as any).customer.findFirst({ where: { name, deletedAt: null } });
    }
    if (existingCustomer) {
      return existingCustomer;
    }

    const generatedCustomerCode = await this.createUniqueCustomerCode(name);
    return (prisma as any).customer.create({ data: { name, mobile, customerCode: generatedCustomerCode, status: "ACTIVE" } });
  }

  async findOrCreateGuestCustomer() {
    let guestCustomer = await (prisma as any).customer.findFirst({ where: { name: "Guest Customer", deletedAt: null } });
    if (!guestCustomer) {
      const generatedCustomerCode = await this.createUniqueCustomerCode("Guest Customer");
      guestCustomer = await (prisma as any).customer.create({ data: { name: "Guest Customer", customerCode: generatedCustomerCode, status: "ACTIVE" } });
    }
    return guestCustomer;
  }

  async linkCustomerToShop(customerId: string, shopId: string) {
    await (prisma as any).customerLedger.create({
      data: {
        shopId,
        customerId,
        entryType: "OPENING_DUE",
        debit: 0,
        credit: 0,
        notes: "Linked customer to shop during sale checkout",
        entryDate: new Date(),
      },
    });

    return (prisma as any).customer.findFirst({ where: { id: customerId, deletedAt: null } });
  }
}
