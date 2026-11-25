class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // TODO: Implementasi oleh Orang B
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    // TODO: Implementasi oleh Orang B
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // TODO: Implementasi oleh Orang B
  }

  Future<void> cancelNotification(int id) async {
    // TODO: Implementasi oleh Orang B
  }
}
