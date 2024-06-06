import 'package:flutter/material.dart';
import 'package:furtherance/routes/fur_home.dart';
import 'package:furtherance/routes/styles.dart';
import 'package:furtherance/globals.dart';
import 'package:furtherance/notification_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Prefs.init();
  _setPrefs();
  await Hive.initFlutter();
  await Hive.openBox('fur_box');
  await NotificationService().init();
  runApp(const Furtherance());
}

class Furtherance extends StatelessWidget {
  const Furtherance({Key? key}) : super(key: key);

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

