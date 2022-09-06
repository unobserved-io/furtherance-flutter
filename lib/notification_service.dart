import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    AndroidInitializationSettings('app_icon');

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

}