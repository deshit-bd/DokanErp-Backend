import 'dart:async';
import 'api_activity_tracker.dart';
import 'api_client.dart';
import 'api_response.dart';

class TrackingApiClient implements ApiClient {
  const TrackingApiClient(this._delegate, this._activity);

  final ApiClient _delegate;
  final ApiActivityTracker _activity;

  @override
  void close({bool force = false}) => _delegate.close(force: force);

  @override
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    final isUntracked = Zone.current[#untracked_api_request] == true;
    final shouldTrack = headers?['X-No-Track'] != 'true' && !isUntracked;
    final outgoingHeaders = headers != null
        ? (Map<String, String>.from(headers)..remove('X-No-Track'))
        : null;
    if (shouldTrack) {
      return _activity.track(
        () => _delegate.get(
          path,
          query: query,
          headers: outgoingHeaders,
          authenticated: authenticated,
        ),
      );
    } else {
      return _delegate.get(
        path,
        query: query,
        headers: outgoingHeaders,
        authenticated: authenticated,
      );
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    final isUntracked = Zone.current[#untracked_api_request] == true;
    final shouldTrack = headers?['X-No-Track'] != 'true' && !isUntracked;
    final outgoingHeaders = headers != null
        ? (Map<String, String>.from(headers)..remove('X-No-Track'))
        : null;
    if (shouldTrack) {
      return _activity.track(
        () => _delegate.post(
          path,
          body: body,
          query: query,
          headers: outgoingHeaders,
          authenticated: authenticated,
        ),
      );
    } else {
      return _delegate.post(
        path,
        body: body,
        query: query,
        headers: outgoingHeaders,
        authenticated: authenticated,
      );
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    final isUntracked = Zone.current[#untracked_api_request] == true;
    final shouldTrack = headers?['X-No-Track'] != 'true' && !isUntracked;
    final outgoingHeaders = headers != null
        ? (Map<String, String>.from(headers)..remove('X-No-Track'))
        : null;
    if (shouldTrack) {
      return _activity.track(
        () => _delegate.put(
          path,
          body: body,
          query: query,
          headers: outgoingHeaders,
          authenticated: authenticated,
        ),
      );
    } else {
      return _delegate.put(
        path,
        body: body,
        query: query,
        headers: outgoingHeaders,
        authenticated: authenticated,
      );
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    final isUntracked = Zone.current[#untracked_api_request] == true;
    final shouldTrack = headers?['X-No-Track'] != 'true' && !isUntracked;
    final outgoingHeaders = headers != null
        ? (Map<String, String>.from(headers)..remove('X-No-Track'))
        : null;
    if (shouldTrack) {
      return _activity.track(
        () => _delegate.patch(
          path,
          body: body,
          query: query,
          headers: outgoingHeaders,
          authenticated: authenticated,
        ),
      );
    } else {
      return _delegate.patch(
        path,
        body: body,
        query: query,
        headers: outgoingHeaders,
        authenticated: authenticated,
      );
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    final isUntracked = Zone.current[#untracked_api_request] == true;
    final shouldTrack = headers?['X-No-Track'] != 'true' && !isUntracked;
    final outgoingHeaders = headers != null
        ? (Map<String, String>.from(headers)..remove('X-No-Track'))
        : null;
    if (shouldTrack) {
      return _activity.track(
        () => _delegate.delete(
          path,
          body: body,
          query: query,
          headers: outgoingHeaders,
          authenticated: authenticated,
        ),
      );
    } else {
      return _delegate.delete(
        path,
        body: body,
        query: query,
        headers: outgoingHeaders,
        authenticated: authenticated,
      );
    }
  }
}
