import { ConflictError, ForbiddenError, NotFoundError, ValidationError } from "@domain/shared/app-error";

export class UnitNameRequiredError extends ValidationError {
  constructor() {
    super("Unit name is required.");
  }
}

export class UnitShortNameRequiredError extends ValidationError {
  constructor() {
    super("Short name is required.");
  }
}

export class UnitTypeRequiredError extends ValidationError {
  constructor() {
    super("Unit type is required.");
  }
}

export class UnitStatusInvalidError extends ValidationError {
  constructor() {
    super("Unit status is invalid.");
  }
}

export class DuplicateUnitFieldError extends ConflictError {
  constructor(field: "Unit name" | "Short name") {
    super(`${field} already exists.`);
  }
}

export class DuplicateUnitFieldsError extends ConflictError {
  constructor() {
    super("Unit name or short name already exists.");
  }
}

export class UnitNotFoundError extends NotFoundError {
  constructor() {
    super("Unit not found.");
  }
}

export class UnitInUseError extends ConflictError {
  constructor() {
    super("Unit is in use by products and cannot be deleted.");
  }
}

export class UnitEditForbiddenError extends ForbiddenError {
  constructor() {
    super("You do not have permission to edit this unit.");
  }
}
