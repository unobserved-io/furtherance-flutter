import 'package:flutter/material.dart';
import 'package:furtherance/database_helper.dart';
import 'package:furtherance/fur_task.dart';
import 'styles.dart';
import 'package:intl/intl.dart';


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

  void getTasks() async {
    List<FurTask> listGetter = await DatabaseHelper().getByIds(widget.idList);
    setState(() {
      _allGroupTasks = listGetter;
    });
  }

  @override
  void initState() {
    getTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const Icon(Icons.edit),
              ],
            ),
            if (_allGroupTasks.isNotEmpty && _allGroupTasks[0].tags != '#') ...[
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _allGroupTasks[0].tags,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  const Icon(
                    Icons.edit,
                    size: 20.0
                  ),
                ],
              ),
            ],
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // crossAxisAlignment: CrossAxisAlignment.,
              children: const [
                Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Stop',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
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
                      ),
                    ),
                  ),
                  const Icon(Icons.edit),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
