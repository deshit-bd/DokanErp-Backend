import { randomUUID } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { type Request, Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";
import { generateBarcodeSvg } from "../utils/barcode/barcode-generator";

const router = Router();

type MasterProductStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

type ProductRow = {
  id: string;
  sku: string;
  name: string;
  description: string | null;
  price: unknown;
  suggestedPrice: unknown;
  packageSize: string | null;
  pictureUrl: string | null;
  status: MasterProductStatusValue;
  createdAt: Date;
  updatedAt: Date;
  category: { id: string; name: string } | null;
  brand: { id: string; name: string; logoUrl: string | null } | null;
  unit: { id: string; name: string; shortName: string } | null;
  barcodes: Array<{
    id: string;
    barcode: string;
    packSize: string | null;
    status: "MAPPED" | "UNMAPPED" | "ARCHIVED";
    createdAt: Date;
    updatedAt: Date;
  }>;
};

const productInclude = {
  category: { select: { id: true, name: true } },
  brand: { select: { id: true, name: true, logoUrl: true } },
  unit: { select: { id: true, name: true, shortName: true } },
  barcodes: {
    orderBy: [{ updatedAt: "desc" }, { createdAt: "desc" }],
    select: {
      id: true,
      barcode: true,
      packSize: true,
      status: true,
      createdAt: true,
      updatedAt: true,
    },
  },
} as const;

const productPictureMimeToExtension: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
  "image/svg+xml": "svg",
};

function toDisplayStatus(status: MasterProductStatusValue) {
  return status.replace(/_/g, " ");
}

function normalizeMoney(value: unknown) {
  if (value == null) {
    return null;
  }

  if (typeof value === "number") {
    return value;
  }

  if (typeof value === "object" && value && "toNumber" in value && typeof value.toNumber === "function") {
    return value.toNumber();
  }

  const parsedValue = Number(value);
  return Number.isNaN(parsedValue) ? null : parsedValue;
}

function toCurrencyLabel(value: unknown) {
  const normalizedValue = normalizeMoney(value);

  if (normalizedValue == null) {
    return null;
  }

  return `$${normalizedValue.toFixed(2).replace(/\.00$/, "")}`;
}

function selectPrimaryBarcode(
  barcodes: ProductRow["barcodes"],
) {
  return (
    barcodes.find((item) => item.status === "MAPPED") ??
    barcodes.find((item) => item.status === "UNMAPPED") ??
    barcodes[0] ??
    null
  );
}

function toBarcodeStatusFromProductStatus(status: MasterProductStatusValue) {
  return status === "ARCHIVED" ? "ARCHIVED" : "MAPPED";
}

function toCurrencyNumber(value: unknown) {
  return normalizeMoney(value);
}

async function syncProductBarcodeRecord(params: {
  barcode: string | null;
  packageSize: string | null;
  productId: string;
  productStatus: MasterProductStatusValue;
  userId: string;
}) {
  const { barcode, packageSize, productId, productStatus, userId } = params;

  const existingBarcode = await (prisma as any).masterProductBarcode.findFirst({
    where: { masterProductId: productId },
    orderBy: [{ updatedAt: "desc" }, { createdAt: "desc" }],
    select: { id: true, barcode: true },
  });

  if (!barcode) {
    await (prisma as any).masterProductBarcode.deleteMany({
      where: { masterProductId: productId },
    });
    return;
  }

  if (existingBarcode) {
    await (prisma as any).masterProductBarcode.update({
      where: { id: existingBarcode.id },
      data: {
        barcode,
        packSize: packageSize,
        status: toBarcodeStatusFromProductStatus(productStatus),
        updatedByUserId: userId,
      },
    });

    return;
  }

  await (prisma as any).masterProductBarcode.create({
    data: {
      masterProductId: productId,
      barcode,
      packSize: packageSize,
      status: toBarcodeStatusFromProductStatus(productStatus),
      createdByUserId: userId,
      updatedByUserId: userId,
    },
  });
}

async function loadProductById(productId: string) {
  return (prisma as any).masterProduct.findUnique({
    where: { id: productId },
    include: productInclude,
  });
}

