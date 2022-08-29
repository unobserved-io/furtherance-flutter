import 'package:flutter/material.dart';
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

class FurNewTask extends StatefulWidget {
  const FurNewTask({Key? key,}) : super(key: key);

  @override
  State<FurNewTask> createState() => _FurNewTaskState();
}

class _FurNewTaskState extends State<FurNewTask> {
  String newTitle = '';
  String newTagsUnedited = '';
  late DateTime newStartTime = DateTime.now().subtract(const Duration(minutes: 10));
  late DateTime newStopTime = DateTime.now().subtract(const Duration(minutes: 1));
  ErrorType errorType = ErrorType.none;
  String errorMessage = '';
  DatabaseHelper databaseHelper = DatabaseHelper();
  final DateFormat formatter = DateFormat('MMM dd, yyyy H:mm');

  String _getErrorMessage() {
    if (errorType == ErrorType.containsPound) {
      return 'The name cannot contain a "#".';
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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'New Task',
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (text) {
                      newTitle = text;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Task Name',
                      // hintText: task.name,
                    ),
                  ),
                  TextField(
                    onChanged: (text) {
                      newTagsUnedited = text;
                    },
                    decoration: const InputDecoration(
                      labelText: '#tags',
                      // hintText: task.name,
                    ),
                  ),
                ],
              ),
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
                    initialDateTime: newStartTime,
                    use24hFormat: true,
                    maximumDate: newStopTime,
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        newStartTime = newDateTime;
                      });
                    },
                  ),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                  title: const Text('Start Time'),
                  trailing: Text(
                      formatter.format(newStartTime),
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
                    initialDateTime: newStopTime,
                    use24hFormat: true,
                    minimumDate: newStartTime,
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        newStopTime = newDateTime;
                      });
                    },
                  ),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                  title: const Text('Stop Time'),
                  trailing: Text(
                    formatter.format(newStopTime),
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 17.0,
                ),
              ),
            ),
            Expanded(child:Container()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                onPressed: () {
                  errorType = ErrorType.none;
                  errorMessage = _getErrorMessage();
                  if (newTitle.trim().isNotEmpty) {
                    if (newTitle.contains('#')) {
                      errorType = ErrorType.containsPound;
                      setState(() {
                        errorMessage = _getErrorMessage();
                      });
                    } else {
                      if (newTagsUnedited.trim().isNotEmpty && newTagsUnedited[0] != '#') {
                        errorType = ErrorType.noPound;
                        setState(() {
                          errorMessage = _getErrorMessage();
                        });
                      } else {
                        //Good to go
                        databaseHelper.addData(newTitle, newStartTime, newStopTime, separateTags());
                        Navigator.pop(context);
                      }
                    }
                  } else {
                    errorType = ErrorType.titleEmpty;
                    setState(() {
                      errorMessage = _getErrorMessage();
                    });
                  }
                },
                color: furPurple,
                textColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.elliptical(10, 10))),
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Icon(
                      Icons.save,
                      size: 25.0,
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ],
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
