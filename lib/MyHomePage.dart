import 'package:flutter/material.dart';
import 'package:notes_app/AddTask.dart';
import 'package:notes_app/TaskList.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: Column(
        children: const [AddTask(), TaskList()],
      ),
    );
  }
}
