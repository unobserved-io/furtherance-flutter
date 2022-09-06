import 'dart:async';
import 'package:flutter/material.dart';
import 'package:furtherance/database_helper.dart';
import 'package:furtherance/fur_combined_task_list.dart';
import 'package:furtherance/fur_task.dart';
import 'package:furtherance/fur_task_display.dart';
import 'package:furtherance/routes/fur_new_task.dart';
import 'package:furtherance/routes/fur_report.dart';
import 'package:furtherance/routes/fur_settings.dart';
import 'package:furtherance/routes/fur_task_group.dart';
import 'styles.dart';
import 'package:furtherance/timer_helper.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:grouped_list/grouped_list.dart';
import 'fur_task_edit.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:furtherance/globals.dart';
import 'package:furtherance/notification_service.dart';


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

  List<FurTaskDisplay> _allDisplayTasks = [];

  void refreshDatabase() async {
    setState(() {
      _allDisplayTasks.clear();
    });
    List<FurTask> newTaskList = await databaseHelper.retrieve();
    FurCombinedTaskList furCombinedTaskList = FurCombinedTaskList(newTaskList);
    setState(() {
      _allDisplayTasks = furCombinedTaskList.orgList;
    });
  }

  void resetPage() {
    setState(() {
      _allDisplayTasks.clear();
      refreshDatabase();
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
      resetPage();
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

  void timerRunningSnack() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    var snackBar = const SnackBar(
        content: Text('Not while the timer is running.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    resetPage();
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
                    if (_stopWatchTimer.isRunning) {
                      timerRunningSnack();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FurNewTask()),
                      ).then((value) => resetPage());
                    }
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 30.0,
                  ),
                  color: Colors.black,
                ),
                IconButton(
                  onPressed: () {
                    if (_stopWatchTimer.isRunning) {
                      timerRunningSnack();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FurReport()),
                      ).then((value) => resetPage());
                    }
                  },
                  icon: const Icon(
                    Icons.list,
                    size: 30.0,
                  ),
                  color: Colors.black,
                ),
                IconButton(
                  onPressed: () {
                    if (_stopWatchTimer.isRunning) {
                      timerRunningSnack();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FurSettings()),
                      ).then((value) => resetPage());
                    }
                  },
                  icon: const Icon(
                    Icons.settings,
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
                        var secs = snap.data;
                        String timerString = '00:00:00';
                        if (Prefs.getValue('pomodoro', false) as bool && (secs == 0 || secs == null)) {
                          int pomodoroTime = (Prefs.getValue('pomodoroTime', 25) as int) * 60;
                          final h = (pomodoroTime / 3600).floor().toString().padLeft(2, '0');
                          final m = (pomodoroTime % 3600 / 60).floor().toString().padLeft(2, '0');
                          final s = (pomodoroTime % 60).floor().toString().padLeft(2, '0');

                          timerString = '$h:$m:$s';
                        }
                        if (secs != null && secs != 0) {
                          if (Prefs.getValue('pomodoro', false) as bool) {
                            final pomodoroTime = (Prefs.getValue('pomodoroTime', 25) as int) * 60;
                            secs = pomodoroTime - secs;
                            if (secs == 0) {
                              WidgetsBinding.instance.addPostFrameCallback((_){
                                startStop();
                                NotificationService().showAndroidPomodoroNotification();
                              });
                            }
                          }
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
                            textCapitalization: TextCapitalization.sentences,
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
                              contentPadding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                              hintText: 'Task name #tags'
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
                            setState(() {
                              startStop();
                            });
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
                stickyHeaderBackgroundColor: const Color(0xFFFAFAFA),
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
    return SwipeTo(
      onLeftSwipe: () {
        if (_stopWatchTimer.isRunning) {
          timerRunningSnack();
        } else {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete'),
              content: task.idsWithin.length > 1
                  ? const Text(
                      'Are you sure you want to delete this whole group of tasks?')
                  : const Text('Are you sure you want to delete this task?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (task.idsWithin.length > 1) {
                      // TODO remove these 'finished' vars
                      var finished = databaseHelper.deleteGroup(task.idsWithin);
                    } else {
                      var finished =
                          databaseHelper.deleteTask(task.idsWithin[0]);
                    }
                    _onLoading();
                  },
                  child: const Text('DELETE'),
                ),
              ],
            ),
          );
        }
      },
      onRightSwipe: () {
        if (_stopWatchTimer.isRunning) {
          timerRunningSnack();
        } else {
          fieldText.text = task.fullName;
          timerHelper.nameAndTags = task.fullName;
          setState(() {
            startStop();
          });
        }
      },
      iconOnRightSwipe: Icons.refresh,
      iconOnLeftSwipe: task.idsWithin.length > 1 ? Icons.delete_forever : Icons.delete,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        elevation: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        child: InkWell(
          onTap: () {
            if (_stopWatchTimer.isRunning) {
              timerRunningSnack();
            } else {
              if (task.idsWithin.length > 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FurTaskGroup(idList: task.idsWithin)),
                ).then((value) {
                  setState(() {
                    _allDisplayTasks.clear();
                    refreshDatabase();
                  });
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FurTaskEdit(id: task.idsWithin[0])),
                ).then((value) => resetPage());
              }
            }
          },
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
            title: Text(task.name),
            subtitle: task.tags.isEmpty ? null : Text(task.tags),
            trailing: Text(
              task.totalTime,
            ),
          ),
        ),
      ),
    );
  }

  void _onLoading() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(height: 10.0,),
              CircularProgressIndicator(),
              SizedBox(height: 10.0,),
              Text('Deleting...'),
              SizedBox(height: 10.0,),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, 'home_page');
  }
}