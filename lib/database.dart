import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'todo_app_database.db'),
    // When the database is first created, create a table to store tasks.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE tasks(id INTEGER PRIMARY KEY, completed BOOLEAN, task String)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  // Define a function that inserts tasks into the database
  Future<void> insertTask(Task task) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Task into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same task is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the tasks from the tasks table.
  Future<List<Task>> tasks() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Tasks.
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    // Convert the List<Map<String, dynamic> into a List<Task>.
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        completed: maps[i]['completed'],
        task: maps[i]['task'],
      );
    });
  }

  Future<void> updateTask(Task task) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Task.
    await db.update(
      'tasks',
      task.toMap(),
      // Ensure that the Task has a matching id.
      where: 'id = ?',
      // Pass the Task's id as a whereArg to prevent SQL injection.
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Task from the database.
    await db.delete(
      'tasks',
      // Use a `where` clause to delete a specific task.
      where: 'id = ?',
      // Pass the Task's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  // Create a Task and add it to the tasks table
  var demoTask = const Task(
    id: 0,
    completed: false,
    task: 'Task Demo',
  );

  await insertTask(demoTask);

  // Now, use the method above to retrieve all the tasks.
  print(await tasks()); // Prints a list that include demoTask.

  // Update demoTask's age and save it to the database.
  demoTask = Task(
    id: demoTask.id,
    completed: demoTask.completed,
    task: demoTask.task + "7",
  );
  await updateTask(demoTask);

  // Print the updated results.
  print(await tasks()); // Prints demoTask with age 42.

  // Delete demoTask from the database.
  await deleteTask(demoTask.id);

  // Print the list of tasks (empty).
  print(await tasks());
}

class Task {
  final int id;
  final bool completed;
  final String task;

  const Task({required this.id, required this.completed, required this.task});

  // Convert a Task into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'completed': completed,
      'task': task,
    };
  }

  // Implement toString to make it easier to see information about
  // each task when using the print statement.
  @override
  String toString() {
    return 'Task{id: $id, completed: $completed, task: $task}';
  }
}
