import { randomUUID } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";

import type { DocumentStoragePort, StoreDocumentPayload } from "@application/auth/ports/document-storage.port";

const MIME_TO_EXTENSION: Record<string, string> = {
  "application/pdf": "pdf",
  "image/jpeg": "jpg",
  "image/png": "png",
};

const ALLOWED_EXTENSIONS = ["pdf", "jpg", "jpeg", "png"];

// Reimplements utils/store-document-upload.ts's persistStoreDocument, but
// takes a plain requestOrigin string instead of an Express Request so the
// application-layer port stays framework-agnostic.
export class StoreDocumentStorageAdapter implements DocumentStoragePort {
  async store(kind: "trade" | "tin" | "bin", payload: StoreDocumentPayload, requestOrigin: string): Promise<string> {
    const fileName = payload.fileName?.trim() ?? "";
    const contentType = payload.contentType?.trim() ?? "";
    const base64Data = payload.base64Data?.trim() ?? "";

    if (!fileName || !contentType || !base64Data) {
      throw new Error("Incomplete document upload payload.");
    }

    const extension = MIME_TO_EXTENSION[contentType] || path.extname(fileName).replace(".", "").toLowerCase();

    if (!extension || !ALLOWED_EXTENSIONS.includes(extension)) {
      throw new Error("Unsupported document format.");
    }

    const uploadDir = path.resolve(process.cwd(), "uploads", kind);
    await mkdir(uploadDir, { recursive: true });

    const storedFileName = `${Date.now()}-${randomUUID()}.${extension === "jpeg" ? "jpg" : extension}`;
    await writeFile(path.join(uploadDir, storedFileName), Buffer.from(base64Data, "base64"));

    return `${requestOrigin}/uploads/${kind}/${storedFileName}`;
  }
}
