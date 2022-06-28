import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class AddTask extends StatefulWidget {
  const AddTask({Key? key}) : super(key: key);

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final tfController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 14.0, bottom: 14.0, left: 10.0, right: 10.0),
      child: Row(
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: tfController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                    labelText: 'Add Task',
                    hintText: 'Add a task...'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              height: 47,
              child:
                  ElevatedButton(onPressed: addTask, child: const Text('Add')),
            ),
          )
        ],
      ),
    );
  }

  void addTask() async {
    final text = tfController.text;
    if (text.isEmpty) return print('Please enter a task.');
    Map<String, dynamic> row = {
      DatabaseHelper.colCompleted: 0,
      DatabaseHelper.colTask: tfController.text
    };
    final id = await dbHelper.insert(row);
    tfController.clear();
  }
}

// class Task {
//   final int id;
//   final bool completed;
//   final String task;

//   const Task({required this.id, required this.completed, required this.task});
// }
