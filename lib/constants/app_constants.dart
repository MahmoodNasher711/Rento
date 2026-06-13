class AppConstants {
  // Database
  static const String databaseName = "rento_db.db";
  static const int databaseVersion = 3;

  // Date Formats
  static const String dateFormat = "yyyy-MM-dd";
  static const String dateFormatDisplay = "dd/MM/yyyy";
  static const String monthFormat = "MMMM yyyy";

  // Pagination
  static const int itemsPerPage = 10;

  // Notification
  static const int contractExpiryNotificationDays = 30;
  static const int paymentReminderDays = 3;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxPhoneLength = 15;
  static const int maxNotesLength = 500;
  static const int maxDescriptionLength = 200;

  // Default Values
  static const double defaultRentAmount = 0.0;
  static const double defaultExpenseAmount = 0.0;
}