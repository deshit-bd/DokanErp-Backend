import { ConflictError, NotFoundError, ValidationError } from "@domain/shared/app-error";

export class CategoryNameRequiredError extends ValidationError {
  constructor() {
    super("Category name is required.");
  }
}

export class DuplicateCategoryNameError extends ConflictError {
  constructor() {
    super("Category name already exists.");
  }
}

export class CategoryNotFoundError extends NotFoundError {
  constructor() {
    super("Category not found.");
  }
}

export class CategoryHasProductsError extends ConflictError {
  constructor() {
    super("Category has products, so it was archived instead of deleted.");
  }
}
