import { ConflictError, NotFoundError, ValidationError } from "@domain/shared/app-error";

export class BankAccountFieldsRequiredError extends ValidationError {
  constructor() {
    super("Shop, account name, bank name, account number, and account type are required.");
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

export class BankAccountNotFoundError extends NotFoundError {
  constructor() {
    super("Bank account not found.");
  }
}

export class DuplicateBankAccountError extends ConflictError {
  constructor() {
    super("A bank account with this bank and account number already exists.");
  }
}
