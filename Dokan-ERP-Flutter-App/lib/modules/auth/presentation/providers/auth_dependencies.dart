import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_gateway.dart';
import '../../domain/repositories/auth_session_repository.dart';

final authSessionRepositoryProvider = Provider<AuthSessionRepository>(
  (_) => throw UnimplementedError('Override authSessionRepositoryProvider'),
);

final authGatewayProvider = Provider<AuthGateway?>(
  (_) => null,
);
