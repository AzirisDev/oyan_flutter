import 'package:flutter/material.dart';
import 'package:oyan/screens/settings/settings.dart';
import 'package:oyan/screens/to_do/to_do_list.dart';

import 'alarm/alarm_list.dart';

// ignore: use_key_in_widget_constructors
class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final List _screens = [
    AlarmListScreen(),
    ToDoListScreen(),
    SettingsScreen(),
  ];

  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).backgroundColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Theme.of(context).selectedRowColor,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
          elevation: 0.0,
          items: [Icons.alarm, Icons.check, Icons.settings]
              .asMap()
              .map((key, value) => MapEntry(
                    key,
                    BottomNavigationBarItem(
                      label: '',
                      icon: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: _currentIndex == key
                              ? Theme.of(context).buttonColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Icon(value),
                      ),
                    ),
                  ))
              .values
              .toList()),
    );
  }
}
