export type StoreDocumentPayload = {
  fileName?: string;
  contentType?: string;
  base64Data?: string;
};

export interface DocumentStoragePort {
  store(kind: "trade" | "tin" | "bin", payload: StoreDocumentPayload, requestOrigin: string): Promise<string>;
}
