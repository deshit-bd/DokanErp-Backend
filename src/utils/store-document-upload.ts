import { randomUUID } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { type Request } from "express";

export type StoreDocumentKind = "trade" | "tin" | "bin";

export type StoreDocumentPayload = {
  fileName?: string;
  contentType?: string;
  base64Data?: string;
};

const mimeToExtension: Record<string, string> = {
  "application/pdf": "pdf",
  "image/jpeg": "jpg",
  "image/png": "png",
};

const fieldByKind: Record<StoreDocumentKind, "tradeLicenseNo" | "tinNo" | "vatRegNo"> = {
  trade: "tradeLicenseNo",
  tin: "tinNo",
  bin: "vatRegNo",
};

export function storeDocumentField(kind: StoreDocumentKind) {
  return fieldByKind[kind];
}

export async function persistStoreDocument(
  kind: StoreDocumentKind,
  payload: StoreDocumentPayload,
  request: Request,
) {
  const fileName = payload.fileName?.trim() ?? "";
  const contentType = payload.contentType?.trim() ?? "";
  const base64Data = payload.base64Data?.trim() ?? "";

  if (!fileName || !contentType || !base64Data) {
    throw new Error("Incomplete document upload payload.");
  }

  const extension =
    mimeToExtension[contentType] ||
    path.extname(fileName).replace(".", "").toLowerCase();

  if (!extension || !["pdf", "jpg", "jpeg", "png"].includes(extension)) {
    throw new Error("Unsupported document format.");
  }

  const uploadDir = path.resolve(process.cwd(), "uploads", kind);
  await mkdir(uploadDir, { recursive: true });

  const storedFileName = `${Date.now()}-${randomUUID()}.${extension === "jpeg" ? "jpg" : extension}`;
  const filePath = path.join(uploadDir, storedFileName);

  await writeFile(filePath, Buffer.from(base64Data, "base64"));

  const protocol = request.protocol || "http";
  const host = request.get("host") || "localhost:4000";

  return `${protocol}://${host}/uploads/${kind}/${storedFileName}`;
}
