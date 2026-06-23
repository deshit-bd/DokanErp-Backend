import { randomUUID } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { type Request, Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";
import { generateBarcodeSvg } from "../utils/barcode/barcode-generator";
import {
  normalizeMoney as normalizeMovementMoney,
  recordStockMovement,
  roundQuantity,
} from "../utils/stock-movement";

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

function normalizeBatchOrder(value: string | null | undefined) {
  return value === "LIFO" ? "LIFO" : "FIFO";
}

function buildBatchGroups(
  inventoryBinItems: Array<{
    id: string;
    masterProductId: string;
    purchaseItemId?: string | null;
    quantity: unknown;
    purchasePrice?: unknown;
    salePrice?: unknown;
    batchNo?: string | null;
    expiryDate?: Date | null;
    createdAt: Date;
  }>,
  stockMethod: string,
) {
  const grouped = new Map<string, {
    id: string;
    purchaseItemId: string | null;
    batchNo: string | null;
    expiryDate: Date | null;
    quantity: number;
    purchasePrice: number | null;
    salePrice: number | null;
    createdAt: Date;
  }>();

  for (const item of inventoryBinItems) {
    const purchasePrice = normalizeMoney(item.purchasePrice);
    const salePrice = normalizeMoney(item.salePrice);
    const expiryDate = item.expiryDate ?? null;
    const batchNo = item.batchNo ?? null;
    const groupKey = [
      item.masterProductId,
      item.purchaseItemId ?? "",
      batchNo ?? "",
      expiryDate?.toISOString() ?? "",
      purchasePrice ?? "",
      salePrice ?? "",
    ].join("|");
    const current = grouped.get(groupKey);

    if (current) {
      current.quantity = Number((current.quantity + Number(item.quantity ?? 0)).toFixed(3));
      if (item.createdAt < current.createdAt) {
        current.createdAt = item.createdAt;
        current.id = item.id;
      }
      continue;
    }

    grouped.set(groupKey, {
      id: item.id,
      purchaseItemId: item.purchaseItemId ?? null,
      batchNo,
      expiryDate,
      quantity: Number(item.quantity ?? 0),
      purchasePrice,
      salePrice,
      createdAt: item.createdAt,
    });
  }

  return Array.from(grouped.values()).sort((left, right) => {
    const delta = left.createdAt.getTime() - right.createdAt.getTime();
    return stockMethod === "LIFO" ? -delta : delta;
  });
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
    const auth = await getAuthenticatedUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    if (["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
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
    } else if (["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role) && auth.payload.shopId) {
      const page = Number(request.query.page || 1);
      const perPage = Number(request.query.per_page || 500);
      const search = typeof request.query.search === "string" ? request.query.search.trim() : "";
      const category = typeof request.query.category === "string" ? request.query.category.trim() : "";
      const inventorySetting = await (prisma as any).shopInventorySetting.findUnique({
        where: { shopId: auth.payload.shopId },
        select: { stockMethod: true },
      });
      const stockMethod = normalizeBatchOrder(inventorySetting?.stockMethod);

      const whereClause: any = { shopId: auth.payload.shopId };

      if (category && category !== "সব" && category !== "Uncategorized") {
        whereClause.OR = [
          { localCategory: { contains: category, mode: 'insensitive' } },
          { masterProduct: { category: { name: { contains: category, mode: 'insensitive' } } } }
        ];
      }
      if (search) {
        whereClause.AND = [
          ...(whereClause.AND || []),
          {
            OR: [
              { localName: { contains: search, mode: 'insensitive' } },
              { localBarcode: { contains: search, mode: 'insensitive' } },
              { masterProduct: { name: { contains: search, mode: 'insensitive' } } },
              { masterProduct: { sku: { contains: search, mode: 'insensitive' } } },
              { masterProduct: { barcodes: { some: { barcode: { contains: search, mode: 'insensitive' } } } } }
            ]
          }
        ];
      }

      const shopProducts = await (prisma as any).shopProduct.findMany({
        where: whereClause,
        include: {
          masterProduct: {
            include: {
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
                },
              },
            },
          },
          approvalRequest: {
            select: {
              id: true,
              status: true,
            },
          },
        },
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * perPage,
        take: perPage,
      });

      const masterProductIds = shopProducts
        .map((item: any) => item.masterProductId)
        .filter((value: string | null | undefined): value is string => Boolean(value));

      const inventoryBinItems = masterProductIds.length
        ? await (prisma as any).inventoryBinItem.findMany({
            where: {
              shopId: auth.payload.shopId,
              masterProductId: { in: masterProductIds },
              quantity: { gt: 0 },
            },
            orderBy: [{ createdAt: stockMethod === "LIFO" ? "desc" : "asc" }, { id: "asc" }],
            select: {
              id: true,
              masterProductId: true,
              purchaseItemId: true,
              quantity: true,
              purchasePrice: true,
              salePrice: true,
              batchNo: true,
              expiryDate: true,
              createdAt: true,
            },
          })
        : [];

      const batchesByProduct = new Map<string, ReturnType<typeof buildBatchGroups>>();
      for (const masterProductId of masterProductIds) {
        batchesByProduct.set(
          masterProductId,
          buildBatchGroups(
            inventoryBinItems.filter((item: any) => item.masterProductId === masterProductId),
            stockMethod,
          ),
        );
      }

      const mappedProducts = shopProducts.map((item: any) => {
        const primaryBarcode = item.masterProduct
          ? selectPrimaryBarcode(item.masterProduct.barcodes)
          : null;

        const barcodeVal = item.localBarcode ?? primaryBarcode?.barcode ?? item.masterProduct?.sku ?? item.id;
        const productBatches = item.masterProductId ? (batchesByProduct.get(item.masterProductId) ?? []) : [];
        const nextBatch = productBatches[0] ?? null;
        const effectiveSalePrice =
          nextBatch?.salePrice ??
          normalizeMoney(item.salePrice ?? item.masterProduct?.suggestedPrice ?? item.masterProduct?.price ?? 0);
        const effectivePurchasePrice =
          nextBatch?.purchasePrice ??
          normalizeMoney(item.purchasePrice ?? item.masterProduct?.price ?? 0);

        return {
          id: barcodeVal,
          sku: barcodeVal,
          barcode: barcodeVal,
          master_product_id: item.masterProductId ?? item.masterProduct?.id ?? null,
          masterProductId: item.masterProductId ?? item.masterProduct?.id ?? null,
          name: item.masterProduct?.name ?? item.localName ?? "Unnamed product",
          category_name: item.masterProduct?.category?.name ?? item.localCategory ?? "Uncategorized",
          category: item.masterProduct?.category?.name ?? item.localCategory ?? "Uncategorized",
          emoji: productVisualType(
            item.masterProduct?.name ?? item.localName ?? "",
            item.masterProduct?.category?.name ?? item.localCategory ?? null
          ) === "oil" ? "🛢️" : "📦",
          brand_name: item.masterProduct?.brand?.name ?? item.localBrand ?? "No Brand",
          brand: item.masterProduct?.brand?.name ?? item.localBrand ?? "No Brand",
          unit_name: item.masterProduct?.unit?.shortName?.toUpperCase() ?? item.masterProduct?.unit?.name ?? item.localUnit ?? "No Unit",
          unit: item.masterProduct?.unit?.shortName?.toUpperCase() ?? item.masterProduct?.unit?.name ?? item.localUnit ?? "No Unit",
          image_url: item.masterProduct?.pictureUrl ?? item.localPictureUrl ?? null,
          imageLabel: item.masterProduct?.pictureUrl ?? item.localPictureUrl ?? null,
          sale_price: effectiveSalePrice,
          salePrice: effectiveSalePrice,
          price: effectiveSalePrice,
          purchase_price: effectivePurchasePrice,
          purchasePrice: effectivePurchasePrice,
          cost_price: effectivePurchasePrice,
          stock: Number(item.openingStock ?? 0),
          quantity: Number(item.openingStock ?? 0),
          stock_quantity: Number(item.openingStock ?? 0),
          low_stock_threshold: Number(item.lowStockLimit ?? 0),
          lowStockThreshold: Number(item.lowStockLimit ?? 0),
          stock_threshold: Number(item.lowStockLimit ?? 0),
          sales_count: 0,
          salesCount: 0,
          pack_info: primaryBarcode?.packSize ?? item.masterProduct?.packageSize ?? item.localUnit ?? "",
          packInfo: primaryBarcode?.packSize ?? item.masterProduct?.packageSize ?? item.localUnit ?? "",
          batches: productBatches.map((batch) => ({
            id: batch.id,
            purchase_item_id: batch.purchaseItemId,
            purchaseItemId: batch.purchaseItemId,
            batch_no: batch.batchNo,
            batchNo: batch.batchNo,
            expiry_date: batch.expiryDate?.toISOString() ?? null,
            expiryDate: batch.expiryDate?.toISOString() ?? null,
            quantity: batch.quantity,
            purchase_price: batch.purchasePrice,
            purchasePrice: batch.purchasePrice,
            sale_price: batch.salePrice,
            salePrice: batch.salePrice,
            created_at: batch.createdAt.toISOString(),
            createdAt: batch.createdAt.toISOString(),
          })),
          source: item.source,
          approvalStatus: item.approvalRequest?.status ?? null,
        };
      });

      return response.json({
        data: mappedProducts,
        products: mappedProducts,
      });
    } else {
      return response.status(403).json({ message: "You do not have permission to manage products." });
    }
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
    const auth = await getAuthenticatedUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    if (["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
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
    } else if (["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role) && auth.payload.shopId) {
      const body = request.body as {
        name?: string;
        barcode?: string | null;
        category?: string | null;
        brand?: string | null;
        unit?: string | null;
        image_url?: string | null;
        sale_price?: number | string | null;
        purchase_price?: number | string | null;
        stock?: number | string | null;
        low_stock_threshold?: number | string | null;
        pack_info?: string | null;
      };

      const name = body.name?.trim();
      const category = body.category?.trim() || "Uncategorized";
      const brand = body.brand?.trim() || null;
      const unit = body.unit?.trim() || "pcs";
      const barcode = body.barcode?.trim() || null;
      const pictureUrl = body.image_url?.trim() || null;
      const salePrice = body.sale_price == null || body.sale_price === "" ? null : Number(body.sale_price);
      const purchasePrice = body.purchase_price == null || body.purchase_price === "" ? null : Number(body.purchase_price);
      const openingStock = body.stock == null || body.stock === "" ? 0 : Number(body.stock);
      const lowStockLimit = body.low_stock_threshold == null || body.low_stock_threshold === "" ? 0 : Number(body.low_stock_threshold);

      if (!name) {
        return response.status(400).json({ message: "Product name is required." });
      }

      if (!Number.isFinite(openingStock) || openingStock < 0) {
        return response.status(400).json({ message: "Stock must be a valid number." });
      }

      if (!Number.isFinite(lowStockLimit) || lowStockLimit < 0) {
        return response.status(400).json({ message: "Low stock limit must be a valid number." });
      }

      const existingLocalBarcode = barcode
        ? await (prisma as any).shopProduct.findFirst({
            where: {
              shopId: auth.payload.shopId,
              OR: [{ localBarcode: barcode }, { masterProduct: { barcodes: { some: { barcode } } } }],
            },
            select: { id: true },
          })
        : null;

      if (existingLocalBarcode) {
        return response.status(409).json({ message: "Barcode already exists in this shop." });
      }

      const { countDistinctShopProducts } = await import("../subscription/access");
      const { evaluateShopSubscriptionAccess } = await import("../subscription/access");
      const currentProductCount = await countDistinctShopProducts(auth.payload.shopId);
      const access = await evaluateShopSubscriptionAccess(auth.payload.shopId);
      if (access.tier === "TRIAL" && currentProductCount >= 50) {
        return response.status(402).json({
          message: `Free tier allows up to 50 products per shop.`,
          subscription: access,
        });
      }

      const created = await (prisma as any).$transaction(async (tx: any) => {
        const requestRow = await tx.masterProductRequest.create({
          data: {
            shopId: auth.payload.shopId,
            createdByUserId: auth.user.id,
            name,
            category,
            brand,
            unit,
            barcode,
            pictureUrl,
            purchasePrice,
            salePrice,
            openingStock,
            lowStockLimit,
            status: "PENDING",
          },
        });

        const shopProduct = await tx.shopProduct.create({
          data: {
            shopId: auth.payload.shopId,
            source: "SHOP_LOCAL",
            localName: name,
            localCategory: category,
            localBrand: brand,
            localUnit: unit,
            localBarcode: barcode,
            localPictureUrl: pictureUrl,
            openingStock,
            lowStockLimit,
            salePrice,
            purchasePrice,
            approvalRequestId: requestRow.id,
          },
        });

        await tx.masterProductRequest.update({
          where: { id: requestRow.id },
          data: { shopProductId: shopProduct.id },
        });

        return shopProduct;
      });

      const mappedProduct = {
        id: created.localBarcode ?? created.id,
        sku: created.localBarcode ?? created.id,
        barcode: created.localBarcode ?? created.id,
        name: created.localName ?? "Unnamed product",
        category_name: created.localCategory ?? "Uncategorized",
        category: created.localCategory ?? "Uncategorized",
        emoji: productVisualType(created.localName ?? "", created.localCategory) === "oil" ? "🛢️" : "📦",
        brand_name: created.localBrand ?? "No Brand",
        brand: created.localBrand ?? "No Brand",
        unit_name: created.localUnit ?? "No Unit",
        unit: created.localUnit ?? "No Unit",
        image_url: created.localPictureUrl ?? null,
        imageLabel: created.localPictureUrl ?? null,
        sale_price: normalizeMoney(created.salePrice ?? 0),
        salePrice: normalizeMoney(created.salePrice ?? 0),
        price: normalizeMoney(created.salePrice ?? 0),
        purchase_price: normalizeMoney(created.purchasePrice ?? 0),
        purchasePrice: normalizeMoney(created.purchasePrice ?? 0),
        cost_price: normalizeMoney(created.purchasePrice ?? 0),
        stock: Number(created.openingStock ?? 0),
        quantity: Number(created.openingStock ?? 0),
        stock_quantity: Number(created.openingStock ?? 0),
        low_stock_threshold: Number(created.lowStockLimit ?? 0),
        lowStockThreshold: Number(created.lowStockLimit ?? 0),
        stock_threshold: Number(created.lowStockLimit ?? 0),
        sales_count: 0,
        salesCount: 0,
        pack_info: created.localUnit ?? "",
        packInfo: created.localUnit ?? "",
        source: created.source,
        approvalStatus: "PENDING",
      };

      return response.status(201).json({
        message: "Shop product created successfully and sent for admin approval.",
        product: mappedProduct,
        data: mappedProduct,
      });
    } else {
      return response.status(403).json({ message: "You do not have permission to manage products." });
    }
  } catch (error) {
    console.error("Failed to save product.", error);

    return response.status(503).json({
      message:
        "Product could not be saved because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

const handleUpdate = async (request: any, response: any) => {
  try {
    const auth = await getAuthenticatedUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const barcodeOrId = request.params.id;

    if (["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
      const productId = barcodeOrId;
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
    } else if (["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role) && auth.payload.shopId) {
      const body = request.body as {
        name?: string;
        category?: string | null;
        brand?: string | null;
        unit?: string | null;
        image_url?: string | null;
        sale_price?: number | string | null;
        purchase_price?: number | string | null;
        stock?: number | string | null;
        low_stock_threshold?: number | string | null;
        pack_info?: string | null;
      };

      const shopProduct = await (prisma as any).shopProduct.findFirst({
        where: {
          shopId: auth.payload.shopId,
          OR: [
            { id: barcodeOrId },
            { localBarcode: barcodeOrId },
            { masterProduct: { barcodes: { some: { barcode: barcodeOrId } } } },
            { masterProduct: { sku: barcodeOrId } }
          ]
        },
        include: {
          masterProduct: true,
        }
      });

      if (!shopProduct) {
        return response.status(404).json({ message: "Product not found." });
      }

      const updateData: any = {};
      if (body.stock !== undefined) {
        updateData.openingStock = body.stock == null || body.stock === "" ? 0 : Number(body.stock);
      }
      if (body.sale_price !== undefined) {
        updateData.salePrice = body.sale_price == null || body.sale_price === "" ? null : Number(body.sale_price);
      }
      if (body.purchase_price !== undefined) {
        updateData.purchasePrice = body.purchase_price == null || body.purchase_price === "" ? null : Number(body.purchase_price);
      }
      if (body.low_stock_threshold !== undefined) {
        updateData.lowStockLimit = body.low_stock_threshold == null || body.low_stock_threshold === "" ? 0 : Number(body.low_stock_threshold);
      }

      if (shopProduct.source === "SHOP_LOCAL") {
        if (body.name !== undefined) {
          updateData.localName = body.name?.trim();
        }
        if (body.category !== undefined) {
          updateData.localCategory = body.category?.trim() || null;
        }
        if (body.brand !== undefined) {
          updateData.localBrand = body.brand?.trim() || null;
        }
        if (body.unit !== undefined) {
          updateData.localUnit = body.unit?.trim() || null;
        }
        if (body.image_url !== undefined) {
          updateData.localPictureUrl = body.image_url?.trim() || null;
        }
      }

      const updated = await (prisma as any).shopProduct.update({
        where: { id: shopProduct.id },
        data: updateData,
        include: {
          masterProduct: {
            include: {
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
                },
              },
            },
          },
          approvalRequest: {
            select: {
              id: true,
              status: true,
            },
          },
        }
      });

      const previousStock = Number(shopProduct.openingStock ?? 0);
      const nextStock = Number(updated.openingStock ?? 0);
      const previousPurchasePrice = normalizeMovementMoney(
        shopProduct.purchasePrice ?? shopProduct.masterProduct?.price ?? null,
      );
      const previousSalePrice = normalizeMovementMoney(
        shopProduct.salePrice ??
          shopProduct.masterProduct?.suggestedPrice ??
          shopProduct.masterProduct?.price ??
          null,
      );
      const nextPurchasePrice = normalizeMovementMoney(
        updated.purchasePrice ?? updated.masterProduct?.price ?? null,
      );
      const nextSalePrice = normalizeMovementMoney(
        updated.salePrice ??
          updated.masterProduct?.suggestedPrice ??
          updated.masterProduct?.price ??
          null,
      );

      if (nextStock < previousStock) {
        return response.status(400).json({
          message:
            "Manual stock deduction has been disabled. Use sales, purchase returns, or damage workflows instead.",
        });
      }

      if (previousStock != nextStock) {
        const delta = roundQuantity(nextStock - previousStock);
        await recordStockMovement(prisma, {
          shopId: auth.payload.shopId,
          shopProductId: updated.id,
          masterProductId: updated.masterProductId,
          movementType: delta >= 0 ? "MANUAL_ADD" : "MANUAL_REDUCE",
          quantityDelta: delta,
          stockBefore: previousStock,
          stockAfter: nextStock,
          purchasePrice: nextPurchasePrice,
          salePrice: nextSalePrice,
          referenceType: "PRODUCT_UPDATE",
          referenceId: updated.id,
          note: delta >= 0 ? "Manual stock increase." : "Manual stock reduction.",
          createdByUserId: auth.user.id,
        });
      }

      if (
        previousPurchasePrice !== nextPurchasePrice ||
        previousSalePrice !== nextSalePrice
      ) {
        await recordStockMovement(prisma, {
          shopId: auth.payload.shopId,
          shopProductId: updated.id,
          masterProductId: updated.masterProductId,
          movementType: "PRICE_CHANGE",
          quantityDelta: 0,
          stockBefore: nextStock,
          stockAfter: nextStock,
          purchasePrice: nextPurchasePrice,
          salePrice: nextSalePrice,
          referenceType: "PRODUCT_UPDATE",
          referenceId: updated.id,
          note: "Product price updated.",
          metadata: {
            previousPurchasePrice,
            previousSalePrice,
            nextPurchasePrice,
            nextSalePrice,
          },
          createdByUserId: auth.user.id,
        });
      }

      const primaryBarcode = updated.masterProduct
        ? selectPrimaryBarcode(updated.masterProduct.barcodes)
        : null;

      const barcodeVal = updated.localBarcode ?? primaryBarcode?.barcode ?? updated.masterProduct?.sku ?? updated.id;

      const mappedProduct = {
        id: barcodeVal,
        sku: barcodeVal,
        barcode: barcodeVal,
        name: updated.masterProduct?.name ?? updated.localName ?? "Unnamed product",
        category_name: updated.masterProduct?.category?.name ?? updated.localCategory ?? "Uncategorized",
        category: updated.masterProduct?.category?.name ?? updated.localCategory ?? "Uncategorized",
        emoji: productVisualType(
          updated.masterProduct?.name ?? updated.localName ?? "",
          updated.masterProduct?.category?.name ?? updated.localCategory ?? null
        ) === "oil" ? "🛢️" : "📦",
        brand_name: updated.masterProduct?.brand?.name ?? updated.localBrand ?? "No Brand",
        brand: updated.masterProduct?.brand?.name ?? updated.localBrand ?? "No Brand",
        unit_name: updated.masterProduct?.unit?.shortName?.toUpperCase() ?? updated.masterProduct?.unit?.name ?? updated.localUnit ?? "No Unit",
        unit: updated.masterProduct?.unit?.shortName?.toUpperCase() ?? updated.masterProduct?.unit?.name ?? updated.localUnit ?? "No Unit",
        image_url: updated.masterProduct?.pictureUrl ?? updated.localPictureUrl ?? null,
        imageLabel: updated.masterProduct?.pictureUrl ?? updated.localPictureUrl ?? null,
        sale_price: normalizeMoney(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price ?? 0),
        salePrice: normalizeMoney(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price ?? 0),
        price: normalizeMoney(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price ?? 0),
        purchase_price: normalizeMoney(updated.purchasePrice ?? updated.masterProduct?.price ?? 0),
        purchasePrice: normalizeMoney(updated.purchasePrice ?? updated.masterProduct?.price ?? 0),
        cost_price: normalizeMoney(updated.purchasePrice ?? updated.masterProduct?.price ?? 0),
        stock: Number(updated.openingStock ?? 0),
        quantity: Number(updated.openingStock ?? 0),
        stock_quantity: Number(updated.openingStock ?? 0),
        low_stock_threshold: Number(updated.lowStockLimit ?? 0),
        lowStockThreshold: Number(updated.lowStockLimit ?? 0),
        stock_threshold: Number(updated.lowStockLimit ?? 0),
        sales_count: 0,
        salesCount: 0,
        pack_info: primaryBarcode?.packSize ?? updated.masterProduct?.packageSize ?? updated.localUnit ?? "",
        packInfo: primaryBarcode?.packSize ?? updated.masterProduct?.packageSize ?? updated.localUnit ?? "",
        source: updated.source,
        approvalStatus: updated.approvalRequest?.status ?? null,
      };

      return response.json({
        message: "Shop product updated successfully.",
        product: mappedProduct,
        data: mappedProduct,
      });
    } else {
      return response.status(403).json({ message: "You do not have permission to manage products." });
    }
  } catch (error) {
    console.error("Failed to update product.", error);
    return response.status(503).json({
      message: "Product could not be updated right now.",
    });
  }
};

router.put("/:id", handleUpdate);
router.patch("/:id", handleUpdate);

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
    const auth = await getAuthenticatedUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const barcodeOrId = request.params.id;

    if (["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
      const productId = barcodeOrId;
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
    } else if (["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role) && auth.payload.shopId) {
      const shopProduct = await (prisma as any).shopProduct.findFirst({
        where: {
          shopId: auth.payload.shopId,
          OR: [
            { id: barcodeOrId },
            { localBarcode: barcodeOrId },
            { masterProduct: { barcodes: { some: { barcode: barcodeOrId } } } },
            { masterProduct: { sku: barcodeOrId } }
          ]
        }
      });

      if (!shopProduct) {
        return response.status(404).json({ message: "Product not found." });
      }

      await (prisma as any).shopProduct.delete({
        where: { id: shopProduct.id }
      });

      return response.json({ message: "Product deleted successfully." });
    } else {
      return response.status(403).json({ message: "You do not have permission to manage products." });
    }
  } catch (error) {
    console.error("Failed to delete product.", error);

    return response.status(503).json({
      message: "Product could not be deleted right now.",
    });
  }
});

export default router;
