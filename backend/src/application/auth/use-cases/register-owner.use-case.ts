import { normalizeOptionalText, validatePasswordRules } from "@domain/auth/auth.entity";
import { ConflictError, ValidationError } from "@domain/shared/app-error";

import type { DocumentStoragePort, StoreDocumentPayload } from "../ports/document-storage.port";
import type { AuthRepository } from "../ports/auth-repository.port";
import { hashPassword } from "../../../auth/password";

export type RegisterOwnerCommand = {
  shopName: string | undefined;
  name: string | undefined;
  mobile: string | undefined;
  email: string | null | undefined;
  password: string | undefined;
  confirmPassword: string | undefined;
  shopAddress: string | null | undefined;
  shopCategory: string | null | undefined;
  shopLocation: string | null | undefined;
  tradeLicenseNo: string | null | undefined;
  tinNo: string | null | undefined;
  binNo: string | null | undefined;
  tradeLicenseFile: StoreDocumentPayload | null | undefined;
  tinFile: StoreDocumentPayload | null | undefined;
  binFile: StoreDocumentPayload | null | undefined;
  requestOrigin: string;
};

export class RegisterOwnerUseCase {
  constructor(
    private readonly authRepository: AuthRepository,
    private readonly documentStorage: DocumentStoragePort,
  ) {}

  async execute(command: RegisterOwnerCommand) {
    const shopName = command.shopName?.trim();
    const name = command.name?.trim();
    // Deliberately NOT normalizeMobile'd, unlike register-owner-draft — matches the original route exactly.
    const mobile = command.mobile?.trim();
    const email = normalizeOptionalText(command.email);
    const password = command.password ?? "";
    const confirmPassword = command.confirmPassword ?? "";
    const shopAddress = normalizeOptionalText(command.shopAddress);
    const shopCategory = normalizeOptionalText(command.shopCategory);
    const shopLocation = normalizeOptionalText(command.shopLocation);
    const tradeLicenseNo = normalizeOptionalText(command.tradeLicenseNo);
    const tinNo = normalizeOptionalText(command.tinNo);
    const binNo = normalizeOptionalText(command.binNo);

    if (!shopName) {
      throw new ValidationError("Shop name is required.");
    }
    if (!name) {
      throw new ValidationError("Owner name is required.");
    }
    if (!mobile) {
      throw new ValidationError("Mobile number is required.");
    }
    if (!validatePasswordRules(password)) {
      throw new ValidationError("Password must be at least 4 characters long.");
    }
    if (password !== confirmPassword) {
      throw new ValidationError("Confirm password does not match.");
    }

    const [existingUserByPhone, existingUserByEmail, existingShopByName] = await Promise.all([
      this.authRepository.findUserByPhone(mobile),
      email ? this.authRepository.findUserByEmail(email) : Promise.resolve(null),
      this.authRepository.findShopByName(shopName),
    ]);

    if (existingUserByPhone) {
      throw new ConflictError("Mobile number is already in use.");
    }
    if (existingUserByEmail) {
      throw new ConflictError("Email is already in use.");
    }
    if (existingShopByName) {
      throw new ConflictError("Shop name is already in use.");
    }

    const tradeLicenseUrl = command.tradeLicenseFile
      ? await this.documentStorage.store("trade", command.tradeLicenseFile, command.requestOrigin)
      : tradeLicenseNo;
    const tinUrl = command.tinFile ? await this.documentStorage.store("tin", command.tinFile, command.requestOrigin) : tinNo;
    const binUrl = command.binFile ? await this.documentStorage.store("bin", command.binFile, command.requestOrigin) : binNo;

    return this.authRepository.createOwnerWithShop({
      name,
      mobile,
      email,
      passwordHash: await hashPassword(password),
      shopName,
      shopAddress,
      shopCategory,
      shopLocation,
      tradeLicenseUrl,
      tinUrl,
      binUrl,
    });
  }
}
