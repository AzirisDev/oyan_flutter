import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oyan/helpers/goals_db_helper.dart';
import 'package:oyan/models/task_model.dart';

class AddTask extends StatefulWidget {
  const AddTask({Key key, this.task, this.updateTaskList}) : super(key: key);

  final Task task;
  final Function updateTaskList;

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority = '';
  DateTime _date = DateTime.now();

  final TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('MMMM dd, yyyy');

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }

    _dateController.text = _dateFormat.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null && _date != date) {
      setState(() {
        _date = date;
      });

      _dateController.text = _dateFormat.format(_date);
    }
  }

  _delete() {
    GoalsDatabaseHelper.instance.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      Task task = Task(title: _title, date: _date, priority: _priority);
      if (widget.task == null) {
        task.status = 0;
        GoalsDatabaseHelper.instance.insertTask(task);
      } else {
        task.id = widget.task.id;
        task.status = widget.task.status;
        GoalsDatabaseHelper.instance.updateTask(task);
      }

      widget.updateTaskList();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Theme.of(context).buttonColor,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  widget.task == null ? 'Add Task' : 'Update Task',
                  style: Theme.of(context).textTheme.headline3,
                ),
                const SizedBox(
                  height: 10,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          style: const TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: const TextStyle(fontSize: 18),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          validator: (input) => input.trim().isEmpty
                              ? 'Please enter the task title'
                              : null,
                          onSaved: (input) => _title = input,
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          onTap: _handleDatePicker,
                          style: const TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: const TextStyle(fontSize: 18),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: DropdownButtonFormField(
                          icon: const Icon(Icons.arrow_circle_down_rounded),
                          iconSize: 25,
                          isDense: true,
                          iconEnabledColor: Theme.of(context).buttonColor,
                          style: const TextStyle(fontSize: 18),
                          items: _priorities.map((String priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            labelStyle: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).accentColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (input) => _priority == ''
                              ? 'Please select a priority level'
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _priority = value.toString();
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).buttonColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: _submit,
                          child: Text(
                            widget.task == null ? 'Add' : 'Update',
                            style: TextStyle(
                              color: Theme.of(context).selectedRowColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      widget.task != null
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).buttonColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextButton(
                                onPressed: _delete,
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Theme.of(context).selectedRowColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
