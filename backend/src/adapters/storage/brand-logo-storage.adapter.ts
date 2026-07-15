import type { LogoStoragePort } from "@application/brand/ports/logo-storage.port";

import { storeBase64Upload } from "./file-storage.adapter";

export class BrandLogoStorageAdapter implements LogoStoragePort {
  async store(dataUrlOrUrl: string, requestOrigin: string): Promise<string> {
    const { url } = await storeBase64Upload({ dataUrl: dataUrlOrUrl, folder: "brands", requestOrigin });
    return url;
  }
}
