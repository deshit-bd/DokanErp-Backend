import '../../modules/auth/domain/entities/dokan_role.dart';

enum DokanPermission {
  salesCreate,
  salesManage,
  productsView,
  stockAdjust,
  stockDelete,
  stockView,
  notificationsView,
  notificationsSend,
  reportsView,
  supplierManage,
  staffManage,
  settingsManage,
}

class DokanAccessControl {
  static const Map<DokanRole, Set<DokanPermission>> _matrix = {
    DokanRole.owner: {
      DokanPermission.salesCreate,
      DokanPermission.salesManage,
      DokanPermission.productsView,
      DokanPermission.stockAdjust,
      DokanPermission.stockDelete,
      DokanPermission.stockView,
      DokanPermission.notificationsView,
      DokanPermission.notificationsSend,
      DokanPermission.reportsView,
      DokanPermission.supplierManage,
      DokanPermission.staffManage,
      DokanPermission.settingsManage,
    },
    DokanRole.salesman: {
      DokanPermission.salesCreate,
      DokanPermission.productsView,
      DokanPermission.stockView,
      DokanPermission.notificationsSend,
    },
  };

  static bool can(DokanRole role, DokanPermission permission) {
    return _matrix[role]?.contains(permission) ?? false;
  }

  static bool canAny(DokanRole role, Iterable<DokanPermission> permissions) {
    for (final permission in permissions) {
      if (can(role, permission)) {
        return true;
      }
    }
    return false;
  }
}
