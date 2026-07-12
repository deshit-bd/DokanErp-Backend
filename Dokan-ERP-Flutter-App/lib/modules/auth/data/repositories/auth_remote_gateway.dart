import '../../../../core/network/json_value.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/entities/dokan_role.dart';
import '../../domain/repositories/auth_gateway.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRemoteGateway implements AuthGateway {
  const AuthRemoteGateway(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<AuthenticatedUser> login({
    required String phone,
    required String password,
    required int role,
    String? shopId,
    bool rememberMe = false,
  }) async {
    final payload = await _remote.login(
      phone: phone,
      password: password,
      role: role,
      shopId: shopId,
      rememberMe: rememberMe,
    );
    return _user(payload, fallbackPhone: phone, fallbackRole: role);
  }

  @override
  Future<void> checkMobile(String phone) => _remote.checkMobile(phone);

  @override
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
  }) async {
    final payload = await _remote.register({
      'name': name,
      'mobile': phone,
      'password': password,
      'confirmPassword': password,
      if (shopName != null) 'shopName': shopName,
      if (shopAddress != null) 'shopAddress': shopAddress,
      if (shopCategory != null) 'shopCategory': shopCategory,
      if (shopLocation != null) 'shopLocation': shopLocation,
      if (tradeLicenseNo != null) 'tradeLicenseNo': tradeLicenseNo,
      if (tinNo != null) 'tinNo': tinNo,
      if (binNo != null) 'binNo': binNo,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    return _user(payload, fallbackPhone: phone, fallbackRole: 0);
  }

  @override
  Future<void> sendOtp(String phone) => _remote.sendOtp(phone);

  @override
  Future<AuthenticatedUser> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final payload = await _remote.verifyOtp(phone: phone, code: code);
    return _user(payload, fallbackPhone: phone, fallbackRole: 0);
  }

  @override
  Future<void> logout() => _remote.logout();

  AuthenticatedUser _user(
    Map<String, dynamic> payload, {
    required String fallbackPhone,
    required int fallbackRole,
  }) {
    final userValue = payload['user'];
    final user = userValue is Map
        ? userValue.map((key, value) => MapEntry('$key', value))
        : payload;
    final roleValue = JsonValue.string(user, const ['role']);
    final role = roleValue.toLowerCase() == 'salesman' ||
            JsonValue.integer(user, const ['role_id'],
                    fallback: fallbackRole) ==
                1
        ? DokanRole.salesman
        : DokanRole.owner;
    final shopValue =
        user['shop'] ?? user['store'] ?? payload['shop'] ?? payload['store'];
    final shop = shopValue is Map
        ? shopValue.map((key, value) => MapEntry('$key', value))
        : const <String, dynamic>{};
    final rawShopCode = JsonValue.string(shop, const ['shopCode', 'shop_code']);
    final match = RegExp(r'(\d+)$').firstMatch(rawShopCode);
    final shopCodeSuffix = match != null ? match.group(0) : '';
    final formattedShopCode = shopCodeSuffix != null && shopCodeSuffix.isNotEmpty
        ? 'DID-$shopCodeSuffix'
        : rawShopCode;

    final permissionsMap = payload['permissions'] is Map
        ? (payload['permissions'] as Map).map((k, v) => MapEntry('$k', v == true))
        : user['permissions'] is Map
            ? (user['permissions'] as Map).map((k, v) => MapEntry('$k', v == true))
            : const <String, bool>{};

    final permissions = <String, bool>{
      'canSell': permissionsMap['canSell'] ?? true,
      'canViewStock': permissionsMap['canViewStock'] ?? true,
      'canViewReports': permissionsMap['canViewReports'] ?? true,
      'canChangePrice': permissionsMap['canChangePrice'] ?? true,
      'canCollectDue': permissionsMap['canCollectDue'] ?? true,
    };

    return AuthenticatedUser(
      role: role,
      name: JsonValue.string(user, const ['name', 'full_name']),
      phone: JsonValue.string(
        user,
        const ['phone', 'mobile'],
        fallback: fallbackPhone,
      ),
      shopId: JsonValue.string(
        shop,
        const ['id', 'uuid', 'shopId', 'shop_id', 'storeId', 'store_id'],
        fallback: JsonValue.string(
          user,
          const ['shopId', 'shop_id', 'storeId', 'store_id'],
          fallback: JsonValue.string(
            payload,
            const ['shopId', 'shop_id', 'storeId', 'store_id'],
          ),
        ),
      ),
      shopName: JsonValue.string(
        shop,
        const ['name', 'shopName', 'shop_name', 'storeName', 'store_name'],
        fallback: JsonValue.string(
          user,
          const ['shopName', 'shop_name', 'storeName', 'store_name'],
          fallback: JsonValue.string(
            payload,
            const ['shopName', 'shop_name', 'storeName', 'store_name'],
          ),
        ),
      ),
      shopCode: formattedShopCode,
      permissions: permissions,
    );
  }
}
