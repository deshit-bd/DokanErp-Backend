import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_authenticator.dart';
import '../../core/network/api_activity_tracker.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_client_factory.dart';
import '../../core/network/api_payload.dart';
import '../../core/network/api_file_transfer.dart';
import '../../core/network/http_api_file_transfer.dart';
import '../../core/network/api_session.dart';
import '../../core/network/refreshing_api_authenticator.dart';
import '../../core/network/tracking_api_client.dart';
import '../../core/network/tracking_api_file_transfer.dart';
import 'secure_api_session_store.dart';
import 'api_response_cache_store.dart';
import 'cached_api_client.dart';
import 'pending_api_mutation_store.dart';
import 'queued_api_client.dart';

final apiSessionStoreProvider = Provider<ApiSessionStore>(
  (ref) => SecureApiSessionStore(
    cache: ref.watch(apiResponseCacheStoreProvider),
    ref: ref,
  ),
);

final apiActivityTrackerProvider = Provider<ApiActivityTracker>((ref) {
  final tracker = ApiActivityTracker();
  ref.onDispose(tracker.dispose);
  return tracker;
});

final apiActivityCountProvider = StreamProvider<int>((ref) async* {
  final tracker = ref.watch(apiActivityTrackerProvider);
  yield tracker.activeRequests;
  yield* tracker.changes;
});

final apiResponseCacheStoreProvider = Provider<ApiResponseCacheStore>(
  (_) => const ApiResponseCacheStore(),
);

final apiAuthenticatorProvider = Provider<ApiAuthenticator>((ref) {
  final activity = ref.watch(apiActivityTrackerProvider);
  return RefreshingApiAuthenticator(
    sessionStore: ref.watch(apiSessionStoreProvider),
    refresh: (refreshToken) async {
      final client = TrackingApiClient(
        createApiClient(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          ref: ref,
        ),
        activity,
      );
      try {
        final response = await client.post(
          ApiEndpoints.refreshToken,
          body: {'refresh_token': refreshToken},
          authenticated: false,
        );
        final payload = ApiPayload.object(response);
        final tokenPayload = payload['tokens'];
        final session = ApiSession.fromJson(
          tokenPayload is Map
              ? Map<String, dynamic>.from(tokenPayload)
              : payload,
        );
        return session.accessToken.isEmpty ? null : session;
      } finally {
        client.close();
      }
    },
  );
});

final directApiClientProvider = Provider<ApiClient>((ref) {
  final client = TrackingApiClient(
    createApiClient(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      authenticator: ref.watch(apiAuthenticatorProvider),
      ref: ref,
    ),
    ref.watch(apiActivityTrackerProvider),
  );
  ref.onDispose(() => client.close(force: true));
  return client;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final transport = CachedApiClient(
    ref.watch(directApiClientProvider),
    ref.watch(apiResponseCacheStoreProvider),
    ref.watch(apiSessionStoreProvider),
  );
  const queue = PendingApiMutationStore();
  unawaited(queue.flush(transport));

  // Auto-sync: Flush the queue every 10 seconds to push offline changes to DB when online
  final timer = Timer.periodic(const Duration(seconds: 10), (_) {
    unawaited(queue.flush(transport));
  });

  final client = QueuedApiClient(transport, queue);
  ref.onDispose(() {
    timer.cancel();
    client.close(force: true);
  });
  return client;
});

final apiConfiguredProvider =
    Provider<bool>((ref) => AppConfig.isApiConfigured);

final apiFileTransferProvider = Provider<ApiFileTransfer>((ref) {
  final transfer = TrackingApiFileTransfer(
    HttpApiFileTransfer(
      baseUrl: AppConfig.apiBaseUrl,
      timeout: AppConfig.receiveTimeout,
      authenticator: ref.watch(apiAuthenticatorProvider),
    ),
    ref.watch(apiActivityTrackerProvider),
  );
  ref.onDispose(transfer.close);
  return transfer;
});

final hasActiveApiSessionProvider = FutureProvider<bool>((ref) async {
  final session = await ref.watch(apiSessionStoreProvider).read();
  return session != null &&
      session.accessToken.isNotEmpty &&
      session.refreshToken.isNotEmpty;
});
