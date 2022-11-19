import 'package:furtherance/fur_task.dart';
import 'package:furtherance/fur_task_display.dart';
import 'package:intl/intl.dart';


class FurCombinedTaskList {

  List<FurTaskDisplay> orgList = [];
  // startDate day needs a leading 0 to properly organize the list
  final DateFormat sortFormatter = DateFormat('MMM dd, yyyy');

  FurCombinedTaskList(List<FurTask> allTasks) {
    for (FurTask task in allTasks) {
      Duration timeDifference = task.stopTime.difference(task.startTime);
      var totalSeconds = timeDifference.inSeconds;
      var startDate = sortFormatter.format(task.startTime);
      var fullName = '${task.name} ${task.tags}';
      var found = false;

      for (FurTaskDisplay orgTask in orgList) {
        if (orgTask.fullName == fullName && orgTask.startDate == startDate) {
          orgTask.addTime(totalSeconds);
          orgTask.addID(task.id);
          found = true;
        }
      }
      if (!found || orgList.isEmpty) {
        orgList.add(FurTaskDisplay(task.id, task.name, task.tags, task.stopTime, totalSeconds, startDate));
      }
    }
  }
}