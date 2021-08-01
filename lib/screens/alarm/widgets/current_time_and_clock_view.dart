
import 'package:flutter/material.dart';
import 'package:oyan/screens/alarm/widgets/clock_view.dart';

class CurrentTimeAndClockView extends StatelessWidget {
  const CurrentTimeAndClockView({
    Key key,
    @required this.formattedTime,
    @required this.formattedDate,
  }) : super(key: key);

  final String formattedTime;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              '$formattedTime',
              style: const TextStyle(
                  fontSize: 64, fontWeight: FontWeight.bold),
            ),
            Text(
              '$formattedDate',
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ClockView(),
        ),
      ],
    );
  }
}