import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:furtherance/fur_task.dart';
import 'package:furtherance/database_helper.dart';
import 'styles.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';


enum ErrorType {
  none,
  containsPound,
  titleEmpty,
  tagsEmpty,
  noPound,
}

class FurTaskEdit extends StatefulWidget {
  const FurTaskEdit({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  State<FurTaskEdit> createState() => _FurTaskEditState();
}

class _FurTaskEditState extends State<FurTaskEdit> {
  FurTask task = FurTask(0, 'Loading...', DateTime.now().toIso8601String(), DateTime.now().toIso8601String(), 'loading...');
  String newTitle = '';
  String newTagsUnedited = '';
  ErrorType errorType = ErrorType.none;
  String errorMessage = '';
  DatabaseHelper databaseHelper = DatabaseHelper();
  final DateFormat formatter = DateFormat('MMM dd, yyyy H:mm');

  void refreshTask() async {
    FurTask taskGetter = await databaseHelper.getById(widget.id);
    setState(() {
      task = taskGetter;
    });
  }

  String _getErrorMessage() {
    if (errorType == ErrorType.containsPound) {
      return 'The title cannot contain a "#".';
    } else if (errorType == ErrorType.titleEmpty) {
      return 'The title cannot be empty.';
    } else if (errorType == ErrorType.noPound) {
      return 'All tags must be marked by a "#".';
    } else if (errorType == ErrorType.none) {
      return '';
    } else {
      return 'Error';
    }
  }

  String separateTags() {
    if (newTagsUnedited.trim().isNotEmpty) {
      var splitTags = newTagsUnedited.trim().split('#');
      // Remove blank element
      splitTags.removeAt(0);
      // Trim each element and lowercase them
      for (int i = 0; i < splitTags.length; i++) {
        splitTags[i] = splitTags[i].trim().toLowerCase();
      }
      // Don't allow empty tags
      splitTags.removeWhere((element) => element.isEmpty);
      // Don't allow duplicate tags
      splitTags = splitTags.toSet().toList();
      return splitTags.join(' #');
    } else {
      return '';
    }
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
    refreshTask();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Task',
        ),
        actions: [
          IconButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Delete this task?'),
                  // content: const Text('Are you sure you want to delete this task?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        databaseHelper.deleteTask(task.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.delete_forever),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                IconButton(
                  onPressed: () {
                    errorType = ErrorType.none;
                    errorMessage = '';
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              contentTextStyle: const TextStyle(
                                color: Colors.blue,
                              ),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    autofocus: true,
                                    onChanged: (text) {
                                      newTitle = text;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Task Name',
                                        hintText: task.name,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    errorMessage,
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'CANCEL',
                                    style: TextStyle(
                                      color: furPurple,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (newTitle.trim().isNotEmpty) {
                                      if (newTitle.contains('#')) {
                                        errorType = ErrorType.containsPound;
                                        setState(() {
                                          errorMessage = _getErrorMessage();
                                        });
                                      } else {
                                        databaseHelper.updateTitle(newTitle, task.id);
                                        refreshTask();
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      errorType = ErrorType.titleEmpty;
                                      setState(() {
                                        errorMessage = _getErrorMessage();
                                      });
                                    }
                                  },
                                  child: const Text(
                                    'SAVE',
                                    style: TextStyle(
                                      color: furPurple,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show tags if there are some, otherwise show "Add tags" so user can still add some to the group
                if (task.tags != '#') ...[
                  Text(
                    task.tags,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Add tags...',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(
                  width: 10.0,
                ),
                IconButton(
                  onPressed: () {
                    errorType = ErrorType.none;
                    errorMessage = _getErrorMessage();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              contentTextStyle: const TextStyle(
                                color: Colors.blue,
                              ),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    autofocus: true,
                                    onChanged: (text) {
                                      newTagsUnedited = text;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Tags', hintText: task.tags
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    errorMessage,
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'CANCEL',
                                    style: TextStyle(
                                      color: furPurple,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    databaseHelper.updateTags('', task.id);
                                    refreshTask();
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'REMOVE ALL',
                                    style: TextStyle(
                                      color: furPurple,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (newTagsUnedited.trim().isNotEmpty && newTagsUnedited[0] != '#') {
                                      errorType = ErrorType.noPound;
                                      setState(() {
                                        errorMessage = _getErrorMessage();
                                      });
                                    } else {
                                      databaseHelper.updateTags(separateTags(), task.id);
                                      refreshTask();
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text(
                                    'SAVE',
                                    style: TextStyle(
                                      color: furPurple,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 20.0,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              elevation: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
              child: InkWell(
                onTap: () => _showDialog(
                  CupertinoDatePicker(
                    // CupertinoDatePicker doesn't seem to like UTC formats, so this is necessary to get the correct max time
                    initialDateTime: task.startTime.toLocal().subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                    use24hFormat: true,
                    maximumDate: task.stopTime.toLocal().subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        databaseHelper.updateStart(newDateTime, task.id);
                        refreshTask();
                      });
                    },
                  ),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                  title: const Text('Start Time'),
                  trailing: Text(
                    formatter.format(task.startTime),
                    style: const TextStyle(
                      fontSize: 16.0,
                    )
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              elevation: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
              child: InkWell(
                onTap: () => _showDialog(
                  CupertinoDatePicker(
                    initialDateTime: task.stopTime.toLocal().subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                    use24hFormat: true,
                    minimumDate: task.startTime.toLocal().subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        databaseHelper.updateStop(newDateTime, task.id);
                        refreshTask();
                      });
                    },
                  ),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                  title: const Text('Stop Time'),
                  trailing: Text(
                    formatter.format(task.stopTime.toUtc()),
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            // ADD MORE ABOVE
          ],
        ),
      ),
    );
  }
}
