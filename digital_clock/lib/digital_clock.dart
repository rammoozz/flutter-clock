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
      //..strokeWidth = 112.0
      ..style = PaintingStyle.fill;
  }

  //final Paint bluePaint = Paint()..color = invertedColors[_Element.background];
  // final TextPainter textPainter = TextPainter();

  // DrawCircleOuter() {
  //   _paint = Paint()
  //     ..color = invertedColors[_Element.background]
  //     ..strokeWidth = 10.0
  //     ..style = PaintingStyle.fill;
  // }

  // final TextStyle textStyle = TextStyle(
  //     color: Colors.white.withAlpha(240),
  //     fontSize: 18,
  //     letterSpacing: 1.2,
  //     fontWeight: FontWeight.w900);

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Rect.fromLTRB(
        -165, size.height - 165, size.width + 165, size.height + 165);

    final Path circle = Path()..addOval(rect);
    final Path smallCircle = Path()..addOval(rect.inflate(8));

    canvas.drawPath(smallCircle, lightBluePaint);
    canvas.drawPath(circle, bluePaint);

    // drawText(canvas, size, 'Write now');
  }

  // void drawText(Canvas canvas, Size size, String text) {
  //   textPainter.text = TextSpan(style: textStyle, text: text);
  //   textPainter.layout();
  //   textPainter.paint(canvas, Offset(size.width, size.height));
  // }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// class DrawCircleOuter extends CustomPainter {
//   Paint _paint;

//   final colors;
//   final invertedColors;

//   DrawCircleOuter({@required this.colors, @required this.invertedColors}) {
//     _paint = Paint()
//       ..color = Colors.blueAccent
//       ..strokeWidth = 10.0
//       ..style = PaintingStyle.fill;
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
// // double width = MediaQuery.of(context).size.width;
// // double height = MediaQuery.of(context).size.height;

//     canvas.drawCircle(Offset(0.0, 0.0), 180.0, _paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }

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
// double width = MediaQuery.of(context).size.width;
// double height = MediaQuery.of(context).size.height;

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
// Update once per minute. If you want to update every second, use the
// following code.
// _timer = Timer(
//   Duration(minutes: 1) -
//       Duration(seconds: _dateTime.second) -
//       Duration(milliseconds: _dateTime.millisecond),
//   _updateTime,
// );
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
    final second = DateFormat('ss').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 5.5;
// final offset = -fontSize / 7;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
//fontFamily: 'PressStart2P',
      //fontSize: fontSize,
// shadows: [
//   Shadow(
//     blurRadius: 0,
//     color: colors[_Element.shadow],
//     offset: Offset(10, 0),
//   ),
//],
    );
