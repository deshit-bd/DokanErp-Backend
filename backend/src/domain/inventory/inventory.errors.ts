import { ConflictError, ForbiddenError, NotFoundError, ServiceUnavailableError, ValidationError } from "@domain/shared/app-error";

export class InventoryAccessForbiddenError extends ForbiddenError {
  constructor() {
    super("Only shop owners can manage inventory layouts.");
  }
}

export class InventoryShopNotFoundError extends NotFoundError {
  constructor() {
    super("Shop not found.");
  }
}

export class ProductIdRequiredError extends ValidationError {
  constructor() {
    super("product_id is required.");
  }
}

export class ProductNotFoundInShopError extends NotFoundError {
  constructor() {
    super("Product not found in this shop.");
  }
}

export class InvalidStockAdjustmentTypeError extends ValidationError {
  constructor() {
    super("type must be ADD or DAMAGE.");
  }
}

export class InvalidStockAdjustmentQuantityError extends ValidationError {
  constructor() {
    super("quantity must be a positive number.");
  }
}

export class InsufficientStockError extends ValidationError {
  constructor() {
    super("Cannot reduce more than available stock.");
  }
}

export class ZoneNameRequiredError extends ValidationError {
  constructor() {
    super("Zone name is required.");
  }
}

export class DuplicateZoneNameError extends ConflictError {
  constructor() {
    super("A zone with this name already exists.");
  }
}

export class ZoneNotFoundError extends NotFoundError {
  constructor() {
    super("Zone not found.");
  }
}

export class RackFieldsRequiredError extends ValidationError {
  constructor() {
    super("zoneId and rack name are required.");
  }
}

export class RackAutoGenerateFieldsInvalidError extends ValidationError {
  constructor() {
    super("shelfCount and binsPerShelf must be greater than 0 when autoGenerate is true.");
  }
}

export class RackNotFoundError extends NotFoundError {
  constructor() {
    super("Rack not found.");
  }
}

export class ShelfFieldsRequiredError extends ValidationError {
  constructor() {
    super("zoneId, rackId, and shelf name are required.");
  }
}

export class ShelfNotFoundError extends NotFoundError {
  constructor() {
    super("Shelf not found.");
  }
}

export class ShelfNotFoundForLocationError extends NotFoundError {
  constructor() {
    super("Shelf not found for the provided location.");
  }
}

export class BinFieldsRequiredError extends ValidationError {
  constructor() {
    super("zoneId, rackId, shelfId, and code are required.");
  }
}

export class BinNotFoundError extends NotFoundError {
  constructor() {
    super("Bin not found.");
  }
}

export class PlacementItemsRequiredError extends ValidationError {
  constructor() {
    super("At least one placement item is required.");
  }
}

export class PlacementItemInvalidError extends ValidationError {
  constructor() {
    super("Each placement requires product, quantity, zone, rack, shelf, and bin.");
  }
}

// NOTE: the original route wrapped the entire placement transaction in a
// try/catch that responded 503 with the raw thrown error's message for
// *any* failure inside the transaction, including "not found" cases. That
// quirk (503, not 404/400, for these two) is preserved deliberately here —
// see CLAUDE.md's inventory migration notes.
export class PlacementBinNotFoundError extends ServiceUnavailableError {
  constructor() {
    super("Selected bin was not found in this shop location.");
  }
}

export class PlacementPurchaseItemNotFoundError extends ServiceUnavailableError {
  constructor() {
    super("Purchase item was not found for this shop.");
  }
}