function toProductResponse(product: ProductRow) {
  const primaryBarcode = selectPrimaryBarcode(product.barcodes);
  const normalizedPrice = toCurrencyNumber(product.price);
  const normalizedSuggestedPrice = toCurrencyNumber(product.suggestedPrice);

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
    barcode: primaryBarcode?.barcode ?? null,
    price: normalizedPrice,
    priceLabel: toCurrencyLabel(product.price),
    suggestedPrice: normalizedSuggestedPrice,
    suggestedPriceLabel: toCurrencyLabel(product.suggestedPrice),
    packageSize: primaryBarcode?.packSize ?? product.packageSize,
    pictureUrl: product.pictureUrl,
    status: product.status,
    statusLabel: toDisplayStatus(product.status),
    type: productVisualType(product.name, product.category?.name ?? null),
    createdAt: product.createdAt,
    updatedAt: product.updatedAt,
  };
}

function productVisualType(name: string, categoryName: string | null) {
  const source = `${name} ${categoryName ?? ""}`.toLowerCase();
  return source.includes("oil") ? "oil" : "sugar";
}

function buildGeneratedSku(name: string) {
  const prefix =
    name
      .toUpperCase()
      .replace(/[^A-Z0-9]/g, "")
      .slice(0, 6) || "PROD";

  return `${prefix}-${Date.now().toString().slice(-6)}`;
}

