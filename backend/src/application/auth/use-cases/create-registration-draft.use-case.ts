import {
  getRegistrationDraftExpiryDate,
  normalizeMobile,
  normalizeNumberInput,
  normalizeOptionalText,
  validatePasswordRules,
} from "@domain/auth/auth.entity";
import { ConflictError, ValidationError } from "@domain/shared/app-error";

import type { AuthRepository } from "../ports/auth-repository.port";
import { hashPassword } from "../../../auth/password";

export type CreateRegistrationDraftCommand = {
  name: string | undefined;
  mobile: string | undefined;
  email: string | null | undefined;
  password: string | undefined;
  confirmPassword: string | undefined;
  shopName: string | undefined;
  shopAddress: string | undefined;
  shopCategory: string | undefined;
  shopLocation: string | null | undefined;
  latitude: string | number | null | undefined;
  longitude: string | number | null | undefined;
};

export class CreateRegistrationDraftUseCase {
  constructor(private readonly authRepository: AuthRepository) {}

  async execute(command: CreateRegistrationDraftCommand) {
    const name = command.name?.trim();
    const mobile = normalizeMobile(command.mobile);
    const email = normalizeOptionalText(command.email);
    const password = command.password ?? "";
    const confirmPassword = command.confirmPassword ?? "";
    const shopName = command.shopName?.trim();
    const shopAddress = command.shopAddress?.trim();
    const shopCategory = command.shopCategory?.trim();
    const shopLocation = normalizeOptionalText(command.shopLocation);
    const latitude = normalizeNumberInput(command.latitude);
    const longitude = normalizeNumberInput(command.longitude);

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
    if (!shopName) {
      throw new ValidationError("Shop name is required.");
    }
    if (!shopAddress) {
      throw new ValidationError("Shop address is required.");
    }
    if (!shopCategory) {
      throw new ValidationError("Shop category is required.");
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

    const duplicateDraft = await this.authRepository.findDuplicateRegistrationDraftByMobileOrShopName(mobile, shopName);

    if (duplicateDraft) {
      throw new ConflictError(
        duplicateDraft.mobile === mobile
          ? "A pending registration already exists for this mobile number."
          : "A pending registration already exists for this shop name.",
      );
    }

    const draft = await this.authRepository.createRegistrationDraft({
      name,
      mobile,
      email,
      passwordHash: await hashPassword(password),
      shopName,
      shopAddress,
      shopCategory,
      shopLocation,
      latitude,
      longitude,
      expiresAt: getRegistrationDraftExpiryDate(),
    });

    return draft;
  }
}
