import { buildShopCode } from "@domain/auth/auth.entity";
import type {
  AuthRepository,
  FullUser,
  OtpWithUser,
  RefreshTokenRecord,
  RegistrationDraft,
  SalesmanPermissions,
  ShopRecord,
} from "@application/auth/ports/auth-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

const USER_INCLUDE = {
  platformUser: true,
  shopUsers: { include: { shop: true } },
  ownedShops: true,
} as const;

export class PrismaAuthRepository implements AuthRepository {
  async findUserByPhone(phone: string) {
    return prisma.user.findUnique({ where: { phone }, select: { id: true } });
  }

  async findUserByEmail(email: string) {
    return prisma.user.findUnique({ where: { email }, select: { id: true } });
  }

  async findUserByIdentity(identity: string, phoneVariations: string[] | null): Promise<FullUser | null> {
    const orConditions: any[] = [{ email: identity }, { phone: identity }];

    if (phoneVariations) {
      orConditions.push({ phone: { in: phoneVariations } });
    }

    const user = await prisma.user.findFirst({
      where: { OR: orConditions },
      include: USER_INCLUDE,
    });

    if (user) {
      return user as unknown as FullUser;
    }

    const shop = await (prisma as any).shop.findFirst({
      where: { shopName: identity },
      include: { owner: { include: USER_INCLUDE } },
    });

    return (shop?.owner as unknown as FullUser) ?? null;
  }

  async findUserById(id: string): Promise<FullUser | null> {
    const user = await prisma.user.findUnique({ where: { id }, include: USER_INCLUDE });
    return (user as unknown as FullUser) ?? null;
  }

  async findUserPasswordHash(id: string) {
    return prisma.user.findUnique({ where: { id }, select: { id: true, passwordHash: true } });
  }

  async createOwnerWithShop(input: Parameters<AuthRepository["createOwnerWithShop"]>[0]) {
    return prisma.$transaction(async (transaction) => {
      const tx = transaction as any;
      const shopCode = await this.createUniqueShopCodeTx(tx, input.shopName);

      const user = await tx.user.create({
        data: {
          name: input.name,
          phone: input.mobile,
          email: input.email,
          passwordHash: input.passwordHash,
          status: "ACTIVE",
        },
      });

      const shop = await tx.shop.create({
        data: {
          shopCode,
          shopName: input.shopName,
          ownerUserId: user.id,
          phone: input.mobile,
          email: input.email,
          address: input.shopAddress,
          area: input.shopLocation,
          businessType: input.shopCategory,
          tradeLicenseNo: input.tradeLicenseUrl,
          tinNo: input.tinUrl,
          vatRegNo: input.binUrl,
          status: "ACTIVE",
        },
      });

      await tx.shopUser.create({
        data: { shopId: shop.id, userId: user.id, role: "SHOP_OWNER", isBillable: true },
      });

      const { ensureShopSubscription } = await import("../../../subscription/access");
      await ensureShopSubscription(shop.id, tx, new Date());

      return {
        user: { id: user.id, name: user.name, phone: user.phone, email: user.email, status: user.status },
        shop: { id: shop.id, shopCode: shop.shopCode ?? null, shopName: shop.shopName, ownerUserId: shop.ownerUserId, status: shop.status },
      };
    });
  }

  async createSalesman(input: Parameters<AuthRepository["createSalesman"]>[0]) {
    return prisma.$transaction(async (transaction) => {
      const tx = transaction as any;

      const user = await tx.user.create({
        data: {
          name: input.name,
          phone: input.mobile,
          email: input.email,
          passwordHash: input.passwordHash,
          status: "ACTIVE",
          createdByUserId: input.createdByUserId,
        },
      });

      const shopUser = await tx.shopUser.create({
        data: { shopId: input.shopId, userId: user.id, role: "SALESMAN", isBillable: false },
      });

      await tx.salesmanPermission.create({
        data: {
          shopUserId: shopUser.id,
          canSell: input.permissions.canSell,
          canViewStock: input.permissions.canViewStock,
          canViewReports: input.permissions.canViewReports,
          canChangePrice: input.permissions.canChangePrice,
          canCollectDue: input.permissions.canCollectDue,
        },
      });

      if (input.pinHash) {
        await tx.userPin.create({ data: { userId: user.id, pinHash: input.pinHash, status: "ACTIVE" } });
      }

      return { id: user.id, name: user.name, phone: user.phone, email: user.email, status: user.status };
    });
  }

  async updateUserProfile(id: string, input: { name: string; email: string | null; phone: string | null }) {
    return prisma.user.update({
      where: { id },
      data: { name: input.name, email: input.email, phone: input.phone },
      select: { id: true, name: true, email: true, phone: true, profileImageUrl: true, status: true },
    });
  }

  async updateUserPassword(id: string, passwordHash: string): Promise<void> {
    await prisma.user.update({ where: { id }, data: { passwordHash } });
  }

  async updateUserAvatar(id: string, profileImageUrl: string) {
    return prisma.user.update({
      where: { id },
      data: { profileImageUrl },
      select: { id: true, name: true, email: true, phone: true, profileImageUrl: true, status: true },
    });
  }

