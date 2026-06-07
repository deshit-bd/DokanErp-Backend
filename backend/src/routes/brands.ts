import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { randomUUID } from "node:crypto";
import { type Request, Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

type BrandStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

const brandLogoMimeToExtension: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/svg+xml": "svg",
};

function toDisplayStatus(status: BrandStatusValue) {
  return status.replace(/_/g, " ");
}

async function persistBrandLogo(logoUrl: string, request: Request) {
  const dataUrlMatch = logoUrl.match(/^data:(image\/[a-zA-Z0-9.+-]+);base64,(.+)$/);

  if (!dataUrlMatch) {
    return logoUrl;
  }

  const [, mimeType, base64Payload] = dataUrlMatch;
  const extension = brandLogoMimeToExtension[mimeType];

  if (!extension) {
    throw new Error("Unsupported brand logo format.");
  }

  const uploadDir = path.resolve(process.cwd(), "uploads", "brands");
  await mkdir(uploadDir, { recursive: true });

  const fileName = `${Date.now()}-${randomUUID()}.${extension}`;
  const filePath = path.join(uploadDir, fileName);

  await writeFile(filePath, Buffer.from(base64Payload, "base64"));

  const protocol = request.protocol || "http";
  const host = request.get("host") || "localhost:4000";

  return `${protocol}://${host}/uploads/brands/${fileName}`;
}

async function requirePlatformUser(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to manage brands." },
    };
  }

  return auth;
}

router.get("/", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const brands = await (prisma as any).brand.findMany({
      orderBy: [{ createdAt: "desc" }, { name: "asc" }],
      include: {
        createdBy: {
          select: { id: true, name: true },
        },
        updatedBy: {
          select: { id: true, name: true },
        },
        masterProducts: {
          select: {
            id: true,
            categoryId: true,
          },
        },
      },
    });

    return response.json({
      stats: {
        total: brands.length,
        active: brands.filter((item: { status: BrandStatusValue }) => item.status === "ACTIVE").length,
        inactive: brands.filter((item: { status: BrandStatusValue }) => item.status === "INACTIVE").length,
        archived: brands.filter((item: { status: BrandStatusValue }) => item.status === "ARCHIVED").length,
      },
      brands: brands.map((brand: {
        id: string;
        name: string;
        description: string | null;
        logoUrl: string | null;
        status: BrandStatusValue;
        createdAt: Date;
        updatedAt: Date;
        createdBy: { id: string; name: string } | null;
        updatedBy: { id: string; name: string } | null;
        masterProducts: Array<{ id: string; categoryId: string | null }>;
      }) => ({
        id: brand.id,
        name: brand.name,
        description: brand.description,
        logoUrl: brand.logoUrl,
        status: brand.status,
        statusLabel: toDisplayStatus(brand.status),
        categories: new Set(brand.masterProducts.map((item: { categoryId: string | null }) => item.categoryId).filter(Boolean)).size,
        products: brand.masterProducts.length,
        createdAt: brand.createdAt,
        updatedAt: brand.updatedAt,
        createdBy: brand.createdBy,
        updatedBy: brand.updatedBy,
      })),
    });
  } catch (error) {
    console.error("Failed to load brands.", error);

    return response.status(503).json({
      message:
        "Brands are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.post("/", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const body = request.body as {
      name?: string;
      description?: string | null;
      logoUrl?: string | null;
      status?: BrandStatusValue;
    };

    const name = body.name?.trim();
    const description = body.description?.trim() || null;
    const rawLogoUrl = body.logoUrl?.trim() || null;
    const status = body.status ?? "ACTIVE";

    if (!name) {
      return response.status(400).json({ message: "Brand name is required." });
    }

    const logoUrl = rawLogoUrl ? await persistBrandLogo(rawLogoUrl, request) : null;

    const existingBrand = await (prisma as any).brand.findUnique({
      where: { name },
      select: { id: true },
    });

    if (existingBrand) {
      return response.status(409).json({ message: "Brand name already exists." });
    }

    const brand = await (prisma as any).brand.create({
      data: {
        name,
        description,
        logoUrl,
        status,
        createdByUserId: auth.user.id,
        updatedByUserId: auth.user.id,
      },
      include: {
        createdBy: {
          select: { id: true, name: true },
        },
        updatedBy: {
          select: { id: true, name: true },
        },
        masterProducts: {
          select: {
            id: true,
            categoryId: true,
          },
        },
      },
    });

    return response.status(201).json({
      message: "Brand created successfully.",
      brand: {
        id: brand.id,
        name: brand.name,
        description: brand.description,
        logoUrl: brand.logoUrl,
        status: brand.status,
        statusLabel: toDisplayStatus(brand.status),
        categories: new Set(brand.masterProducts.map((item: { categoryId: string | null }) => item.categoryId).filter(Boolean)).size,
        products: brand.masterProducts.length,
        createdAt: brand.createdAt,
        updatedAt: brand.updatedAt,
        createdBy: brand.createdBy,
        updatedBy: brand.updatedBy,
      },
    });
  } catch (error) {
    console.error("Failed to save brand.", error);

    return response.status(503).json({
      message:
        "Brand could not be saved because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

export default router;
