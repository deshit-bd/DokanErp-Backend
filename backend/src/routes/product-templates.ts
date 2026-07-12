import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

type ProductTemplateStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

function toDisplayStatus(status: ProductTemplateStatusValue) {
  return status.replace(/_/g, " ");
}

async function requirePlatformUser(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to manage product templates." },
    };
  }

  return auth;
}

const productTemplateInclude = {
  products: {
    orderBy: [{ masterProduct: { name: "asc" } }],
    include: {
      masterProduct: {
        include: {
          category: { select: { id: true, name: true } },
          brand: { select: { id: true, name: true } },
          unit: { select: { id: true, name: true, shortName: true } },
          barcodes: {
            orderBy: [{ updatedAt: "desc" }, { createdAt: "desc" }],
            select: {
              barcode: true,
              status: true,
            },
          },
        },
      },
    },
  },
} as const;

function selectPrimaryBarcode(
  barcodes: Array<{ barcode: string; status: "MAPPED" | "UNMAPPED" | "ARCHIVED" }>,
) {
  return (
    barcodes.find((item) => item.status === "MAPPED") ??
    barcodes.find((item) => item.status === "UNMAPPED") ??
    barcodes[0] ??
    null
  );
}

function mapTemplate(template: any) {
  return {
    id: template.id,
    code: template.code,
    name: template.name,
    description: template.description,
    status: template.status,
    statusLabel: toDisplayStatus(template.status),
    productCount: template.products.length,
    products: template.products.map((item: any) => {
      const primaryBarcode = selectPrimaryBarcode(item.masterProduct.barcodes ?? []);

      return {
        id: item.id,
        masterProductId: item.masterProductId,
        name: item.masterProduct.name,
        sku: item.masterProduct.sku,
        barcode: primaryBarcode?.barcode ?? null,
        pictureUrl: item.masterProduct.pictureUrl,
        category: item.masterProduct.category?.name ?? "Uncategorized",
        brand: item.masterProduct.brand?.name ?? "No Brand",
        unit: item.masterProduct.unit?.shortName?.toUpperCase() ?? item.masterProduct.unit?.name ?? "No Unit",
      };
    }),
    createdAt: template.createdAt,
    updatedAt: template.updatedAt,
  };
}

