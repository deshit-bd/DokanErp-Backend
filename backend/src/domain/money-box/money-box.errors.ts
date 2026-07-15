import { ConflictError, NotFoundError, ValidationError } from "@domain/shared/app-error";

export class ShopRequiredError extends ValidationError {
  constructor() {
    super("Shop is required.");
  }
}

export class MoneyBoxNameRequiredError extends ValidationError {
  constructor() {
    super("Money box name is required.");
  }
}

export class MoneyBoxCodeRequiredError extends ValidationError {
  constructor() {
    super("Money box code is required.");
  }
}

export class MoneyBoxTypeRequiredError extends ValidationError {
  constructor() {
    super("Money box type is required.");
  }
}

export class MoneyBoxFieldsRequiredError extends ValidationError {
  constructor() {
    super("Shop, name, code, and type are required.");
  }
}

export class InvalidOpeningBalanceError extends ValidationError {
  constructor() {
    super("Opening balance must be a valid number.");
  }
}

export class ShopNotFoundError extends NotFoundError {
  constructor() {
    super("Selected shop was not found.");
  }
}

export class MoneyBoxNotFoundError extends NotFoundError {
  constructor() {
    super("Money box not found.");
  }
}

export class DuplicateMoneyBoxCodeError extends ConflictError {
  constructor() {
    super("Money box code already exists.");
  }
}
