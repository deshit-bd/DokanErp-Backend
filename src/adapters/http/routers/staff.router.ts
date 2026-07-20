import { Router } from "express";

import { staffController } from "../controllers/staff.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware);

router.get("/me/performance", asyncHandler(staffController.getOwnPerformance));
router.get("/", asyncHandler(staffController.list));
router.get("/:staffUserId", asyncHandler(staffController.getOne));
router.patch("/:staffUserId/permissions", asyncHandler(staffController.updatePermissions));
router.post("/:staffUserId/permissions", asyncHandler(staffController.updatePermissions));
router.post("/:staffUserId/pin-reset", asyncHandler(staffController.resetPin));
router.patch("/:staffUserId/status", asyncHandler(staffController.updateStatus));

export default router;
