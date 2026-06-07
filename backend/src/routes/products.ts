import { randomUUID } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { type Request, Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

type MasterProductStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

type ProductRow = {
  id: string;
  sku: string;
  name: string;
  description: string | null;
  barcode: string | null;
  price: number | null;
  suggestedPrice: number | null;
  packageSize: string | null;
  pictureUrl: string | null;
  status: MasterProductStatusValue;
  createdAt: Date;
  updatedAt: Date;
  category: { id: string; name: string } | null;
  brand: { id: string; name: string; logoUrl: string | null } | null;
  unit: { id: string; name: string; shortName: string } | null;
};

const productPictureMimeToExtension: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
  "image/svg+xml": "svg",
};

function toDisplayStatus(status: MasterProductStatusValue) {
  return status.replace(/_/g, " ");
}

function toCurrencyLabel(value: number | null | undefined) {
  if (value == null) {
    return null;
  }

  return `$${value.toFixed(2).replace(/\.00$/, "")}`;
}

function productVisualType(name: string, categoryName: string | null) {
  const source = `${name} ${categoryName ?? ""}`.toLowerCase();
  return source.includes("oil") ? "oil" : "sugar";
}

function mapProduct(product: ProductRow) {
  return {
    id: product.id,
    sku: product.sku,
    name: product.name,
    note: product.description,
    categoryId: product.category?.id ?? null,
    category: product.category?.name ?? "Uncategorized",
    brandId: product.brand?.id ?? null,
    brand: product.brand?.name ?? "No Brand",
    brandLogoUrl: product.brand?.logoUrl ?? null,
    unitId: product.unit?.id ?? null,
    unit: product.unit?.shortName?.toUpperCase() ?? product.unit?.name ?? "No Unit",
    barcode: product.barcode,
    price: product.price,
    priceLabel: toCurrencyLabel(product.price),
    suggestedPrice: product.suggestedPrice,
    suggestedPriceLabel: toCurrencyLabel(product.suggestedPrice),
    packageSize: product.packageSize,
    pictureUrl: product.pictureUrl,
    status: product.status,
    statusLabel: toDisplayStatus(product.status),
    type: productVisualType(product.name, product.category?.name ?? null),
    createdAt: product.createdAt,
    updatedAt: product.updatedAt,
  };
}

async function requirePlatformUser(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to manage products." },
    };
  }

  return auth;
}

async function persistProductPicture(pictureUrl: string, request: Request) {
  const dataUrlMatch = pictureUrl.match(/^data:(image\/[a-zA-Z0-9.+-]+);base64,(.+)$/);

  if (!dataUrlMatch) {
    return pictureUrl;
  }

  const [, mimeType, base64Payload] = dataUrlMatch;
  const extension = productPictureMimeToExtension[mimeType];

  if (!extension) {
    throw new Error("Unsupported product picture format.");
  }

  const uploadDir = path.resolve(process.cwd(), "uploads", "products");
  await mkdir(uploadDir, { recursive: true });

  const fileName = `${Date.now()}-${randomUUID()}.${extension}`;
  const filePath = path.join(uploadDir, fileName);

  await writeFile(filePath, Buffer.from(base64Payload, "base64"));

  const protocol = request.protocol || "http";
  const host = request.get("host") || "localhost:4000";

  return `${protocol}://${host}/uploads/products/${fileName}`;
}

async function buildProductFilters() {
  const [categories, brands, units] = await Promise.all([
    (prisma as any).productCategory.findMany({
      where: { status: { not: "ARCHIVED" } },
      orderBy: { name: "asc" },
      select: { id: true, name: true },
    }),
    (prisma as any).brand.findMany({
      where: { status: { not: "ARCHIVED" } },
      orderBy: { name: "asc" },
      select: { id: true, name: true, logoUrl: true },
    }),
    (prisma as any).unit.findMany({
      where: { status: { not: "ARCHIVED" } },
      orderBy: { name: "asc" },
      select: { id: true, name: true, shortName: true },
    }),
  ]);

  return { categories, brands, units };
}

function buildDuplicateSku(baseSku: string) {
  return `${baseSku}-COPY-${Date.now().toString().slice(-6)}`;
}

