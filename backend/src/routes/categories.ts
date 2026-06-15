import { CategoryLogAction, CategoryStatus } from "@prisma/client";
import { Router } from "express";

import { prisma } from "../config/prisma";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";

const router = Router();

function toDisplayStatus(status: CategoryStatus) {
  return status.replace(/_/g, " ");
}

async function requirePlatformUser(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN", "SHOP_OWNER"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to manage categories." },
    };
  }

  return auth;
}

router.get("/", async (request, response) => {
  const auth = await requirePlatformUser(request);

  if (isAuthError(auth)) {
    return sendAuthError(response, auth);
  }

  const isAdmin = ["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role);

  const categories = await prisma.productCategory.findMany({
    where: isAdmin ? {} : {
      OR: [
        { isGlobal: true },
        { shopId: auth.payload.shopId }
      ]
    },
    orderBy: { createdAt: "desc" },
    include: {
      _count: {
        select: {
          masterProducts: true,
        },
      },
      createdBy: {
        select: { id: true, name: true },
      },
      updatedBy: {
        select: { id: true, name: true },
      },
    },
  });

  const stats = {
    total: categories.length,
    active: categories.filter((item) => item.status === CategoryStatus.ACTIVE).length,
    inactive: categories.filter((item) => item.status === CategoryStatus.INACTIVE).length,
    empty: categories.filter((item) => item._count.masterProducts === 0).length,
  };

  return response.json({
    stats,
    categories: categories.map((category) => ({
      id: category.id,
      name: category.name,
      description: category.description,
      status: category.status,
      statusLabel: toDisplayStatus(category.status),
      isGlobal: category.isGlobal,
      isApproved: category.isApproved,
      shopId: category.shopId,
      products: category._count.masterProducts,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      createdBy: category.createdBy,
      updatedBy: category.updatedBy,
    })),
  });
});

router.post("/", async (request, response) => {
  const auth = await requirePlatformUser(request);

  if (isAuthError(auth)) {
    return sendAuthError(response, auth);
  }

  const body = request.body as {
    name?: string;
    description?: string | null;
    status?: CategoryStatus;
  };

  const name = body.name?.trim();
  const description = body.description?.trim() || null;
  const status = body.status ?? CategoryStatus.ACTIVE;

  if (!name) {
    return response.status(400).json({ message: "Category name is required." });
  }

  const isAdmin = ["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role);

  const existingCategory = await prisma.productCategory.findFirst({
    where: {
      name,
      OR: isAdmin ? [
        { isGlobal: true }
      ] : [
        { isGlobal: true },
        { shopId: auth.payload.shopId }
      ]
    },
    select: { id: true, status: true },
  });

  if (existingCategory) {
    return response.status(409).json({ message: "Category name already exists." });
  }

  const category = await prisma.productCategory.create({
    data: {
      name,
      description,
      status,
      shopId: isAdmin ? null : auth.payload.shopId,
      isGlobal: isAdmin,
      isApproved: isAdmin,
      createdByUserId: auth.user.id,
      updatedByUserId: auth.user.id,
      logs: {
        create: {
          action: CategoryLogAction.CREATED,
          newData: {
            name,
            description,
            status,
            shopId: isAdmin ? null : auth.payload.shopId,
            isGlobal: isAdmin,
            isApproved: isAdmin,
          },
          performedById: auth.user.id,
        },
      },
    },
    include: {
      _count: {
        select: {
          masterProducts: true,
        },
      },
      createdBy: {
        select: { id: true, name: true },
      },
      updatedBy: {
        select: { id: true, name: true },
      },
    },
  });

  return response.json({
    message: "Category created successfully.",
    category: {
      id: category.id,
      name: category.name,
      description: category.description,
      status: category.status,
      statusLabel: toDisplayStatus(category.status),
      isGlobal: category.isGlobal,
      isApproved: category.isApproved,
      shopId: category.shopId,
      products: category._count.masterProducts,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      createdBy: category.createdBy,
      updatedBy: category.updatedBy,
    },
  });
});

router.patch("/:id", async (request, response) => {
  const auth = await requirePlatformUser(request);

  if (isAuthError(auth)) {
    return sendAuthError(response, auth);
  }

  const { id } = request.params;
  const category = await prisma.productCategory.findUnique({
    where: { id },
  });

  if (!category) {
    return response.status(404).json({ message: "Category not found." });
  }

  const body = request.body as {
    name?: string;
    description?: string | null;
    status?: CategoryStatus;
  };

  const name = body.name?.trim();
  const description = body.description?.trim() || null;
  const status = body.status ?? category.status;

  if (!name) {
    return response.status(400).json({ message: "Category name is required." });
  }

  const existingCategory = await prisma.productCategory.findFirst({
    where: {
      name,
      id: { not: id },
    },
    select: { id: true },
  });

  if (existingCategory) {
    return response.status(409).json({ message: "Category name already exists." });
  }

  const action =
    category.status !== status
      ? status === CategoryStatus.ARCHIVED
        ? CategoryLogAction.ARCHIVED
        : CategoryLogAction.STATUS_CHANGED
      : CategoryLogAction.UPDATED;

  const updatedCategory = await prisma.productCategory.update({
    where: { id },
    data: {
      name,
      description,
      status,
      updatedByUserId: auth.user.id,
      logs: {
        create: {
          action,
          oldData: {
            name: category.name,
            description: category.description,
            status: category.status,
          },
          newData: {
            name,
            description,
            status,
          },
          performedById: auth.user.id,
        },
      },
    },
    include: {
      _count: {
        select: {
          masterProducts: true,
        },
      },
      createdBy: {
        select: { id: true, name: true },
      },
      updatedBy: {
        select: { id: true, name: true },
      },
    },
  });

  return response.json({
    message: "Category updated successfully.",
    category: {
      id: updatedCategory.id,
      name: updatedCategory.name,
      description: updatedCategory.description,
      status: updatedCategory.status,
      statusLabel: updatedCategory.status.replace(/_/g, " "),
      products: updatedCategory._count.masterProducts,
      createdAt: updatedCategory.createdAt,
      updatedAt: updatedCategory.updatedAt,
      createdBy: updatedCategory.createdBy,
      updatedBy: updatedCategory.updatedBy,
    },
  });
});

router.delete("/:id", async (request, response) => {
  const auth = await requirePlatformUser(request);

  if (isAuthError(auth)) {
    return sendAuthError(response, auth);
  }

  const { id } = request.params;
  const category = await prisma.productCategory.findUnique({
    where: { id },
    include: {
      _count: {
        select: {
          masterProducts: true,
        },
      },
    },
  });

  if (!category) {
    return response.status(404).json({ message: "Category not found." });
  }

  if (category._count.masterProducts > 0) {
    await prisma.productCategory.update({
      where: { id },
      data: {
        status: CategoryStatus.ARCHIVED,
        updatedByUserId: auth.user.id,
        logs: {
          create: {
            action: CategoryLogAction.DELETE_BLOCKED,
            oldData: {
              status: category.status,
              productCount: category._count.masterProducts,
            },
            newData: {
              status: CategoryStatus.ARCHIVED,
              productCount: category._count.masterProducts,
            },
            performedById: auth.user.id,
          },
        },
      },
    });

    return response
      .status(409)
      .json({ message: "Category has products, so it was archived instead of deleted." });
  }

  await prisma.categoryLog.create({
    data: {
      categoryId: id,
      action: CategoryLogAction.ARCHIVED,
      oldData: {
        name: category.name,
        status: category.status,
      },
      newData: {
        deleted: true,
      },
      performedById: auth.user.id,
    },
  });

  await prisma.productCategory.delete({
    where: { id },
  });

  return response.json({
    message: "Category deleted successfully.",
  });
});

router.post("/:id/approve", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
      return response.status(403).json({ message: "Only administrators can approve master categories." });
    }

    const { id } = request.params;
    const category = await prisma.productCategory.findUnique({
      where: { id },
    });

    if (!category) {
      return response.status(404).json({ message: "Category not found." });
    }

    const updated = await prisma.productCategory.update({
      where: { id },
      data: {
        isGlobal: true,
        isApproved: true,
        shopId: null,
        updatedByUserId: auth.user.id,
      },
      include: {
        _count: {
          select: {
            masterProducts: true,
          },
        },
        createdBy: {
          select: { id: true, name: true },
        },
        updatedBy: {
          select: { id: true, name: true },
        },
      },
    });

    return response.json({
      message: "Category approved and elevated to global master data successfully.",
      category: {
        id: updated.id,
        name: updated.name,
        description: updated.description,
        status: updated.status,
        statusLabel: updated.status.replace(/_/g, " "),
        isGlobal: updated.isGlobal,
        isApproved: updated.isApproved,
        shopId: updated.shopId,
        products: updated._count.masterProducts,
        createdAt: updated.createdAt,
        updatedAt: updated.updatedAt,
        createdBy: updated.createdBy,
        updatedBy: updated.updatedBy,
      },
    });
  } catch (error) {
    console.error("Failed to approve category.", error);
    return response.status(500).json({ message: "Failed to approve category." });
  }
});

export default router;
