import type { Request, Response } from "express";
import type { AppType } from "@prisma/client";

import { PrismaAuthRepository } from "../../persistence/prisma/auth.repository";
import { StoreDocumentStorageAdapter } from "../../storage/store-document-storage.adapter";

import { CheckMobileAvailabilityUseCase } from "@application/auth/use-cases/check-mobile-availability.use-case";
import { RegisterOwnerUseCase } from "@application/auth/use-cases/register-owner.use-case";
import { RegisterSalesmanUseCase } from "@application/auth/use-cases/register-salesman.use-case";
import { CreateRegistrationDraftUseCase } from "@application/auth/use-cases/create-registration-draft.use-case";
import { SendRegistrationOtpUseCase } from "@application/auth/use-cases/send-registration-otp.use-case";
import { VerifyRegistrationOtpUseCase } from "@application/auth/use-cases/verify-registration-otp.use-case";
import { SetupRegistrationPinUseCase } from "@application/auth/use-cases/setup-registration-pin.use-case";
import { CompleteRegistrationUseCase } from "@application/auth/use-cases/complete-registration.use-case";
import { VerifyOwnerCredentialsUseCase } from "@application/auth/use-cases/verify-owner-credentials.use-case";
import { VerifySalesmanCredentialsUseCase } from "@application/auth/use-cases/verify-salesman-credentials.use-case";
import { SendOwnerLoginOtpUseCase } from "@application/auth/use-cases/send-owner-login-otp.use-case";
import { SendSalesmanLoginOtpUseCase } from "@application/auth/use-cases/send-salesman-login-otp.use-case";
import { SendLoginOtpUseCase } from "@application/auth/use-cases/send-login-otp.use-case";
import { VerifyLoginOtpUseCase } from "@application/auth/use-cases/verify-login-otp.use-case";
import { LoginUseCase } from "@application/auth/use-cases/login.use-case";
import { RefreshSessionUseCase } from "@application/auth/use-cases/refresh-session.use-case";
import { LogoutUseCase } from "@application/auth/use-cases/logout.use-case";
import { GetCurrentUserUseCase } from "@application/auth/use-cases/get-current-user.use-case";
import { UpdateProfileUseCase } from "@application/auth/use-cases/update-profile.use-case";
import { ChangePasswordUseCase } from "@application/auth/use-cases/change-password.use-case";
import { UpdateAvatarUseCase } from "@application/auth/use-cases/update-avatar.use-case";

import { ACCESS_TOKEN_TTL_SECONDS, REFRESH_TOKEN_COOKIE } from "../../../auth/constants";
import { parseCookies } from "../../../auth/cookies";
import { clearAuthCookies, setAccessCookie, setRefreshCookie } from "../../../auth/session";

const authRepository = new PrismaAuthRepository();
const documentStorage = new StoreDocumentStorageAdapter();

const checkMobileAvailabilityUseCase = new CheckMobileAvailabilityUseCase(authRepository);
const registerOwnerUseCase = new RegisterOwnerUseCase(authRepository, documentStorage);
const registerSalesmanUseCase = new RegisterSalesmanUseCase(authRepository);
const createRegistrationDraftUseCase = new CreateRegistrationDraftUseCase(authRepository);
const sendRegistrationOtpUseCase = new SendRegistrationOtpUseCase(authRepository);
const verifyRegistrationOtpUseCase = new VerifyRegistrationOtpUseCase(authRepository);
const setupRegistrationPinUseCase = new SetupRegistrationPinUseCase(authRepository);
const completeRegistrationUseCase = new CompleteRegistrationUseCase(authRepository);
const verifyOwnerCredentialsUseCase = new VerifyOwnerCredentialsUseCase(authRepository);
const verifySalesmanCredentialsUseCase = new VerifySalesmanCredentialsUseCase(authRepository);
const sendOwnerLoginOtpUseCase = new SendOwnerLoginOtpUseCase(authRepository);
const sendSalesmanLoginOtpUseCase = new SendSalesmanLoginOtpUseCase(authRepository);
const sendLoginOtpUseCase = new SendLoginOtpUseCase(authRepository);
const verifyLoginOtpUseCase = new VerifyLoginOtpUseCase(authRepository);
const loginUseCase = new LoginUseCase(authRepository);
const refreshSessionUseCase = new RefreshSessionUseCase(authRepository);
const logoutUseCase = new LogoutUseCase(authRepository);
const getCurrentUserUseCase = new GetCurrentUserUseCase(authRepository);
const updateProfileUseCase = new UpdateProfileUseCase(authRepository);
const changePasswordUseCase = new ChangePasswordUseCase(authRepository);
const updateAvatarUseCase = new UpdateAvatarUseCase(authRepository);

