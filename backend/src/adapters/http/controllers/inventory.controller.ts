import type { Request, Response } from "express";

import { AppError, InternalError, ServiceUnavailableError } from "@domain/shared/app-error";
import { InventoryAccessForbiddenError, InventoryShopNotFoundError } from "@domain/inventory/inventory.errors";
import { AddStockMovementUseCase } from "@application/inventory/use-cases/add-stock-movement.use-case";
import { CreateBinUseCase } from "@application/inventory/use-cases/create-bin.use-case";
import { CreatePlacementsUseCase } from "@application/inventory/use-cases/create-placements.use-case";
import { CreateRackUseCase } from "@application/inventory/use-cases/create-rack.use-case";
import { CreateShelfUseCase } from "@application/inventory/use-cases/create-shelf.use-case";
import { CreateZoneUseCase } from "@application/inventory/use-cases/create-zone.use-case";
import { DeleteBinUseCase } from "@application/inventory/use-cases/delete-bin.use-case";
import { DeleteRackUseCase } from "@application/inventory/use-cases/delete-rack.use-case";
import { DeleteShelfUseCase } from "@application/inventory/use-cases/delete-shelf.use-case";
import { DeleteZoneUseCase } from "@application/inventory/use-cases/delete-zone.use-case";
import { GetGeneralStoreUseCase } from "@application/inventory/use-cases/get-general-store.use-case";
import { GetInventoryDashboardUseCase } from "@application/inventory/use-cases/get-inventory-dashboard.use-case";
import { GetInventoryModeUseCase } from "@application/inventory/use-cases/get-inventory-mode.use-case";
import { GetLayoutTreeUseCase } from "@application/inventory/use-cases/get-layout-tree.use-case";
import { GetStockMovementHistoryUseCase } from "@application/inventory/use-cases/get-stock-movement-history.use-case";
import { ListAttentionBinsUseCase } from "@application/inventory/use-cases/list-attention-bins.use-case";
import { ListBinsUseCase } from "@application/inventory/use-cases/list-bins.use-case";
import { ListRacksUseCase } from "@application/inventory/use-cases/list-racks.use-case";
import { ListShelvesUseCase } from "@application/inventory/use-cases/list-shelves.use-case";
import { ListZonesUseCase } from "@application/inventory/use-cases/list-zones.use-case";
import { SaveInventoryModeUseCase } from "@application/inventory/use-cases/save-inventory-mode.use-case";
import { UpdateBinUseCase } from "@application/inventory/use-cases/update-bin.use-case";
import { UpdateRackUseCase } from "@application/inventory/use-cases/update-rack.use-case";
import { UpdateShelfUseCase } from "@application/inventory/use-cases/update-shelf.use-case";
import { UpdateZoneUseCase } from "@application/inventory/use-cases/update-zone.use-case";
import type { InventoryRepository, ShopProductSummary } from "@application/inventory/ports/inventory-repository.port";
import { mapStockMovement } from "../../../utils/stock-movement";

import { PrismaInventoryRepository } from "../../persistence/prisma/inventory.repository";
import { createNotification } from "./notification.controller";
import { toBinDto, toLayoutTreeDto, toRackDto, toShelfDto, toZoneDto } from "../presenters/inventory.presenter";

const inventoryRepository: InventoryRepository = new PrismaInventoryRepository();

const getInventoryModeUseCase = new GetInventoryModeUseCase(inventoryRepository);
const saveInventoryModeUseCase = new SaveInventoryModeUseCase(inventoryRepository);
const getInventoryDashboardUseCase = new GetInventoryDashboardUseCase(inventoryRepository);
const listAttentionBinsUseCase = new ListAttentionBinsUseCase(inventoryRepository);
const getGeneralStoreUseCase = new GetGeneralStoreUseCase(inventoryRepository);
const getStockMovementHistoryUseCase = new GetStockMovementHistoryUseCase(inventoryRepository);
const addStockMovementUseCase = new AddStockMovementUseCase(inventoryRepository);
const getLayoutTreeUseCase = new GetLayoutTreeUseCase(inventoryRepository);
const listZonesUseCase = new ListZonesUseCase(inventoryRepository);
const createZoneUseCase = new CreateZoneUseCase(inventoryRepository);
const updateZoneUseCase = new UpdateZoneUseCase(inventoryRepository);
const deleteZoneUseCase = new DeleteZoneUseCase(inventoryRepository);
const listRacksUseCase = new ListRacksUseCase(inventoryRepository);
const createRackUseCase = new CreateRackUseCase(inventoryRepository);
const updateRackUseCase = new UpdateRackUseCase(inventoryRepository);
const deleteRackUseCase = new DeleteRackUseCase(inventoryRepository);
const listShelvesUseCase = new ListShelvesUseCase(inventoryRepository);
const createShelfUseCase = new CreateShelfUseCase(inventoryRepository);
const updateShelfUseCase = new UpdateShelfUseCase(inventoryRepository);
const deleteShelfUseCase = new DeleteShelfUseCase(inventoryRepository);
const listBinsUseCase = new ListBinsUseCase(inventoryRepository);
const createBinUseCase = new CreateBinUseCase(inventoryRepository);
const updateBinUseCase = new UpdateBinUseCase(inventoryRepository);
const deleteBinUseCase = new DeleteBinUseCase(inventoryRepository);
const createPlacementsUseCase = new CreatePlacementsUseCase(inventoryRepository);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

