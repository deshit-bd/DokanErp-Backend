import { Router } from "express";

import { supplierController } from "../controllers/supplier.controller";
import { asyncHandler } from "../middleware/async-handler";

const router = Router();

// NOTE: no router-wide `authMiddleware` here — see supplier.controller.ts's
// comment on why this module bridges to `auth/current-user.ts` per-endpoint
// instead (heterogeneous/conditional auth requirements, including two
// endpoints with no auth requirement at all in the original).
router.post("/send-due-otp", asyncHandler(supplierController.sendDueOtp));
router.post("/verify-due-otp", asyncHandler(supplierController.verifyDueOtp));

router.get("/", asyncHandler(supplierController.list));
router.post("/", asyncHandler(supplierController.create));
router.get("/:id", asyncHandler(supplierController.getOne));
router.put("/:id", asyncHandler(supplierController.update));
router.delete("/:id", asyncHandler(supplierController.remove));
router.patch("/:id/status", asyncHandler(supplierController.updateStatus));
router.get("/:id/dues", asyncHandler(supplierController.getDues));
router.get("/:id/ledger", asyncHandler(supplierController.getLedger));
router.post("/:id/payments", asyncHandler(supplierController.createPayment));
router.get("/:id/payments", asyncHandler(supplierController.listPayments));
router.get("/:id/purchases", asyncHandler(supplierController.listPurchases));

export default router;
