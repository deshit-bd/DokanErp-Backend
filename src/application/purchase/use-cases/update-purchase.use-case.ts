import { normalizePurchasePayment, normalizeText, type NormalizedPurchaseItem } from "@domain/purchase/purchase.entity";
import {
  InvalidDiscountAmountError,
  InvalidExpiryDateError,
  InvalidExtraChargeAmountError,
  InvalidPaidAmountError,
  InvalidPurchaseDateError,
  InvalidPurchaseItemError,
  PaidAmountExceedsTotalError,
  PurchaseItemsRequiredError,
  PurchaseNotEditableError,
  PurchaseNotFoundError,
  PurchaseProductsDoNotExistError,
  PurchasePaymentValidationError,
  SupplierNotLinkedToShopError,
} from "@domain/purchase/purchase.errors";
import { ForbiddenError, PaymentRequiredError } from "@domain/shared/app-error";

import type { PurchaseRepository } from "../ports/purchase-repository.port";

export class UpdatePurchaseUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(shopId: string, purchaseId: string, body: any) {
    const existingPurchase = await this.purchaseRepository.findPurchaseByIdInShop(purchaseId, shopId);

    if (!existingPurchase) {
      throw new PurchaseNotFoundError();
    }

    if (!["PENDING_APPROVAL", "REJECTED", "DRAFT"].includes(existingPurchase.status)) {
      throw new PurchaseNotEditableError();
    }

    const supplierId = body.supplierId ?? body.supplier_id ?? body.supplierKey ?? body.supplier_key;
    const notes = body.notes ?? body.note ?? null;
    const discountAmount =
      body.discountAmount == null || body.discountAmount === ""
        ? body.discount_amount == null || body.discount_amount === ""
          ? Number(existingPurchase.discountAmount ?? 0)
          : Number(body.discount_amount)
        : Number(body.discountAmount);
    const extraChargeAmount =
      body.extraChargeAmount == null || body.extraChargeAmount === ""
        ? body.extra_charge_amount == null || body.extra_charge_amount === ""
          ? Number(existingPurchase.extraChargeAmount ?? 0)
          : Number(body.extra_charge_amount)
        : Number(body.extraChargeAmount);
    const paidAmount =
      body.paidAmount == null || body.paidAmount === ""
        ? body.paid_amount == null || body.paid_amount === ""
          ? Number(existingPurchase.paidAmount ?? 0)
          : Number(body.paid_amount)
        : Number(body.paidAmount);
    const paymentMethod = body.paymentMethod ?? body.payment_method ?? existingPurchase.paymentMethod ?? "CASH";
    const purchaseDateRaw = body.purchaseDate ?? body.purchase_date ?? existingPurchase.purchaseDate;

    const rawItems = body.items ?? body.lines ?? [];
    if (rawItems.length === 0) {
      throw new PurchaseItemsRequiredError();
    }

    const normalizedItems: NormalizedPurchaseItem[] = rawItems.map((item: any) => {
      const masterProductId = item.masterProductId ?? item.productId ?? item.product_id ?? item.shopProductId ?? item.id ?? "";
      const quantity = Number(item.quantity ?? item.qty ?? item.orderedQuantity ?? item.ordered_quantity ?? 0);
      const purchasePrice = Number(item.purchasePrice ?? item.purchase_price ?? item.unitCost ?? item.unit_cost ?? 0);

      return {
        masterProductId,
        quantity,
        purchasePrice,
        totalAmount: Number((quantity * purchasePrice).toFixed(2)),
        batchNo: item.batchNo ?? item.batch_no ?? null,
        expiryDate: item.expiryDate ?? item.expiry_date ? new Date(item.expiryDate ?? item.expiry_date) : null,
      };
    });

    if (normalizedItems.some((item) => !item.masterProductId || !Number.isFinite(item.quantity) || item.quantity <= 0 || !Number.isFinite(item.purchasePrice) || item.purchasePrice < 0)) {
      throw new InvalidPurchaseItemError();
    }

    if (normalizedItems.some((item) => item.expiryDate && Number.isNaN(item.expiryDate.getTime()))) {
      throw new InvalidExpiryDateError();
    }

    const subtotalAmount = Number(normalizedItems.reduce((sum, item) => sum + item.totalAmount, 0).toFixed(2));

    if (!Number.isFinite(discountAmount) || discountAmount < 0) {
      throw new InvalidDiscountAmountError();
    }

    if (!Number.isFinite(extraChargeAmount) || extraChargeAmount < 0) {
      throw new InvalidExtraChargeAmountError();
    }

    if (!Number.isFinite(paidAmount) || paidAmount < 0) {
      throw new InvalidPaidAmountError();
    }

    const totalAmount = Number(Math.max(0, subtotalAmount - discountAmount + extraChargeAmount).toFixed(2));

    if (paidAmount > totalAmount) {
      throw new PaidAmountExceedsTotalError();
    }

    const paymentInfo = normalizePurchasePayment(paymentMethod, paidAmount, body.paymentDetails ?? body.payment_details);

    if ("error" in paymentInfo) {
      throw new PurchasePaymentValidationError(paymentInfo.error);
    }

    const masterProducts = await this.purchaseRepository.findMasterProductsByIds(normalizedItems.map((item) => item.masterProductId));

    if (masterProducts.length !== normalizedItems.length) {
      throw new PurchaseProductsDoNotExistError();
    }

    const productAccess = await this.purchaseRepository.canAddProductsToShop(shopId, normalizedItems.map((item) => item.masterProductId));

    if (!productAccess.allowed) {
      const details = {
        subscription: productAccess.access,
        currentProductCount: productAccess.currentProductCount,
        nextProductCount: productAccess.nextProductCount,
      };
      if (productAccess.access?.tier === "BLOCKED") {
        throw new PaymentRequiredError(productAccess.message ?? "Subscription access denied.", details);
      }
      throw new ForbiddenError(productAccess.message ?? "You do not have permission to add these products.", details);
    }

    const normalizedSupplierId = typeof supplierId === "string" ? supplierId.trim() : "";

    if (normalizedSupplierId) {
      const supplier = await this.purchaseRepository.resolveSupplierLinkedToShop(normalizedSupplierId, shopId);
      if (!supplier) {
        throw new SupplierNotLinkedToShopError();
      }
    }

    const dueAmount = Number(Math.max(totalAmount - paidAmount, 0).toFixed(2));
    const purchaseDate = purchaseDateRaw ? new Date(purchaseDateRaw) : existingPurchase.purchaseDate;

    if (Number.isNaN(purchaseDate.getTime())) {
      throw new InvalidPurchaseDateError();
    }

    return this.purchaseRepository.updatePurchase({
      id: existingPurchase.id,
      shopId,
      supplierId: normalizedSupplierId || null,
      invoiceNo: normalizeText(body.invoiceNo ?? body.invoice_no ?? body.reference) || null,
      purchaseDate,
      subtotalAmount,
      discountAmount,
      extraChargeAmount,
      totalAmount,
      paidAmount,
      dueAmount,
      paymentMethod: paymentInfo.paymentMethod,
      paymentMeta: paymentInfo.paymentMeta,
      notes: normalizeText(notes) || null,
      items: normalizedItems,
    });
  }
}
