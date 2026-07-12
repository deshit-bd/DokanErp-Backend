import '../entities/user_session.dart';

abstract interface class AuthSessionRepository {
  Future<UserSession> loadSession();
  Future<void> saveStartupStage(String stage);
  Future<void> saveOwner({
    required String name,
    required String phone,
    required String password,
  });
  Future<void> saveShopIdentity(
      {required String shopId, required String shopName, String? shopCode});
  Future<void> saveUser({
    required int role,
    String? salesmanPhone,
    String? salesmanName,
    String? shopId,
    String? shopName,
    String? shopCode,
    Map<String, bool> permissions = const {
      'canSell': true,
      'canViewStock': true,
      'canViewReports': true,
      'canChangePrice': true,
      'canCollectDue': true,
    },
  });
  Future<void> clearUser();
  Future<bool> verifyOwnerPassword(String password);
}
