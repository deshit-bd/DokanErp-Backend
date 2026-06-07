import { randomUUID } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";

import { NextResponse } from "next/server";

import { patchAvatarInBackend } from "@/lib/server/backend-proxy";

const MAX_FILE_SIZE = 2 * 1024 * 1024;
const ALLOWED_TYPES = new Set(["image/jpeg", "image/png", "image/webp"]);

function getFileExtension(file: File) {
  if (file.type === "image/jpeg") {
    return "jpg";
  }

  if (file.type === "image/png") {
    return "png";
  }

  if (file.type === "image/webp") {
    return "webp";
  }

  return file.name.split(".").pop()?.toLowerCase() || "jpg";
}

export async function POST(request: Request) {
  const formData = await request.formData();
  const file = formData.get("file");

  if (!(file instanceof File)) {
    return NextResponse.json({ message: "Please select an image file." }, { status: 400 });
  }

  if (!ALLOWED_TYPES.has(file.type)) {
    return NextResponse.json({ message: "Only JPG, PNG, or WEBP images are allowed." }, { status: 400 });
  }

  if (file.size > MAX_FILE_SIZE) {
    return NextResponse.json({ message: "Image size must be 2MB or less." }, { status: 400 });
  }

  const extension = getFileExtension(file);
  const fileName = `${randomUUID()}.${extension}`;
  const relativePath = `/uploads/profiles/${fileName}`;
  const uploadDirectory = path.join(process.cwd(), "public", "uploads", "profiles");
  const absolutePath = path.join(uploadDirectory, fileName);

  await mkdir(uploadDirectory, { recursive: true });
  await writeFile(absolutePath, Buffer.from(await file.arrayBuffer()));

  return patchAvatarInBackend(request, relativePath);
}