  async updateLastLogin(id: string, phoneVerifiedAtIfUnset?: Date): Promise<void> {
    const data: any = { lastLoginAt: new Date() };
    if (phoneVerifiedAtIfUnset) {
      const user = await prisma.user.findUnique({ where: { id }, select: { phoneVerifiedAt: true } });
      data.phoneVerifiedAt = user?.phoneVerifiedAt ?? phoneVerifiedAtIfUnset;
    }
    await prisma.user.update({ where: { id }, data });
  }

  async findUserByAnyEmailExcept(email: string, excludeId: string) {
    return prisma.user.findFirst({ where: { email, id: { not: excludeId } }, select: { id: true } });
  }

  async findUserByAnyPhoneExcept(phone: string, excludeId: string) {
    return prisma.user.findFirst({ where: { phone, id: { not: excludeId } }, select: { id: true } });
  }

  async resolveShopIdentifier(identifier: string): Promise<ShopRecord | null> {
    const normalized = identifier.trim();
    const match = normalized.match(/^(did|sid)[-]?(\d+)$/i);

    if (match) {
      const digits = match[2];
      return (prisma as any).shop.findFirst({
        where: { shopCode: { endsWith: digits } },
        select: { id: true, shopCode: true, shopName: true, status: true },
      });
    }

    return (prisma as any).shop.findFirst({
      where: { OR: [{ id: normalized }, { shopCode: normalized }] },
      select: { id: true, shopCode: true, shopName: true, status: true },
    });
  }

  async findShopById(id: string): Promise<ShopRecord | null> {
    return prisma.shop.findUnique({ where: { id }, select: { id: true, shopCode: true, shopName: true, status: true } });
  }

  async findShopByName(shopName: string) {
    return prisma.shop.findFirst({ where: { shopName }, select: { id: true } });
  }

  async createUniqueShopCode(shopName: string): Promise<string> {
    return this.createUniqueShopCodeTx(prisma, shopName);
  }

  private async createUniqueShopCodeTx(client: any, shopName: string): Promise<string> {
    let shopCode = buildShopCode(shopName);

    for (let attempt = 0; attempt < 5; attempt += 1) {
      const existingShop = await client.shop.findUnique({ where: { shopCode }, select: { id: true } });
      if (!existingShop) {
        return shopCode;
      }
      shopCode = buildShopCode(`${shopName}${attempt}`);
    }

    return `${buildShopCode(shopName)}${Math.floor(Math.random() * 1000)}`;
  }

  async getSalesmanPermissions(shopId: string, userId: string): Promise<SalesmanPermissions | null> {
    const shopUser = await prisma.shopUser.findUnique({
      where: { shopId_userId: { shopId, userId } },
      include: { salesmanPermission: true },
    });

    return shopUser?.salesmanPermission ?? null;
  }

  async cancelPendingLoginOtps(userId: string, shopId?: string): Promise<void> {
    await (prisma as any).otpVerification.updateMany({
      where: { userId, ...(shopId ? { shopId } : {}), purpose: "LOGIN", status: "PENDING" },
      data: { status: "CANCELLED" },
    });
  }

  async createOtp(input: Parameters<AuthRepository["createOtp"]>[0]) {
    return (prisma as any).otpVerification.create({
      data: {
        userId: input.userId,
        shopId: input.shopId ?? null,
        appType: "MOBILE",
        purpose: input.purpose,
        channel: "SMS",
        recipient: input.recipient,
        codeHash: input.codeHash,
        expiresAt: input.expiresAt,
        status: "PENDING",
      },
      select: { id: true, expiresAt: true },
    });
  }

  async findOtpById(id: string): Promise<OtpWithUser | null> {
    const otp = await (prisma as any).otpVerification.findUnique({
      where: { id },
      include: { user: { include: USER_INCLUDE } },
    });

    return otp as OtpWithUser | null;
  }

  async findLatestPendingOtpByRecipient(recipient: string) {
    return (prisma as any).otpVerification.findFirst({
      where: { recipient, status: "PENDING" },
      orderBy: { createdAt: "desc" },
    });
  }

  async markOtpExpired(id: string): Promise<void> {
    await (prisma as any).otpVerification.update({ where: { id }, data: { status: "EXPIRED" } });
  }

  async recordFailedOtpAttempt(id: string, nextAttempts: number, cancel: boolean): Promise<void> {
    await (prisma as any).otpVerification.update({
      where: { id },
      data: { attempts: nextAttempts, ...(cancel ? { status: "CANCELLED" } : {}) },
    });
  }

  async markOtpVerified(id: string, verifiedAt: Date, nextAttempts: number): Promise<void> {
    await (prisma as any).otpVerification.update({
      where: { id },
      data: { attempts: nextAttempts, verifiedAt, consumedAt: verifiedAt, status: "VERIFIED" },
    });
  }

  async findActiveRegistrationDraft(id: string): Promise<RegistrationDraft | null> {
    return (prisma as any).ownerRegistrationDraft.findFirst({
      where: {
        id,
        completedAt: null,
        status: { notIn: ["CANCELLED", "EXPIRED", "COMPLETED"] },
        expiresAt: { gt: new Date() },
      },
    });
  }

