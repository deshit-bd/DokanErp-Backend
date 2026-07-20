import { toCustomerSummary, type CustomerStatusValue } from "@domain/customer/customer.entity";
import { CustomerAlreadyLinkedToShopError, CustomerNameRequiredError } from "@domain/customer/customer.errors";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export type CreateCustomerBody = {
  customerCode?: string;
  companyOrPersonName?: string;
  name?: string;
  mobile?: string | null;
  email?: string | null;
  address?: string | null;
  shortNote?: string | null;
  notes?: string | null;
  status?: CustomerStatusValue;
  openingDue?: number | string | null;
};

export class CreateCustomerUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async execute(shop: ShopScope, body: CreateCustomerBody) {
    const customerCode = body.customerCode?.trim();
    const name = body.name?.trim() || body.companyOrPersonName?.trim() || "";
    const mobile = body.mobile?.trim() || null;
    const email = body.email?.trim() || null;
    const address = body.address?.trim() || null;
    const notes = body.notes?.trim() || body.shortNote?.trim() || null;
    const status = body.status ?? "ACTIVE";

    if (!name) {
      throw new CustomerNameRequiredError();
    }

    const generatedCustomerCode = customerCode || (await this.customerRepository.createUniqueCustomerCode(name));

    const duplicateCustomer = await this.customerRepository.findCustomerForLinkCheck({ customerCode: generatedCustomerCode, mobile, name });

    if (duplicateCustomer) {
      const existingShopLink = await this.customerRepository.resolveCustomerLinkedToShop(duplicateCustomer.id, shop.id);

      if (existingShopLink) {
        throw new CustomerAlreadyLinkedToShopError({
          customer: {
            id: duplicateCustomer.id,
            customerCode: duplicateCustomer.customerCode,
            name: duplicateCustomer.name,
            companyOrPersonName: duplicateCustomer.name,
            mobile: duplicateCustomer.mobile,
          },
        });
      }

      const openingDue = Number(body.openingDue ?? 0);

      await this.customerRepository.createShopCustomerLedgerEntry({
        shopId: shop.id,
        customerId: duplicateCustomer.id,
        referenceNo: `REG-${duplicateCustomer.customerCode}`,
        debit: openingDue,
        credit: 0,
        notes: openingDue > 0 ? "প্রারম্ভিক বকেয়া" : "বিদ্যমান গ্রাহককে এই দোকানের সাথে যুক্ত করা হয়েছে",
      });

      const linkedCustomer = await this.customerRepository.findCustomerById(duplicateCustomer.id);

      return { linkedExisting: true, customer: toCustomerSummary(linkedCustomer) };
    }

    const customer = await this.customerRepository.createGlobalCustomer({
      customerCode: generatedCustomerCode,
      name,
      mobile,
      email,
      address,
      notes,
      status,
    });

    const openingDue = Number(body.openingDue ?? 0);

    await this.customerRepository.createShopCustomerLedgerEntry({
      shopId: shop.id,
      customerId: customer.id,
      referenceNo: `REG-${customer.customerCode}`,
      debit: openingDue,
      credit: 0,
      notes: openingDue > 0 ? "প্রারম্ভিক বকেয়া" : "গ্রাহক নিবন্ধন",
    });

    return { linkedExisting: false, customer: toCustomerSummary(customer), customerName: name };
  }
}