type ScopedRequest = Request & { apiClientAppType?: AppType };

function requestOrigin(request: Request): string {
  const protocol = request.protocol || "http";
  const host = request.get("host") || "localhost:4000";
  return `${protocol}://${host}`;
}

function shopIdFromBody(body: any): string | undefined {
  return body.shopId?.trim() || body.shop_id?.trim() || undefined;
}

export const authController = {
  async checkMobile(request: Request, response: Response) {
    const body = request.body as { mobile?: string; phone?: string };
    const result = await checkMobileAvailabilityUseCase.execute(body.mobile ?? body.phone);
    response.json(result);
  },

  async registerOwner(request: Request, response: Response) {
    const body = request.body as any;
    const result = await registerOwnerUseCase.execute({
      shopName: body.shopName,
      name: body.name,
      mobile: body.mobile,
      email: body.email,
      password: body.password,
      confirmPassword: body.confirmPassword,
      shopAddress: body.shopAddress,
      shopCategory: body.shopCategory,
      shopLocation: body.shopLocation,
      tradeLicenseNo: body.tradeLicenseNo,
      tinNo: body.tinNo,
      binNo: body.binNo,
      tradeLicenseFile: body.tradeLicenseFile,
      tinFile: body.tinFile,
      binFile: body.binFile,
      requestOrigin: requestOrigin(request),
    });

    response.status(201).json({
      message: "Shop owner registered successfully.",
      user: result.user,
      shop: result.shop,
    });
  },

  async registerSalesman(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as any;

    const result = await registerSalesmanUseCase.execute({
      ownerId: context.userId,
      ownerShopIdFromSession: context.shopId,
      shopId: body.shopId,
      name: body.name,
      mobile: body.mobile,
      email: body.email,
      password: body.password,
      pin: body.pin,
      permissions: body.permissions,
    });

    response.status(201).json({
      message: "Salesman registered successfully.",
      user: result.user,
      shop: result.shop,
      role: result.role,
      permissions: result.permissions,
      pinRequiredFromSettings: result.pinRequiredFromSettings,
    });
  },

  async registerOwnerDraft(request: Request, response: Response) {
    const body = request.body as any;
    const draft = await createRegistrationDraftUseCase.execute(body);

    response.status(201).json({
      message: "Registration draft created successfully.",
      registrationId: draft.id,
      draft,
    });
  },

  async sendOtp(request: Request, response: Response) {
    const body = request.body as any;
    const result = await sendRegistrationOtpUseCase.execute(body.mobile ?? body.phone, body.registrationId);

    response.json({ message: "OTP sent successfully.", ...result });
  },

  async verifyOtp(request: Request, response: Response) {
    const body = request.body as any;
    const result = await verifyRegistrationOtpUseCase.execute({
      registrationId: body.registrationId,
      mobile: body.mobile ?? body.phone,
      otp: body.otp ?? body.code,
    });

    response.json({
      message: "OTP verified successfully.",
      verified: true,
      registrationId: result.registrationId,
      ...(result.session ?? {}),
    });
  },

  async setupPin(request: Request, response: Response) {
    const body = request.body as any;
    const result = await setupRegistrationPinUseCase.execute(body.registrationId, body.pin, body.confirmPin);
    response.json({ message: "PIN set successfully.", registrationId: result.registrationId });
  },

  async completeRegistration(request: Request, response: Response) {
    const body = request.body as any;
    const { result, tokens } = await completeRegistrationUseCase.execute(body.registrationId);

    setAccessCookie(response, tokens.accessToken);
    setRefreshCookie(response, tokens.refreshToken);

    response.status(201).json({
      message: "Registration completed successfully.",
      user: result.user,
      shop: result.shop,
      role: "SHOP_OWNER",
      appType: "MOBILE",
      redirectTo: "/welcome",
    });
  },

  async preLoginOrSendOwnerOtp(request: Request, response: Response) {
    const body = request.body as any;
    const result = await sendOwnerLoginOtpUseCase.execute(body.mobile, body.password);
    response.json({ message: "Password verified. OTP sent successfully.", ...result, requiresOtp: true });
  },

  async ownersLogin(request: Request, response: Response) {
    const body = request.body as any;
    const { mobile, user, authContext } = await verifyOwnerCredentialsUseCase.execute(body.mobile, body.password);

    response.json({
      message: "Owner credentials verified successfully.",
      verified: true,
      requiresOtp: true,
      nextStep: "/app/api/auth/owners-login-otp",
      owner: { id: user.id, name: user.name, mobile },
      shop: authContext.shopId
        ? {
            id: authContext.shopId,
            shopCode: user.ownedShops.find((shop) => shop.id === authContext.shopId)?.shopCode ?? null,
            shopName: user.ownedShops.find((shop) => shop.id === authContext.shopId)?.shopName ?? null,
          }
        : null,
    });
  },

  async salesmansLogin(request: Request, response: Response) {
    const body = request.body as any;
    const { mobile, shopId, user } = await verifySalesmanCredentialsUseCase.execute(body.mobile, body.password, shopIdFromBody(body));

    response.json({
      message: "Salesman credentials verified successfully.",
      verified: true,
      requiresOtp: true,
      nextStep: "/app/api/auth/salesmans-login-otp",
      salesman: { id: user.id, name: user.name, mobile },
      shop: {
        id: shopId,
        shopCode: user.shopUsers.find((item) => item.shopId === shopId)?.shop.shopCode ?? null,
        shopName: user.shopUsers.find((item) => item.shopId === shopId)?.shop.shopName ?? null,
      },
    });
  },

  async sendSalesmanLoginOtp(request: Request, response: Response) {
    const body = request.body as any;
    const result = await sendSalesmanLoginOtpUseCase.execute(body.mobile, body.password, shopIdFromBody(body));
    response.json({ message: "Password verified. OTP sent successfully.", ...result, requiresOtp: true });
  },

  async sendLoginOtp(request: Request, response: Response) {
    const body = request.body as any;
    const result = await sendLoginOtpUseCase.execute(body.mobile);
    response.json({ message: "OTP sent successfully.", ...result });
  },

  async verifyLoginOtp(request: Request, response: Response) {
    const body = request.body as any;
    const result = await verifyLoginOtpUseCase.execute({
      loginRequestId: body.loginRequestId,
      mobile: body.mobile,
      otp: body.otp,
      rememberMe: body.rememberMe,
    });

    setAccessCookie(response, result.tokens.accessToken);
    setRefreshCookie(response, result.tokens.refreshToken, body.rememberMe === true || String(body.rememberMe) === "true");

    response.json({
      message: "Login successful.",
      authenticated: true,
      redirectTo: result.redirectTo,
      role: result.role,
      appType: "MOBILE",
      tokens: {
        access_token: result.tokens.accessToken,
        refresh_token: result.tokens.refreshToken,
        expires_in: ACCESS_TOKEN_TTL_SECONDS,
      },
      access_token: result.tokens.accessToken,
      refresh_token: result.tokens.refreshToken,
      expires_in: ACCESS_TOKEN_TTL_SECONDS,
      user: result.user,
      shop: result.shop,
    });
  },

  async login(request: Request, response: Response) {
    const body = request.body as any;
    const appType: AppType = body.appType ?? (request as ScopedRequest).apiClientAppType ?? "WEB";

    const result = await loginUseCase.execute({
      identity: body.identity ?? body.phone ?? body.mobile,
      password: body.password,
      requestedShopIdentifier: shopIdFromBody(body),
      appType,
      rememberMe: body.rememberMe,
    });

    const rememberMe = body.rememberMe === true || String(body.rememberMe) === "true";
    setAccessCookie(response, result.tokens.accessToken);
    setRefreshCookie(response, result.tokens.refreshToken, rememberMe);

    const responseData: any = {
      message: result.message,
      redirectTo: result.redirectTo,
      role: result.role,
      appType: result.appType,
      subscription: result.subscription,
      subscriptionLocked: result.subscriptionLocked,
      permissions: result.permissions,
      user: result.user,
    };

    if (appType === "MOBILE") {
      responseData.tokens = {
        access_token: result.tokens.accessToken,
        refresh_token: result.tokens.refreshToken,
        expires_in: ACCESS_TOKEN_TTL_SECONDS,
      };
      responseData.access_token = result.tokens.accessToken;
      responseData.refresh_token = result.tokens.refreshToken;
      responseData.expires_in = ACCESS_TOKEN_TTL_SECONDS;
    }

    response.json(responseData);
  },

  async refresh(request: Request, response: Response) {
    const body = request.body as { refresh_token?: string; refreshToken?: string } | undefined;
    const refreshToken =
      parseCookies(request)[REFRESH_TOKEN_COOKIE] ||
      (typeof body?.refresh_token === "string" ? body.refresh_token.trim() : "") ||
      (typeof body?.refreshToken === "string" ? body.refreshToken.trim() : "");

    const result = await refreshSessionUseCase.execute(refreshToken || undefined);

    setAccessCookie(response, result.tokens.accessToken);
    setRefreshCookie(response, result.tokens.refreshToken, false);

    const responseData: any = {
      message: result.message,
      redirectTo: result.redirectTo,
      role: result.role,
      appType: result.appType,
      subscription: result.subscription,
      subscriptionLocked: result.subscriptionLocked,
    };

    if (result.appType === "MOBILE") {
      responseData.tokens = {
        access_token: result.tokens.accessToken,
        refresh_token: result.tokens.refreshToken,
        expires_in: ACCESS_TOKEN_TTL_SECONDS,
      };
      responseData.access_token = result.tokens.accessToken;
      responseData.refresh_token = result.tokens.refreshToken;
      responseData.expires_in = ACCESS_TOKEN_TTL_SECONDS;
    }

    response.json(responseData);
  },

  async logout(request: Request, response: Response) {
    const refreshToken = parseCookies(request)[REFRESH_TOKEN_COOKIE];
    await logoutUseCase.execute(refreshToken);
    clearAuthCookies(response);
    response.json({ message: "Logged out successfully." });
  },

  async getMe(request: Request, response: Response) {
    const context = request.context!;
    const result = await getCurrentUserUseCase.execute({
      userId: context.userId,
      role: context.role,
      appType: context.appType,
      shopId: context.shopId,
    });
    response.json(result);
  },

  async updateProfile(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as any;
    const user = await updateProfileUseCase.execute(context.userId, { name: body.name, email: body.email, phone: body.phone });
    response.json({ message: "Profile updated successfully.", user });
  },

  async changePassword(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as any;
    await changePasswordUseCase.execute(context.userId, {
      currentPassword: body.currentPassword,
      newPassword: body.newPassword,
      confirmPassword: body.confirmPassword,
    });
    response.json({ message: "Password updated successfully." });
  },

  async updateAvatar(request: Request, response: Response) {
    const context = request.context!;
    const body = request.body as { profileImageUrl?: string };
    const user = await updateAvatarUseCase.execute(context.userId, body.profileImageUrl);
    response.json({ message: "Profile image updated successfully.", user });
  },
};