final randomColor =  Color.fromARGB(255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
    final clockDigitInfo = DefaultTextStyle(
      style: defaultStyle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            hour,
            style: new TextStyle(
                
                
                fontSize: 32),
          ),
          AutoSizeText(
            ":",
            style: new TextStyle(
                
                
                fontSize: 32),
          ),
          AutoSizeText(
            minute,
            style: new TextStyle(
                
                
                fontSize: 32),
          ),
// AutoSizeText(
//   ":",
//   style: new TextStyle(
//     fontStyle: FontStyle.normal,
//     fontWeight: FontWeight.w900,
//     fontSize:60
//   ),
// ),
// AutoSizeText(
//   second,
//   style: new TextStyle(
//     fontStyle: FontStyle.normal,
//     fontWeight: FontWeight.w900,
//     fontSize:60
//   ),
// ),
        ],
      ),
    );

    // final boxes = Container(
    //   // grey box
    //   child: Text(
    //     "Lorem ipsum",
    //     style: TextStyle(
    //       fontSize: 24,
    //       fontWeight: FontWeight.w900,
    //       //fontFamily: "Georgia",
    //     ),
    //   ),
    //   width: 200,
    //   height: 240,
    //   color: Colors.grey[300],
    // );
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

        // DrawnHand(
        //   color: colors[_Element.background],
        //   thickness: 2,
        //   size: 0.9,
        //   angleRadians:0 * radiansPerTick,
        // ),
        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 1,
        //   size: 0.3,
        //   angleRadians: 5 * radiansPerTick,
        // ),
        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 1,
        //   size: 0.3,
        //   angleRadians: 10 * radiansPerTick,
        // ),
        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 1,
        //   size: 0.3,
        //   angleRadians: 15 * radiansPerTick,
        // ),
        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 1,
        //   size: 0.3,
        //   angleRadians: 20 * radiansPerTick,
        // ),
        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 1,
        //   size: 0.3,
        //   angleRadians: 25 * radiansPerTick,
        // ),
        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 1,
        //   size: 0.3,
        //   angleRadians: 30 * radiansPerTick,
        // ),

        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 1,
        //   size: 0.3,
        //   angleRadians: 35 * radiansPerTick,
        // ),

        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 1,
        //   size: 0.3,
        //   angleRadians: 40 * radiansPerTick,
        // ),

        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 1,
        //   size: 0.3,
        //   angleRadians: 45 * radiansPerTick,
        // ),

        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 1,
        //   size: 0.3,
        //   angleRadians: 50 * radiansPerTick,
        // ),

        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 1,
        //   size: 0.3,
        //   angleRadians: 55 * radiansPerTick,
        // ),

        // DrawnHand(
        //   color: colors[_Element.lighter],
        //   thickness: 8,
        //   size: 0.6,
        //    angleRadians: _dateTime.hour * radiansPerHour +
        //           (_dateTime.minute / 60) * radiansPerHour,
        // ),
        DrawnHand(
          color: colors[_Element.lighter],
          thickness: 32,
          size: 0.80,
          angleRadians: _dateTime.minute * radiansPerTick,
        ),

        // DrawnHand(
        //   color: Colors.green,
        //   thickness: 5,
        //   size: 0.9,
        //   angleRadians:360,
        // ),
        // ContainerHand(
        //           color: Colors.transparent,
        //           size: 0.5,
        //           angleRadians:5,
        //           child: Transform.translate(
        //             offset: Offset(0.0, -245.0),
        //             child: Container(
        //               width: 32,
        //               height: 150,
        //               decoration: BoxDecoration(
        //                 color: Colors.red,
        //               ),
        //             ),
        //           ),
        //         ),
        // ContainerHand(
        //           color: Colors.transparent,
        //           size: 0.5,
        //           angleRadians: 10,
        //           child: Transform.translate(
        //             offset: Offset(0.0, -245.0),
        //             child: Container(
        //               width: 32,
        //               height: 150,
        //               decoration: BoxDecoration(
        //                 color: Colors.red,
        //               ),
        //             ),
        //           ),
        //         ),
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
            // child: Stack(
            //   children: [
            //     Stack(children: [
            //       Center(
            //           child: CustomPaint(
            //         painter: CirclePainter(),
            //       ))
            //     ]),
            //     Center(child: Text('hi'))
            //   ],
            // )));
            child: Stack(
                //overflow: Overflow.clip,
                children: [
                  // Center(
                  //     child: CustomPaint(
                  //         painter: DrawCircleOuter(
                  //             colors: colors, invertedColors: invertedColors))),
                  Center(
                    child:    Container(
                          height: 350.0,
                          width: 350.0,
                          child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor:AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                              value: secondValue)),
                  ),
                  // Center(
                  //     child: CustomPaint(
                  //   painter: CirclePainter(
                  //       colors: colors, invertedColors: invertedColors),
                  // )),
                  minHands,
                  // Center(child: Container(child: Center(child: boxes))),
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
                              AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                              value: hourValue))),
                  Center(
                      child: Container(child: Center(child: clockDigitInfo))),
                ])));
  }
}
