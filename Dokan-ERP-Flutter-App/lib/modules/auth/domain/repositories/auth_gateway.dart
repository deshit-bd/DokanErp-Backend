import '../entities/authenticated_user.dart';

abstract interface class AuthGateway {
  Future<AuthenticatedUser> login({
    required String phone,
    required String password,
    required int role,
    String? shopId,
    bool rememberMe = false,
  });

  Future<void> checkMobile(String phone);

  Future<AuthenticatedUser> register({
    required String name,
    required String phone,
    required String password,
    String? shopName,
    String? shopAddress,
    String? shopCategory,
    String? shopLocation,
    String? tradeLicenseNo,
    String? tinNo,
    String? binNo,
    double? latitude,
    double? longitude,
  });

  Future<void> sendOtp(String phone);

  Future<AuthenticatedUser> verifyOtp({
    required String phone,
    required String code,
  });

  Future<void> logout();
}
