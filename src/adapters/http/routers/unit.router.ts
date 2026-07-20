import { Router } from "express";

import { unitController } from "../controllers/unit.controller";
import { CreateUnitDto, UpdateUnitDto } from "../dto/unit.dto";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware, requireRole } from "../middleware/auth.middleware";
import { validate } from "../middleware/validate-request.middleware";

const router = Router();

const requireUnitManager = requireRole("SUPER_ADMIN", "ADMIN", "SHOP_OWNER");
const requireAdmin = requireRole("SUPER_ADMIN", "ADMIN");

router.use(authMiddleware);

router.get("/", requireUnitManager, asyncHandler(unitController.list));
router.post("/", requireUnitManager, validate({ body: CreateUnitDto }), asyncHandler(unitController.create));
router.patch("/:id", requireUnitManager, validate({ body: UpdateUnitDto }), asyncHandler(unitController.update));
router.delete("/:id", requireUnitManager, asyncHandler(unitController.remove));
router.post("/:id/approve", requireAdmin, asyncHandler(unitController.approve));

export default router;
