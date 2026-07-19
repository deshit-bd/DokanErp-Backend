import type { AppType } from "@domain/shared/auth-role";
import type { UserForAuthContext } from "@domain/auth/auth.entity";

export type FullUser = UserForAuthContext & {
  id: string;
  name: string;
  email: string | null;
  phone: string | null;
  status: string;
  passwordHash: string;
  profileImageUrl: string | null;
  phoneVerifiedAt: Date | null;
  ownedShops: Array<{ id: string; status: string; shopCode?: string | null; shopName?: string | null }>;
  shopUsers: Array<{ shopId: string; role: string; shop: { status: string; shopCode?: string | null; shopName?: string | null } }>;
};

export type ShopRecord = { id: string; shopCode: string | null; shopName: string; status: string };

export type OtpRecord = {
  id: string;
  purpose: string;
  appType: string;
  recipient: string;
  status: string;
  codeHash: string;
  attempts: number;
  maxAttempts: number;
  expiresAt: Date;
  userId: string | null;
};

export type OtpWithUser = OtpRecord & { user: FullUser | null };

export type RegistrationDraft = {
  id: string;
  name: string;
  mobile: string;
  email: string | null;
  passwordHash: string;
  shopName: string;
  shopAddress: string;
  shopCategory: string;
  shopLocationLabel: string | null;
  status: string;
  expiresAt: Date;
  otpVerifiedAt: Date | null;
  pinHash: string | null;
  completedAt: Date | null;
};

export type RefreshTokenRecord = {
  id: string;
  family: string;
  appType: AppType;
  revokedAt: Date | null;
  expiresAt: Date;
  createdAt: Date;
  userId: string;
  user: FullUser;
};

export type SalesmanPermissions = {
  canSell: boolean;
  canViewStock: boolean;
  canViewReports: boolean;
  canChangePrice: boolean;
  canCollectDue: boolean;
};

// Deliberately a single coarse repository (not one-per-aggregate like
// categories/units/brands): the 19 auth use cases share heavily
// cross-entity transactional logic (user+shop+shopUser+subscription created
// atomically, OTP tied to registration drafts tied to user creation), so
// splitting into micro-repositories would multiply file count without
// improving clarity. See CLAUDE.md for this documented exception.
export interface AuthRepository {
  findUserByPhone(phone: string): Promise<{ id: string } | null>;
  findUserByEmail(email: string): Promise<{ id: string } | null>;
  findUserByIdentity(identity: string, phoneVariations: string[] | null): Promise<FullUser | null>;
  findUserById(id: string): Promise<FullUser | null>;
  findUserPasswordHash(id: string): Promise<{ id: string; passwordHash: string } | null>;

  createOwnerWithShop(input: {
    name: string;
    mobile: string;
    email: string | null;
    passwordHash: string;
    shopName: string;
    shopAddress: string | null;
    shopCategory: string | null;
    shopLocation: string | null;
    tradeLicenseUrl: string | null;
    tinUrl: string | null;
    binUrl: string | null;
  }): Promise<{ user: { id: string; name: string; phone: string | null; email: string | null; status: string }; shop: { id: string; shopCode: string | null; shopName: string; ownerUserId: string | null; status: string } }>;

  createSalesman(input: {
    name: string;
    mobile: string;
    email: string | null;
    passwordHash: string;
    createdByUserId: string;
    shopId: string;
    permissions: SalesmanPermissions;
    pinHash: string | null;
  }): Promise<{ id: string; name: string; phone: string | null; email: string | null; status: string }>;

  updateUserProfile(id: string, input: { name: string; email: string | null; phone: string | null }): Promise<{ id: string; name: string; email: string | null; phone: string | null; profileImageUrl: string | null; status: string }>;
  updateUserPassword(id: string, passwordHash: string): Promise<void>;
  updateUserAvatar(id: string, profileImageUrl: string): Promise<{ id: string; name: string; email: string | null; phone: string | null; profileImageUrl: string | null; status: string }>;
  updateLastLogin(id: string, phoneVerifiedAtIfUnset?: Date): Promise<void>;
  findUserByAnyEmailExcept(email: string, excludeId: string): Promise<{ id: string } | null>;
  findUserByAnyPhoneExcept(phone: string, excludeId: string): Promise<{ id: string } | null>;

  resolveShopIdentifier(identifier: string): Promise<ShopRecord | null>;
  findShopById(id: string): Promise<ShopRecord | null>;
  findShopByName(shopName: string): Promise<{ id: string } | null>;
  createUniqueShopCode(shopName: string): Promise<string>;
  getSalesmanPermissions(shopId: string, userId: string): Promise<SalesmanPermissions | null>;

  cancelPendingLoginOtps(userId: string, shopId?: string): Promise<void>;
  createOtp(input: {
    userId?: string;
    shopId?: string | null;
    purpose: "LOGIN" | "REGISTRATION";
    recipient: string;
    codeHash: string;
    expiresAt: Date;
  }): Promise<{ id: string; expiresAt: Date }>;
  findOtpById(id: string): Promise<OtpWithUser | null>;
  findLatestPendingOtpByRecipient(recipient: string): Promise<OtpRecord | null>;
  markOtpExpired(id: string): Promise<void>;
  recordFailedOtpAttempt(id: string, nextAttempts: number, cancel: boolean): Promise<void>;
  markOtpVerified(id: string, verifiedAt: Date, nextAttempts: number): Promise<void>;

  findActiveRegistrationDraft(id: string): Promise<RegistrationDraft | null>;
  findRegistrationDraftWithOtp(id: string): Promise<RegistrationDraft | null>;
  findDuplicateRegistrationDraftByMobile(mobile: string): Promise<{ id: string; mobile: string; shopName: string } | null>;
  findDuplicateRegistrationDraftByMobileOrShopName(mobile: string, shopName: string): Promise<{ id: string; mobile: string; shopName: string } | null>;
  createRegistrationDraft(input: {
    name: string;
    mobile: string;
    email: string | null;
    passwordHash: string;
    shopName: string;
    shopAddress: string;
    shopCategory: string;
    shopLocation: string | null;
    latitude: number | null;
    longitude: number | null;
    expiresAt: Date;
  }): Promise<{ id: string; mobile: string; shopName: string; status: string; expiresAt: Date }>;
  linkOtpToRegistrationDraft(draftId: string, otpId: string): Promise<void>;
  markRegistrationDraftOtpVerified(draftId: string, verifiedAt: Date, expiresAt: Date): Promise<void>;
  setRegistrationDraftPin(draftId: string, pinHash: string, pinSetAt: Date, expiresAt: Date): Promise<void>;
  completeRegistrationDraft(draft: RegistrationDraft): Promise<{ user: { id: string; name: string; phone: string | null; email: string | null }; shop: { id: string; shopCode: string | null; shopName: string } }>;

  createRefreshToken(input: { userId: string; tokenHash: string; family: string; appType: AppType; expiresAt: Date }): Promise<{ id: string; family: string; expiresAt: Date; createdAt: Date }>;
  findRefreshTokenByHash(tokenHash: string): Promise<RefreshTokenRecord | null>;
  revokeRefreshToken(id: string): Promise<void>;
  revokeRefreshTokenByHash(tokenHash: string): Promise<void>;
  revokeRefreshFamily(family: string): Promise<void>;
}
