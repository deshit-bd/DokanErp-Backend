import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(() {
    service.disconnect();
  });
  return service;
});

class SocketService {
  io.Socket? _socket;
  String? _currentShopId;
  Function(Map<String, dynamic>)? _onNewNotification;

  void connect({
    required String? shopId,
    Function(Map<String, dynamic>)? onNewNotification,
  }) {
    if (_socket != null) {
      disconnect();
    }

    _currentShopId = shopId;
    _onNewNotification = onNewNotification;

    final url = AppConfig.apiBaseUrl;
    if (url.isEmpty) {
      debugPrint('[SOCKET] No API base URL configured. Skipping connection.');
      return;
    }

    debugPrint('[SOCKET] Connecting to $url...');
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[SOCKET] Connected successfully!');
      _joinShopRoom();
    });

    _socket!.onDisconnect((_) {
      debugPrint('[SOCKET] Disconnected!');
    });

    _socket!.onConnectError((err) {
      debugPrint('[SOCKET] Connect error: $err');
    });

    _socket!.on('new-notification', (data) {
      debugPrint('[SOCKET] Received new-notification: $data');
      if (_onNewNotification != null) {
        if (data is Map) {
          _onNewNotification!(Map<String, dynamic>.from(data));
        }
      }
    });

    _socket!.connect();
  }

  void _joinShopRoom() {
    if (_socket != null && _socket!.connected && _currentShopId != null) {
      debugPrint('[SOCKET] Emitting join-shop for $_currentShopId');
      _socket!.emit('join-shop', _currentShopId);
    }
  }

  void updateShop(String? shopId) {
    if (_currentShopId != shopId) {
      _currentShopId = shopId;
      _joinShopRoom();
    }
  }

  void disconnect() {
    if (_socket != null) {
      debugPrint('[SOCKET] Disconnecting...');
      _socket!.disconnect();
      _socket = null;
    }
    _currentShopId = null;
    _onNewNotification = null;
  }
}
