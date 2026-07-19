import { Router } from "express";

import { customerController } from "../controllers/customer.controller";
import { asyncHandler } from "../middleware/async-handler";

const router = Router();

// NOTE: no router-wide `authMiddleware` — see customer.controller.ts's
// comment for why (dual-mode finance/plain views, and two fully
// unauthenticated endpoints in the original).
router.get("/", asyncHandler(customerController.list));
router.post("/", asyncHandler(customerController.create));

router.get("/sales", asyncHandler(customerController.listShopSales));
router.get("/sales/closing-summary", asyncHandler(customerController.getSalesClosingSummary));
router.get("/sales/:saleId", asyncHandler(customerController.getSale));
router.post("/sales/:saleId/cancel", asyncHandler(customerController.cancelSale));

router.post("/send-due-otp", asyncHandler(customerController.sendDueOtp));
router.post("/verify-due-otp", asyncHandler(customerController.verifyDueOtp));

router.post("/sales", asyncHandler(customerController.createSale));

router.get("/:id/sales", asyncHandler(customerController.listCustomerSales));
router.post("/:id/payments", asyncHandler(customerController.createPayment));
router.get("/:id/ledger", asyncHandler(customerController.getLedger));
router.get("/:id", asyncHandler(customerController.getOne));

export default router;
