import type { LogoStoragePort } from "@application/shop-profile/ports/logo-storage.port";

import { storeBase64Upload } from "./file-storage.adapter";

export class ShopLogoStorageAdapter implements LogoStoragePort {
  async store(dataUrlOrUrl: string, requestOrigin: string): Promise<string> {
    const { url } = await storeBase64Upload({ dataUrl: dataUrlOrUrl, folder: "shopprofilelogo", requestOrigin });
    return url;
  }
}
