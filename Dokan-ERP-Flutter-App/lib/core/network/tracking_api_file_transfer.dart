import 'api_activity_tracker.dart';
import 'api_file_transfer.dart';
import 'api_response.dart';

class TrackingApiFileTransfer implements ApiFileTransfer {
  const TrackingApiFileTransfer(this._delegate, this._activity);

  final ApiFileTransfer _delegate;
  final ApiActivityTracker _activity;

  @override
  void close() => _delegate.close();

  @override
  Future<ApiDownload> download(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String> headers = const {},
    bool authenticated = true,
  }) {
    return _activity.track(
      () => _delegate.download(
        path,
        query: query,
        headers: headers,
        authenticated: authenticated,
      ),
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> upload(
    String path, {
    required List<ApiUploadFile> files,
    Map<String, String> fields = const {},
    Map<String, String> headers = const {},
    bool authenticated = true,
  }) {
    return _activity.track(
      () => _delegate.upload(
        path,
        files: files,
        fields: fields,
        headers: headers,
        authenticated: authenticated,
      ),
    );
  }
}
