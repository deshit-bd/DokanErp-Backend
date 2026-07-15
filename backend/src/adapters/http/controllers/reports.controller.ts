import type { Request, Response } from "express";

import { AppError, ServiceUnavailableError } from "@domain/shared/app-error";
import { GetDailySalesReportUseCase } from "@application/reports/use-cases/get-daily-sales-report.use-case";
import { GetDashboardReportUseCase } from "@application/reports/use-cases/get-dashboard-report.use-case";
import { GetDuesSummaryReportUseCase } from "@application/reports/use-cases/get-dues-summary-report.use-case";
import { GetExpenseSummaryReportUseCase } from "@application/reports/use-cases/get-expense-summary-report.use-case";
import { GetProfitLossReportUseCase } from "@application/reports/use-cases/get-profit-loss-report.use-case";
import { GetPurchaseSummaryReportUseCase } from "@application/reports/use-cases/get-purchase-summary-report.use-case";
import { GetStockValueReportUseCase } from "@application/reports/use-cases/get-stock-value-report.use-case";
import { ResolveReportShopScopeUseCase } from "@application/reports/use-cases/resolve-report-shop-scope.use-case";
import type { ReportsRepository } from "@application/reports/ports/reports-repository.port";

import { PrismaReportsRepository } from "../../persistence/prisma/reports.repository";

const reportsRepository: ReportsRepository = new PrismaReportsRepository();

const resolveReportShopScopeUseCase = new ResolveReportShopScopeUseCase();
const getDashboardReportUseCase = new GetDashboardReportUseCase(reportsRepository);
const getDailySalesReportUseCase = new GetDailySalesReportUseCase(reportsRepository);
const getPurchaseSummaryReportUseCase = new GetPurchaseSummaryReportUseCase(reportsRepository);
const getDuesSummaryReportUseCase = new GetDuesSummaryReportUseCase(reportsRepository);
const getExpenseSummaryReportUseCase = new GetExpenseSummaryReportUseCase(reportsRepository);
const getProfitLossReportUseCase = new GetProfitLossReportUseCase(reportsRepository);
const getStockValueReportUseCase = new GetStockValueReportUseCase(reportsRepository);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

function resolveShopId(request: Request): string {
  const context = request.context!;
  const queryShopId = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";
  const bodyShopId = (request.body as { shopId?: string } | undefined)?.shopId?.trim();

  return resolveReportShopScopeUseCase.execute({
    role: context.role,
    authShopId: context.shopId,
    queryShopId,
    bodyShopId,
  });
}

export const reportsController = {
  async getDashboard(request: Request, response: Response) {
    try {
      const shopId = resolveShopId(request);
      const result = await getDashboardReportUseCase.execute(shopId, request.query);
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Reports dashboard could not be loaded."));
    }
  },

  async getDailySales(request: Request, response: Response) {
    try {
      const shopId = resolveShopId(request);
      const result = await getDailySalesReportUseCase.execute(shopId, request.query);
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Daily sales report could not be loaded."));
    }
  },

  async getPurchaseSummary(request: Request, response: Response) {
    try {
      const shopId = resolveShopId(request);
      const result = await getPurchaseSummaryReportUseCase.execute(shopId, request.query);
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Purchase summary report could not be loaded."));
    }
  },

  async getDuesSummary(request: Request, response: Response) {
    try {
      const shopId = resolveShopId(request);
      const result = await getDuesSummaryReportUseCase.execute(shopId, request.query);
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Due summary report could not be loaded."));
    }
  },

  async getExpenseSummary(request: Request, response: Response) {
    try {
      const shopId = resolveShopId(request);
      const result = await getExpenseSummaryReportUseCase.execute(shopId, request.query);
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Expense summary report could not be loaded."));
    }
  },

  async getProfitLoss(request: Request, response: Response) {
    try {
      const shopId = resolveShopId(request);
      const result = await getProfitLossReportUseCase.execute(shopId, request.query);
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Profit-loss report could not be loaded."));
    }
  },

  async getStockValue(request: Request, response: Response) {
    try {
      const shopId = resolveShopId(request);
      const result = await getStockValueReportUseCase.execute(shopId);
      response.json(result);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Stock value report could not be loaded."));
    }
  },
};
