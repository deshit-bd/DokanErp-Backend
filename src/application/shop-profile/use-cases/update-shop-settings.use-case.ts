import { mapShopSettingsResponse, type ReceiptSettings } from "@domain/shop-profile/shop-profile.entity";
import { ConflictError, ValidationError } from "@domain/shared/app-error";

import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export type UpdateShopSettingsCommand = {
  shopId: string;
  ownerId: string;
  shopName: string | undefined;
  businessType: string | null | undefined;
  phone: string | null | undefined;
  address: string | null | undefined;
  ownerName: string | undefined;
  ownerPhone: string | null | undefined;
  receipt: Partial<ReceiptSettings> | undefined;
};

export class UpdateShopSettingsUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(command: UpdateShopSettingsCommand) {
    const shopName = command.shopName?.trim();
    const ownerName = command.ownerName?.trim();
    const phone = command.phone?.toString().trim() || null;
    const address = command.address?.toString().trim() || null;
    const businessType = command.businessType?.toString().trim() || null;
    const ownerPhone = command.ownerPhone?.toString().trim() || null;

    if (!shopName) {
      throw new ValidationError("Shop name is required.");
    }
    if (!ownerName) {
      throw new ValidationError("Owner name is required.");
    }

    const duplicateShopPhone = phone ? await this.shopProfileRepository.findShopByPhoneExcept(phone, command.shopId) : null;

    if (duplicateShopPhone) {
      throw new ConflictError("Shop mobile number is already in use.");
    }

    const duplicateOwnerPhone = ownerPhone ? await this.shopProfileRepository.findUserByPhoneExcept(ownerPhone, command.ownerId) : null;

    if (duplicateOwnerPhone) {
      throw new ConflictError("Owner mobile number is already in use.");
    }

    const receiptInput: ReceiptSettings = {
      showPhone: command.receipt?.showPhone ?? true,
      showAddress: command.receipt?.showAddress ?? false,
      showLogo: command.receipt?.showLogo ?? false,
      showVatInfo: command.receipt?.showVatInfo ?? false,
    };

    const result = await this.shopProfileRepository.updateShopProfile(
      command.shopId,
      { shopName, businessType, phone, address },
      command.ownerId,
      { name: ownerName, phone: ownerPhone },
      receiptInput,
    );

    return {
      ...mapShopSettingsResponse(result.shop, result.owner),
      preferences: { language: "bn", theme: "light", currency: "BDT" },
    };
  }
}
