import '../../../../core/network/api_session.dart';
import '../../domain/repositories/subscription_session_repository.dart';

class SubscriptionSessionRepositoryImpl
    implements SubscriptionSessionRepository {
  const SubscriptionSessionRepositoryImpl(this._sessionStore);

  final ApiSessionStore _sessionStore;

  @override
  Future<bool> hasActiveSession() async {
    final session = await _sessionStore.read();
    return session != null &&
        session.accessToken.trim().isNotEmpty &&
        session.refreshToken.trim().isNotEmpty;
  }
}