router.get("/", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const templates = await (prisma as any).productTemplate.findMany({
      orderBy: [{ createdAt: "desc" }, { name: "asc" }],
      include: productTemplateInclude,
    });

    return response.json({
      stats: {
        total: templates.length,
        active: templates.filter((item: { status: ProductTemplateStatusValue }) => item.status === "ACTIVE").length,
        inactive: templates.filter((item: { status: ProductTemplateStatusValue }) => item.status === "INACTIVE").length,
        archived: templates.filter((item: { status: ProductTemplateStatusValue }) => item.status === "ARCHIVED").length,
        withProducts: templates.filter((item: { products: unknown[] }) => item.products.length > 0).length,
      },
      templates: templates.map(mapTemplate),
    });
  } catch (error) {
    console.error("Failed to load product templates.", error);

    return response.status(503).json({
      message:
        "Product templates are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
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
      code?: string;
      name?: string;
      description?: string | null;
      status?: ProductTemplateStatusValue;
    };

    const code = body.code?.trim();
    const name = body.name?.trim();
    const description = body.description?.trim() || null;
    const status = body.status ?? "ACTIVE";

    if (!code) {
      return response.status(400).json({ message: "Template code is required." });
    }

    if (!name) {
      return response.status(400).json({ message: "Template name is required." });
    }

    const existingTemplate = await (prisma as any).productTemplate.findFirst({
      where: {
        OR: [{ code }, { name }],
      },
      select: { id: true, code: true, name: true },
    });

    if (existingTemplate) {
      return response.status(409).json({
        message: existingTemplate.code === code ? "Template code already exists." : "Template name already exists.",
      });
    }

    const template = await (prisma as any).productTemplate.create({
      data: {
        code,
        name,
        description,
        status,
      },
      include: productTemplateInclude,
    });

    return response.status(201).json({
      message: "Product template created successfully.",
      template: mapTemplate(template),
    });
  } catch (error) {
    console.error("Failed to create product template.", error);

    return response.status(503).json({
      message:
        "Product template could not be saved because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.put("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const templateId = request.params.id;
    const body = request.body as {
      code?: string;
      name?: string;
      description?: string | null;
      status?: ProductTemplateStatusValue;
    };

    const code = body.code?.trim();
    const name = body.name?.trim();
    const description = body.description?.trim() || null;
    const status = body.status ?? "ACTIVE";

    if (!code) {
      return response.status(400).json({ message: "Template code is required." });
    }

    if (!name) {
      return response.status(400).json({ message: "Template name is required." });
    }

    const template = await (prisma as any).productTemplate.findUnique({
      where: { id: templateId },
      select: { id: true },
    });

    if (!template) {
      return response.status(404).json({ message: "Product template not found." });
    }

    const duplicateTemplate = await (prisma as any).productTemplate.findFirst({
      where: {
        id: { not: templateId },
        OR: [{ code }, { name }],
      },
      select: { id: true, code: true, name: true },
    });

    if (duplicateTemplate) {
      return response.status(409).json({
        message: duplicateTemplate.code === code ? "Template code already exists." : "Template name already exists.",
      });
    }

    const updatedTemplate = await (prisma as any).productTemplate.update({
      where: { id: templateId },
      data: {
        code,
        name,
        description,
        status,
      },
      include: productTemplateInclude,
    });

    return response.json({
      message: "Product template updated successfully.",
      template: mapTemplate(updatedTemplate),
    });
  } catch (error) {
    console.error("Failed to update product template.", error);

    return response.status(503).json({
      message:
        "Product template could not be updated because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.delete("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const templateId = request.params.id;

    const template = await (prisma as any).productTemplate.findUnique({
      where: { id: templateId },
      select: { id: true },
    });

    if (!template) {
      return response.status(404).json({ message: "Product template not found." });
    }

    await (prisma as any).productTemplate.delete({
      where: { id: templateId },
    });

    return response.json({ message: "Product template deleted successfully." });
  } catch (error) {
    console.error("Failed to delete product template.", error);

    return response.status(503).json({
      message:
        "Product template could not be deleted because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.put("/:id/products", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const templateId = request.params.id;
    const body = request.body as { productIds?: string[] };
    const productIds = Array.from(new Set((body.productIds ?? []).map((value) => value.trim()).filter(Boolean)));

    const template = await (prisma as any).productTemplate.findUnique({
      where: { id: templateId },
      select: { id: true },
    });

    if (!template) {
      return response.status(404).json({ message: "Product template not found." });
    }

    const products = productIds.length
      ? await (prisma as any).masterProduct.findMany({
          where: { id: { in: productIds } },
          select: { id: true },
        })
      : [];

    if (products.length !== productIds.length) {
      return response.status(400).json({ message: "One or more selected master products do not exist." });
    }

    await (prisma as any).$transaction([
      (prisma as any).productTemplateItem.deleteMany({
        where: { templateId },
      }),
      ...(productIds.length
        ? [
            (prisma as any).productTemplateItem.createMany({
              data: productIds.map((masterProductId) => ({
                templateId,
                masterProductId,
              })),
            }),
          ]
        : []),
    ]);

    const updatedTemplate = await (prisma as any).productTemplate.findUnique({
      where: { id: templateId },
      include: productTemplateInclude,
    });

    return response.json({
      message: "Template products updated successfully.",
      template: mapTemplate(updatedTemplate),
    });
  } catch (error) {
    console.error("Failed to update template products.", error);

    return response.status(503).json({
      message:
        "Template products could not be updated because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.delete("/:id/products/:productId", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    await (prisma as any).productTemplateItem.deleteMany({
      where: {
        templateId: request.params.id,
        masterProductId: request.params.productId,
      },
    });

    const updatedTemplate = await (prisma as any).productTemplate.findUnique({
      where: { id: request.params.id },
      include: productTemplateInclude,
    });

    if (!updatedTemplate) {
      return response.status(404).json({ message: "Product template not found." });
    }

    return response.json({
      message: "Product removed from template successfully.",
      template: mapTemplate(updatedTemplate),
    });
  } catch (error) {
    console.error("Failed to remove template product.", error);

    return response.status(503).json({
      message:
        "Template product could not be removed because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

export default router;
