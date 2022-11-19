import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:furtherance/globals.dart';


class NotificationService {
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_stat_notifications');

    const IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: null
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future selectNotification(String payload) async {
    //Handle notification tapped logic here
  }

  void showAndroidPomodoroNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('fur-timer', 'pomodoro',
        channelDescription: 'Pomodoro timer',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Time\'s up!', 'It\'s time for a break.', platformChannelSpecifics,
        payload: 'item x');
  }

  void showTimedAndroidPomodoroNotification() async {
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Time\'s up!',
        'It\'s time for a break.',
        tz.TZDateTime.now(tz.local).add(Duration(seconds: (Prefs.getValue('pomodoroTime', 25) as int) * 60)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'fur-timer', 'pomodoro',
                channelDescription: 'Pomodoro Timer')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void cancelPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var pendingRequest in pendingNotificationRequests) {
      flutterLocalNotificationsPlugin.cancel(pendingRequest.id);
    }
  }

}