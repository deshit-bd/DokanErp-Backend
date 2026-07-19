import { Router } from "express";

import { productController } from "../controllers/product.controller";
import { asyncHandler } from "../middleware/async-handler";

const router = Router();

// NOTE: no router-wide `authMiddleware` — see product.controller.ts's
// comment for why (every endpoint branches on role within the handler
// itself, for the admin-catalog vs shop-product dual behavior).
router.get("/", asyncHandler(productController.list));
router.get("/:id/barcode.svg", asyncHandler(productController.getBarcodeSvg));
router.post("/", asyncHandler(productController.create));
router.put("/:id", asyncHandler(productController.update));
router.patch("/:id", asyncHandler(productController.update));
router.post("/:id/duplicate", asyncHandler(productController.duplicate));
router.get("/approval-requests", asyncHandler(productController.listApprovalRequests));
router.patch("/approval-requests/:id/approve", asyncHandler(productController.approveApprovalRequest));
router.patch("/approval-requests/:id/reject", asyncHandler(productController.rejectApprovalRequest));
router.patch("/:id/status", asyncHandler(productController.updateStatus));
router.delete("/:id", asyncHandler(productController.remove));

export default router;
