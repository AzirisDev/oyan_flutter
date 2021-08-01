import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyThemes {
  final lightTheme = ThemeData(
    accentColor: Colors.black,
    buttonColor: Colors.blue,
    backgroundColor: Colors.white,
    primaryColor: Colors.blue,
    brightness: Brightness.light,
    unselectedWidgetColor: Colors.grey,
    selectedRowColor: Colors.white,
    textTheme: const TextTheme(
      headline3: TextStyle(
        fontSize: 40,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  final darkTheme = ThemeData(
    accentColor: Colors.white,
    buttonColor: Color(0xff16e59d),
    backgroundColor: Colors.grey[800],
    primaryColor: Colors.blue,
    brightness: Brightness.dark,
    unselectedWidgetColor: Colors.grey,
    selectedRowColor: Colors.black,
    textTheme: const TextTheme(
      headline3: TextStyle(
        fontSize: 40,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
