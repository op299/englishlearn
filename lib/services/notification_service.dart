import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _reminderTimesKey = 'reminder_times';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _channelId = 'study_reminder_channel';
  static const String _channelName = 'Study Reminders';
  static const String _channelDescription =
      'Reminders for daily study sessions';

  Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(initSettings);

    // Request permissions on Android 13+
    await _requestPermissions();

    // Reschedule any pending reminders
    if (await _isEnabled()) {
      await _rescheduleAll();
    }
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Get all saved reminder times (as "HH:mm" strings)
  Future<List<String>> getReminderTimes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_reminderTimesKey) ?? [];
  }

  /// Check if notifications are enabled
  Future<bool> _isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// Save a list of reminder times and reschedule
  Future<void> saveReminderTimes(List<String> times) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_reminderTimesKey, times);

    // Cancel old notifications and schedule new ones
    await _cancelAll();
    if (await _isEnabled()) {
      await _scheduleNotifications(times);
    }
  }

  /// Add a single reminder time
  Future<void> addReminderTime(String time) async {
    final times = await getReminderTimes();
    if (!times.contains(time)) {
      times.add(time);
      times.sort();
      await saveReminderTimes(times);
    }
  }

  /// Remove a single reminder time
  Future<void> removeReminderTime(String time) async {
    final times = await getReminderTimes();
    times.remove(time);
    await saveReminderTimes(times);
  }

  /// Enable/disable all notifications
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    if (enabled) {
      final times = await getReminderTimes();
      await _scheduleNotifications(times);
    } else {
      await _cancelAll();
    }
  }

  /// Schedule notifications for the given list of "HH:mm" times
  Future<void> _scheduleNotifications(List<String> times) async {
    for (int i = 0; i < times.length; i++) {
      final parts = times[i].split(':');
      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      await _scheduleDaily(i, hour, minute, times[i]);
    }
  }

  Future<void> _scheduleDaily(
    int id,
    int hour,
    int minute,
    String timeLabel,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      'Time to Study! 📚',
      'Your study session at $timeLabel is starting now.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel all scheduled notifications
  Future<void> _cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Reschedule all saved reminders
  Future<void> _rescheduleAll() async {
    final times = await getReminderTimes();
    if (times.isNotEmpty) {
      await _scheduleNotifications(times);
    }
  }
}