async function requireOwnerInventoryContext(request: Request) {
  const context = request.context!;

  if (!context?.shopId) {
    throw new InventoryAccessForbiddenError();
  }

  const shop = await inventoryRepository.findOwnerShop(context.shopId);
  if (!shop) {
    throw new InventoryShopNotFoundError();
  }

  return shop;
}

function mapShopProductResponse(updated: ShopProductSummary) {
  return {
    id: updated.source === "SHOP_LOCAL" ? updated.id : updated.masterProductId,
    shopProductId: updated.id,
    masterProductId: updated.masterProductId,
    sku: updated.masterProduct?.sku ?? updated.localBarcode ?? updated.id,
    name: updated.masterProduct?.name ?? updated.localName ?? "Unnamed product",
    packageSize: updated.masterProduct?.packageSize ?? updated.localUnit ?? updated.id,
    stock: Number(updated.openingStock ?? 0),
    salePrice: Number(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price ?? 0),
    purchasePrice: Number(updated.purchasePrice ?? updated.masterProduct?.price ?? 0),
  };
}

export const inventoryController = {
  async getMode(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const result = await getInventoryModeUseCase.execute(shop.id);
      response.json({ shop, ...result });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory mode could not be loaded right now."));
    }
  },

  async saveMode(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const body = request.body as { mode?: string };
      const setting = await saveInventoryModeUseCase.execute(shop.id, body.mode);
      response.json({ message: "Inventory mode saved successfully.", setting, configured: true });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory mode could not be saved right now."));
    }
  },

  async getDashboard(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const result = await getInventoryDashboardUseCase.execute(shop.id);
      response.json({ shop, ...result });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory dashboard could not be loaded right now."));
    }
  },

  async getAttention(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const bins = await listAttentionBinsUseCase.execute(shop.id);
      response.json({ shop, bins: bins.map(toBinDto) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory alerts could not be loaded right now."));
    }
  },

  async getGeneralStore(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const result = await getGeneralStoreUseCase.execute(shop.id);
      response.json({ shop, ...result });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("General inventory store could not be loaded right now."));
    }
  },

  async getStockMovements(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const result = await getStockMovementHistoryUseCase.execute(shop.id, request.query.product_id, request.query.limit);
      response.json({ shop, product: result.product, history: result.history.map(mapStockMovement) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Stock movement history could not be loaded right now."));
    }
  },

  async addStockMovement(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const context = request.context!;
      const body = request.body as {
        product_id?: string;
        quantity?: number | string;
        type?: string;
        reference?: string;
        note?: string;
        purchase_price?: number | string | null;
      };

      const { action, updated, movement } = await addStockMovementUseCase.execute({
        shopId: shop.id,
        createdByUserId: context.userId,
        productId: body.product_id,
        quantity: body.quantity,
        type: body.type,
        reference: body.reference,
        note: body.note,
        purchasePrice: body.purchase_price,
      });

      const productName = updated.masterProduct?.name ?? updated.localName ?? "Unnamed product";
      const currentStock = Number(updated.openingStock ?? 0);
      const lowStockLimit = Number(updated.lowStockLimit ?? 0);

      if (action === "ADD") {
        await createNotification(
          shop.id,
          "INVENTORY",
          "স্টক আপডেট হয়েছে",
          `পণ্য: ${productName} | নতুন স্টক: ${currentStock} টি যোগ করা হয়েছে।`,
        );
      }

      if (currentStock <= lowStockLimit) {
        await createNotification(
          shop.id,
          "INVENTORY",
          "কম স্টক সতর্কতা",
          `একটি পণ্যের (${productName}) স্টক নির্ধারিত সীমার (${lowStockLimit}) নিচে নেমে গেছে। বর্তমান স্টক: ${currentStock}`,
        );
      }

      response.json({
        message: action === "ADD" ? "Stock added successfully." : "Damaged stock removed successfully.",
        product: mapShopProductResponse(updated),
        movement: mapStockMovement(movement),
      });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Stock movement could not be saved right now."));
    }
  },

  async getLayoutTree(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const zones = await getLayoutTreeUseCase.execute(shop.id);
      response.json({ shop, zones: toLayoutTreeDto(zones) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Layout tree could not be loaded right now."));
    }
  },

  async listZones(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const zones = await listZonesUseCase.execute(shop.id);
      response.json({ shop, zones: zones.map(toZoneDto) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory zones could not be loaded right now."));
    }
  },

  async createZone(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const zone = await createZoneUseCase.execute(shop.id, request.body ?? {});
      response.status(201).json({ message: "Inventory zone created successfully.", zone: toZoneDto(zone) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory zone could not be created right now."));
    }
  },

  async updateZone(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const zone = await updateZoneUseCase.execute(shop.id, String(request.params.id), request.body ?? {});
      response.json({ message: "Zone updated successfully.", zone: toZoneDto(zone) });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to update zone."));
    }
  },

  async deleteZone(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      await deleteZoneUseCase.execute(shop.id, String(request.params.id));
      response.json({ message: "Zone deleted successfully." });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to delete zone."));
    }
  },

  async listRacks(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const zoneId = typeof request.query.zoneId === "string" ? request.query.zoneId.trim() : undefined;
      const racks = await listRacksUseCase.execute(shop.id, zoneId);
      response.json({ shop, racks: racks.map(toRackDto) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory racks could not be loaded right now."));
    }
  },

  async createRack(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const result = await createRackUseCase.execute(shop.id, request.body ?? {});
      response.status(201).json({
        message: "Inventory rack created successfully.",
        rack: toRackDto(result.rack),
        shelves: result.shelves.map(toShelfDto),
        bins: result.bins.map(toBinDto),
      });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory rack could not be created right now."));
    }
  },

  async updateRack(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const rack = await updateRackUseCase.execute(shop.id, String(request.params.id), request.body ?? {});
      response.json({ message: "Rack updated successfully.", rack: toRackDto(rack) });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to update rack."));
    }
  },

  async deleteRack(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      await deleteRackUseCase.execute(shop.id, String(request.params.id));
      response.json({ message: "Rack deleted successfully." });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to delete rack."));
    }
  },

  async listShelves(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const zoneId = typeof request.query.zoneId === "string" ? request.query.zoneId.trim() : undefined;
      const rackId = typeof request.query.rackId === "string" ? request.query.rackId.trim() : undefined;
      const shelves = await listShelvesUseCase.execute(shop.id, zoneId, rackId);
      response.json({ shop, shelves: shelves.map(toShelfDto) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory shelves could not be loaded right now."));
    }
  },

  async createShelf(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const shelf = await createShelfUseCase.execute(shop.id, request.body ?? {});
      response.status(201).json({ message: "Shelf created successfully.", shelf: toShelfDto(shelf) });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to create shelf."));
    }
  },

  async updateShelf(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const shelf = await updateShelfUseCase.execute(shop.id, String(request.params.id), request.body ?? {});
      response.json({ message: "Shelf updated successfully.", shelf: toShelfDto(shelf) });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to update shelf."));
    }
  },

  async deleteShelf(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      await deleteShelfUseCase.execute(shop.id, String(request.params.id));
      response.json({ message: "Shelf deleted successfully." });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to delete shelf."));
    }
  },

  async listBins(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const zoneId = typeof request.query.zoneId === "string" ? request.query.zoneId.trim() : undefined;
      const rackId = typeof request.query.rackId === "string" ? request.query.rackId.trim() : undefined;
      const shelfId = typeof request.query.shelfId === "string" ? request.query.shelfId.trim() : undefined;
      const bins = await listBinsUseCase.execute(shop.id, zoneId, rackId, shelfId);
      response.json({ shop, bins: bins.map(toBinDto) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory bins could not be loaded right now."));
    }
  },

  async createBin(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const bin = await createBinUseCase.execute(shop.id, request.body ?? {});
      response.status(201).json({ message: "Inventory bin created successfully.", bin: toBinDto(bin) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory bin could not be created right now."));
    }
  },

  async updateBin(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const bin = await updateBinUseCase.execute(shop.id, String(request.params.id), request.body ?? {});
      response.json({ message: "Bin updated successfully.", bin: toBinDto(bin) });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to update bin."));
    }
  },

  async deleteBin(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      await deleteBinUseCase.execute(shop.id, String(request.params.id));
      response.json({ message: "Bin deleted successfully." });
    } catch (error) {
      rethrowOr(error, new InternalError("Failed to delete bin."));
    }
  },

  async createPlacements(request: Request, response: Response) {
    try {
      const shop = await requireOwnerInventoryContext(request);
      const body = request.body as { items?: any[] };
      const placements = await createPlacementsUseCase.execute(shop.id, body.items);
      response.status(201).json({ message: "Purchase items assigned to inventory successfully.", placements });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Inventory placement could not be saved right now."));
    }
  },
};
