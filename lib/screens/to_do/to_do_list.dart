import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oyan/helpers/goals_db_helper.dart';
import 'package:oyan/models/task_model.dart';
import 'package:oyan/screens/to_do/add_task.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({Key key}) : super(key: key);

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormat = DateFormat('MMMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = GoalsDatabaseHelper.instance.getTaskList();
    });
  }

  Widget _buildTask(Task task) {
    return Column(
      children: [
        ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 24,
              decoration: task.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
            ),
          ),
          subtitle: Text(
            "${_dateFormat.format(task.date)} • ${task.priority}",
            style: TextStyle(
              fontSize: 18,
              decoration: task.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
            ),
          ),
          trailing: Checkbox(
            onChanged: (value) {
              task.status = value ? 1 : 0;
              GoalsDatabaseHelper.instance.updateTask(task);
              _updateTaskList();
            },
            value: task.status == 1 ? true : false,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTask(
                task: task,
                updateTaskList: _updateTaskList,
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTask(
                updateTaskList: _updateTaskList,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _taskList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final int completedTaskCount = snapshot.data
              .where((Task task) => task.status == 1)
              .toList()
              .length;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
            itemCount: 1 + snapshot.data.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20, left: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goals',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        '$completedTaskCount of ${snapshot.data.length}',
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }
              return _buildTask(snapshot.data[index - 1]);
            },
          );
        },
      ),
    );
  }
}
