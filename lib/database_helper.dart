import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = 'task_database.db';
  static const _databaseVersion = 1;

  static const table = 'tasks';

  static const colId = '_id';
  static const colCompleted = 'completed';
  static const colTask = 'task';

  static final DatabaseHelper _databaseHelper = DatabaseHelper._internal();
  factory DatabaseHelper() => _databaseHelper;
  DatabaseHelper._internal();

  // DatabaseHelper._privateConstructor();
  // static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  // static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    String path = join(databasePath, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $table($colId INTEGER PRIMARY KEY, $colCompleted INTEGER, $colTask TEXT)');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await _databaseHelper.database;
    return await db.insert(table, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAllTask() async {
    Database db = await _databaseHelper.database;
    return await db.query(table);
  }

  // Future<int?> queryRowCount() async {
  //   Database db = await instance.database;
  //   return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  // }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await _databaseHelper.database;
    int id = row['_id'];
    return await db.update(table, row, where: '_id=?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await _databaseHelper.database;
    return db.delete(table, where: '_id=?', whereArgs: [id]);
  }
}

// Data Model Class
class Task {
  final int id;
  final int completed;
  final String task;

  const Task({required this.id, required this.completed, required this.task});

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'completed': completed,
      'task': task,
    };
  }

  @override
  String toString() {
    return 'Task{_id: $id, completed: $completed, task: $task}';
  }
}
