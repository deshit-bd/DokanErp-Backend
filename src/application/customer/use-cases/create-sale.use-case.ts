import { normalizeCustomerPayment, toMoney } from "@domain/customer/customer.entity";
import {
  CustomerCouldNotBeResolvedError,
  CustomerPaymentValidationError,
  InvalidChargeAmountError,
  InvalidDiscountAmountError,
  InvalidPaidAmountError,
  InvalidSaleItemError,
  InvalidStoreCreditUsedError,
  InvalidTaxAmountError,
  MoneyBoxNotFoundForShopError,
  SaleItemsRequiredError,
  SaleProductsDoNotExistError,
  StoreCreditExceedsAvailableError,
} from "@domain/customer/customer.errors";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export type CreateSaleCommand = {
  shop: ShopScope;
  createdByUserId: string;
  body: any;
};

export class CreateSaleUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async execute(command: CreateSaleCommand) {
    const { shop, createdByUserId, body } = command;

    let customerId = body.customerId;
    const reqCustomer = body.customer;

    if (!customerId && reqCustomer) {
      const customerName = reqCustomer.name?.trim() || "Guest Customer";
      const customerPhone = reqCustomer.phone?.trim() || reqCustomer.mobile?.trim() || null;
      const resolved = await this.customerRepository.findOrCreateGuestOrNamedCustomer(customerName, customerPhone);
      customerId = resolved.id;
    }

    if (!customerId) {
      const guest = await this.customerRepository.findOrCreateGuestCustomer();
      customerId = guest.id;
    }

    let customer = await this.customerRepository.resolveCustomerLinkedToShop(customerId as string, shop.id);
    if (!customer) {
      customer = await this.customerRepository.linkCustomerToShop(customerId as string, shop.id);
    }

    if (!customer) {
      throw new CustomerCouldNotBeResolvedError();
    }

    const items = body.items ?? body.lines ?? [];

    if (items.length === 0) {
      throw new SaleItemsRequiredError();
    }

    const normalizedItems = items.map((item: any) => {
      const masterProductId = item.masterProductId || item.productId || item.shopProductId || "";
      const quantity = Number(item.quantity ?? item.qty ?? 0);
      const salePrice = Number(item.salePrice ?? item.unitPrice ?? item.price ?? 0);
      const batchNo = typeof item.batchNo === "string" ? item.batchNo.trim() || null : null;

      return { masterProductId, quantity, salePrice, totalAmount: Number((quantity * salePrice).toFixed(2)), batchNo };
    });

    if (normalizedItems.some((item: any) => !item.masterProductId || !Number.isFinite(item.quantity) || item.quantity <= 0 || !Number.isFinite(item.salePrice) || item.salePrice < 0)) {
      throw new InvalidSaleItemError();
    }

    const paidAmount = body.paidAmount == null || body.paidAmount === "" ? 0 : Number(body.paidAmount);
    const requestedStoreCreditUsed = body.storeCreditUsed == null || body.storeCreditUsed === "" ? 0 : Number(body.storeCreditUsed);
    const discountAmount = body.discountAmount == null || body.discountAmount === "" ? 0 : Number(body.discountAmount);
    const taxAmount = body.taxAmount == null || body.taxAmount === "" ? 0 : Number(body.taxAmount);
    const chargeAmount = body.chargeAmount == null || body.chargeAmount === "" ? 0 : Number(body.chargeAmount);

    if (!Number.isFinite(paidAmount) || paidAmount < 0) throw new InvalidPaidAmountError();
    if (!Number.isFinite(requestedStoreCreditUsed) || requestedStoreCreditUsed < 0) throw new InvalidStoreCreditUsedError();
    if (!Number.isFinite(discountAmount) || discountAmount < 0) throw new InvalidDiscountAmountError();
    if (!Number.isFinite(taxAmount) || taxAmount < 0) throw new InvalidTaxAmountError();
    if (!Number.isFinite(chargeAmount) || chargeAmount < 0) throw new InvalidChargeAmountError();

    const paymentInfo = normalizeCustomerPayment(body.paymentMethod, paidAmount, body.paymentDetails);

    if ("error" in paymentInfo) {
      throw new CustomerPaymentValidationError(paymentInfo.error);
    }

    for (const item of normalizedItems) {
      const sp = await this.customerRepository.resolveShopProduct(shop.id, item.masterProductId);
      if (!sp) {
        throw new SaleProductsDoNotExistError();
      }
    }

    const moneyBox = await this.customerRepository.resolveShopMoneyBox(shop.id, body.moneyBoxId);
    const fallbackMoneyBox = !moneyBox ? await this.customerRepository.resolveDefaultMoneyBoxByType(shop.id, paymentInfo.paymentMethod) : null;
    const effectiveMoneyBox = moneyBox ?? fallbackMoneyBox;

    if (body.moneyBoxId && !moneyBox) {
      throw new MoneyBoxNotFoundForShopError();
    }

    const availableStoreCredit = toMoney(customer.storeCredit);

    if (requestedStoreCreditUsed > availableStoreCredit) {
      throw new StoreCreditExceedsAvailableError();
    }

    const saleDate = body.saleDate ? new Date(body.saleDate) : new Date();

    const { createdSale, payment, storeCreditUsed } = await this.customerRepository.createSale({
      shop,
      customer,
      createdByUserId,
      invoiceNo: typeof body.invoiceNo === "string" ? body.invoiceNo.trim() || null : null,
      notes: typeof body.notes === "string" ? body.notes.trim() || null : null,
      saleDate,
      items: normalizedItems,
      paidAmount,
      requestedStoreCreditUsed,
      discountAmount,
      taxAmount,
      chargeAmount,
      paymentMethod: paymentInfo.paymentMethod,
      paymentMeta: paymentInfo.paymentMeta,
      effectiveMoneyBoxId: effectiveMoneyBox?.id ?? null,
    });

    return {
      customer,
      sale: {
        id: createdSale.id,
        shopId: createdSale.shopId,
        customerId: createdSale.customerId,
        invoiceNo: createdSale.invoiceNo,
        saleDate: createdSale.saleDate,
        totalAmount: toMoney(createdSale.totalAmount),
        paidAmount: toMoney(createdSale.paidAmount),
        dueAmount: toMoney(createdSale.dueAmount),
        storeCreditUsed,
        paymentMethod: createdSale.paymentMethod,
        notes: createdSale.notes,
        salesmanPhone: createdSale.createdBy?.phone ?? null,
        salesmanName: createdSale.createdBy?.name ?? null,
        items: createdSale.items.map((item: any) => ({
          id: item.id,
          masterProductId: item.masterProductId,
          name: item.masterProduct.name,
          sku: item.masterProduct.sku,
          quantity: toMoney(item.quantity),
          salePrice: toMoney(item.salePrice),
          totalAmount: toMoney(item.totalAmount),
          batchNo: item.batchNo ?? null,
        })),
      },
      payment: payment
        ? {
            id: payment.id,
            amount: toMoney(payment.amount),
            paymentMethod: payment.paymentMethod,
            paymentDetails: payment.paymentMeta ?? null,
            moneyBoxId: payment.moneyBoxId,
            referenceNo: payment.referenceNo,
            paidAt: payment.paidAt,
          }
        : null,
    };
  }
}
