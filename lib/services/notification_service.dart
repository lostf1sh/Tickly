import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/timer_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<bool> requestPermissions() async {
    final androidGranted = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission() ?? false;

    final iosGranted = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;

    return androidGranted || iosGranted;
  }

  Future<bool> areNotificationsEnabled() async {
    final androidEnabled = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled() ?? false;

    final iosEnabled = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;

    return androidEnabled || iosEnabled;
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final timerId = response.payload!;
      debugPrint('Notification tapped for timer: $timerId');
    }
  }

  Future<void> scheduleTimerNotification(TimerModel timer) async {
    if (!timer.hasNotification || timer.reminderHours == null) return;

    final reminderTime = timer.targetDateTime
        .subtract(Duration(hours: timer.reminderHours!));

    if (reminderTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      timer.id.hashCode,
      'Timer Reminder',
      '${timer.name} will end in ${timer.reminderHours} hour${timer.reminderHours == 1 ? '' : 's'}',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_reminders',
          'Timer Reminders',
          channelDescription: 'Notifications for timer reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: timer.id,
    );
  }

  Future<void> scheduleDailyReminder(TimerModel timer) async {
    if (!timer.hasDailyReminder || timer.dailyReminderTime == null) return;
    
    final now = DateTime.now();
    final todayReminder = DateTime(
      now.year,
      now.month,
      now.day,
      timer.dailyReminderTime!.hour,
      timer.dailyReminderTime!.minute,
    );
    
    DateTime scheduledTime;
    if (todayReminder.isBefore(now)) {
      scheduledTime = todayReminder.add(const Duration(days: 1));
    } else {
      scheduledTime = todayReminder;
    }
    
    final daysLeft = timer.daysLeft;
    final message = daysLeft == 0 
        ? '${timer.name} expires today!'
        : '${timer.name} has $daysLeft day${daysLeft == 1 ? '' : 's'} left';
    
    await _notifications.zonedSchedule(
      _getDailyReminderId(timer.id),
      'Daily Reminder: ${timer.name}',
      message,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily countdown reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: timer.id,
    );
  }

  int _getDailyReminderId(String timerId) {
    return '${timerId}_daily'.hashCode;
  }

  Future<void> sendTestNotification(TimerModel timer) async {
    final daysLeft = timer.daysLeft;
    final message = daysLeft == 0 
        ? '${timer.name} expires today!'
        : '${timer.name} has $daysLeft day${daysLeft == 1 ? '' : 's'} left';

    await _notifications.show(
      '${timer.id}_test'.hashCode,
      'Test Daily Reminder',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily countdown reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelTimerNotification(TimerModel timer) async {
    await _notifications.cancel(timer.id.hashCode);
  }

  Future<void> cancelDailyReminder(TimerModel timer) async {
    await _notifications.cancel(_getDailyReminderId(timer.id));
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 