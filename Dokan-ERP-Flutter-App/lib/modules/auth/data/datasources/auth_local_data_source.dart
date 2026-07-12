import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/security/credential_hasher.dart';
import '../../domain/entities/dokan_role.dart';
import '../../domain/entities/user_session.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource();

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  Future<UserSession> loadSession() async {
    final prefs = await _preferences;
    final hasRoleKey = prefs.containsKey(AppKeys.currentUserRole);
    bool hasSession = hasRoleKey;

    if (hasRoleKey) {
      final loginTime = prefs.getInt(AppKeys.sessionLoginTime) ?? 0;
      if (loginTime > 0) {
        final elapsed = DateTime.now().millisecondsSinceEpoch - loginTime;
        if (elapsed > 24 * 60 * 60 * 1000) {
          hasSession = false;
          await prefs.remove(AppKeys.currentUserRole);
          await prefs.remove(AppKeys.salesmanPhone);
          await prefs.remove(AppKeys.salesmanName);
          await prefs.remove(AppKeys.sessionLoginTime);
        }
      }
    }

    return UserSession(
      hasSession: hasSession,
      role: (prefs.getInt(AppKeys.currentUserRole) ?? 0).toDokanRole(),
      salesmanPhone: prefs.getString(AppKeys.salesmanPhone),
      salesmanName: prefs.getString(AppKeys.salesmanName),
      ownerPhone: prefs.getString(AppKeys.ownerPhone) ?? '01712345678',
      ownerPassword: '',
      shopId: prefs.getString(AppKeys.shopId) ?? '',
      shopName: prefs.getString(AppKeys.shopName) ?? 'দোকান',
      registeredName: prefs.getString(AppKeys.registeredName) ?? 'আপনার',
      shopCode: prefs.getString(AppKeys.shopCode) ?? '',
      permissions: {
        'canSell': prefs.getBool(AppKeys.permCanSell) ?? true,
        'canViewStock': prefs.getBool(AppKeys.permCanViewStock) ?? true,
        'canViewReports': prefs.getBool(AppKeys.permCanViewReports) ?? true,
        'canChangePrice': prefs.getBool(AppKeys.permCanChangePrice) ?? true,
        'canCollectDue': prefs.getBool(AppKeys.permCanCollectDue) ?? true,
      },
    );
  }

  Future<void> saveStartupStage(String stage) async {
    await (await _preferences).setString(AppKeys.startupStage, stage);
  }

  Future<void> saveOwner({
    required String name,
    required String phone,
    required String password,
  }) async {
    final prefs = await _preferences;
    await prefs.setString(AppKeys.registeredName, name);
    await prefs.setString(AppKeys.ownerPhone, phone);
    await prefs.setString(
        AppKeys.ownerPassword, CredentialHasher.hash(password));
  }

  Future<void> saveShopIdentity({
    required String shopId,
    required String shopName,
    String? shopCode,
  }) async {
    final prefs = await _preferences;
    if (shopId.isNotEmpty) await prefs.setString(AppKeys.shopId, shopId);
    if (shopName.isNotEmpty) await prefs.setString(AppKeys.shopName, shopName);
    if (shopCode?.isNotEmpty == true) {
      await prefs.setString(AppKeys.shopCode, shopCode!);
    }
  }

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
  }) async {
    final prefs = await _preferences;
    await prefs.setInt(AppKeys.currentUserRole, role);
    await _setNullable(prefs, AppKeys.salesmanPhone, salesmanPhone);
    await _setNullable(prefs, AppKeys.salesmanName, salesmanName);
    if (shopId?.isNotEmpty == true) {
      await prefs.setString(AppKeys.shopId, shopId!);
    }
    if (shopName?.isNotEmpty == true) {
      await prefs.setString(AppKeys.shopName, shopName!);
    }
    if (shopCode?.isNotEmpty == true) {
      await prefs.setString(AppKeys.shopCode, shopCode!);
    }
    await prefs.setBool(AppKeys.permCanSell, permissions['canSell'] ?? true);
    await prefs.setBool(AppKeys.permCanViewStock, permissions['canViewStock'] ?? true);
    await prefs.setBool(AppKeys.permCanViewReports, permissions['canViewReports'] ?? true);
    await prefs.setBool(AppKeys.permCanChangePrice, permissions['canChangePrice'] ?? true);
    await prefs.setBool(AppKeys.permCanCollectDue, permissions['canCollectDue'] ?? true);
    await prefs.setInt(
        AppKeys.sessionLoginTime, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clearUser() async {
    final prefs = await _preferences;
    await prefs.remove(AppKeys.currentUserRole);
    await prefs.remove(AppKeys.salesmanPhone);
    await prefs.remove(AppKeys.salesmanName);
    await prefs.remove(AppKeys.permCanSell);
    await prefs.remove(AppKeys.permCanViewStock);
    await prefs.remove(AppKeys.permCanViewReports);
    await prefs.remove(AppKeys.permCanChangePrice);
    await prefs.remove(AppKeys.permCanCollectDue);
    await prefs.remove(AppKeys.sessionLoginTime);
  }

  Future<bool> verifyOwnerPassword(String password) async {
    final prefs = await _preferences;
    final stored = prefs.getString(AppKeys.ownerPassword) ?? '1234';
    final valid = CredentialHasher.verify(password, stored);
    if (valid && CredentialHasher.needsMigration(stored)) {
      await prefs.setString(
        AppKeys.ownerPassword,
        CredentialHasher.hash(password),
      );
    }
    return valid;
  }

  Future<void> _setNullable(
    SharedPreferences prefs,
    String key,
    String? value,
  ) async {
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }
}
