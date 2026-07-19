import type { Request, Response } from "express";

import type { ExpenseSummaryRange } from "@domain/expense/expense.entity";
import { AppError, ServiceUnavailableError } from "@domain/shared/app-error";
import { CreateExpenseUseCase } from "@application/expense/use-cases/create-expense.use-case";
import { DeleteExpenseUseCase } from "@application/expense/use-cases/delete-expense.use-case";
import { GetExpenseSummaryUseCase } from "@application/expense/use-cases/get-expense-summary.use-case";
import { ListExpensesUseCase } from "@application/expense/use-cases/list-expenses.use-case";
import { ResolveExpenseShopScopeUseCase } from "@application/expense/use-cases/resolve-expense-shop-scope.use-case";
import { UpdateExpenseUseCase } from "@application/expense/use-cases/update-expense.use-case";

import { PrismaExpenseRepository } from "../../persistence/prisma/expense.repository";
import { toExpenseDto } from "../presenters/expense.presenter";

const expenseRepository = new PrismaExpenseRepository();
const resolveExpenseShopScopeUseCase = new ResolveExpenseShopScopeUseCase(expenseRepository);
const getExpenseSummaryUseCase = new GetExpenseSummaryUseCase(expenseRepository);
const listExpensesUseCase = new ListExpensesUseCase(expenseRepository);
const createExpenseUseCase = new CreateExpenseUseCase(expenseRepository);
const updateExpenseUseCase = new UpdateExpenseUseCase(expenseRepository);
const deleteExpenseUseCase = new DeleteExpenseUseCase(expenseRepository);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

function normalizeText(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function requestedShopId(request: Request): string | undefined {
  const query = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";
  const body = (request.body as { shopId?: string } | undefined)?.shopId?.trim();
  return query || body || undefined;
}

export const expenseController = {
  async summary(request: Request, response: Response) {
    const context = request.context!;

    try {
      const shop = await resolveExpenseShopScopeUseCase.execute({
        role: context.role,
        authShopId: context.shopId,
        requestedShopId: requestedShopId(request),
        mode: "report",
      });

      const rangeParam = normalizeText(request.query.range).toLowerCase() || "month";
      const range: ExpenseSummaryRange = ["today", "week", "month", "year", "all"].includes(rangeParam) ? (rangeParam as ExpenseSummaryRange) : "month";

      const result = await getExpenseSummaryUseCase.execute({
        shop,
        range,
        from: normalizeText(request.query.from) || undefined,
        to: normalizeText(request.query.to) || undefined,
        limit: request.query.limit ? Number(request.query.limit) : undefined,
      });

      response.json({
        ...result,
        expenses: result.expenses.map(toExpenseDto),
        recentExpenses: result.recentExpenses.map(toExpenseDto),
      });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Expense summary could not be loaded right now."));
    }
  },

  async list(request: Request, response: Response) {
    const context = request.context!;

    try {
      const shop = await resolveExpenseShopScopeUseCase.execute({
        role: context.role,
        authShopId: context.shopId,
        requestedShopId: requestedShopId(request),
        mode: "manage",
      });

      const period = typeof request.query.period === "string" ? request.query.period : undefined;
      const result = await listExpensesUseCase.execute(shop, period);

      response.json({ ...result, expenses: result.expenses.map(toExpenseDto) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Expenses could not be loaded right now."));
    }
  },

  async create(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as any;

    try {
      const shop = await resolveExpenseShopScopeUseCase.execute({
        role: context.role,
        authShopId: context.shopId,
        requestedShopId: requestedShopId(request),
        mode: "manage",
      });

      const expense = await createExpenseUseCase.execute({
        shopId: shop.id,
        category: body.category,
        amount: body.amount,
        paymentMethod: body.paymentMethod ?? body.payment_method,
        title: body.title ?? body.description,
        note: body.note,
        expenseDate: body.expenseDate ?? body.date,
        moneyBoxId: body.moneyBoxId ?? body.money_box_id,
        bankAccountId: body.bankAccountId ?? body.bank_account_id,
      });

      response.status(201).json({ message: "Expense recorded successfully.", expense: toExpenseDto(expense) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Expense could not be recorded right now."));
    }
  },

  async update(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as any;

    try {
      const shop = await resolveExpenseShopScopeUseCase.execute({
        role: context.role,
        authShopId: context.shopId,
        requestedShopId: requestedShopId(request),
        mode: "manage",
      });

      const expense = await updateExpenseUseCase.execute({
        id: String(request.params.id),
        shopId: shop.id,
        category: body.category,
        amount: body.amount,
        paymentMethod: body.paymentMethod ?? body.payment_method,
        title: body.title ?? body.description,
        note: body.note,
        expenseDate: body.expenseDate ?? body.date,
        status: body.status,
        moneyBoxId: body.moneyBoxId ?? body.money_box_id,
        bankAccountId: body.bankAccountId ?? body.bank_account_id,
      });

      response.json({ message: "Expense updated successfully.", expense: toExpenseDto(expense) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Expense could not be updated right now."));
    }
  },

  async remove(request: Request, response: Response) {
    const context = request.context!;

    try {
      const shop = await resolveExpenseShopScopeUseCase.execute({
        role: context.role,
        authShopId: context.shopId,
        requestedShopId: requestedShopId(request),
        mode: "manage",
      });

      await deleteExpenseUseCase.execute(String(request.params.id), shop.id);
      response.status(204).send();
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Expense could not be deleted right now."));
    }
  },
};
