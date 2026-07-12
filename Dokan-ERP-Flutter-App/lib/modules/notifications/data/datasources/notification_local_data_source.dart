import 'package:shared_preferences/shared_preferences.dart';

class NotificationLocalDataSource {
  const NotificationLocalDataSource();

  static const _key = 'dokan_notifications_v1';

  Future<String?> read() async {
    return (await SharedPreferences.getInstance()).getString(_key);
  }

  Future<void> write(String snapshot) async {
    await (await SharedPreferences.getInstance()).setString(_key, snapshot);
  }
}
