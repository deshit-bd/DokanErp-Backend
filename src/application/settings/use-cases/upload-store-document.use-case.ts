import { prisma } from "../../../config/prisma";
import { persistStoreDocument, storeDocumentField, type StoreDocumentKind } from "../../../utils/store-document-upload";

export class UploadStoreDocumentUseCase {
  async execute(shopId: string, ownerUserId: string | null, type: StoreDocumentKind, body: any, request: any) {
    if (!["trade", "tin", "bin"].includes(type)) {
      throw new Error("Unsupported document type.");
    }

    const documentUrl = await persistStoreDocument(type, body ?? {}, request);
    const field = storeDocumentField(type);

    const shop = await prisma.shop.update({
      where: { id: shopId },
      data: { [field]: documentUrl },
      select: {
        shopName: true,
        phone: true,
        address: true,
        area: true,
        businessType: true,
        tradeLicenseNo: true,
        tinNo: true,
        vatRegNo: true,
      },
    });

    let ownerName = "";
    if (ownerUserId) {
      const owner = await prisma.user.findUnique({
        where: { id: ownerUserId },
        select: { name: true },
      });
      ownerName = owner?.name ?? "";
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
    };
  }
}
