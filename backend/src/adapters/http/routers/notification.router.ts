import { Router } from "express";

import { notificationController } from "../controllers/notification.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

// Deliberately unauthenticated, matching the original route exactly (a
// testing/dev utility endpoint) — must be registered before the blanket
// authMiddleware below.
router.get("/send-test-dummies-unauth", asyncHandler(notificationController.sendTestDummiesUnauth));

router.use(authMiddleware);

router.get("/settings", asyncHandler(notificationController.getSettings));
router.put("/settings", asyncHandler(notificationController.updateSettings));
router.get("/send-test-dummies", asyncHandler(notificationController.sendTestDummies));
router.get("/", asyncHandler(notificationController.list));
router.post("/", asyncHandler(notificationController.create));
router.put("/read", asyncHandler(notificationController.markRead));
router.delete("/", asyncHandler(notificationController.remove));
router.patch("/:id/read", asyncHandler(notificationController.markSingleRead));
router.post("/read-all", asyncHandler(notificationController.markAllRead));
router.delete("/:id", asyncHandler(notificationController.removeSingle));

export default router;
