import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_role.dart';

final authRoleProvider = StateProvider<UserRole>((ref) => UserRole.owner);
final rememberMeProvider = StateProvider<bool>((ref) => true);
final loginPasswordHiddenProvider = StateProvider<bool>((ref) => true);
