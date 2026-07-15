import { ConflictError, NotFoundError, ValidationError } from "@domain/shared/app-error";

export class TemplateCodeRequiredError extends ValidationError {
  constructor() {
    super("Template code is required.");
  }
}

export class TemplateNameRequiredError extends ValidationError {
  constructor() {
    super("Template name is required.");
  }
}

export class DuplicateTemplateFieldError extends ConflictError {
  constructor(field: "code" | "name") {
    super(field === "code" ? "Template code already exists." : "Template name already exists.");
  }
}

export class ProductTemplateNotFoundError extends NotFoundError {
  constructor() {
    super("Product template not found.");
  }
}

export class InvalidMasterProductsError extends ValidationError {
  constructor() {
    super("One or more selected master products do not exist.");
  }
}
