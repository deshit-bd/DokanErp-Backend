import { Router } from "express";

import { moneyBoxController } from "../controllers/money-box.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware, requireRole } from "../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware, requireRole("SUPER_ADMIN", "ADMIN"));

router.get("/", asyncHandler(moneyBoxController.list));
router.post("/", asyncHandler(moneyBoxController.create));
router.put("/:id", asyncHandler(moneyBoxController.update));

export default router;