router.get("/", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const [products, filters] = await Promise.all([
      (prisma as any).masterProduct.findMany({
        orderBy: [{ createdAt: "desc" }, { name: "asc" }],
        include: {
          category: { select: { id: true, name: true } },
          brand: { select: { id: true, name: true, logoUrl: true } },
          unit: { select: { id: true, name: true, shortName: true } },
        },
      }),
      buildProductFilters(),
    ]);

    return response.json({
      stats: {
        total: products.length,
        active: products.filter((item: { status: MasterProductStatusValue }) => item.status === "ACTIVE").length,
        inactive: products.filter((item: { status: MasterProductStatusValue }) => item.status === "INACTIVE").length,
        usingShops: 0,
      },
      filters,
      products: products.map(mapProduct),
    });
  } catch (error) {
    console.error("Failed to load products.", error);

    return response.status(503).json({
      message:
        "Products are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
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
      sku?: string;
      price?: number | string | null;
      barcode?: string | null;
      suggestedPrice?: number | string | null;
      categoryId?: string | null;
      brandId?: string | null;
      unitId?: string | null;
      packageSize?: string | null;
      description?: string | null;
      pictureUrl?: string | null;
    };

    const name = body.name?.trim();
    const sku = body.sku?.trim();
    const barcode = body.barcode?.trim() || null;
    const categoryId = body.categoryId?.trim() || null;
    const brandId = body.brandId?.trim() || null;
    const unitId = body.unitId?.trim() || null;
    const packageSize = body.packageSize?.trim() || null;
    const description = body.description?.trim() || null;
    const rawPictureUrl = body.pictureUrl?.trim() || null;
    const parsedPrice = body.price === "" || body.price == null ? null : Number(body.price);
    const parsedSuggestedPrice =
      body.suggestedPrice === "" || body.suggestedPrice == null ? null : Number(body.suggestedPrice);

    if (!name) {
      return response.status(400).json({ message: "Product name is required." });
    }

    if (!sku) {
      return response.status(400).json({ message: "SKU is required." });
    }

    if (parsedPrice != null && Number.isNaN(parsedPrice)) {
      return response.status(400).json({ message: "Price must be a valid number." });
    }

    if (parsedSuggestedPrice != null && Number.isNaN(parsedSuggestedPrice)) {
      return response.status(400).json({ message: "Suggested selling price must be a valid number." });
    }

    const [existingSku, existingBarcode] = await Promise.all([
      (prisma as any).masterProduct.findUnique({
        where: { sku },
        select: { id: true },
      }),
      barcode
        ? (prisma as any).masterProduct.findUnique({
            where: { barcode },
            select: { id: true },
          })
        : Promise.resolve(null),
    ]);

    if (existingSku) {
      return response.status(409).json({ message: "SKU already exists." });
    }

    if (existingBarcode) {
      return response.status(409).json({ message: "Barcode already exists." });
    }

    const pictureUrl = rawPictureUrl ? await persistProductPicture(rawPictureUrl, request) : null;

    const product = await (prisma as any).masterProduct.create({
      data: {
        name,
        sku,
        barcode,
        price: parsedPrice,
        suggestedPrice: parsedSuggestedPrice,
        categoryId,
        brandId,
        unitId,
        packageSize,
        description,
        pictureUrl,
        status: "ACTIVE",
        createdByUserId: auth.user.id,
        updatedByUserId: auth.user.id,
      },
      include: {
        category: { select: { id: true, name: true } },
        brand: { select: { id: true, name: true, logoUrl: true } },
        unit: { select: { id: true, name: true, shortName: true } },
      },
    });

    return response.status(201).json({
      message: "Product created successfully.",
      product: mapProduct(product),
    });
  } catch (error) {
    console.error("Failed to save product.", error);

    return response.status(503).json({
      message:
        "Product could not be saved because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.put("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const productId = request.params.id;
    const body = request.body as {
      name?: string;
      sku?: string;
      price?: number | string | null;
      barcode?: string | null;
      suggestedPrice?: number | string | null;
      categoryId?: string | null;
      brandId?: string | null;
      unitId?: string | null;
      packageSize?: string | null;
      description?: string | null;
      pictureUrl?: string | null;
    };

    const existingProduct = await (prisma as any).masterProduct.findUnique({
      where: { id: productId },
      select: { id: true },
    });

    if (!existingProduct) {
      return response.status(404).json({ message: "Product not found." });
    }

    const name = body.name?.trim();
    const sku = body.sku?.trim();
    const barcode = body.barcode?.trim() || null;
    const categoryId = body.categoryId?.trim() || null;
    const brandId = body.brandId?.trim() || null;
    const unitId = body.unitId?.trim() || null;
    const packageSize = body.packageSize?.trim() || null;
    const description = body.description?.trim() || null;
    const rawPictureUrl = body.pictureUrl?.trim() || null;
    const parsedPrice = body.price === "" || body.price == null ? null : Number(body.price);
    const parsedSuggestedPrice =
      body.suggestedPrice === "" || body.suggestedPrice == null ? null : Number(body.suggestedPrice);

    if (!name) {
      return response.status(400).json({ message: "Product name is required." });
    }

    if (!sku) {
      return response.status(400).json({ message: "SKU is required." });
    }

    if (parsedPrice != null && Number.isNaN(parsedPrice)) {
      return response.status(400).json({ message: "Price must be a valid number." });
    }

    if (parsedSuggestedPrice != null && Number.isNaN(parsedSuggestedPrice)) {
      return response.status(400).json({ message: "Suggested selling price must be a valid number." });
    }

    const [existingSku, existingBarcode] = await Promise.all([
      (prisma as any).masterProduct.findFirst({
        where: {
          sku,
          NOT: { id: productId },
        },
        select: { id: true },
      }),
      barcode
        ? (prisma as any).masterProduct.findFirst({
            where: {
              barcode,
              NOT: { id: productId },
            },
            select: { id: true },
          })
        : Promise.resolve(null),
    ]);

    if (existingSku) {
      return response.status(409).json({ message: "SKU already exists." });
    }

    if (existingBarcode) {
      return response.status(409).json({ message: "Barcode already exists." });
    }

    const pictureUrl = rawPictureUrl ? await persistProductPicture(rawPictureUrl, request) : null;

    const product = await (prisma as any).masterProduct.update({
      where: { id: productId },
      data: {
        name,
        sku,
        barcode,
        price: parsedPrice,
        suggestedPrice: parsedSuggestedPrice,
        categoryId,
        brandId,
        unitId,
        packageSize,
        description,
        pictureUrl,
        updatedByUserId: auth.user.id,
      },
      include: {
        category: { select: { id: true, name: true } },
        brand: { select: { id: true, name: true, logoUrl: true } },
        unit: { select: { id: true, name: true, shortName: true } },
      },
    });

    return response.json({
      message: "Product updated successfully.",
      product: mapProduct(product),
    });
  } catch (error) {
    console.error("Failed to update product.", error);

    return response.status(503).json({
      message: "Product could not be updated right now.",
    });
  }
});

router.post("/:id/duplicate", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const productId = request.params.id;
    const sourceProduct = await (prisma as any).masterProduct.findUnique({
      where: { id: productId },
      include: {
        category: { select: { id: true, name: true } },
        brand: { select: { id: true, name: true, logoUrl: true } },
        unit: { select: { id: true, name: true, shortName: true } },
      },
    });

    if (!sourceProduct) {
      return response.status(404).json({ message: "Product not found." });
    }

    const duplicatedProduct = await (prisma as any).masterProduct.create({
      data: {
        sku: buildDuplicateSku(sourceProduct.sku),
        name: `${sourceProduct.name} Copy`,
        description: sourceProduct.description,
        categoryId: sourceProduct.category?.id ?? null,
        brandId: sourceProduct.brand?.id ?? null,
        unitId: sourceProduct.unit?.id ?? null,
        barcode: null,
        price: sourceProduct.price,
        suggestedPrice: sourceProduct.suggestedPrice,
        packageSize: sourceProduct.packageSize,
        pictureUrl: sourceProduct.pictureUrl,
        status: sourceProduct.status,
        createdByUserId: auth.user.id,
        updatedByUserId: auth.user.id,
      },
      include: {
        category: { select: { id: true, name: true } },
        brand: { select: { id: true, name: true, logoUrl: true } },
        unit: { select: { id: true, name: true, shortName: true } },
      },
    });

    return response.status(201).json({
      message: "Product duplicated successfully.",
      product: mapProduct(duplicatedProduct),
    });
  } catch (error) {
    console.error("Failed to duplicate product.", error);

    return response.status(503).json({
      message: "Product could not be duplicated right now.",
    });
  }
});

