import 'package:flutter/material.dart';
import 'package:furtherance/routes/styles.dart';
import 'styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:furtherance/fur_task.dart';
import 'package:tuple/tuple.dart';
import 'package:furtherance/database_helper.dart';


class FurReport extends StatefulWidget {
  const FurReport({Key? key}) : super(key: key);

  @override
  State<FurReport> createState() => _FurReportState();
}

class _FurReportState extends State<FurReport> {
  String dateRange = 'Past week';
  String sortBy = 'Task';
  String filterBy = 'Task';
  String filterText = '';
  bool filterCheck = false;
  late List<FurTask> allTasks;
  DateTime rangeStartDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day
      ).subtract(const Duration(days: 6));
  DateTime rangeStopDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final DateFormat formatter = DateFormat('MMM dd, yyyy');
  String totalTimeLabel = '';
  List<String> splitTagsList = [];

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Tuple3<String, int, List<Tuple2<String, int>>>> sortedTasksByDuration = [];

  void getAllTasks() async {
    allTasks = await databaseHelper.retrieve();
  }

  String durationToString(int duration) {
    var hours = duration ~/ Duration.secondsPerHour;
    duration = duration.remainder(Duration.secondsPerHour);

    var minutes = duration ~/ Duration.secondsPerMinute;
    duration = duration.remainder(Duration.secondsPerMinute);

    var minutesPadding = minutes < 10 ? "0" : "";

    var seconds = duration;

    var secondsPadding = seconds < 10 ? "0" : "";

    return "$hours:"
        "$minutesPadding$minutes:"
        "$secondsPadding$seconds";
  }

  void _furReportGenerator() {
    int totalTimeReported = 0;
    List<Tuple2<FurTask, int>> tasksInRange = [];

    for (FurTask task in allTasks) {
      // Check if start time is in date range and if not remove it from task_list
      final taskStartDate = DateTime(task.startTime.year, task.startTime.month, task.startTime.day);
      if (rangeStartDate.subtract(const Duration(days: 1)).isBefore(taskStartDate)
        && rangeStopDate.add(const Duration(days: 1)).isAfter(taskStartDate) ) {
        if (filterCheck && filterText.trim().isNotEmpty) {
          if (filterBy == 'Task') {
            // If user set a task filter
            List<String> splitTasks = filterText.split(',');
            // Trim and lowercase each task
            for (int i = 0; i < splitTasks.length; i++) {
              splitTasks[i] = splitTasks[i].trim().toLowerCase();
            }
            // Don't allow empty tasks
            splitTasks.removeWhere((element) => element.isEmpty);
            // Handle duplicate tasks
            splitTasks = splitTasks.toSet().toList();
            
            if (splitTasks.contains(task.name.toLowerCase())) {
              Duration timeDifference = task.stopTime.difference(task.startTime);
              totalTimeReported += timeDifference.inSeconds;
              tasksInRange.add(Tuple2<FurTask, int>(task, timeDifference.inSeconds));
            }
          } else if (filterBy == 'Tag') {
            // If user set a tag filter
            List<String> splitTags = filterText.split('#');
            // Trim and lowercase each task
            for (int i = 0; i < splitTags.length; i++) {
              splitTags[i] = splitTags[i].trim().toLowerCase();
            }
            // Don't allow empty tasks
            splitTags.removeWhere((element) => element.isEmpty);
            // Handle duplicate tasks
            splitTagsList = splitTags.toSet().toList();

            // Get and trim task's tags
            List<String> splitTaskTags = task.tags.split('#');
            for (int i = 0; i < splitTaskTags.length; i++) {
              splitTaskTags[i] = splitTaskTags[i].trim();
            }
            splitTaskTags.removeWhere((element) => element.isEmpty);

            // Remove all tags that don't match the user's chosen tags
            splitTaskTags.removeWhere((element) => !splitTagsList.contains(element));

            if (splitTaskTags.isNotEmpty) {
              Duration timeDifference = task.stopTime.difference(task.startTime);
              totalTimeReported += timeDifference.inSeconds;
              tasksInRange.add(Tuple2<FurTask, int>(task, timeDifference.inSeconds));
            }
          }
        } else {
          // Filter box not checked
          Duration timeDifference = task.stopTime.difference(task.startTime);
          totalTimeReported += timeDifference.inSeconds;
          tasksInRange.add(Tuple2<FurTask, int>(task, timeDifference.inSeconds));
        }
      }
    }

    if (tasksInRange.isEmpty) {
      totalTimeLabel = 'No results';
    } else {
      totalTimeLabel = 'Total time: ${durationToString(totalTimeReported)}';
    }

    if (sortBy == 'Task') {
      List<List<Tuple2<FurTask, int>>> tasksByName = [];

      // Group tasks by name
      for (Tuple2<FurTask, int> t in tasksInRange) {
        FurTask task = t.item1;
        int timeDiff = t.item2;
        bool unique = true;
        for (int i = 0; i < tasksByName.length; i++) {
          FurTask tbn = tasksByName[i][0].item1;
          if (tbn.name == task.name) {
            tasksByName[i].add(Tuple2(task, timeDiff));
            unique = false;
          }
        }
        if (unique) {
          List<Tuple2<FurTask, int>> newNameList = [];
          newNameList.add(Tuple2(task, timeDiff));
          tasksByName.add(newNameList);
        }
      }

      for (List<Tuple2<FurTask, int>> tbn in tasksByName) {
        int totalDuration = 0;
        List<Tuple2<String, int>> tagsDur = [];
        String taskName = tbn[0].item1.name;

        for (Tuple2<FurTask, int> tbnTuple in tbn) {
          FurTask task = tbnTuple.item1;
          int taskDuration = tbnTuple.item2;
          totalDuration += taskDuration;

          if (task.tags.isNotEmpty) {
            bool unique = true;
            for (int i = 0; i < tagsDur.length; i++) {
              String tags = tagsDur[i].item1;
              int dur = tagsDur[i].item2;
              if (tags == task.tags) {
                int newDur = dur + taskDuration;
                tagsDur[i] = Tuple2(task.tags, newDur);
                unique = false;
              }
            }
            if (unique) {
              tagsDur.add(Tuple2(task.tags, taskDuration));
            }
          }
        }
        // Sort tasks and tags in descending order by duration
        tagsDur.sort((Tuple2 a, Tuple2 b) => a.item2.compareTo(b.item2));
        tagsDur = List.from(tagsDur.reversed);
        sortedTasksByDuration.add(Tuple3(taskName, totalDuration, tagsDur));
        sortedTasksByDuration.sort((Tuple3 a, Tuple3 b) => a.item2.compareTo(b.item2));
        sortedTasksByDuration = List.from(sortedTasksByDuration.reversed);
      }

    } else { // Sort By Tag
      List<List<Tuple3<String, FurTask, int>>> tasksByTag = [];

      // Group tasks by tag
      for (Tuple2<FurTask, int> t in tasksInRange) {
        FurTask task = t.item1;
        int timeDiff = t.item2;
        var splitTags = task.tags.split('#');
        // Trim each element and lowercase them
        for (int i = 0; i < splitTags.length; i++) {
          splitTags[i] = splitTags[i].trim().toLowerCase();
        }
        // Don't allow empty tags
        splitTags.removeWhere((element) => element.isEmpty);
        for (String tag in splitTags) {
          if (!(filterCheck && filterText.trim().isNotEmpty && filterBy == 'Tag')
            || (filterCheck && filterText.trim().isNotEmpty && splitTagsList.contains(tag))) {
            bool unique = true;
            for (int i = 0; i < tasksByTag.length; i++) {
              String tbtTag = tasksByTag[i][0].item1;
              if (tbtTag == tag) {
                tasksByTag[i].add(Tuple3(tag, task, timeDiff));
                unique = false;
              }
            }
            if (unique) {
              // Add unique task to list for group name
              tasksByTag.add([Tuple3(tag, task, timeDiff)]);
            }
          }
        }
      }

      for (List<Tuple3<String, FurTask, int>> tbt in tasksByTag) {
        int totalDuration = 0;
        List<Tuple2<String, int>> tasksDur = [];
        String tagName = '#${tbt[0].item1}';
        for (Tuple3 tbtTuple in tbt) {
          FurTask task = tbtTuple.item2;
          int tagDuration = tbtTuple.item3;
          totalDuration += tagDuration;

          bool unique = true;
          for (int i = 0; i < tasksDur.length; i++) {
            String tdTask = tasksDur[i].item1;
            int dur = tasksDur[i].item2;
            if (tdTask == task.name) {
              int newDur = dur + tagDuration;
              tasksDur[i] = Tuple2(task.name, newDur);
              unique = false;
            }
          }
          if (unique) {
            tasksDur.add(Tuple2(task.name, tagDuration));
          }

        }
        // Sort tasks and tags in descending order by duration
        tasksDur.sort((Tuple2 a, Tuple2 b) => a.item2.compareTo(b.item2));
        tasksDur = List.from(tasksDur.reversed);
        sortedTasksByDuration.add(Tuple3(tagName, totalDuration, tasksDur));
        sortedTasksByDuration.sort((Tuple3 a, Tuple3 b) => a.item2.compareTo(b.item2));
        sortedTasksByDuration = List.from(sortedTasksByDuration.reversed);
      }
    }

  }

  DateTime todayDate() {
    var today = DateTime.now();
    return DateTime(today.year, today.month, today.day);
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          // The Bottom margin is provided to align the popup above the system navigation bar.
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          // Provide a background color for the popup.
          color: CupertinoColors.systemBackground.resolveFrom(context),
          // Use a SafeArea widget to avoid system overlaps.
          child: SafeArea(
            top: false,
            child: child,
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    getAllTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generate Report',
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: dateRange,
              underline: Container(
                height: 2,
                color: furPurple,
              ),
              onChanged: (newValue) {
                setState(() {
                  dateRange = newValue!;
                  if (newValue == 'Past week') {
                    rangeStartDate = todayDate().subtract(const Duration(days: 6));
                  } else if (newValue == 'This month') {
                    var daysFromFirstOfMonth = todayDate().day;
                    rangeStartDate = todayDate().subtract(Duration(days: daysFromFirstOfMonth));
                  } else if (newValue == 'Past 30 days') {
                    rangeStartDate = todayDate().subtract(const Duration(days: 29));
                  } else if (newValue == 'Past 180 days') {
                    rangeStartDate = todayDate().subtract(const Duration(days: 179));
                  } else if (newValue == 'Past year') {
                    rangeStartDate = todayDate().subtract(const Duration(days: 364));
                  }

                  if (newValue != 'Date range') {
                    rangeStopDate = todayDate();
                  }
                });
              },
              items: <String>['Past week', 'This month', 'Past 30 days', 'Past 180 days', 'Past year', 'Date range']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (dateRange == 'Date range') ...[
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      elevation: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
                      child: InkWell(
                        onTap: () => _showDialog(
                          CupertinoDatePicker(
                            // CupertinoDatePicker doesn't seem to like UTC formats, so this is necessary to get the correct max time
                            initialDateTime: rangeStartDate,
                            mode: CupertinoDatePickerMode.date,
                            maximumDate: rangeStopDate,
                            onDateTimeChanged: (DateTime newDateTime) {
                              setState(() {
                                rangeStartDate = newDateTime;
                              });
                            },
                          ),
                        ),
                        child: ListTile(
                          contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                          title: Center(
                            child: Text(
                              formatter.format(rangeStartDate),
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'to'
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      elevation: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
                      child: InkWell(
                        onTap: () => _showDialog(
                          CupertinoDatePicker(
                            // CupertinoDatePicker doesn't seem to like UTC formats, so this is necessary to get the correct max time
                            initialDateTime: rangeStopDate,
                            mode: CupertinoDatePickerMode.date,
                            minimumDate: rangeStartDate,
                            maximumDate: todayDate(),
                            onDateTimeChanged: (DateTime newDateTime) {
                              setState(() {
                                rangeStopDate = newDateTime;
                              });
                            },
                          ),
                        ),
                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                          title: Center(
                            child: Text(
                              formatter.format(rangeStopDate),
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sort by:',
                ),
                const SizedBox(
                  width: 5.0,
                ),
                DropdownButton<String>(
                  value: sortBy,
                  underline: Container(
                    height: 2,
                    color: furPurple,
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      sortBy = newValue!;
                    });
                  },
                  items: <String>['Task', 'Tag']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  activeColor: furPurple,
                  checkColor: Colors.white,
                  // fillColor: MaterialStateProperty.resolveWith(furPurple),
                  value: filterCheck,
                  onChanged: (bool? value) {
                    setState(() {
                      filterCheck = value!;
                    });
                  },
                ),
                const Text(
                  'Filter by tasks or tags'
                ),
              ],
            ),
            if (filterCheck) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: filterBy,
                      underline: Container(
                        height: 2,
                        color: furPurple,
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          filterBy = newValue!;
                        });
                      },
                      items: <String>['Task', 'Tag']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (text) {
                          filterText = text;
                        },
                        maxLines: 1,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            borderSide: BorderSide(color: furPurple, width: 2.0),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.fromLTRB(10.0, 7.0, 10.0, 7.0),
                          hintText: filterBy == 'Task' ? 'Task one, Task two' : '#tag1 #tag two',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: furPurple, width: 2.0,),
              ),
              onPressed: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                setState(() {
                  sortedTasksByDuration = [];
                  _furReportGenerator();
                });
              },
              child: const Text('Generate'),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              totalTimeLabel,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sortedTasksByDuration.length,
                itemBuilder: (BuildContext context, int i) {
                  if (sortedTasksByDuration[i].item3.isNotEmpty) {
                    return ExpansionTile(
                      title: Text(
                        sortedTasksByDuration[i].item1,
                      ),
                      trailing: Text(
                        durationToString(sortedTasksByDuration[i].item2),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      children: _buildExpandedRow(sortedTasksByDuration[i].item3),
                    );
                  } else {
                    return Theme(
                      data: ThemeData().copyWith(
                          dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          sortedTasksByDuration[i].item1,
                        ),
                        trailing: Text(
                          durationToString(sortedTasksByDuration[i].item2),
                        ),
                        controlAffinity: null,
                        leading: const Text(' '),
                        textColor: Colors.black,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildExpandedRow(List<Tuple2<String, int>> sortedListItem) {
    List<Widget> tileContent = [];

    for (Tuple2 tagItem in sortedListItem) {
      tileContent.add(
        ListTile(
          title: Text(tagItem.item1),
          trailing: Text(durationToString(tagItem.item2)),
        ),
      );
    }

    return tileContent;
  }

}
