// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'dart:math';

import 'draw_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

class CirclePainter extends CustomPainter {
  Paint _paint;

  final colors;
  final invertedColors;

  Paint lightBluePaint;
  Paint bluePaint;

  CirclePainter({@required this.colors, @required this.invertedColors}) {
    lightBluePaint = Paint()..color = colors[_Element.lighter];
    bluePaint = Paint()..color = invertedColors[_Element.background];
    _paint = Paint()
      ..color = invertedColors[_Element.background]
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Rect.fromLTRB(
        -165, size.height - 165, size.width + 165, size.height + 165);

    final Path circle = Path()..addOval(rect);
    final Path smallCircle = Path()..addOval(rect.inflate(8));

    canvas.drawPath(smallCircle, lightBluePaint);
    canvas.drawPath(circle, bluePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DrawCircleInner extends CustomPainter {
  Paint _paint;

  final colors;
  final invertedColors;

  DrawCircleInner({@required this.colors, @required this.invertedColors}) {
    _paint = Paint()
      ..color = colors[_Element.lighter]
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, 0.0), 65.0, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

enum _Element {
  background,
  lighter,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.lighter: Colors.white,
  _Element.text: Colors.black,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.lighter: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Colors.white,
};

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  static Random random = new Random();

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
// Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();

// Update once per second, but make sure to do it at the beginning of each
// new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _darkTheme
        : _lightTheme;
    final invertedColors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);

    final defaultStyle = TextStyle(
      color: colors[_Element.text],
    );
    final randomColor = Color.fromARGB(
        255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
    final clockDigitInfo = DefaultTextStyle(
      style: defaultStyle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            hour,
            style: new TextStyle(fontSize: 32),
          ),
          AutoSizeText(
            ":",
            style: new TextStyle(fontSize: 32),
          ),
          AutoSizeText(
            minute,
            style: new TextStyle(fontSize: 32),
          ),
        ],
      ),
    );

    final hourValue = int.parse(DateFormat('hh').format(_dateTime)) / 12;
    final secondValue = int.parse(DateFormat('ss').format(_dateTime)) / 60;
    final minHands = Stack(
      children: [
        DrawnHand(
          color: Colors.blueAccent,
          thickness: 4,
          size: .96,
          angleRadians: _dateTime.second * radiansPerTick,
        ),
        DrawnHand(
          color: colors[_Element.lighter],
          thickness: 32,
          size: 0.80,
          angleRadians: _dateTime.minute * radiansPerTick,
        ),
      ],
    );

    return AnimatedOpacity(
// If the widget is visible, animate to 0.0 (invisible).
// If the widget is hidden, animate to 1.0 (fully visible).
        opacity: 1.0,
        duration: Duration(milliseconds: 500),
// The green box must be a child of the AnimatedOpacity widget.
        child: Container(
            decoration: BoxDecoration(
              color: invertedColors[_Element.background],
            ),
            child: Stack(
                //overflow: Overflow.clip,
                children: [
                  Center(
                    child: Container(
                        height: 350.0,
                        width: 350.0,
                        child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blueAccent),
                            value: secondValue)),
                  ),
                  minHands,
                  Center(
                      child: CustomPaint(
                          painter: DrawCircleInner(
                              colors: colors, invertedColors: invertedColors))),
                  Center(
                      child: Container(
                          height: 123.0,
                          width: 123.0,
                          child: CircularProgressIndicator(
                              strokeWidth: 8,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                              value: hourValue))),
                  Center(
                      child: Container(child: Center(child: clockDigitInfo))),
                ])));
  }
}
