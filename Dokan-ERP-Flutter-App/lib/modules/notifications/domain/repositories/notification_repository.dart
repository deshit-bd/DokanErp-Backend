abstract interface class NotificationRepository {
  Future<List<Map<String, dynamic>>> list();
  Future<Map<String, dynamic>> loadPreferences();
  Future<void> updatePreferences(Map<String, dynamic> prefs);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> delete(String id);
  Future<void> create({
    required String type,
    required String title,
    required String message,
  });
}
