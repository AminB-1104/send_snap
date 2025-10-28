import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // In-memory list of fired notifications
  final ValueNotifier<List<String>> notifications = ValueNotifier([]);

  bool _initialized = false;

  /// Initialize the local notification service
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // When tapped, record it in our in-memory list
        notifications.value = [
          "Opened: ${response.payload ?? 'No message'}",
          ...notifications.value,
        ];
      },
    );

    _initialized = true;
  }

  /// Schedule a daily reminder at the chosen time
  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      0,
      'Log Your Expenses 💸',
      'Don’t forget to record today’s expenses!',
      scheduledDate, // this is a TZDateTime
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Reminders to log expenses',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // runs daily
      payload: "Daily Reminder",
    );
  }

  /// Instantly fire a notification (for testing)
  Future<void> showInstantNotification(String message) async {
    await initialize();

    await _notificationsPlugin.show(
      999,
      'Expense Tracker 💰',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_channel',
          'Instant Notifications',
          channelDescription: 'Immediate alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: message,
    );

    // Add to in-memory list (so it appears in NotificationListPage)
    notifications.value = [message, ...notifications.value];
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
