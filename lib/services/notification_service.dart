// Placeholder for future Push Notifications implementation.
library;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static Future<void> initialize() async {}

  static Future<void> scheduleContractExpiry({
    required String tenantId,
    required String tenantName,
    required DateTime expiryDate,
  }) async {}

  static Future<void> scheduleLatePaymentReminder({
    required String tenantId,
    required String tenantName,
    required String month,
  }) async {}

  static Future<void> cancelNotification(String id) async {}
  static Future<void> cancelAll() async {}
}
