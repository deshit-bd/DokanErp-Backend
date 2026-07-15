import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { randomUUID } from "node:crypto";

const MIME_TO_EXTENSION: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/svg+xml": "svg",
  "image/webp": "webp",
};

export type Base64Upload = {
  /** A `data:<mime>;base64,<payload>` URL, or a plain URL/path to pass through unchanged. */
  dataUrl: string;
  folder: string;
  requestOrigin: string;
};

export type StoredFile = {
  url: string;
};

// Consolidates the base64-data-URL upload logic that was previously
// duplicated (byte-for-byte) as persistProductPicture (routes/products.ts)
// and persistBrandLogo (routes/brands.ts). Not yet wired into those two
// routes — they migrate to this adapter when products/brands migrate.
export async function storeBase64Upload({ dataUrl, folder, requestOrigin }: Base64Upload): Promise<StoredFile> {
  const dataUrlMatch = dataUrl.match(/^data:(image\/[a-zA-Z0-9.+-]+);base64,(.+)$/);

  if (!dataUrlMatch) {
    return { url: dataUrl };
  }

  const [, mimeType, base64Payload] = dataUrlMatch;
  const extension = MIME_TO_EXTENSION[mimeType];

  if (!extension) {
    throw new Error(`Unsupported upload format: ${mimeType}`);
  }

  const uploadDir = path.resolve(process.cwd(), "uploads", folder);
  await mkdir(uploadDir, { recursive: true });

  const fileName = `${Date.now()}-${randomUUID()}.${extension}`;
  await writeFile(path.join(uploadDir, fileName), Buffer.from(base64Payload, "base64"));

  return { url: `${requestOrigin}/uploads/${folder}/${fileName}` };
}
