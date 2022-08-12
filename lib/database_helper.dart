import 'dart:io';
import 'fur_task.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static final DatabaseHelper _singleton = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _singleton;
  }

  DatabaseHelper._internal();

  static const _databaseName = "furtherance.db";
  static const _databaseVersion = 2;

  // Database table and column names
  static const String tableName = 'tasks';
  static const String columnId = 'id';
  static const String columnTaskName = 'task_name';
  static const String columnStartTime = 'start_time';
  static const String columnStopTime = 'stop_time';
  static const String columnTags = 'tags';

  static Database? _database;

  static Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: (Database db, int version) async {
          await db.execute('''
              CREATE TABLE $tableName (
                $columnId INTEGER PRIMARY KEY,
                $columnTaskName TEXT NOT NULL,
                $columnStartTime TEXT NOT NULL,
                $columnStopTime TEXT NOT NULL,
                $columnTags TEXT
              )
            ''');
        });
  }

  static Future<Database> getDatabaseConnect() async =>
      _database ??= await _initDatabase();


  Future<List<FurTask>> retrieve() async {
    final Database db = await getDatabaseConnect();
    final query = await db.rawQuery('SELECT * FROM $tableName ORDER BY start_time DESC');

    return List.generate(query.length, (i) {
      return FurTask(
        query[i][columnId] as int,
        query[i][columnTaskName] as String,
        query[i][columnStartTime] as String,
        query[i][columnStopTime] as String,
        query[i][columnTags] as String,
      );
    });
  }

  Future addData(String taskName, DateTime startTime, DateTime stopTime, String tags) async {
    var task = {
      columnTaskName: taskName,
      columnStartTime: _toRfc3339String(startTime),
      columnStopTime: _toRfc3339String(stopTime),
      columnTags: tags,
    };

    final Database db = await getDatabaseConnect();
    await db.insert(tableName, task);
  }

  Future<List<FurTask>> getByIds(List<int> ids) async {
    final Database db = await getDatabaseConnect();
    List<FurTask> allTheseIds = [];
    // final query = await db.rawQuery('SELECT * FROM $tableName ORDER BY start_time DESC');
    for (int i = 0; i < ids.length; i++) {
      final query = await db.rawQuery('SELECT * FROM $tableName WHERE $columnId = ${ids[i]}');

      allTheseIds.add(FurTask(
        query.first[columnId] as int,
        query.first[columnTaskName] as String,
        query.first[columnStartTime] as String,
        query.first[columnStopTime] as String,
        query.first[columnTags] as String,
      ));
    }

    return allTheseIds;
  }

  String _toRfc3339String(DateTime dateTime) {
    // TODO Add timezones when Flutter makes them available
    final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss+00:00');
    return formatter.format(dateTime);
  }

}