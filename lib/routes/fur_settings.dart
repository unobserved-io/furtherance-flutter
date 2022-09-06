import 'package:flutter/material.dart';
import 'package:furtherance/globals.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';


class FurSettings extends StatefulWidget {
  const FurSettings({Key? key}) : super(key: key);

  @override
  State<FurSettings> createState() => _FurSettingsState();
}

class _FurSettingsState extends State<FurSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
      ),
      body: SafeArea(
        child: ListView(children: <Widget>[
          ListTile(
            title: const Text('Pomodoro Timer'),
            trailing: Switch(
              value: Prefs.getValue('pomodoro', false) as bool,
              onChanged: (val) {
                setState(() {
                  Prefs.setValue('pomodoro', val);
                });
              },
            ),
          ),
          if (Prefs.getValue('pomodoro', false) as bool) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SpinBox(
                min: 1,
                max: 180,
                value: (Prefs.getValue('pomodoroTime', 25) as int).toDouble(),
                decoration: const InputDecoration(labelText: 'Interval (in minutes)'),
                onChanged: (val) => Prefs.setValue('pomodoroTime', val.toInt()),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
