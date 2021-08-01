import 'package:flutter/material.dart';
import 'package:oyan/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings',style: Theme.of(context).textTheme.headline3,),
            const SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(themeProvider.isDarkMode ? "Dark" : "Light",
                style: Theme.of(context).textTheme.headline3.copyWith(fontSize: 24),),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value){
                    final provider = Provider.of<ThemeProvider>(context, listen: false);
                    provider.toggleTheme(value);
                  },
                ),
              ],
            ),
            const Divider(),

          ],
        ),
      ),
    );
  }
}


