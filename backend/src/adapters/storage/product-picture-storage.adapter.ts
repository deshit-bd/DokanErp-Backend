import type { ProductPictureStoragePort } from "@application/product/ports/product-picture-storage.port";

import { storeBase64Upload } from "./file-storage.adapter";

export class ProductPictureStorageAdapter implements ProductPictureStoragePort {
  async store(dataUrlOrUrl: string, requestOrigin: string): Promise<string> {
    const { url } = await storeBase64Upload({ dataUrl: dataUrlOrUrl, folder: "products", requestOrigin });
    return url;
  }
}
