import type { Request, Response } from "express";

import { AppError, ServiceUnavailableError } from "@domain/shared/app-error";
import { CreateBankAccountUseCase } from "@application/bank-account/use-cases/create-bank-account.use-case";
import { ListBankAccountsUseCase } from "@application/bank-account/use-cases/list-bank-accounts.use-case";
import { UpdateBankAccountUseCase } from "@application/bank-account/use-cases/update-bank-account.use-case";

import { PrismaBankAccountRepository } from "../../persistence/prisma/bank-account.repository";
import { toBankAccountDto } from "../presenters/bank-account.presenter";

const bankAccountRepository = new PrismaBankAccountRepository();
const listBankAccountsUseCase = new ListBankAccountsUseCase(bankAccountRepository);
const createBankAccountUseCase = new CreateBankAccountUseCase(bankAccountRepository);
const updateBankAccountUseCase = new UpdateBankAccountUseCase(bankAccountRepository);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

export const bankAccountController = {
  async list(request: Request, response: Response) {
    try {
      const search = typeof request.query.search === "string" ? request.query.search.trim() : "";
      const shopId = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";
      const bankName = typeof request.query.bankName === "string" ? request.query.bankName.trim() : "";
      const status = typeof request.query.status === "string" ? request.query.status.trim().toUpperCase() : "";

      const result = await listBankAccountsUseCase.execute({ search, shopId, bankName, status });

      response.json({ stats: result.stats, banks: result.banks, bankAccounts: result.bankAccounts.map(toBankAccountDto) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Bank accounts are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async create(request: Request, response: Response) {
    const body = request.body as any;

    try {
      const bankAccount = await createBankAccountUseCase.execute({
        shopId: body.shopId,
        accountName: body.accountName,
        bankName: body.bankName,
        branchName: body.branchName,
        accountNumber: body.accountNumber,
        accountType: body.accountType,
        openingBalance: body.openingBalance,
        currency: body.currency,
        status: body.status,
        isDefault: body.isDefault,
        notes: body.notes,
      });

      response.status(201).json({ message: "Bank account created successfully.", bankAccount: toBankAccountDto(bankAccount) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Bank account could not be created because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },

  async update(request: Request, response: Response) {
    const body = request.body as any;

    try {
      const bankAccount = await updateBankAccountUseCase.execute({
        id: String(request.params.id),
        shopId: body.shopId,
        accountName: body.accountName,
        bankName: body.bankName,
        branchName: body.branchName,
        accountNumber: body.accountNumber,
        accountType: body.accountType,
        openingBalance: body.openingBalance,
        currency: body.currency,
        status: body.status,
        isDefault: body.isDefault,
        notes: body.notes,
      });

      response.json({ message: "Bank account updated successfully.", bankAccount: toBankAccountDto(bankAccount) });
    } catch (error) {
      rethrowOr(
        error,
        new ServiceUnavailableError(
          "Bank account could not be updated because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
        ),
      );
    }
  },
};
