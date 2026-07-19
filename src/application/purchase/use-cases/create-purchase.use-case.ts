import { normalizePurchasePayment, normalizeText, type NormalizedPurchaseItem } from "@domain/purchase/purchase.entity";
import {
  InvalidDiscountAmountError,
  InvalidExpiryDateError,
  InvalidExtraChargeAmountError,
  InvalidPaidAmountError,
  InvalidPurchaseItemError,
  PaidAmountExceedsTotalError,
  PurchaseItemsRequiredError,
  PurchaseProductNotFoundInShopError,
  PurchaseProductsDoNotExistError,
  PurchasePaymentValidationError,
  SupplierNotLinkedToShopError,
} from "@domain/purchase/purchase.errors";
import { ForbiddenError, PaymentRequiredError } from "@domain/shared/app-error";

import type { PurchaseRepository, ShopScope } from "../ports/purchase-repository.port";

export type CreatePurchaseCommand = {
  shop: ShopScope;
  createdByUserId: string;
  body: any;
};

export class CreatePurchaseUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(command: CreatePurchaseCommand) {
    const { shop, createdByUserId, body } = command;
    const shopId = shop.id;

    const supplierId = body.supplierId ?? body.supplier_id ?? body.supplierKey ?? body.supplier_key;
    const discountAmount =
      body.discountAmount == null || body.discountAmount === ""
        ? body.discount_amount == null || body.discount_amount === ""
          ? 0
          : Number(body.discount_amount)
        : Number(body.discountAmount);
    const extraChargeAmount =
      body.extraChargeAmount == null || body.extraChargeAmount === ""
        ? body.extra_charge_amount == null || body.extra_charge_amount === ""
          ? 0
          : Number(body.extra_charge_amount)
        : Number(body.extraChargeAmount);
    const paidAmount =
      body.paidAmount == null || body.paidAmount === ""
        ? body.paid_amount == null || body.paid_amount === ""
          ? 0
          : Number(body.paid_amount)
        : Number(body.paidAmount);
    const invoiceFileNameRaw = body.invoiceFileName ?? body.invoice_file_name;
    const purchaseDateRaw = body.purchaseDate ?? body.purchase_date ?? new Date().toISOString();

    const rawItems = body.items ?? body.lines ?? [];
    if (rawItems.length === 0) {
      throw new PurchaseItemsRequiredError();
    }

    let normalizedItems: NormalizedPurchaseItem[] = rawItems.map((item: any) => {
      const masterProductId = item.masterProductId ?? item.productId ?? item.product_id ?? item.shopProductId ?? "";
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

    const resolvedItems: NormalizedPurchaseItem[] = [];
    for (const item of normalizedItems) {
      let shopProduct = await this.purchaseRepository.resolveShopProductByIdentifier(shopId, item.masterProductId);

      if (!shopProduct) {
        throw new PurchaseProductNotFoundInShopError(item.masterProductId);
      }

      if (!shopProduct.masterProductId) {
        shopProduct = await this.purchaseRepository.promoteShopLocalProductToShadowMaster(shopProduct, createdByUserId);
      }

      resolvedItems.push({
        masterProductId: shopProduct.masterProductId,
        quantity: item.quantity,
        purchasePrice: item.purchasePrice,
        totalAmount: item.totalAmount,
        batchNo: item.batchNo,
        expiryDate: item.expiryDate,
      });
    }

    normalizedItems = resolvedItems;

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

    // NOTE: uses `body.paymentMethod`/`body.paymentDetails` directly, not the
    // (dead, in the original) locally-derived `paymentMethod` variable with
    // its "CASH" default and `payment_method` alias — this preserves a real
    // divergence from the update flow, which does honor that alias. Do not
    // "fix" this into parity with update; see CLAUDE.md purchases notes.
    const paymentInfo = normalizePurchasePayment(body.paymentMethod, paidAmount, body.paymentDetails);

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
    const purchaseDate = purchaseDateRaw ? new Date(purchaseDateRaw) : new Date();
    const invoiceFileName = normalizeText(invoiceFileNameRaw) || null;

    return this.purchaseRepository.createPurchase({
      shopId,
      createdByUserId,
      supplierId: normalizedSupplierId || null,
      // NOTE: original uses `body.invoiceNo?.trim() || null` / `body.notes?.trim() || null`
      // directly here — the `invoice_no`/`reference`/`note` aliases (computed
      // but unused in the original create handler) are silently ignored,
      // unlike update. Preserved verbatim.
      invoiceNo: normalizeText(body.invoiceNo) || null,
      purchaseDate,
      subtotalAmount,
      discountAmount,
      extraChargeAmount,
      totalAmount,
      paidAmount,
      dueAmount,
      paymentMethod: paymentInfo.paymentMethod,
      paymentMeta: paymentInfo.paymentMeta,
      invoiceFileName,
      notes: normalizeText(body.notes) || null,
      items: normalizedItems,
      requestedMoneyBoxId: body.moneyBoxId,
      requestedBankAccountId: body.bankAccountId,
    });
  }
}
