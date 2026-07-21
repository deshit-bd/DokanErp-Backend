import {
  normalizeText,
  type NormalizedPurchaseItem,
  type PurchaseInventoryPlacementInput,
  type PurchaseReturnItemInput,
  type PurchaseStatusValue,
  type ReceivePurchaseItemInput,
} from "@domain/purchase/purchase.entity";
import {
  ApprovedPurchasesCannotBeCancelledError,
  BankAccountNotFoundError,
  InvalidPhysicalCountError,
  MoneyBoxNotFoundForPaymentError,
  MoneyBoxNotFoundForPurchaseError,
  OnlyApprovedPurchasesCanBeReturnedError,
  OnlyApprovedPurchasesReceiveDuePaymentsError,
  OnlyPendingPurchasesCanBeRejectedError,
  PaymentExceedsRemainingDueError,
  PurchaseHasNoSupplierForPaymentError,
  ReceivePurchaseBankAccountNotFoundError,
  ReceivePurchaseMoneyBoxNotFoundError,
  ReceivePurchasePaymentInfoError,
  RejectedPurchasesCannotBeApprovedError,
  RejectedPurchasesCannotBeReceivedError,
  ReturnItemNotInPurchaseError,
  ReturnQuantityExceedsAvailableError,
  UnknownReceivedProductError,
} from "@domain/purchase/purchase.errors";
import { getPurchaseReturnSummary, normalizePurchasePayment } from "@domain/purchase/purchase.entity";
import type { PurchaseRepository } from "@application/purchase/ports/purchase-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";
import { recordStockMovement, normalizeMoney as normalizeStockMoney, resolveShopProductByIdentifier as resolveShopProductTx } from "../../../utils/stock-movement";
import { ensureGeneralInventoryBin } from "./inventory.repository";
import {
  buildPurchaseInclude,
  resolveShopMoneyBox,
  resolveDefaultMoneyBoxByType,
  resolveShopBankAccount,
  resolveDefaultBankAccount,
  resolvePurchasePlacementBin,
  applyApprovedPurchaseEffects,
} from "./purchase-repository.helper";

export class PrismaPurchaseRepository implements PurchaseRepository {
  async resolveShopIdentifier(identifier: string) {
    const normalized = identifier?.trim();
    if (!normalized) return null;

    return prisma.shop.findFirst({
      where: { OR: [{ id: normalized }, { shopCode: normalized }] },
      select: { id: true, shopCode: true, shopName: true },
    });
  }

  async resolveSupplierLinkedToShop(supplierId: string, shopId: string) {
    return (prisma as any).supplier.findFirst({
      where: {
        id: supplierId,
        deletedAt: null,
        OR: [{ purchases: { some: { shopId } } }, { supplierPayments: { some: { shopId } } }, { supplierLedgers: { some: { shopId } } }],
      },
      select: { id: true, supplierCode: true, name: true },
    });
  }

  async resolveShopProductByIdentifier(shopId: string, identifier: string) {
    return resolveShopProductTx(prisma, shopId, identifier);
  }

