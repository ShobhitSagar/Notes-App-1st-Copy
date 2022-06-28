import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'database_helper.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final dbHelper = DatabaseHelper();
  var allIdList = [];
  var allComplList = [];
  var allTaskList = [];

  // @override
  // void initState() {
  //   super.initState();

  //   allTasks();
  // }

  Future<List<Map<String, dynamic>>> allTasks() async {
    final alllist = await dbHelper.queryAllTask();
    allIdList = [];
    allComplList = [];
    allTaskList = [];
    for (var taskObj in alllist) {
      allIdList.add(taskObj['_id']);
      allComplList.add(taskObj['completed']);
      allTaskList.add(taskObj['task']);
    }
    return alllist;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: allTasks(),
        builder: (context, snapshot) {
          //
          // Waiting...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  Text(
                    'Loading...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            //
            // If has Error
            if (snapshot.hasError) {
              print('SnapshotHasError: $snapshot');
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'No Data found!',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              //
              // Actual Todo List
              print('SnapshotHasData: ${snapshot.data}');
              return ListView.builder(
                itemCount: allTaskList.length,
                itemBuilder: ((context, index) {
                  return CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      '${allTaskList[index]}',
                      style: TextStyle(
                          decoration: allComplList[index] == 1
                              ? TextDecoration.lineThrough
                              : TextDecoration.none),
                    ),
                    value: allComplList[index] == 1 ? true : false,
                    activeColor: Colors.grey,
                    onChanged: (bool? value) {
                      isChecked(value, index);
                    },
                    secondary: IconButton(
                        onPressed: () {
                          delete(index);
                        },
                        icon: Icon(Icons.delete)),
                  );
                }),
              );
            } else {
              //
              // No Data
              return const Center(
                child: Text(
                  'Nothing to do!',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              );
            }
            // If nothing
          } else {
            return Center(
              child: Text(
                'State: ${snapshot.connectionState}',
                style: const TextStyle(color: Colors.blue, fontSize: 16),
              ),
            );
          }
        },
      ),
    );
  }

  void isChecked(bool? checked, int i) {
    if (checked != null && checked) {
      Map<String, dynamic> row = {
        DatabaseHelper.colId: allIdList[i],
        DatabaseHelper.colCompleted: 1,
        DatabaseHelper.colTask: allTaskList[i]
      };
      dbHelper.update(row);

      setState(() {
        allComplList[i] = 1;
      });
    } else {
      Map<String, dynamic> row = {
        DatabaseHelper.colId: allIdList[i],
        DatabaseHelper.colCompleted: 0,
        DatabaseHelper.colTask: allTaskList[i]
      };
      dbHelper.update(row);

      setState(() {
        allComplList[i] = 0;
      });
    }
  }

  void delete(int index) {
    dbHelper.delete(allIdList[index]);
    setState(() {
      allTasks();
    });
  }
}
