import { ForbiddenError, NotFoundError, ValidationError } from "@domain/shared/app-error";

export class ShopIdRequiredError extends ValidationError {
  constructor(context: "operations" | "report operations") {
    super(`shopId is required for expense ${context}.`);
  }
}

export class ShopScopeForbiddenError extends ForbiddenError {
  constructor(context: "expenses" | "expense reports") {
    super(`You can only access ${context} for your own shop.`);
  }
}

export class ShopNotFoundError extends NotFoundError {
  constructor() {
    super("Shop not found for the provided shopId/shopCode.");
  }
}

export class ExpenseCategoryRequiredError extends ValidationError {
  constructor() {
    super("Expense category is required.");
  }
}

export class InvalidExpenseAmountError extends ValidationError {
  constructor() {
    super("Expense amount must be a valid positive number.");
  }
}

export class InvalidPaymentMethodError extends ValidationError {
  constructor() {
    super("Payment method must be CASH, BKASH, NAGAD, or BANK.");
  }
}

export class InvalidExpenseDateError extends ValidationError {
  constructor() {
    super("Expense date must be a valid date.");
  }
}

export class ExpenseNotFoundError extends NotFoundError {
  constructor() {
    super("Expense not found.");
  }
}

export class MoneyBoxNotAvailableError extends ValidationError {
  constructor(type: "CASH" | "BKASH" | "NAGAD") {
    super(`No active ${type === "CASH" ? "cash" : type === "BKASH" ? "bKash" : "Nagad"} money box found for this shop.`);
  }
}

export class BankAccountNotAvailableError extends ValidationError {
  constructor() {
    super("No active bank account found for this shop.");
  }
}
