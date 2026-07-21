import { prisma } from "../../../config/prisma";

export class GetStoreSettingsUseCase {
  async execute(shopId: string) {
    const shop = await prisma.shop.findUnique({
      where: { id: shopId },
      select: {
        id: true,
        shopCode: true,
        shopName: true,
        ownerUserId: true,
        phone: true,
        address: true,
        area: true,
        businessType: true,
        tradeLicenseNo: true,
        tinNo: true,
        vatRegNo: true,
        logoUrl: true,
      },
    });

    if (!shop) {
      throw new Error("Shop not found.");
    }

    let ownerName = "";
    if (shop.ownerUserId) {
      const owner = await prisma.user.findUnique({
        where: { id: shop.ownerUserId },
        select: { name: true },
      });
      if (owner) {
        ownerName = owner.name;
      }
    }

    return {
      store_name: shop.shopName,
      owner_name: ownerName,
      mobile: shop.phone || "",
      address: shop.address || "",
      store_type: shop.businessType || "",
      trade_license_no: shop.tradeLicenseNo || "",
      tin_no: shop.tinNo || "",
      bin_no: shop.vatRegNo || "",
      live_location: shop.area || "",
      latitude: null,
      longitude: null,
      logo_url: shop.logoUrl || "",
    };
  }
}
