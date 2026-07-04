import { UnitStatus, UnitType } from "@prisma/client";
import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

function toDisplayLabel(value: string) {
  return value
    .toLowerCase()
    .split("_")
    .map((segment) => segment.charAt(0).toUpperCase() + segment.slice(1))
    .join(" ");
}

async function requirePlatformUser(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN", "SHOP_OWNER"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to manage units." },
    };
  }

  return auth;
}

function serializeUnit(unit: {
  id: string;
  name: string;
  shortName: string;
  type: UnitType;
  description: string | null;
  status: UnitStatus;
  shopId: string | null;
  isGlobal: boolean;
  isApproved: boolean;
  createdAt: Date;
  updatedAt: Date;
}) {
  return {
    id: unit.id,
    name: unit.name,
    shortName: unit.shortName,
    type: unit.type,
    typeLabel: toDisplayLabel(unit.type),
    description: unit.description,
    status: unit.status,
    statusLabel: toDisplayLabel(unit.status),
    shopId: unit.shopId,
    isGlobal: unit.isGlobal,
    isApproved: unit.isApproved,
    createdAt: unit.createdAt,
    updatedAt: unit.updatedAt,
  };
}

router.get("/", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const isAdmin = ["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role);

    const units = await prisma.unit.findMany({
      where: isAdmin ? {} : {
        OR: [
          { isGlobal: true },
          { shopId: auth.payload.shopId }
        ]
      },
      orderBy: [{ createdAt: "desc" }, { name: "asc" }],
    });

    return response.json({
      stats: {
        total: units.length,
        active: units.filter((unit) => unit.status === UnitStatus.ACTIVE).length,
        inactive: units.filter((unit) => unit.status === UnitStatus.INACTIVE).length,
        archived: units.filter((unit) => unit.status === UnitStatus.ARCHIVED).length,
      },
      units: units.map(serializeUnit),
    });
  } catch (error) {
    console.error("Failed to load units.", error);

    return response.status(503).json({
      message:
        "Units are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
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
      shortName?: string;
      type?: UnitType;
      description?: string | null;
      status?: UnitStatus;
    };

    const name = body.name?.trim();
    const shortName = body.shortName?.trim();
    const description = body.description?.trim() || null;
    const type = body.type;
    const status = body.status ?? UnitStatus.ACTIVE;

    if (!name) {
      return response.status(400).json({ message: "Unit name is required." });
    }

    if (!shortName) {
      return response.status(400).json({ message: "Short name is required." });
    }

    if (!type || !Object.values(UnitType).includes(type)) {
      return response.status(400).json({ message: "Unit type is required." });
    }

    if (!Object.values(UnitStatus).includes(status)) {
      return response.status(400).json({ message: "Unit status is invalid." });
    }

    const isAdmin = ["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role);

    const existingUnit = await prisma.unit.findFirst({
      where: {
        OR: isAdmin ? [
          { name, isGlobal: true },
          { shortName, isGlobal: true }
        ] : [
          { name, isGlobal: true },
          { name, shopId: auth.payload.shopId },
          { shortName, isGlobal: true },
          { shortName, shopId: auth.payload.shopId }
        ]
      },
      select: {
        id: true,
        name: true,
        shortName: true,
      },
    });

    if (existingUnit) {
      const duplicateField = existingUnit.name === name ? "Unit name" : "Short name";
      return response.status(409).json({ message: `${duplicateField} already exists.` });
    }

    const unit = await prisma.unit.create({
      data: {
        name,
        shortName,
        type,
        description,
        status,
        shopId: isAdmin ? null : auth.payload.shopId,
        isGlobal: isAdmin,
        isApproved: isAdmin,
      },
    });

    return response.status(201).json({
      message: "Unit created successfully.",
      unit: serializeUnit(unit),
    });
  } catch (error) {
    console.error("Failed to save unit.", error);

    return response.status(503).json({
      message:
        "Unit could not be saved because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.patch("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const { id } = request.params;
    const body = request.body as {
      name?: string;
      shortName?: string;
      type?: UnitType;
      description?: string | null;
      status?: UnitStatus;
    };

    const unit = await prisma.unit.findUnique({
      where: { id },
    });

    if (!unit) {
      return response.status(404).json({ message: "Unit not found." });
    }

    const isAdmin = ["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role);

    if (!isAdmin && unit.shopId !== auth.payload.shopId) {
      return response.status(403).json({ message: "You do not have permission to edit this unit." });
    }

    const name = body.name?.trim();
    const shortName = body.shortName?.trim();
    const description = body.description !== undefined ? (body.description?.trim() || null) : undefined;
    const type = body.type;
    const status = body.status;

    if (name !== undefined || shortName !== undefined) {
      const existingUnit = await prisma.unit.findFirst({
        where: {
          id: { not: id },
          OR: isAdmin ? [
            { name: name || unit.name, isGlobal: true },
            { shortName: shortName || unit.shortName, isGlobal: true }
          ] : [
            { name: name || unit.name, isGlobal: true },
            { name: name || unit.name, shopId: auth.payload.shopId },
            { shortName: shortName || unit.shortName, isGlobal: true },
            { shortName: shortName || unit.shortName, shopId: auth.payload.shopId }
          ]
        },
      });

      if (existingUnit) {
        return response.status(409).json({ message: "Unit name or short name already exists." });
      }
    }

    const updated = await prisma.unit.update({
      where: { id },
      data: {
        name: name !== undefined ? name : undefined,
        shortName: shortName !== undefined ? shortName : undefined,
        type: type !== undefined ? type : undefined,
        description: description !== undefined ? description : undefined,
        status: status !== undefined ? status : undefined,
      },
    });

    return response.json({
      message: "Unit updated successfully.",
      unit: serializeUnit(updated),
    });
  } catch (error) {
    console.error("Failed to update unit.", error);
    return response.status(500).json({ message: "Failed to update unit." });
  }
});

router.delete("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const { id } = request.params;
    const unit = await prisma.unit.findUnique({
      where: { id },
      include: {
        _count: {
          select: {
            masterProducts: true,
          },
        },
      },
    });

    if (!unit) {
      return response.status(404).json({ message: "Unit not found." });
    }

    if (unit._count.masterProducts > 0) {
      return response.status(409).json({ message: "Unit is in use by products and cannot be deleted." });
    }

    await prisma.unit.delete({
      where: { id },
    });

    return response.json({
      message: "Unit deleted successfully.",
    });
  } catch (error) {
    console.error("Failed to delete unit.", error);
    return response.status(500).json({ message: "Failed to delete unit." });
  }
});

router.post("/:id/approve", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
      return response.status(403).json({ message: "Only administrators can approve master units." });
    }

    const { id } = request.params;
    const unit = await prisma.unit.findUnique({
      where: { id },
    });

    if (!unit) {
      return response.status(404).json({ message: "Unit not found." });
    }

    const updated = await prisma.unit.update({
      where: { id },
      data: {
        isGlobal: true,
        isApproved: true,
        shopId: null,
      },
    });

    return response.json({
      message: "Unit approved and elevated to global master data successfully.",
      unit: serializeUnit(updated),
    });
  } catch (error) {
    console.error("Failed to approve unit.", error);
    return response.status(500).json({ message: "Failed to approve unit." });
  }
});

export default router;
