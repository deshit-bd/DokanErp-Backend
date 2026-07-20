import type { Request, Response } from "express";

import { AppError, InternalError, ServiceUnavailableError } from "@domain/shared/app-error";
import { ApproveUnitUseCase } from "@application/unit/use-cases/approve-unit.use-case";
import { CreateUnitUseCase } from "@application/unit/use-cases/create-unit.use-case";
import { DeleteUnitUseCase } from "@application/unit/use-cases/delete-unit.use-case";
import { ListUnitsUseCase } from "@application/unit/use-cases/list-units.use-case";
import { UpdateUnitUseCase } from "@application/unit/use-cases/update-unit.use-case";

import { PrismaUnitRepository } from "../../persistence/prisma/unit.repository";
import { toUnitDto } from "../presenters/unit.presenter";

const unitRepository = new PrismaUnitRepository();
const listUnitsUseCase = new ListUnitsUseCase(unitRepository);
const createUnitUseCase = new CreateUnitUseCase(unitRepository);
const updateUnitUseCase = new UpdateUnitUseCase(unitRepository);
const deleteUnitUseCase = new DeleteUnitUseCase(unitRepository);
const approveUnitUseCase = new ApproveUnitUseCase(unitRepository);

function isAdminRole(role: string) {
  return role === "SUPER_ADMIN" || role === "ADMIN";
}

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

export const unitController = {
  async list(request: Request, response: Response) {
    const context = request.context!;

    try {
      const { units, stats } = await listUnitsUseCase.execute({ isAdmin: isAdminRole(context.role), shopId: context.shopId });
      response.json({ stats, units: units.map(toUnitDto) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Units are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async create(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as { name?: string; shortName?: string; type?: any; description?: string | null; status?: any };

    try {
      const unit = await createUnitUseCase.execute({
        name: body.name,
        shortName: body.shortName,
        type: body.type,
        description: body.description,
        status: body.status,
        isAdmin: isAdminRole(context.role),
        shopId: context.shopId,
      });

      response.status(201).json({ message: "Unit created successfully.", unit: toUnitDto(unit) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Unit could not be saved because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async update(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as { name?: string; shortName?: string; type?: any; description?: string | null; status?: any };

    try {
      const unit = await updateUnitUseCase.execute({
        id: String(request.params.id),
        name: body.name,
        shortName: body.shortName,
        type: body.type,
        description: body.description,
        status: body.status,
        isAdmin: isAdminRole(context.role),
        shopId: context.shopId,
      });

      response.json({ message: "Unit updated successfully.", unit: toUnitDto(unit) });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to update unit."));
    }
  },

  async remove(request: Request, response: Response) {
    try {
      await deleteUnitUseCase.execute(String(request.params.id));
      response.json({ message: "Unit deleted successfully." });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to delete unit."));
    }
  },

  async approve(request: Request, response: Response) {
    try {
      const unit = await approveUnitUseCase.execute(String(request.params.id));
      response.json({ message: "Unit approved and elevated to global master data successfully.", unit: toUnitDto(unit) });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to approve unit."));
    }
  },
};