function mapProduct(product: ProductRow) {
  return toProductResponse(product);
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
        include: productInclude,
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

router.get("/:id/barcode.svg", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const product = await loadProductById(request.params.id);

    if (!product) {
      return response.status(404).json({ message: "Product not found." });
    }

    const primaryBarcode = selectPrimaryBarcode(product.barcodes);

    if (!primaryBarcode?.barcode) {
      return response.status(404).json({ message: "Barcode is not assigned for this product." });
    }

    const svg = generateBarcodeSvg(primaryBarcode.barcode);
    const shouldDownload = request.query.download === "1";
    const safeFileName = `${product.sku}-${primaryBarcode.barcode}`.replace(/[^a-zA-Z0-9-_]+/g, "-");

    response.setHeader("content-type", "image/svg+xml; charset=utf-8");

    if (shouldDownload) {
      response.setHeader("content-disposition", `attachment; filename="${safeFileName}.svg"`);
    }

    return response.status(200).send(svg);
  } catch (error) {
    console.error("Failed to generate barcode SVG.", error);

    return response.status(503).json({
      message: "Barcode could not be generated right now.",
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
        ? (prisma as any).masterProductBarcode.findUnique({
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

    const createdProduct = await (prisma as any).masterProduct.create({
      data: {
        name,
        sku,
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
      select: { id: true },
    });

    await syncProductBarcodeRecord({
      barcode,
      packageSize,
      productId: createdProduct.id,
      productStatus: "ACTIVE",
      userId: auth.user.id,
    });

    const product = await loadProductById(createdProduct.id);

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
      select: { id: true, status: true },
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
        ? (prisma as any).masterProductBarcode.findFirst({
            where: {
              barcode,
              NOT: { masterProductId: productId },
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

    await (prisma as any).masterProduct.update({
      where: { id: productId },
      data: {
        name,
        sku,
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
    });

    await syncProductBarcodeRecord({
      barcode,
      packageSize,
      productId,
      productStatus: existingProduct.status ?? "ACTIVE",
      userId: auth.user.id,
    });

    const product = await loadProductById(productId);

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
      include: productInclude,
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
        price: sourceProduct.price,
        suggestedPrice: sourceProduct.suggestedPrice,
        packageSize: selectPrimaryBarcode(sourceProduct.barcodes)?.packSize ?? sourceProduct.packageSize,
        pictureUrl: sourceProduct.pictureUrl,
        status: sourceProduct.status,
        createdByUserId: auth.user.id,
        updatedByUserId: auth.user.id,
      },
      include: productInclude,
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

router.get("/approval-requests", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const status = typeof request.query.status === "string" ? request.query.status.trim().toUpperCase() : "";

    const requests = await (prisma as any).masterProductRequest.findMany({
      where: status && ["PENDING", "APPROVED", "REJECTED"].includes(status) ? { status } : {},
      include: {
        shop: {
          select: { id: true, shopName: true, shopCode: true },
        },
      },
      orderBy: [{ createdAt: "desc" }],
    });

    return response.json({
      requests: requests.map((item: any) => ({
        id: item.id,
        shopId: item.shopId,
        shopName: item.shop?.shopName ?? null,
        shopCode: item.shop?.shopCode ?? null,
        shopProductId: item.shopProductId,
        masterProductId: item.masterProductId,
        name: item.name,
        category: item.category,
        brand: item.brand,
        unit: item.unit,
        barcode: item.barcode,
        pictureUrl: item.pictureUrl,
        purchasePrice: normalizeMoney(item.purchasePrice),
        salePrice: normalizeMoney(item.salePrice),
        openingStock: normalizeMoney(item.openingStock),
        lowStockLimit: normalizeMoney(item.lowStockLimit),
        status: item.status,
        rejectionReason: item.rejectionReason,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      })),
    });
  } catch (error) {
    console.error("Failed to load master product approval requests.", error);
    return response.status(503).json({ message: "Approval requests could not be loaded right now." });
  }
});

router.patch("/approval-requests/:id/approve", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const approvalRequest = await (prisma as any).masterProductRequest.findUnique({
      where: { id: request.params.id },
    });

    if (!approvalRequest) {
      return response.status(404).json({ message: "Approval request not found." });
    }

    if (approvalRequest.status === "APPROVED" && approvalRequest.masterProductId) {
      const existingProduct = await loadProductById(approvalRequest.masterProductId);
      return response.json({
        message: "Approval request already approved.",
        product: existingProduct ? mapProduct(existingProduct) : null,
      });
    }

    const result = await (prisma as any).$transaction(async (tx: any) => {
      const sku = buildGeneratedSku(approvalRequest.name);
      const createdProduct = await tx.masterProduct.create({
        data: {
          sku,
          name: approvalRequest.name,
          packageSize: approvalRequest.unit,
          description: approvalRequest.category,
          pictureUrl: approvalRequest.pictureUrl,
          price: approvalRequest.purchasePrice,
          suggestedPrice: approvalRequest.salePrice,
          status: "ACTIVE",
          createdByUserId: auth.user.id,
          updatedByUserId: auth.user.id,
        },
        select: { id: true },
      });

      await syncProductBarcodeRecord({
        barcode: approvalRequest.barcode,
        packageSize: approvalRequest.unit,
        productId: createdProduct.id,
        productStatus: "ACTIVE",
        userId: auth.user.id,
      });

      await tx.masterProductRequest.update({
        where: { id: approvalRequest.id },
        data: {
          status: "APPROVED",
          reviewedByUserId: auth.user.id,
          masterProductId: createdProduct.id,
          rejectionReason: null,
        },
      });

      if (approvalRequest.shopProductId) {
        await tx.shopProduct.update({
          where: { id: approvalRequest.shopProductId },
          data: {
            masterProductId: createdProduct.id,
            source: "MASTER",
          },
        });
      }

      return loadProductById(createdProduct.id);
    });

    return response.json({
      message: "Approval request approved and master product created successfully.",
      product: result ? mapProduct(result as ProductRow) : null,
    });
  } catch (error) {
    console.error("Failed to approve master product request.", error);
    return response.status(503).json({ message: "Approval request could not be approved right now." });
  }
});

router.patch("/approval-requests/:id/reject", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const reason = (request.body as { reason?: string | null } | undefined)?.reason?.trim() || null;

    const approvalRequest = await (prisma as any).masterProductRequest.update({
      where: { id: request.params.id },
      data: {
        status: "REJECTED",
        reviewedByUserId: auth.user.id,
        rejectionReason: reason,
      },
    });

    return response.json({
      message: "Approval request rejected successfully.",
      request: {
        id: approvalRequest.id,
        status: approvalRequest.status,
        rejectionReason: approvalRequest.rejectionReason,
      },
    });
  } catch (error) {
    console.error("Failed to reject master product request.", error);
    return response.status(503).json({ message: "Approval request could not be rejected right now." });
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
      include: productInclude,
    });

    await (prisma as any).masterProductBarcode.updateMany({
      where: { masterProductId: productId },
      data: {
        status: toBarcodeStatusFromProductStatus(nextStatus),
        updatedByUserId: auth.user.id,
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

    await (prisma as any).masterProductBarcode.deleteMany({
      where: { masterProductId: productId },
    });

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
