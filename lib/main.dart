import 'package:flutter/material.dart';
import 'package:furtherance/routes/fur_home.dart';
import 'package:furtherance/routes/styles.dart';
import 'package:furtherance/globals.dart';
import 'package:furtherance/notification_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  _setPrefs();

  // Init local notifications
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  // FlutterLocalNotificationsPlugin();
  // const AndroidInitializationSettings initializationSettingsAndroid =
  // AndroidInitializationSettings('app_icon');
  // const IOSInitializationSettings initializationSettingsIOS =
  // IOSInitializationSettings(
  //     requestAlertPermission: false,
  //     requestBadgePermission: false,
  //     requestSoundPermission: false,
  // );
  // const InitializationSettings initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid,
  //     iOS: initializationSettingsIOS
  // );
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Furtherance',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: furPurple,
          onPrimary: Colors.white,
          secondary: Color(0xFFB179F1),
          onSecondary: Colors.white,
          background: Colors.white,
        )
        // scaffoldBackgroundColor: Colors.white70,
      ),
      initialRoute: 'home_page',
      routes: {
        'home_page': (context) => const FurHome(),
      },
    );
  }
}

void _setPrefs() {
  if (!(Prefs.getValue('prefsSet', false) as bool)) {
    Prefs.setValue('prefsSet', true);
    Prefs.setValue('pomodoro', false);
    Prefs.setValue('pomodoroTime', 25);
  }
}

