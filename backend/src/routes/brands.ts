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

const brandInclude = {
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
} as const;

function mapBrand(brand: {
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
}) {
  return {
    id: brand.id,
    name: brand.name,
    description: brand.description,
    logoUrl: brand.logoUrl,
    status: brand.status,
    statusLabel: toDisplayStatus(brand.status),
    categories: new Set(brand.masterProducts.map((item) => item.categoryId).filter(Boolean)).size,
    products: brand.masterProducts.length,
    createdAt: brand.createdAt,
    updatedAt: brand.updatedAt,
    createdBy: brand.createdBy,
    updatedBy: brand.updatedBy,
  };
}

router.get("/", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const brands = await (prisma as any).brand.findMany({
      orderBy: [{ createdAt: "desc" }, { name: "asc" }],
      include: brandInclude,
    });

    return response.json({
      stats: {
        total: brands.length,
        active: brands.filter((item: { status: BrandStatusValue }) => item.status === "ACTIVE").length,
        inactive: brands.filter((item: { status: BrandStatusValue }) => item.status === "INACTIVE").length,
        archived: brands.filter((item: { status: BrandStatusValue }) => item.status === "ARCHIVED").length,
      },
      brands: brands.map(mapBrand),
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
      include: brandInclude,
    });

    return response.status(201).json({
      message: "Brand created successfully.",
      brand: mapBrand(brand),
    });
  } catch (error) {
    console.error("Failed to save brand.", error);

    return response.status(503).json({
      message:
        "Brand could not be saved because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.put("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const brandId = request.params.id;
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

    const brandRecord = await (prisma as any).brand.findUnique({
      where: { id: brandId },
      select: { id: true },
    });

    if (!brandRecord) {
      return response.status(404).json({ message: "Brand not found." });
    }

    const duplicateBrand = await (prisma as any).brand.findFirst({
      where: {
        id: { not: brandId },
        name,
      },
      select: { id: true },
    });

    if (duplicateBrand) {
      return response.status(409).json({ message: "Brand name already exists." });
    }

    const logoUrl = rawLogoUrl ? await persistBrandLogo(rawLogoUrl, request) : null;

    const brand = await (prisma as any).brand.update({
      where: { id: brandId },
      data: {
        name,
        description,
        logoUrl,
        status,
        updatedByUserId: auth.user.id,
      },
      include: brandInclude,
    });

    return response.json({
      message: "Brand updated successfully.",
      brand: mapBrand(brand),
    });
  } catch (error) {
    console.error("Failed to update brand.", error);

    return response.status(503).json({
      message:
        "Brand could not be updated because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.delete("/", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const { ids } = request.body as { ids: string[] };
    if (!Array.isArray(ids) || ids.length === 0) {
      return response.status(400).json({ message: "Invalid or empty brand IDs." });
    }

    const brands = await (prisma as any).brand.findMany({
      where: { id: { in: ids } },
      include: {
        masterProducts: {
          select: { id: true },
        },
      },
    });

    const toArchive = brands.filter((b: any) => b.masterProducts.length > 0).map((b: any) => b.id);
    const toDelete = brands.filter((b: any) => b.masterProducts.length === 0).map((b: any) => b.id);

    if (toArchive.length > 0) {
      await (prisma as any).brand.updateMany({
        where: { id: { in: toArchive } },
        data: {
          status: "ARCHIVED",
          updatedByUserId: auth.user.id,
        },
      });
    }

    if (toDelete.length > 0) {
      await (prisma as any).brand.deleteMany({
        where: { id: { in: toDelete } },
      });
    }

    let message = "";
    if (toDelete.length > 0 && toArchive.length > 0) {
      message = `${toDelete.length} brands deleted, ${toArchive.length} brands archived (due to associated products).`;
    } else if (toDelete.length > 0) {
      message = `${toDelete.length} brands deleted successfully.`;
    } else if (toArchive.length > 0) {
      message = `${toArchive.length} brands archived successfully (due to associated products).`;
    } else {
      message = "No brands found.";
    }

    return response.json({ message });
  } catch (error) {
    console.error("Failed to delete brands.", error);
    return response.status(500).json({ message: "Failed to delete brands." });
  }
});

router.delete("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const brandId = request.params.id;
    const brand = await (prisma as any).brand.findUnique({
      where: { id: brandId },
      include: {
        masterProducts: {
          select: { id: true },
        },
      },
    });

    if (!brand) {
      return response.status(404).json({ message: "Brand not found." });
    }

    if (brand.masterProducts.length > 0) {
      await (prisma as any).brand.update({
        where: { id: brandId },
        data: {
          status: "ARCHIVED",
          updatedByUserId: auth.user.id,
        },
      });

      return response.status(409).json({
        message: "Brand has products, so it was archived instead of deleted.",
      });
    }

    await (prisma as any).brand.delete({
      where: { id: brandId },
    });

    return response.json({ message: "Brand deleted successfully." });
  } catch (error) {
    console.error("Failed to delete brand.", error);

    return response.status(500).json({ message: "Failed to delete brand." });
  }
});

export default router;
