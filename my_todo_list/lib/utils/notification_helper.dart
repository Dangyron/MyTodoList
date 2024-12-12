import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

class NotificationHelper {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationHelper() {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInitialization = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iOSInitialization,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle tap on the notification
      },
    );
  }

  Future<void> scheduleReminderNotification(Task task) async {
    if (task.reminderDate == null) return;
    // TODO snooze task
    final scheduledTime = task.reminderDate!;

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Task Reminders',
      channelDescription: 'Notification channel for task reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails();
    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.hashCode,
      'Task Reminder',
      task.title,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }
}
