import type { Request, Response } from "express";

import { AppError, ServiceUnavailableError } from "@domain/shared/app-error";
import { CreateMoneyBoxUseCase } from "@application/money-box/use-cases/create-money-box.use-case";
import { ListMoneyBoxesUseCase } from "@application/money-box/use-cases/list-money-boxes.use-case";
import { UpdateMoneyBoxUseCase } from "@application/money-box/use-cases/update-money-box.use-case";

import { PrismaMoneyBoxRepository } from "../../persistence/prisma/money-box.repository";
import { toMoneyBoxDto } from "../presenters/money-box.presenter";

const moneyBoxRepository = new PrismaMoneyBoxRepository();
const listMoneyBoxesUseCase = new ListMoneyBoxesUseCase(moneyBoxRepository);
const createMoneyBoxUseCase = new CreateMoneyBoxUseCase(moneyBoxRepository);
const updateMoneyBoxUseCase = new UpdateMoneyBoxUseCase(moneyBoxRepository);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

export const moneyBoxController = {
  async list(request: Request, response: Response) {
    try {
      const search = typeof request.query.search === "string" ? request.query.search.trim() : "";
      const shopId = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";
      const status = typeof request.query.status === "string" ? request.query.status.trim().toUpperCase() : "";

      const result = await listMoneyBoxesUseCase.execute({ search, shopId, status });

      response.json({ stats: result.stats, moneyBoxes: result.moneyBoxes.map(toMoneyBoxDto) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Money boxes are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async create(request: Request, response: Response) {
    const body = request.body as any;

    try {
      const moneyBox = await createMoneyBoxUseCase.execute({
        shopId: body.shopId,
        boxName: body.boxName,
        code: body.code,
        type: body.type,
        openingBalance: body.openingBalance,
        details: body.details,
        status: body.status,
      });

      response.status(201).json({ message: "Money box created successfully.", moneyBox: toMoneyBoxDto(moneyBox) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Money box could not be created because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async update(request: Request, response: Response) {
    const body = request.body as any;

    try {
      const moneyBox = await updateMoneyBoxUseCase.execute({
        id: String(request.params.id),
        shopId: body.shopId,
        boxName: body.boxName,
        code: body.code,
        type: body.type,
        openingBalance: body.openingBalance,
        details: body.details,
        status: body.status,
      });

      response.json({ message: "Money box updated successfully.", moneyBox: toMoneyBoxDto(moneyBox) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Money box could not be updated right now."));
    }
  },
};
