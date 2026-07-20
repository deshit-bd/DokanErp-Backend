import { Router } from "express";

import { bankAccountController } from "../controllers/bank-account.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware, requireRole } from "../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware, requireRole("SUPER_ADMIN", "ADMIN"));

router.get("/", asyncHandler(bankAccountController.list));
router.post("/", asyncHandler(bankAccountController.create));
router.put("/:id", asyncHandler(bankAccountController.update));

export default router;
