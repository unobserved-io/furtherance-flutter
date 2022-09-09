import 'database_helper.dart';
import 'package:furtherance/globals.dart';


class TimerHelper {
  late DateTime startTime;
  late DateTime stopTime;
  late String taskName;
  late String taskTags;
  late String nameAndTags = '';

  DatabaseHelper databaseHelper = DatabaseHelper();

  void setStartTime(DateTime startTime) {
    this.startTime = startTime;
  }

  void setStopTime(DateTime stopTime) {
    this.stopTime = stopTime;
  }

  void startTimer() {
    setStartTime(DateTime.now());
    separateTags();
  }

  void stopTimer(bool lateStop) {
    if (!lateStop) {
      setStopTime(DateTime.now());
    } else {
      setStopTime(startTime.add(Duration(minutes: Prefs.getValue('pomodoroTime', 25) as int)));
    }
    databaseHelper.addData(taskName, startTime, stopTime, taskTags);
  }

  void separateTags() {
    var splitTags = nameAndTags.trim().split('#');
    // Get and remove task name from tags list
    taskName = splitTags[0].trim();
    splitTags.removeAt(0);
    // Trim each element and lowercase them
    for (int i = 0; i < splitTags.length; i++) {
      splitTags[i] = splitTags[i].trim().toLowerCase();
    }
    // Don't allow empty tags
    splitTags.removeWhere((element) => element.isEmpty);
    // Don't allow duplicate tags
    splitTags = splitTags.toSet().toList();
    taskTags = splitTags.join(' #');
  }

}