  async findRegistrationDraftWithOtp(id: string): Promise<RegistrationDraft | null> {
    return (prisma as any).ownerRegistrationDraft.findUnique({ where: { id }, include: { otpVerification: true } });
  }

  async findDuplicateRegistrationDraftByMobile(mobile: string) {
    return (prisma as any).ownerRegistrationDraft.findFirst({
      where: { mobile, status: { notIn: ["CANCELLED", "EXPIRED", "COMPLETED"] }, expiresAt: { gt: new Date() } },
      select: { id: true },
    });
  }

  async findDuplicateRegistrationDraftByMobileOrShopName(mobile: string, shopName: string) {
    return (prisma as any).ownerRegistrationDraft.findFirst({
      where: {
        OR: [{ mobile }, { shopName }],
        status: { notIn: ["CANCELLED", "EXPIRED", "COMPLETED"] },
        expiresAt: { gt: new Date() },
      },
      select: { id: true, mobile: true, shopName: true },
    });
  }

  async createRegistrationDraft(input: Parameters<AuthRepository["createRegistrationDraft"]>[0]) {
    return (prisma as any).ownerRegistrationDraft.create({
      data: {
        name: input.name,
        mobile: input.mobile,
        email: input.email,
        passwordHash: input.passwordHash,
        shopName: input.shopName,
        shopAddress: input.shopAddress,
        shopCategory: input.shopCategory,
        shopLocationLabel: input.shopLocation,
        latitude: input.latitude,
        longitude: input.longitude,
        status: "PENDING",
        expiresAt: input.expiresAt,
      },
      select: { id: true, mobile: true, shopName: true, status: true, expiresAt: true },
    });
  }

  async linkOtpToRegistrationDraft(draftId: string, otpId: string): Promise<void> {
    await (prisma as any).ownerRegistrationDraft.update({
      where: { id: draftId },
      data: { otpVerificationId: otpId, status: "OTP_SENT" },
    });
  }

  async markRegistrationDraftOtpVerified(draftId: string, verifiedAt: Date, expiresAt: Date): Promise<void> {
    await (prisma as any).ownerRegistrationDraft.update({
      where: { id: draftId },
      data: { otpVerifiedAt: verifiedAt, status: "OTP_VERIFIED", expiresAt },
    });
  }

  async setRegistrationDraftPin(draftId: string, pinHash: string, pinSetAt: Date, expiresAt: Date): Promise<void> {
    await (prisma as any).ownerRegistrationDraft.update({
      where: { id: draftId },
      data: { pinHash, pinSetAt, status: "PIN_SET", expiresAt },
    });
  }

  async completeRegistrationDraft(draft: RegistrationDraft) {
    const completedAt = new Date();

    return prisma.$transaction(async (transaction) => {
      const tx = transaction as any;
      const shopCode = await this.createUniqueShopCodeTx(tx, draft.shopName);

      const user = await tx.user.create({
        data: {
          name: draft.name,
          phone: draft.mobile,
          email: draft.email,
          passwordHash: draft.passwordHash,
          phoneVerifiedAt: draft.otpVerifiedAt,
          status: "ACTIVE",
        },
      });

      const shop = await tx.shop.create({
        data: {
          shopCode,
          shopName: draft.shopName,
          ownerUserId: user.id,
          phone: draft.mobile,
          email: draft.email,
          businessType: draft.shopCategory,
          address: draft.shopAddress,
          area: draft.shopLocationLabel,
          status: "ACTIVE",
        },
      });

      await tx.shopUser.create({ data: { shopId: shop.id, userId: user.id, role: "SHOP_OWNER", isBillable: true } });

      const { ensureShopSubscription } = await import("../../../subscription/access");
      await ensureShopSubscription(shop.id, tx, completedAt);

      await tx.userPin.create({ data: { userId: user.id, pinHash: draft.pinHash, status: "ACTIVE" } });

      await tx.ownerRegistrationDraft.update({
        where: { id: draft.id },
        data: { completedAt, status: "COMPLETED" },
      });

      return {
        user: { id: user.id, name: user.name, phone: user.phone, email: user.email },
        shop: { id: shop.id, shopCode: shop.shopCode ?? null, shopName: shop.shopName },
      };
    });
  }

  async createRefreshToken(input: Parameters<AuthRepository["createRefreshToken"]>[0]) {
    return prisma.refreshToken.create({ data: input });
  }

  async findRefreshTokenByHash(tokenHash: string): Promise<RefreshTokenRecord | null> {
    const record = await prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: { include: USER_INCLUDE } },
    });

    return record as unknown as RefreshTokenRecord | null;
  }

  async revokeRefreshToken(id: string): Promise<void> {
    await prisma.refreshToken.update({ where: { id }, data: { revokedAt: new Date() } });
  }

  async revokeRefreshTokenByHash(tokenHash: string): Promise<void> {
    await prisma.refreshToken.updateMany({
      where: { tokenHash, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  async revokeRefreshFamily(family: string): Promise<void> {
    await prisma.refreshToken.updateMany({
      where: { family, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }
}
