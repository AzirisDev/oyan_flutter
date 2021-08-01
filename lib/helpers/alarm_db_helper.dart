import 'package:oyan/models/alarm_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AlarmDatabaseHelper {
  final String tableAlarm = 'alarm_table';
  final String columnId = 'id';
  final String columnTitle = 'title';
  final String columnDateTime = 'date';
  final String columnPending = 'isPending';

  static Database _db;

  static final AlarmDatabaseHelper instance = AlarmDatabaseHelper._instance();

  AlarmDatabaseHelper._instance();

  Future<Database> get db async {
    if (_db == null) {
      _db = await initializeDatabase();
    }
    return _db;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getApplicationDocumentsDirectory();
    var path = dir.path + "alarm.db";

    final finalAlarmDb =
        await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute(
          'CREATE TABLE $tableAlarm($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnTitle TEXT, $columnDateTime TEXT, $columnPending INTEGER)');
    }, onOpen: (db) {});
    return finalAlarmDb;
  }

  Future<List<Map<String, dynamic>>> getAlarmMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(tableAlarm);
    return result;
  }

  Future<List<Alarm>> getAlarmList() async {
    final List<Map<String, dynamic>> alarmMapList = await getAlarmMapList();
    List<Alarm> alarmList = [];
    for (var alarmMap in alarmMapList) {
      alarmList.add(Alarm.fromMap(alarmMap));
    }
    // taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return alarmList;
  }

  Future<int> insertAlarm(Alarm alarm) async {
    var db = await this.db;
    var result = db.insert(tableAlarm, alarm.toMap());
    return result;
  }


  Future<int> updateAlarm(Alarm alarm) async {
    var db = await this.db;
    final result = await db.update(tableAlarm, alarm.toMap(),
        where: '$columnId = ?', whereArgs: [alarm.id]);
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    var result = db.delete(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
    return result;
  }
}
