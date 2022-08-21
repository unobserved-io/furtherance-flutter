import 'package:flutter/material.dart';
import 'package:furtherance/database_helper.dart';
import 'package:furtherance/fur_combined_task_list.dart';
import 'package:furtherance/fur_task.dart';
import 'package:furtherance/fur_task_display.dart';
import 'package:furtherance/routes/fur_new_task.dart';
import 'package:furtherance/routes/fur_task_group.dart';
import 'styles.dart';
import 'package:furtherance/timer_helper.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:grouped_list/grouped_list.dart';
import 'fur_task_edit.dart';
import 'package:intl/intl.dart';


class FurHome extends StatefulWidget {
  const FurHome({Key? key}) : super(key: key);

  @override
  State<FurHome> createState() => _FurHomeState();
}

class _FurHomeState extends State<FurHome> {
  final fieldText = TextEditingController();
  DatabaseHelper databaseHelper = DatabaseHelper();
  static const startIcon = Icon(
    Icons.play_arrow_rounded,
    color: Colors.white,
    size: 50.0,
  );
  static const stopIcon = Icon(
    Icons.stop_rounded,
    color: Colors.white,
    size: 50.0,
  );
  Icon startStopIcon = startIcon;

  final _stopWatchTimer = StopWatchTimer();
  TimerHelper timerHelper = TimerHelper();
  bool taskEntryEnabled = true;

  // List<FurTask> _allTasks = [];
  List<FurTaskDisplay> _allDisplayTasks = [];

  void refreshDatabase() async {
    List<FurTask> newTaskList = await databaseHelper.retrieve();
    FurCombinedTaskList furCombinedTaskList = FurCombinedTaskList(newTaskList);
    setState(() {
      _allDisplayTasks = furCombinedTaskList.orgList;
    });
  }

  void startStop() {
    if (_stopWatchTimer.isRunning) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      timerHelper.stopTimer();
      startStopIcon = startIcon;
      fieldText.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      taskEntryEnabled = true;
      refreshDatabase();
    } else {
      if (timerHelper.nameAndTags.isNotEmpty) {
        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
        timerHelper.startTimer();
        startStopIcon = stopIcon;
        FocusManager.instance.primaryFocus?.unfocus();
        taskEntryEnabled = false;
      }
    }
  }

  String _dateDisplay(String displayDate) {
    // Remove the year if it matches the current year.
    if (displayDate.substring(displayDate.length - 4) == DateTime.now().year.toString()) {
      displayDate = displayDate.substring(0, displayDate.length - 6);
    }

    if (displayDate == DateFormat.MMMd().format(DateTime.now())) {
      displayDate = 'Today';
    }
    else if (displayDate == DateFormat.MMMd().format(DateTime.now().subtract(const Duration(days:1)))) {
      displayDate = 'Yesterday';
    }

    return displayDate;
  }

  @override
  void initState() {
    super.initState();
    refreshDatabase();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FurNewTask()
                      ),
                    ).then((value) => refreshDatabase());
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 30.0,
                  ),
                  color: Colors.black,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    darkFurPurple,
                    lightFurPurple,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                  bottomLeft: Radius.circular(40.0)
                )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    StreamBuilder<int>(
                      stream: _stopWatchTimer.secondTime,
                      initialData: _stopWatchTimer.secondTime.value,
                      builder: (context, snap) {
                        final secs = snap.data;
                        String timerString = '00:00:00';
                        if (secs != null) {
                          final h = (secs / 3600).floor().toString().padLeft(2, '0');
                          final m = (secs % 3600 / 60).floor().toString().padLeft(2, '0');
                          final s = (secs % 60).floor().toString().padLeft(2, '0');

                          timerString = '$h:$m:$s';
                        }
                        return Text(
                          timerString,
                          style: const TextStyle(
                            fontSize: 80.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            maxLines: 1,
                            onSubmitted: (val) {
                              setState(() {
                                startStop();
                              });
                            },
                            onChanged: (text) {
                              timerHelper.nameAndTags = text;
                            },
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none,
                            ),
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0)
                            ),
                            controller: fieldText,
                            enabled: taskEntryEnabled,
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(
                            minHeight: 70.0,
                            minWidth: 50.0,
                          ),
                          onPressed: () {

                          },
                          icon: startStopIcon,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Expanded(
              child: GroupedListView<FurTaskDisplay, String>(
                elements: _allDisplayTasks,
                groupBy: (task) => task.startDate,
                groupSeparatorBuilder: (String groupByValue) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  child: Text(
                    _dateDisplay(groupByValue),
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
                itemBuilder: (_, FurTaskDisplay task) => _createItem(context, task),
                itemComparator: (item1, item2) => item1.stopTime.compareTo(item2.stopTime),
                useStickyGroupSeparators: true,
                floatingHeader: false,
                order: GroupedListOrder.DESC,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createItem(BuildContext ctx, FurTaskDisplay task) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          if (task.idsWithin.length > 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FurTaskGroup(idList: task.idsWithin)
              ),
            ).then((value) => refreshDatabase());
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FurTaskEdit(id: task.idsWithin[0]) //TODO
              ),
            ).then((value) => refreshDatabase());
          }
        },
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
          title: Text(task.name),
          subtitle: task.tags == '#' ? null : Text(task.tags),
          trailing: Text(
            task.totalTime,
            // TODO add repeat button? Or should that be a swipe?
          ),
        ),
      ),
    );
  }
}