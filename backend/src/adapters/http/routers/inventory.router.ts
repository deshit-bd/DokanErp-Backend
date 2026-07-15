import { Router } from "express";

import { inventoryController } from "../controllers/inventory.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware);

router.get("/mode", asyncHandler(inventoryController.getMode));
router.post("/mode", asyncHandler(inventoryController.saveMode));
router.get("/dashboard", asyncHandler(inventoryController.getDashboard));
router.get("/attention", asyncHandler(inventoryController.getAttention));
router.get("/general-store", asyncHandler(inventoryController.getGeneralStore));
router.get("/stock-movements", asyncHandler(inventoryController.getStockMovements));
router.post("/stock-movements", asyncHandler(inventoryController.addStockMovement));
router.get("/layout-tree", asyncHandler(inventoryController.getLayoutTree));
router.get("/zones", asyncHandler(inventoryController.listZones));
router.post("/zones", asyncHandler(inventoryController.createZone));
router.get("/racks", asyncHandler(inventoryController.listRacks));
router.post("/racks", asyncHandler(inventoryController.createRack));
router.get("/shelves", asyncHandler(inventoryController.listShelves));
router.get("/bins", asyncHandler(inventoryController.listBins));
router.post("/bins", asyncHandler(inventoryController.createBin));
router.post("/placements", asyncHandler(inventoryController.createPlacements));
router.patch("/zones/:id", asyncHandler(inventoryController.updateZone));
router.delete("/zones/:id", asyncHandler(inventoryController.deleteZone));
router.patch("/racks/:id", asyncHandler(inventoryController.updateRack));
router.delete("/racks/:id", asyncHandler(inventoryController.deleteRack));
router.post("/shelves", asyncHandler(inventoryController.createShelf));
router.patch("/shelves/:id", asyncHandler(inventoryController.updateShelf));
router.delete("/shelves/:id", asyncHandler(inventoryController.deleteShelf));
router.patch("/bins/:id", asyncHandler(inventoryController.updateBin));
router.delete("/bins/:id", asyncHandler(inventoryController.deleteBin));

export default router;
