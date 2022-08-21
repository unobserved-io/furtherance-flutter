import 'package:flutter/material.dart';
import 'package:furtherance/routes/fur_home.dart';
import 'package:furtherance/routes/fur_task_group.dart';
import 'package:furtherance/routes/styles.dart';

void main() {
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
        // 'edit_task_page': (context) => FurEditTask(),
        // 'new_task_page': (context) => FurNewTask(),
        // 'task_group_page': (context) => FurTaskGroup(),
      },
    );
  }
}
