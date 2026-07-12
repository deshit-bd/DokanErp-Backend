import 'dokan_role.dart';

class AuthenticatedUser {
  const AuthenticatedUser({
    required this.role,
    this.name,
    this.phone,
    this.shopId,
    this.shopName,
    this.shopCode,
    this.permissions = const {
      'canSell': true,
      'canViewStock': true,
      'canViewReports': true,
      'canChangePrice': true,
      'canCollectDue': true,
    },
  });

  final DokanRole role;
  final String? name;
  final String? phone;
  final String? shopId;
  final String? shopName;
  final String? shopCode;
  final Map<String, bool> permissions;
}
