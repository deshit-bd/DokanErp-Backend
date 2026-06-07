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

  if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
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

    const units = await prisma.unit.findMany({
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

    const existingUnit = await prisma.unit.findFirst({
      where: {
        OR: [{ name }, { shortName }],
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

export default router;
