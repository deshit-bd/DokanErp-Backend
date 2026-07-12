import 'dokan_role.dart';

class UserSession {
  const UserSession({
    this.role = DokanRole.owner,
    this.hasSession = false,
    this.salesmanPhone,
    this.salesmanName,
    this.ownerPhone = '01712345678',
    this.ownerPassword = '1234',
    this.shopId = '',
    this.shopName = 'দোকান',
    this.registeredName = 'আপনার',
    this.shopCode = '',
    this.permissions = const {
      'canSell': true,
      'canViewStock': true,
      'canViewReports': true,
      'canChangePrice': true,
      'canCollectDue': true,
    },
  });

  final DokanRole role;
  final bool hasSession;
  final String? salesmanPhone;
  final String? salesmanName;
  final String ownerPhone;
  final String ownerPassword;
  final String shopId;
  final String shopName;
  final String registeredName;
  final String shopCode;
  final Map<String, bool> permissions;

  int get roleIndex => role.index;
}