  async promoteShopLocalProductToShadowMaster(shopProduct: any, createdByUserId: string) {
    const sku = `LOCAL-${shopProduct.id}`;
    const shadowMaster = await (prisma as any).masterProduct.create({
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

    return (prisma as any).shopProduct.update({
      where: { id: shopProduct.id },
      data: { masterProductId: shadowMaster.id, source: "MASTER" },
      include: { masterProduct: true },
    });
  }

  async findMasterProductsByIds(ids: string[]) {
    return (prisma as any).masterProduct.findMany({ where: { id: { in: ids } }, select: { id: true, sku: true, name: true } });
  }

  async canAddProductsToShop(shopId: string, masterProductIds: string[]) {
    const { canAddProductsToShop } = await import("../../../subscription/access");
    return canAddProductsToShop(shopId, masterProductIds);
  }

  async createPurchase(params: Parameters<PurchaseRepository["createPurchase"]>[0]) {
    return (prisma as any).$transaction(async (tx: any) => {
      const selectedMoneyBox = await resolveShopMoneyBox(tx, params.shopId, params.requestedMoneyBoxId);
      const defaultMoneyBox = !selectedMoneyBox ? await resolveDefaultMoneyBoxByType(tx, params.shopId, params.paymentMethod) : null;
      const effectiveMoneyBox = selectedMoneyBox ?? defaultMoneyBox;

      if (params.requestedMoneyBoxId && !selectedMoneyBox) {
        throw new MoneyBoxNotFoundForPurchaseError();
      }

      const selectedBankAccount = await resolveShopBankAccount(tx, params.shopId, params.requestedBankAccountId);
      const defaultBankAccount =
        params.paymentMethod === "BANK" && !selectedBankAccount ? await resolveDefaultBankAccount(tx, params.shopId) : null;
      const effectiveBankAccount = selectedBankAccount ?? defaultBankAccount;

      if (params.requestedBankAccountId && !selectedBankAccount) {
        throw new BankAccountNotFoundError();
      }

      if (params.paidAmount > 0 && params.paymentMethod === "BANK" && !effectiveBankAccount) {
        throw new BankAccountNotFoundError();
      }

      if (params.paidAmount > 0 && ["CASH", "BKASH", "NAGAD"].includes(params.paymentMethod || "") && !effectiveMoneyBox) {
        throw new MoneyBoxNotFoundForPurchaseError();
      }

      for (const item of params.items) {
        await tx.shopProduct.upsert({
          where: { shopId_masterProductId: { shopId: params.shopId, masterProductId: item.masterProductId } },
          update: {},
          create: { shopId: params.shopId, masterProductId: item.masterProductId, openingStock: 0 },
        });
      }

      return tx.purchase.create({
        data: {
          shopId: params.shopId,
          supplierId: params.supplierId,
          createdByUserId: params.createdByUserId,
          approvedByUserId: null,
          invoiceNo: params.invoiceNo,
          purchaseDate: params.purchaseDate,
          status: "PENDING_APPROVAL",
          subtotalAmount: params.subtotalAmount,
          discountAmount: params.discountAmount,
          extraChargeAmount: params.extraChargeAmount,
          totalAmount: params.totalAmount,
          paidAmount: params.paidAmount,
          dueAmount: params.dueAmount,
          paymentMethod: params.paymentMethod,
          paymentMeta: params.paymentMeta,
          invoiceFileName: params.invoiceFileName,
          notes: params.notes,
          approvedAt: null,
          items: {
            create: params.items.map((item) => ({
              masterProductId: item.masterProductId,
              batchNo: item.batchNo,
              expiryDate: item.expiryDate,
              quantity: item.quantity,
              purchasePrice: item.purchasePrice,
              totalAmount: item.totalAmount,
            })),
          },
        },
        include: buildPurchaseInclude(),
      });
    });
  }

  async listPurchases(shopId: string, supplierId?: string, status?: PurchaseStatusValue) {
    return (prisma as any).purchase.findMany({
      where: { shopId, ...(supplierId ? { supplierId } : {}), ...(status ? { status } : {}) },
      include: buildPurchaseInclude(),
      orderBy: [{ purchaseDate: "desc" }, { createdAt: "desc" }],
    });
  }

  async findPurchaseByIdUnscoped(id: string) {
    return (prisma as any).purchase.findUnique({ where: { id }, include: buildPurchaseInclude() });
  }

  async findPurchaseByIdInShop(id: string, shopId: string) {
    return (prisma as any).purchase.findFirst({ where: { id, shopId }, include: buildPurchaseInclude() });
  }

  async updatePurchase(params: Parameters<PurchaseRepository["updatePurchase"]>[0]) {
    return (prisma as any).$transaction(async (tx: any) => {
      for (const item of params.items) {
        await tx.shopProduct.upsert({
          where: { shopId_masterProductId: { shopId: params.shopId, masterProductId: item.masterProductId } },
          update: {},
          create: { shopId: params.shopId, masterProductId: item.masterProductId, openingStock: 0 },
        });
      }

      await tx.purchaseItem.deleteMany({ where: { purchaseId: params.id } });

      await tx.purchase.update({
        where: { id: params.id },
        data: {
          supplierId: params.supplierId,
          invoiceNo: params.invoiceNo,
          purchaseDate: params.purchaseDate,
          subtotalAmount: params.subtotalAmount,
          discountAmount: params.discountAmount,
          extraChargeAmount: params.extraChargeAmount,
          totalAmount: params.totalAmount,
          paidAmount: params.paidAmount,
          dueAmount: params.dueAmount,
          paymentMethod: params.paymentMethod,
          paymentMeta: params.paymentMeta,
          notes: params.notes,
          items: {
            create: params.items.map((item) => ({
              masterProductId: item.masterProductId,
              batchNo: item.batchNo,
              expiryDate: item.expiryDate,
              quantity: item.quantity,
              purchasePrice: item.purchasePrice,
              totalAmount: item.totalAmount,
            })),
          },
        },
      });

      return tx.purchase.findUnique({ where: { id: params.id }, include: buildPurchaseInclude() });
    });
  }

  async recordPurchasePayment(params: Parameters<PurchaseRepository["recordPurchasePayment"]>[0]) {
    return (prisma as any).$transaction(async (tx: any) => {
      const selectedMoneyBox = await resolveShopMoneyBox(tx, params.shopId, params.requestedMoneyBoxId);
      const defaultMoneyBox = !selectedMoneyBox ? await resolveDefaultMoneyBoxByType(tx, params.shopId, params.paymentMethod) : null;
      const effectiveMoneyBox = selectedMoneyBox ?? defaultMoneyBox;

      if (params.requestedMoneyBoxId && !selectedMoneyBox) {
        throw new MoneyBoxNotFoundForPaymentError();
      }

      const selectedBankAccount = await resolveShopBankAccount(tx, params.shopId, params.requestedBankAccountId);
      const defaultBankAccount =
        params.paymentMethod === "BANK" && !selectedBankAccount ? await resolveDefaultBankAccount(tx, params.shopId) : null;
      const effectiveBankAccount = selectedBankAccount ?? defaultBankAccount;

      if (params.requestedBankAccountId && !selectedBankAccount) {
        throw new BankAccountNotFoundError();
      }

      if (params.paymentMethod === "BANK" && !effectiveBankAccount) {
        throw new BankAccountNotFoundError();
      }

      if (["CASH", "BKASH", "NAGAD"].includes(params.paymentMethod || "") && !effectiveMoneyBox) {
        throw new MoneyBoxNotFoundForPaymentError();
      }

      const purchase = await tx.purchase.findFirst({ where: { id: params.purchaseId, shopId: params.shopId }, include: buildPurchaseInclude() });

      if (!purchase) return null;

      if (purchase.status !== "APPROVED") {
        throw new OnlyApprovedPurchasesReceiveDuePaymentsError();
      }

      const returnSummary = getPurchaseReturnSummary(purchase);
      const allowedDue = Number(returnSummary.remainingDue);

      if (params.amount > allowedDue) {
        throw new PaymentExceedsRemainingDueError();
      }

      if (!purchase.supplierId) {
        throw new PurchaseHasNoSupplierForPaymentError();
      }

      const payment = await tx.supplierPayment.create({
        data: {
          shopId: params.shopId,
          supplierId: purchase.supplierId,
          amount: params.amount,
          paymentMethod: params.paymentMethod,
          paymentMeta: params.paymentMeta,
          moneyBoxId: effectiveMoneyBox?.id ?? null,
          bankAccountId: effectiveBankAccount?.id ?? null,
          notes: params.notes,
          paidAt: params.paidAt,
        },
      });

      if (effectiveMoneyBox && ["CASH", "BKASH", "NAGAD"].includes(params.paymentMethod || "")) {
        await tx.moneyBox.update({ where: { id: effectiveMoneyBox.id }, data: { currentBalance: { decrement: params.amount } } });
      }

      if (effectiveBankAccount && params.paymentMethod === "BANK") {
        await tx.bankAccount.update({ where: { id: effectiveBankAccount.id }, data: { currentBalance: { decrement: params.amount } } });
      }

      await tx.supplierLedger.create({
        data: {
          shopId: params.shopId,
          supplierId: purchase.supplierId,
          purchaseId: purchase.id,
          supplierPaymentId: payment.id,
          entryType: "PAYMENT",
          referenceNo: purchase.invoiceNo || purchase.supplier?.supplierCode || null,
          debit: 0,
          credit: params.amount,
          notes: params.notes,
          entryDate: params.paidAt,
        },
      });

      const updatedPurchase = await tx.purchase.update({
        where: { id: purchase.id },
        data: {
          paidAmount: Number((Number(purchase.paidAmount ?? 0) + params.amount).toFixed(2)),
          dueAmount: Number(Math.max(Number(purchase.dueAmount ?? 0) - params.amount, 0).toFixed(2)),
        },
        include: buildPurchaseInclude(),
      });

      return { payment, purchase: updatedPurchase };
    });
  }

  async createPurchaseReturn(params: Parameters<PurchaseRepository["createPurchaseReturn"]>[0]) {
    return (prisma as any).$transaction(async (tx: any) => {
      const purchase = await tx.purchase.findFirst({ where: { id: params.purchaseId, shopId: params.shopId }, include: buildPurchaseInclude() });

      if (!purchase) return null;

      if (purchase.status !== "APPROVED") {
        throw new OnlyApprovedPurchasesCanBeReturnedError();
      }

      const existingReturnedByItem = new Map<string, number>();
      for (const existingReturn of purchase.returns ?? []) {
        for (const item of existingReturn.items ?? []) {
          existingReturnedByItem.set(item.purchaseItemId, Number((existingReturnedByItem.get(item.purchaseItemId) ?? 0) + Number(item.quantity ?? 0)));
        }
      }

      const purchaseItemsById = new Map<string, any>((purchase.items ?? []).map((item: any) => [item.id, item]));
      let refundAmount = 0;
      const normalizedItems = params.items.map((item) => ({ ...item }));

      for (const item of normalizedItems) {
        let purchaseItem = purchaseItemsById.get(item.purchaseItemId);
        if (!purchaseItem) {
          purchaseItem = (purchase.items ?? []).find((pi: any) => pi.masterProductId === item.purchaseItemId || pi.id === item.purchaseItemId);
        }
        if (!purchaseItem) {
          throw new ReturnItemNotInPurchaseError();
        }
        item.purchaseItemId = purchaseItem.id;

        const purchasedQty = Number(purchaseItem.quantity ?? 0);
        const alreadyReturnedQty = Number(existingReturnedByItem.get(item.purchaseItemId) ?? 0);
        const allowedQty = Number((purchasedQty - alreadyReturnedQty).toFixed(3));

        if (item.quantity > allowedQty) {
          throw new ReturnQuantityExceedsAvailableError(purchaseItem.masterProduct.name);
        }

        refundAmount += Number((item.quantity * Number(purchaseItem.purchasePrice ?? 0)).toFixed(2));
      }

      refundAmount = Number(refundAmount.toFixed(2));
      const isShopOwner = params.isShopOwner;

      const createdReturn = await tx.purchaseReturn.create({
        data: {
          shopId: params.shopId,
          purchaseId: purchase.id,
          supplierId: purchase.supplierId,
          createdByUserId: params.createdByUserId,
          approvedByUserId: isShopOwner ? params.createdByUserId : null,
          returnDate: new Date(),
          status: isShopOwner ? "APPROVED" : "PENDING_APPROVAL",
          refundMethod: params.refundMethod,
          refundAmount,
          notes: params.notes,
          items: {
            create: normalizedItems.map((item) => {
              const purchaseItem = purchaseItemsById.get(item.purchaseItemId);
              return {
                purchaseItemId: item.purchaseItemId,
                masterProductId: purchaseItem.masterProductId,
                quantity: item.quantity,
                unitPrice: Number(purchaseItem.purchasePrice ?? 0),
                totalAmount: Number((item.quantity * Number(purchaseItem.purchasePrice ?? 0)).toFixed(2)),
                reason: item.reason,
              };
            }),
          },
        },
        include: { items: true },
      });

      if (createdReturn.status === "APPROVED") {
        for (const item of normalizedItems) {
          const purchaseItem = purchaseItemsById.get(item.purchaseItemId);
          const shopProduct = await tx.shopProduct.findUnique({
            where: { shopId_masterProductId: { shopId: params.shopId, masterProductId: purchaseItem.masterProductId } },
            select: { id: true, masterProductId: true, openingStock: true, purchasePrice: true, salePrice: true },
          });

          const previousStock = Number(shopProduct?.openingStock ?? 0);
          const nextStock = previousStock - item.quantity;

          await tx.shopProduct.update({
            where: { shopId_masterProductId: { shopId: params.shopId, masterProductId: purchaseItem.masterProductId } },
            data: { openingStock: { decrement: item.quantity } },
          });

          if (shopProduct) {
            await recordStockMovement(tx, {
              shopId: params.shopId,
              shopProductId: shopProduct.id,
              masterProductId: shopProduct.masterProductId,
              movementType: "PURCHASE_RETURN",
              quantityDelta: -item.quantity,
              stockBefore: previousStock,
              stockAfter: nextStock,
              purchasePrice: normalizeStockMoney(shopProduct.purchasePrice),
              salePrice: normalizeStockMoney(shopProduct.salePrice),
              unitPrice: Number(purchaseItem.purchasePrice ?? 0),
              referenceType: "PURCHASE_RETURN",
              referenceId: createdReturn.id,
              referenceNo: purchase.invoiceNo || null,
              note: item.reason || params.notes || "Purchase return approved.",
              createdByUserId: params.createdByUserId,
            });
          }
        }

        if (purchase.supplierId) {
          await tx.supplierLedger.create({
            data: {
              shopId: params.shopId,
              supplierId: purchase.supplierId,
              purchaseId: purchase.id,
              entryType: "PURCHASE_RETURN",
              referenceNo: purchase.invoiceNo || purchase.supplier?.supplierCode || null,
              debit: 0,
              credit: refundAmount,
              notes: params.notes || `Purchase return via ${params.refundMethod}`,
              entryDate: new Date(),
            },
          });
        }

        const adjustedDue = Math.max(Number(purchase.totalAmount ?? 0) - refundAmount - Number(purchase.paidAmount ?? 0), 0);
        await tx.purchase.update({ where: { id: purchase.id }, data: { dueAmount: Number(adjustedDue.toFixed(2)) } });
      }

      return tx.purchase.findUnique({ where: { id: purchase.id }, include: buildPurchaseInclude() });
    });
  }

  async approvePurchase(id: string, shopId: string, approvedByUserId: string) {
    return (prisma as any).$transaction(async (tx: any) => {
      const existingPurchase = await tx.purchase.findFirst({ where: { id, shopId }, include: buildPurchaseInclude() });

      if (!existingPurchase) return null;

      if (existingPurchase.status === "REJECTED") {
        throw new RejectedPurchasesCannotBeApprovedError();
      }

      if (existingPurchase.status !== "PENDING_APPROVAL") {
        return existingPurchase;
      }

      const updatedPurchase = await tx.purchase.update({
        where: { id: existingPurchase.id },
        data: { status: "APPROVED", approvedByUserId, approvedAt: new Date(), rejectionReason: null, rejectedAt: null },
        include: buildPurchaseInclude(),
      });

      await applyApprovedPurchaseEffects({
        tx,
        shopId,
        purchase: updatedPurchase,
        items: updatedPurchase.items.map((item: any) => ({
          masterProductId: item.masterProductId,
          quantity: Number(item.quantity),
          purchasePrice: Number(item.purchasePrice),
          totalAmount: Number(item.totalAmount),
          batchNo: item.batchNo,
          expiryDate: item.expiryDate,
        })),
        paymentMethod: updatedPurchase.paymentMethod,
        paymentMeta: updatedPurchase.paymentMeta ?? null,
      });

      return updatedPurchase;
    });
  }

  async rejectPurchase(id: string, shopId: string, reason: string | null) {
    const purchase = await (prisma as any).purchase.findFirst({ where: { id, shopId }, select: { id: true, status: true } });

    if (!purchase) return null;

    if (purchase.status !== "PENDING_APPROVAL") {
      throw new OnlyPendingPurchasesCanBeRejectedError();
    }

    return (prisma as any).purchase.update({
      where: { id: purchase.id },
      data: { status: "REJECTED", approvedByUserId: null, approvedAt: null, rejectedAt: new Date(), rejectionReason: reason },
      include: {
        supplier: { select: { id: true, name: true, supplierCode: true } },
        shop: { select: { id: true, shopName: true } },
        items: { include: { masterProduct: { select: { id: true, name: true, sku: true } } } },
      },
    });
  }

  async receivePurchase(params: Parameters<PurchaseRepository["receivePurchase"]>[0]) {
    return (prisma as any).$transaction(async (tx: any) => {
      const existingPurchase = await tx.purchase.findFirst({ where: { id: params.purchaseId, shopId: params.shopId }, include: buildPurchaseInclude() });

      if (!existingPurchase) return null;

      if (existingPurchase.status === "REJECTED") {
        throw new RejectedPurchasesCannotBeReceivedError();
      }

      if (existingPurchase.status === "APPROVED") {
        return existingPurchase;
      }

      const existingItems = Array.isArray(existingPurchase.items) ? existingPurchase.items : [];
      const incomingByProductId = new Map(params.lines.map((item) => [item.masterProductId, item] as const));
      const placementByProductId = new Map(params.placements.map((item) => [item.masterProductId, item] as const));

      const updatedItems = existingItems.map((item: any) => {
        const incoming = incomingByProductId.get(item.masterProductId);
        const physicalCount = Number(incoming?.quantity ?? item.quantity ?? 0);
        if (!Number.isFinite(physicalCount) || physicalCount <= 0) {
          throw new InvalidPhysicalCountError(item.masterProduct?.name ?? "a purchase item");
        }

        const purchasePrice = Number(incoming?.purchasePrice ?? item.purchasePrice ?? 0);
        const totalAmount = Number((physicalCount * purchasePrice).toFixed(2));

        return {
          masterProductId: item.masterProductId,
          quantity: physicalCount,
          purchasePrice,
          totalAmount,
          expiryDate: item.expiryDate,
          salePrice: incoming?.salePrice ?? null,
          batchNo: incoming?.batchNo ?? item.batchNo ?? null,
        };
      });

      if (params.lines.length > 0) {
        const unknownLines = params.lines.filter((item) => !existingItems.some((purchaseItem: any) => purchaseItem.masterProductId === item.masterProductId));
        if (unknownLines.length > 0) {
          throw new UnknownReceivedProductError();
        }
      }

      const subtotalAmount = Number(
        updatedItems.reduce((sum: number, item: any) => sum + Number((Number(item.quantity) * Number(item.purchasePrice ?? 0)).toFixed(2)), 0).toFixed(2),
      );
      const discountAmount = Number(existingPurchase.discountAmount ?? 0);
      const extraChargeAmount = Number(existingPurchase.extraChargeAmount ?? 0);
      const totalAmount = Number(Math.max(0, subtotalAmount - discountAmount + extraChargeAmount).toFixed(2));

      const paidAmountInput = params.bodyPaidAmount !== undefined && params.bodyPaidAmount !== null ? Number(params.bodyPaidAmount) : null;

      let finalPaymentMethod: string | null = existingPurchase.paymentMethod ?? "CASH";
      let finalPaymentMeta: Record<string, unknown> | null = existingPurchase.paymentMeta ?? null;
      let finalPaidAmount: number | null =
        existingPurchase.paidAmount !== null && existingPurchase.paidAmount !== undefined ? Number(existingPurchase.paidAmount) : null;

      if (params.bodyPaymentMethod) {
        const paymentInfo = normalizePurchasePayment(params.bodyPaymentMethod, paidAmountInput ?? totalAmount, params.bodyPaymentDetails as any);
        if (paymentInfo && "error" in paymentInfo) {
          throw new ReceivePurchasePaymentInfoError(paymentInfo.error);
        }
        finalPaymentMethod = paymentInfo.paymentMethod;
        finalPaymentMeta = paymentInfo.paymentMeta;
        finalPaidAmount = paidAmountInput ?? (finalPaymentMethod === "DUE" ? 0 : totalAmount);
      } else if (paidAmountInput !== null) {
        finalPaidAmount = paidAmountInput;
      } else if (finalPaidAmount === null) {
        finalPaidAmount = finalPaymentMethod === "DUE" ? 0 : totalAmount;
      }

      if (finalPaymentMethod === "DUE") {
        finalPaidAmount = 0;
      }

      const finalDueAmount = Math.max(0, totalAmount - (finalPaidAmount ?? 0));

      const selectedMoneyBox = await resolveShopMoneyBox(tx, params.shopId, params.requestedMoneyBoxId);
      const defaultMoneyBox = !selectedMoneyBox ? await resolveDefaultMoneyBoxByType(tx, params.shopId, finalPaymentMethod) : null;
      const effectiveMoneyBox = selectedMoneyBox ?? defaultMoneyBox;

      const selectedBankAccount = await resolveShopBankAccount(tx, params.shopId, params.requestedBankAccountId);
      const defaultBankAccount =
        finalPaymentMethod === "BANK" && !selectedBankAccount ? await resolveDefaultBankAccount(tx, params.shopId) : null;
      const effectiveBankAccount = selectedBankAccount ?? defaultBankAccount;

      if (params.requestedMoneyBoxId && !selectedMoneyBox) {
        throw new ReceivePurchaseMoneyBoxNotFoundError();
      }

      if (params.requestedBankAccountId && !selectedBankAccount) {
        throw new ReceivePurchaseBankAccountNotFoundError();
      }

      if ((finalPaidAmount ?? 0) > 0 && finalPaymentMethod === "BANK" && !effectiveBankAccount) {
        throw new ReceivePurchaseBankAccountNotFoundError();
      }

      if ((finalPaidAmount ?? 0) > 0 && ["CASH", "BKASH", "NAGAD", "ROCKET"].includes(finalPaymentMethod || "") && !effectiveMoneyBox) {
        throw new ReceivePurchaseMoneyBoxNotFoundError();
      }

      const updatedPurchase = await tx.purchase.update({
        where: { id: existingPurchase.id },
        data: {
          status: "APPROVED",
          approvedByUserId: params.approvedByUserId,
          approvedAt: new Date(),
          rejectionReason: null,
          rejectedAt: null,
          subtotalAmount,
          totalAmount,
          paidAmount: finalPaidAmount,
          dueAmount: finalDueAmount,
          paymentMethod: finalPaymentMethod,
          paymentMeta: finalPaymentMeta,
          items: {
            deleteMany: {},
            create: updatedItems.map((item: any) => ({
              masterProductId: item.masterProductId,
              batchNo: item.batchNo,
              expiryDate: item.expiryDate,
              quantity: item.quantity,
              purchasePrice: item.purchasePrice,
              totalAmount: item.totalAmount,
            })),
          },
        },
        include: buildPurchaseInclude(),
      });

      await applyApprovedPurchaseEffects({
        tx,
        shopId: params.shopId,
        purchase: updatedPurchase,
        items: updatedItems,
        placements: updatedItems.map((item: any) => {
          const placement = placementByProductId.get(item.masterProductId);
          return {
            masterProductId: item.masterProductId,
            quantity: Number(item.quantity),
            salePrice: item.salePrice ?? null,
            zoneId: placement?.zoneId ?? null,
            rackId: placement?.rackId ?? null,
            shelfId: placement?.shelfId ?? null,
            binId: placement?.binId ?? null,
            batchNo: placement?.batchNo ?? item.batchNo ?? null,
            expiryDate: placement?.expiryDate ?? item.expiryDate ?? null,
            productName: placement?.productName ?? item.masterProduct?.name ?? null,
          };
        }),
        paymentMethod: finalPaymentMethod,
        paymentMeta: finalPaymentMeta,
        moneyBoxId: effectiveMoneyBox?.id ?? null,
        bankAccountId: effectiveBankAccount?.id ?? null,
      });

      return updatedPurchase;
    });
  }

  async cancelPurchase(id: string, shopId: string, reason: string) {
    return (prisma as any).$transaction(async (tx: any) => {
      const existingPurchase = await tx.purchase.findFirst({ where: { id, shopId } });

      if (!existingPurchase) return null;

      if (existingPurchase.status === "APPROVED") {
        throw new ApprovedPurchasesCannotBeCancelledError();
      }

      return tx.purchase.update({
        where: { id: existingPurchase.id },
        data: { status: "REJECTED", rejectedAt: new Date(), rejectionReason: reason },
        include: buildPurchaseInclude(),
      });
    });
  }
}
