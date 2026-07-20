import { ForbiddenError, ValidationError } from "@domain/shared/app-error";

export class ReportsAccessForbiddenError extends ForbiddenError {
  constructor() {
    super("You do not have permission to view reports.");
  }
}

export class ReportShopIdRequiredError extends ValidationError {
  constructor() {
    super("shopId is required for report operations.");
  }
}

export class ReportShopScopeForbiddenError extends ForbiddenError {
  constructor() {
    super("You can only view reports for your own shop.");
  }
}

export class InvalidPurchaseSummaryDateRangeError extends ValidationError {
  constructor() {
    super("Invalid purchase summary date range.");
  }
}

export class InvalidCustomDateRangeError extends ValidationError {
  constructor() {
    super("Invalid custom date range.");
  }
}