router.patch("/:id/status", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const productId = request.params.id;
    const body = request.body as { status?: MasterProductStatusValue };
    const nextStatus = body.status;

    if (!nextStatus || !["ACTIVE", "INACTIVE", "ARCHIVED"].includes(nextStatus)) {
      return response.status(400).json({ message: "A valid status is required." });
    }

    const product = await (prisma as any).masterProduct.update({
      where: { id: productId },
      data: {
        status: nextStatus,
        updatedByUserId: auth.user.id,
      },
      include: {
        category: { select: { id: true, name: true } },
        brand: { select: { id: true, name: true, logoUrl: true } },
        unit: { select: { id: true, name: true, shortName: true } },
      },
    });

    return response.json({
      message: "Product status updated successfully.",
      product: mapProduct(product),
    });
  } catch (error) {
    console.error("Failed to update product status.", error);

    return response.status(503).json({
      message: "Product status could not be updated right now.",
    });
  }
});

router.delete("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const productId = request.params.id;
    const existingProduct = await (prisma as any).masterProduct.findUnique({
      where: { id: productId },
      select: { id: true },
    });

    if (!existingProduct) {
      return response.status(404).json({ message: "Product not found." });
    }

    await (prisma as any).masterProduct.delete({
      where: { id: productId },
    });

    return response.json({ message: "Product deleted successfully." });
  } catch (error) {
    console.error("Failed to delete product.", error);

    return response.status(503).json({
      message: "Product could not be deleted right now.",
    });
  }
});

export default router;
