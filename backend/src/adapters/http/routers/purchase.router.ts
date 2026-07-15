import { Router } from "express";

import { purchaseController } from "../controllers/purchase.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware);

router.post("/", asyncHandler(purchaseController.create));
router.get("/", asyncHandler(purchaseController.list));
router.get("/:id", asyncHandler(purchaseController.getOne));
router.patch("/:id", asyncHandler(purchaseController.update));
router.post("/:id/payments", asyncHandler(purchaseController.recordPayment));
router.get("/:id/returns", asyncHandler(purchaseController.listReturns));
router.post("/:id/returns", asyncHandler(purchaseController.createReturn));
router.patch("/:id/approve", asyncHandler(purchaseController.approve));
router.patch("/:id/reject", asyncHandler(purchaseController.reject));
router.post("/:id/receive", asyncHandler(purchaseController.receive));
router.post("/:id/cancel", asyncHandler(purchaseController.cancel));

export default router;
