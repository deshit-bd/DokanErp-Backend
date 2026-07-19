import { ForbiddenError, NotFoundError, ValidationError } from "@domain/shared/app-error";

export class InvalidAppScopeError extends ForbiddenError {
  constructor() {
    super("Invalid application scope.");
  }
}

export class OwnerOnlyError extends ForbiddenError {
  constructor(message = "Only shop owners can manage quick setup.") {
    super(message);
  }
}

export class ShopNotFoundError extends NotFoundError {
  constructor() {
    super("Shop not found.");
  }
}

export { ForbiddenError, ValidationError };
