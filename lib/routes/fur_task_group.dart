import 'package:flutter/material.dart';
import 'package:furtherance/database_helper.dart';
import 'package:furtherance/fur_task.dart';
import 'package:furtherance/routes/fur_task_edit.dart';
import 'styles.dart';
import 'package:intl/intl.dart';


enum ErrorType {
  none,
  containsPound,
  titleEmpty,
  tagsEmpty,
  noPound,
}

class FurTaskGroup extends StatefulWidget {
  const FurTaskGroup({Key? key, required this.idList}) : super(key: key);

  final List<int> idList;
  // final List<FurTask> taskList;

  @override
  State<FurTaskGroup> createState() => _FurTaskGroupState();
}

class _FurTaskGroupState extends State<FurTaskGroup> {
  List<FurTask> _allGroupTasks = [];
  final DateFormat timeFormatter = DateFormat('HH:mm:ss');
  DatabaseHelper databaseHelper = DatabaseHelper();
  String newTitle = '';
  String newTagsUnedited = '';
  ErrorType errorType = ErrorType.none;
  String errorMessage = '';

  void getTasks() async {
    List<FurTask> listGetter = await DatabaseHelper().getByIds(widget.idList);
    setState(() {
      _allGroupTasks = listGetter;
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

  @override
  void initState() {
    getTasks();
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
                title: const Text('Delete All?'),
                content: const Text('Are you sure you want to delete every task listed here?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () {
                      databaseHelper.deleteGroup(widget.idList);
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
                  _allGroupTasks.isNotEmpty ? _allGroupTasks[0].name : 'Loading...',
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
                                      labelText: 'Task Name', hintText: _allGroupTasks[0].name
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
                                        databaseHelper.updateGroupTitle(newTitle, widget.idList);
                                        getTasks();
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
                if (_allGroupTasks.isNotEmpty && _allGroupTasks[0].tags.isNotEmpty) ...[
                  Text(
                    _allGroupTasks[0].tags,
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
                                        labelText: 'Tags',
                                        hintText: _allGroupTasks[0].tags.isNotEmpty ? _allGroupTasks[0].tags : '#add #tags',
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
                                    databaseHelper.updateGroupTags('', widget.idList);
                                    getTasks();
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
                                      databaseHelper.updateGroupTags(separateTags(), widget.idList);
                                      getTasks();
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
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                SizedBox(
                  width: 1.0,
                ),
                Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 25.0,
                ),
                Text(
                  'Stop',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 23.0,
                ),
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 35.0,
                ),
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            for (FurTask task in _allGroupTasks)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: Text(
                      timeFormatter.format(task.startTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: Text(
                      timeFormatter.format(task.stopTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: furPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: Text(
                      task.totalTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FurTaskEdit(id: task.id),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
