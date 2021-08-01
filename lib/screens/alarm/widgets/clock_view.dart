import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class ClockView extends StatefulWidget {
  const ClockView({Key key}) : super(key: key);

  @override
  _ClockViewState createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {

  Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {

      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: Transform.rotate(
        angle: - pi / 2,
        child: CustomPaint(
          painter: ClockPainter(context),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {

  BuildContext context;

  ClockPainter(this.context);

  var dateTime = DateTime.now();

  @override
  void paint(Canvas canvas, Size size) {

    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var center = Offset(centerX, centerY);
    var radius = centerX * 1.8;


    var fillBrush = Paint()..color = Theme.of(context).backgroundColor;
    var lineBrush = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = Theme.of(context).accentColor;
    var centerBrush = Paint()..color = Theme.of(context).accentColor;

    canvas.drawCircle(center, radius * 0.55, fillBrush);
    canvas.drawCircle(center, radius * 0.55, lineBrush);
    canvas.drawCircle(center, radius * 0.07, centerBrush);

    var secHandX = centerX + radius * 4 /9 * cos(dateTime.second * 6 * pi / 180);
    var secHandY = centerY + radius * 4 /9 * sin(dateTime.second * 6 * pi / 180);
    canvas.drawLine(
        center, Offset(secHandX, secHandY), lineBrush..strokeWidth = 4);
    var minHandX = centerX + radius * 35 /90 * cos(dateTime.minute * 6 * pi / 180);
    var minHandY = centerY + radius * 35 /90 * sin(dateTime.minute * 6 * pi / 180);
    canvas.drawLine(
        center, Offset(minHandX, minHandY), lineBrush..strokeWidth = 6);
    var hourHandX = centerX +
        radius / 3 * cos((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    var hourHandY = centerY +
        radius / 3 * sin((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), lineBrush..strokeWidth = 8);

    var outerCircleRadius = radius - radius * 24 / 90;
    var innerCircleRadius = radius - radius * 32 / 90;

    for(double i = 0; i < 360; i += 30){
      var x1  = centerX + outerCircleRadius * cos(i * pi / 180);
      var y1  = centerY + outerCircleRadius * sin(i * pi / 180);

      var x2  = centerX + innerCircleRadius * cos(i * pi / 180);
      var y2  = centerY + innerCircleRadius * sin(i * pi / 180);
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), lineBrush..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
