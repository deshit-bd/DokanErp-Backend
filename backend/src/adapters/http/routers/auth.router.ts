import type { NextFunction, Request, Response } from "express";
import { Router } from "express";

import { ForbiddenError } from "@domain/shared/app-error";

import { authController } from "../controllers/auth.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware } from "../middleware/auth.middleware";
import { requireMobileScope } from "../middleware/require-mobile-scope.middleware";

const router = Router();

const mobileRegistrationOnly = requireMobileScope("This registration route is only available for the mobile app.");
const mobileOtpOnly = requireMobileScope("This OTP route is only available for the mobile app.");
const mobilePinOnly = requireMobileScope("This PIN route is only available for the mobile app.");
const mobileLoginOnly = requireMobileScope("This login route is only available for the mobile app.");

function requireShopOwnerOnMobile(request: Request, _response: Response, next: NextFunction) {
  const context = request.context!;
  if (context.appType !== "MOBILE" || context.role !== "SHOP_OWNER") {
    return next(new ForbiddenError("Only shop owners can add salesmen."));
  }
  next();
}

router.post("/check-mobile", asyncHandler(authController.checkMobile));
router.post("/register-owner", mobileRegistrationOnly, asyncHandler(authController.registerOwner));
router.post(
  "/register-salesman",
  mobileRegistrationOnly,
  authMiddleware,
  requireShopOwnerOnMobile,
  asyncHandler(authController.registerSalesman),
);
router.post("/register-owner-draft", mobileRegistrationOnly, asyncHandler(authController.registerOwnerDraft));
router.post("/send-otp", mobileOtpOnly, asyncHandler(authController.sendOtp));
router.post("/verify-otp", mobileOtpOnly, asyncHandler(authController.verifyOtp));
router.post("/setup-pin", mobilePinOnly, asyncHandler(authController.setupPin));
router.post("/complete-registration", mobileRegistrationOnly, asyncHandler(authController.completeRegistration));

router.post("/pre-login", mobileLoginOnly, asyncHandler(authController.preLoginOrSendOwnerOtp));
router.post("/owners-login", mobileLoginOnly, asyncHandler(authController.ownersLogin));
router.post("/salesmans-login", mobileLoginOnly, asyncHandler(authController.salesmansLogin));
router.post("/send-owner-login-otp", mobileLoginOnly, asyncHandler(authController.preLoginOrSendOwnerOtp));
router.post("/owners-login-otp", mobileLoginOnly, asyncHandler(authController.preLoginOrSendOwnerOtp));
router.post("/salesmans-login-otp", mobileLoginOnly, asyncHandler(authController.sendSalesmanLoginOtp));

router.post("/send-login-otp", mobileOtpOnly, asyncHandler(authController.sendLoginOtp));
router.post("/verify-login-otp", mobileOtpOnly, asyncHandler(authController.verifyLoginOtp));
router.post("/owners-verify-otp", mobileOtpOnly, asyncHandler(authController.verifyLoginOtp));
router.post("/salesmans-verify-otp", mobileOtpOnly, asyncHandler(authController.verifyLoginOtp));

router.post("/login", asyncHandler(authController.login));
router.post("/refresh", asyncHandler(authController.refresh));
router.post("/logout", asyncHandler(authController.logout));

router.get("/me", authMiddleware, asyncHandler(authController.getMe));
router.patch("/me", authMiddleware, asyncHandler(authController.updateProfile));
router.patch("/me/password", authMiddleware, asyncHandler(authController.changePassword));
router.patch("/me/avatar", authMiddleware, asyncHandler(authController.updateAvatar));

export default router;
