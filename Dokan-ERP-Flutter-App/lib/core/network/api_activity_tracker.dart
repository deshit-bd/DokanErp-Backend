import 'dart:async';

class ApiActivityTracker {
  ApiActivityTracker();

  final StreamController<int> _controller =
      StreamController<int>.broadcast(sync: true);
  int _activeRequests = 0;

  int get activeRequests => _activeRequests;
  bool get isActive => _activeRequests > 0;
  Stream<int> get changes => _controller.stream;

  Future<T> track<T>(Future<T> Function() request) async {
    _setActiveRequests(_activeRequests + 1);
    try {
      return await request();
    } finally {
      _setActiveRequests(_activeRequests - 1);
    }
  }

  void _setActiveRequests(int value) {
    _activeRequests = value < 0 ? 0 : value;
    if (!_controller.isClosed) {
      _controller.add(_activeRequests);
    }
  }

  Future<void> dispose() => _controller.close();
}
