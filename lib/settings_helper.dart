import 'package:shared_preferences/shared_preferences.dart';

class SettingsHelper {

  late SharedPreferences prefs;

  SettingsHelper() {
    getPrefs();
  }

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

}