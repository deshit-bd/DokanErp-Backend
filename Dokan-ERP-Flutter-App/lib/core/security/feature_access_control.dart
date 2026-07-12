import '../../modules/auth/domain/entities/dokan_role.dart';

enum DokanFeature {
  voiceAssist,
}

class FeatureAccessControl {
  static const Map<DokanRole, Set<DokanFeature>> _matrix = {
    DokanRole.owner: <DokanFeature>{},
    DokanRole.salesman: <DokanFeature>{},
  };

  static bool can(DokanRole role, DokanFeature feature) {
    return _matrix[role]?.contains(feature) ?? false;
  }
}
