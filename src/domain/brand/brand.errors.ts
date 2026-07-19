import { ConflictError, NotFoundError, ValidationError } from "@domain/shared/app-error";

export class BrandNameRequiredError extends ValidationError {
  constructor() {
    super("Brand name is required.");
  }
}

export class DuplicateBrandNameError extends ConflictError {
  constructor() {
    super("Brand name already exists.");
  }
}

export class BrandNotFoundError extends NotFoundError {
  constructor() {
    super("Brand not found.");
  }
}

export class BrandHasProductsError extends ConflictError {
  constructor() {
    super("Brand has products, so it was archived instead of deleted.");
  }
}

export class InvalidBrandIdsError extends ValidationError {
  constructor() {
    super("Invalid or empty brand IDs.");
  }
}
