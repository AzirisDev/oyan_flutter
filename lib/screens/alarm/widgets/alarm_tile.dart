import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oyan/helpers/alarm_db_helper.dart';
import 'package:oyan/main.dart';
import 'package:oyan/models/alarm_model.dart';

class AlarmTile extends StatelessWidget {
  AlarmTile({
    Key key,
    this.alarm,
    this.updateList,
    this.scheduleAlarm,
  }) : super(key: key);

  Alarm alarm;
  final Function updateList;
  final Function scheduleAlarm;

  @override
  Widget build(BuildContext context) {
    String _alarmTimeString = DateFormat('HH:mm').format(alarm.alarmDateTime);
    DateTime _alarmTime = alarm.alarmDateTime;
    final _formKey = GlobalKey<FormState>();
    String _title = alarm.title;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).buttonColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.label,
                    color: Theme.of(context).selectedRowColor,
                    size: 24,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    alarm.title,
                    style: TextStyle(
                        color: Theme.of(context).selectedRowColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Switch(
                value: alarm.isPending == 1 ? (DateTime.now().isBefore(alarm.alarmDateTime) ? true : false) : false,
                onChanged: (bool value) async {

                  if(value && DateTime.now().isAfter(alarm.alarmDateTime)){
                    _alarmTime = _alarmTime.add(const Duration(days: 1));
                  }

                  Alarm updatedAlarm = Alarm.withId(
                      id: alarm.id,
                      title: _title,
                      alarmDateTime: _alarmTime,
                      isPending: value == true ? 1 : 0);

                  if (value == false) {
                    await flutterLocalNotificationsPlugin.cancel(updatedAlarm.id);
                  } else {
                    scheduleAlarm(updatedAlarm);
                  }

                  AlarmDatabaseHelper.instance.updateAlarm(updatedAlarm);

                  updateList();
                },
                activeColor: Colors.white,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('kk:mm a').format(alarm.alarmDateTime),
                style: TextStyle(
                    color: Theme.of(context).selectedRowColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 24),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: StatefulBuilder(
                          builder: (context, setModalState) {
                            return SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        var selectedTime = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                              alarm.alarmDateTime),
                                          builder: (BuildContext context,
                                              Widget child) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                primaryColor: Theme.of(context)
                                                    .buttonColor,
                                                accentColor: Theme.of(context)
                                                    .buttonColor,
                                                colorScheme: ColorScheme.light(
                                                    primary: Theme.of(context)
                                                        .buttonColor),
                                                buttonTheme:
                                                    const ButtonThemeData(
                                                        textTheme:
                                                            ButtonTextTheme
                                                                .primary),
                                              ),
                                              child: child,
                                            );
                                          },
                                        );

                                        if (selectedTime != null) {
                                          final now = DateTime.now();
                                          var selectedDateTime = DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                              selectedTime.hour,
                                              selectedTime.minute);

                                          setModalState(() {
                                            _alarmTime = selectedDateTime;
                                            _alarmTimeString =
                                                DateFormat('HH:mm')
                                                    .format(selectedDateTime);
                                          });
                                        }
                                      },
                                      child: Text(
                                        _alarmTimeString,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                    ),
                                    Form(
                                      key: _formKey,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: TextFormField(
                                          style: const TextStyle(fontSize: 18),
                                          decoration: InputDecoration(
                                            labelText: 'Title',
                                            labelStyle:
                                                const TextStyle(fontSize: 18),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          validator: (input) => input
                                                  .trim()
                                                  .isEmpty
                                              ? 'Please enter the task title'
                                              : null,
                                          onSaved: (input) => _title = input,
                                          initialValue: _title,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      height: 60,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).buttonColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: TextButton(
                                        onPressed: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            _formKey.currentState.save();

                                            Alarm updatedAlarm = Alarm.withId(
                                                id: alarm.id,
                                                title: _title,
                                                alarmDateTime: _alarmTime,
                                                isPending: 1);

                                            AlarmDatabaseHelper.instance
                                                .updateAlarm(updatedAlarm);

                                            updateList();

                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text(
                                          'Update alarm',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .selectedRowColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      height: 60,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).buttonColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: TextButton(
                                        onPressed: () async {
                                          await flutterLocalNotificationsPlugin.cancel(alarm.id);
                                          AlarmDatabaseHelper.instance
                                              .deleteTask(alarm.id);
                                          updateList();
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Delete alarm',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .selectedRowColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context).selectedRowColor,
                  size: 30,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
