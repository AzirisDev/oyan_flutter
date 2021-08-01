import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:oyan/helpers/alarm_db_helper.dart';
import 'package:oyan/main.dart';
import 'package:oyan/models/alarm_model.dart';
import 'package:oyan/screens/alarm/widgets/alarm_tile.dart';
import 'package:oyan/screens/alarm/widgets/current_time_and_clock_view.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({Key key}) : super(key: key);

  @override
  _AlarmListState createState() => _AlarmListState();
}

class _AlarmListState extends State<AlarmListScreen> {
  Future<List<Alarm>> _alarmList;
  String _alarmTimeString;
  DateTime _alarmTime = DateTime.now();

  final _formKey = GlobalKey<FormState>();
  String _title = '';

  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    _updateAlarmList();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  _updateAlarmList() {
    setState(() {
      _alarmList = AlarmDatabaseHelper.instance.getAlarmList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var formattedTime = DateFormat('HH:mm').format(now);
    var formattedDate = DateFormat('EEE, d MMM').format(now);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonColor,
        onPressed: () async {
          _alarmTimeString = DateFormat('HH:mm').format(DateTime.now());
          await setOrUpdateBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 60),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              CurrentTimeAndClockView(
                  formattedTime: formattedTime, formattedDate: formattedDate),
              const SizedBox(
                height: 30,
              ),
              FutureBuilder(
                future: _alarmList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return AlarmTile(
                          alarm: snapshot.data[index],
                          updateList: _updateAlarmList,
                          scheduleAlarm: scheduleAlarm,
                        );
                      });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  setOrUpdateBottomSheet(BuildContext context) async {
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
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () async {
                        var selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (BuildContext context, Widget child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: Theme.of(context).buttonColor,
                                accentColor: Theme.of(context).buttonColor,
                                colorScheme: ColorScheme.light(
                                    primary: Theme.of(context).buttonColor),
                                buttonTheme: const ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary),
                              ),
                              child: child,
                            );
                          },
                        );

                        if (selectedTime != null) {
                          final now = DateTime.now();
                          var selectedDateTime = DateTime(now.year, now.month,
                              now.day, selectedTime.hour, selectedTime.minute);

                          setModalState(() {
                            _alarmTime = selectedDateTime;
                            _alarmTimeString =
                                DateFormat('HH:mm').format(selectedDateTime);
                          });
                        }
                      },
                      child: Text(
                        _alarmTimeString,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Padding(
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
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();

                            Alarm alarm = Alarm(
                                title: _title,
                                alarmDateTime: _alarmTime,
                                isPending: 1);

                            await AlarmDatabaseHelper.instance
                                .insertAlarm(alarm)
                                .then(
                              (value) {
                                alarm.id = value;
                              },
                            );

                            scheduleAlarm(alarm);

                            _updateAlarmList();

                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'Set alarm',
                          style: TextStyle(
                            color: Theme.of(context).selectedRowColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

void scheduleAlarm(Alarm alarm) async {
  DateTime scheduledNotificationDateTime = alarm.alarmDateTime;

  if (alarm.alarmDateTime.isBefore(DateTime.now())) {
    scheduledNotificationDateTime =
        scheduledNotificationDateTime.add(const Duration(days: 1));
    Alarm updatedAlarm = Alarm.withId(
        id: alarm.id,
        title: alarm.title,
        alarmDateTime: scheduledNotificationDateTime,
        isPending: 1);

    AlarmDatabaseHelper.instance.updateAlarm(updatedAlarm);
  }

  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'alarm_notif',
    'alarm_notif',
    'Channel for Alarm notification',
    icon: 'check_logo',
    largeIcon: DrawableResourceAndroidBitmap('check_logo'),
  );

  var iOSPlatformChannelSpecifics = const IOSNotificationDetails(
      presentAlert: true, presentBadge: true, presentSound: true);

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.schedule(alarm.id, 'Oyan', alarm.title,
      scheduledNotificationDateTime, platformChannelSpecifics);
}
