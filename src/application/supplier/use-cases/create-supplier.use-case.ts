import { toDisplayStatus, type SupplierStatusValue } from "@domain/supplier/supplier.entity";
import {
  DuplicateSupplierCodeError,
  DuplicateSupplierNameError,
  InvalidDueAmountError,
  SupplierAlreadyLinkedToShopError,
  SupplierCodeRequiredError,
  SupplierMobileRequiredError,
  SupplierNameRequiredError,
} from "@domain/supplier/supplier.errors";

import type { ShopScope, SupplierRepository } from "../ports/supplier-repository.port";

export type CreateSupplierBody = {
  shopId?: string;
  supplierCode?: string;
  companyOrPersonName?: string;
  name?: string;
  mobile?: string | null;
  email?: string | null;
  address?: string | null;
  productType?: string | null;
  shortNote?: string | null;
  contactPerson?: string | null;
  contactPersonMobile?: string | null;
  notes?: string | null;
  dueAmount?: number | string | null;
  sendWhatsAppInvite?: boolean;
  status?: SupplierStatusValue;
};

export class CreateSupplierUseCase {
  constructor(private readonly supplierRepository: SupplierRepository) {}

  async executeFinance(shop: ShopScope, body: CreateSupplierBody) {
    const { name, mobile, email, address, contactPerson, notes, dueAmount, sendWhatsAppInvite, status, supplierCode } = normalizeBody(body);

    if (!name) throw new SupplierNameRequiredError();
    if (!mobile) throw new SupplierMobileRequiredError();
    if (!Number.isFinite(dueAmount) || dueAmount < 0) throw new InvalidDueAmountError();

    const generatedSupplierCode = supplierCode || (await this.supplierRepository.createUniqueSupplierCode(name));
    const existingSupplier = await this.supplierRepository.findSupplierForLinkCheck({ supplierCode: generatedSupplierCode, mobile, name });

    if (existingSupplier) {
      const alreadyLinked = await this.supplierRepository.isSupplierLinkedToShop(existingSupplier.id, shop.id);

      if (alreadyLinked) {
        throw new SupplierAlreadyLinkedToShopError({
          shop: { id: shop.id, shopCode: shop.shopCode, shopName: shop.shopName },
          supplier: {
            id: existingSupplier.id,
            supplierCode: existingSupplier.supplierCode,
            name: existingSupplier.name,
            companyOrPersonName: existingSupplier.name,
            mobile: existingSupplier.mobile,
          },
        });
      }

      const openingDueEntry = await this.supplierRepository.createShopSupplierOpeningDue({
        shopId: shop.id,
        supplierId: existingSupplier.id,
        referenceNo: existingSupplier.supplierCode,
        dueAmount,
        notes: notes || (dueAmount > 0 ? "Opening due added while linking existing global supplier to shop." : "Existing global supplier linked to this shop."),
      });

      return {
        linkedExisting: true,
        shop,
        supplier: {
          id: existingSupplier.id,
          supplierCode: existingSupplier.supplierCode,
          name: existingSupplier.name,
          companyOrPersonName: existingSupplier.name,
          mobile: existingSupplier.mobile,
          email: existingSupplier.email,
          address: existingSupplier.address,
          productType: existingSupplier.contactPerson,
          shortNote: existingSupplier.notes,
          contactPerson: existingSupplier.contactPerson,
          contactPersonMobile: existingSupplier.contactPersonMobile,
          notes: existingSupplier.notes,
          status: existingSupplier.status,
          statusLabel: toDisplayStatus(existingSupplier.status),
          createdAt: existingSupplier.createdAt,
          updatedAt: existingSupplier.updatedAt,
        },
        openingDue: { amount: dueAmount, entryType: openingDueEntry.entryType, ledgerId: openingDueEntry.id },
        sendWhatsAppInvite,
      };
    }

    const supplier = await this.supplierRepository.createGlobalSupplier({
      supplierCode: generatedSupplierCode,
      name,
      mobile,
      email,
      address,
      contactPerson,
      contactPersonMobile: body.contactPersonMobile?.trim() || null,
      notes,
      status: status ?? "ACTIVE",
    });

    const openingDueEntry = await this.supplierRepository.createShopSupplierOpeningDue({
      shopId: shop.id,
      supplierId: supplier.id,
      referenceNo: supplier.supplierCode,
      dueAmount,
      notes: notes || (dueAmount > 0 ? "Opening due added during supplier creation." : "Supplier created for this shop."),
    });

    return {
      linkedExisting: false,
      shop,
      supplier: {
        id: supplier.id,
        supplierCode: supplier.supplierCode,
        name: supplier.name,
        companyOrPersonName: supplier.name,
        mobile: supplier.mobile,
        email: supplier.email,
        address: supplier.address,
        productType: supplier.contactPerson,
        shortNote: supplier.notes,
        contactPerson: supplier.contactPerson,
        contactPersonMobile: supplier.contactPersonMobile,
        notes: supplier.notes,
        status: supplier.status,
        statusLabel: toDisplayStatus(supplier.status),
        createdAt: supplier.createdAt,
        updatedAt: supplier.updatedAt,
      },
      openingDue: { amount: dueAmount, entryType: openingDueEntry.entryType, ledgerId: openingDueEntry.id },
      sendWhatsAppInvite,
    };
  }

  async executePlatform(body: CreateSupplierBody) {
    const { name, mobile, email, address, contactPerson, contactPersonMobile, notes, status, supplierCode } = normalizeBody(body);

    if (!name) throw new SupplierNameRequiredError();
    if (!supplierCode) throw new SupplierCodeRequiredError();

    const existingSupplier = await this.supplierRepository.findSupplierForPlatformDuplicateCheck({ supplierCode, name });

    if (existingSupplier) {
      throw existingSupplier.supplierCode === supplierCode ? new DuplicateSupplierCodeError() : new DuplicateSupplierNameError();
    }

    const supplier = await this.supplierRepository.createGlobalSupplier({
      supplierCode,
      name,
      mobile,
      email,
      address,
      contactPerson,
      contactPersonMobile,
      notes,
      status: status ?? "ACTIVE",
    });

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
      purchases: 0,
      createdAt: supplier.createdAt,
      updatedAt: supplier.updatedAt,
    };
  }
}

function normalizeBody(body: CreateSupplierBody) {
  const name = body.name?.trim() || body.companyOrPersonName?.trim() || "";
  const mobile = body.mobile?.trim() || null;
  const email = body.email?.trim() || null;
  const address = body.address?.trim() || null;
  const productType = body.productType?.trim() || null;
  const shortNote = body.shortNote?.trim() || null;
  const contactPerson = body.contactPerson?.trim() || productType;
  const contactPersonMobile = body.contactPersonMobile?.trim() || null;
  const notes = body.notes?.trim() || shortNote;
  const dueAmount = Number(body.dueAmount ?? 0);
  const sendWhatsAppInvite = Boolean(body.sendWhatsAppInvite);
  const status = body.status;
  const supplierCode = body.supplierCode?.trim();

  return { name, mobile, email, address, contactPerson, contactPersonMobile, notes, dueAmount, sendWhatsAppInvite, status, supplierCode };
}
