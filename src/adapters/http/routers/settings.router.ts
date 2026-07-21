import { Router } from "express";

import { settingsController } from "../controllers/settings.controller";
import { asyncHandler } from "../middleware/async-handler";

const router = Router();

router.get("/store", asyncHandler(settingsController.getStoreSettings));
router.put("/store", asyncHandler(settingsController.updateStoreSettings));
router.post("/store/documents/:type", asyncHandler(settingsController.uploadStoreDocument));
router.get("/inventory", asyncHandler(settingsController.getInventorySettings));
router.patch("/inventory", asyncHandler(settingsController.updateInventorySettings));
router.get("/support-contact", asyncHandler(settingsController.getSupportContact));

export default router;
