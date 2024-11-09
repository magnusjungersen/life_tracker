import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationsHandler {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    //initialize timezones database
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("orb"); // app icon
    
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Method to request notification permission using permission_handler
  static Future<bool> requestNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      return true; // Permission is already granted
    } else {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
  }

  static Future<void> scheduleNotifications() async {
    // notifications (hour, minute, id)
    await _scheduleNotification(9, 0, 1); // 9 AM
    await _scheduleNotification(22, 0, 0); // 10 PM
    await _scheduleNotification(16, 50, 2); // test notification
  }

  static Future<void> _scheduleNotification(int hour, int minute, int id) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Life Tracker',
      'Please give me data, Daddy uWu',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Daily reminders for data entry',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}