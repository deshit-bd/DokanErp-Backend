import { prisma } from "../../../config/prisma";

export interface UpdateStoreSettingsInput {
  store_name?: string;
  owner_name?: string;
  mobile?: string | null;
  address?: string | null;
  store_type?: string | null;
  trade_license_no?: string | null;
  tin_no?: string | null;
  bin_no?: string | null;
  live_location?: string | null;
  latitude?: number | null;
  longitude?: number | null;
}

export class UpdateStoreSettingsUseCase {
  async execute(shopId: string, ownerUserId: string | null, input: UpdateStoreSettingsInput) {
    const store_name = input.store_name?.trim();
    const owner_name = input.owner_name?.trim();
    const mobile = input.mobile?.trim() || null;
    const address = input.address?.trim() || null;
    const store_type = input.store_type?.trim() || null;
    const trade_license_no = input.trade_license_no?.trim() || null;
    const tin_no = input.tin_no?.trim() || null;
    const bin_no = input.bin_no?.trim() || null;
    const live_location = input.live_location?.trim() || null;

    if (!store_name) {
      throw new Error("Store name is required.");
    }

    await prisma.shop.update({
      where: { id: shopId },
      data: {
        shopName: store_name,
        phone: mobile,
        address: address,
        area: live_location,
        businessType: store_type,
        tradeLicenseNo: trade_license_no,
        tinNo: tin_no,
        vatRegNo: bin_no,
      },
    });

    if (owner_name && ownerUserId) {
      await prisma.user.update({
        where: { id: ownerUserId },
        data: { name: owner_name },
      });
    }

    return {
      store_name,
      owner_name: owner_name || "",
      mobile: mobile || "",
      address: address || "",
      store_type: store_type || "",
      trade_license_no: trade_license_no || "",
      tin_no: tin_no || "",
      bin_no: bin_no || "",
      live_location: live_location || "",
      latitude: input.latitude ?? null,
      longitude: input.longitude ?? null,
    };
  }
}
