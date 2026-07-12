import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_session_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthSessionRepositoryImpl implements AuthSessionRepository {
  const AuthSessionRepositoryImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<UserSession> loadSession() => _localDataSource.loadSession();

  @override
  Future<void> saveStartupStage(String stage) {
    return _localDataSource.saveStartupStage(stage);
  }

  @override
  Future<void> saveOwner({
    required String name,
    required String phone,
    required String password,
  }) {
    return _localDataSource.saveOwner(
      name: name,
      phone: phone,
      password: password,
    );
  }

  @override
  Future<void> saveShopIdentity({
    required String shopId,
    required String shopName,
    String? shopCode,
  }) {
    return _localDataSource.saveShopIdentity(
      shopId: shopId,
      shopName: shopName,
      shopCode: shopCode,
    );
  }

  @override
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
  }) {
    return _localDataSource.saveUser(
      role: role,
      salesmanPhone: salesmanPhone,
      salesmanName: salesmanName,
      shopId: shopId,
      shopName: shopName,
      shopCode: shopCode,
      permissions: permissions,
    );
  }

  @override
  Future<void> clearUser() => _localDataSource.clearUser();

  @override
  Future<bool> verifyOwnerPassword(String password) {
    return _localDataSource.verifyOwnerPassword(password);
  }
}
