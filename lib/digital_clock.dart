// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:digital_clock/model.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> with SingleTickerProviderStateMixin  {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  String location;
  String weatherCondition;
  String date;
  String temperature, high, low;
  String unit;
  bool isDay;
  String weatherIcon = 'assets/WeatherIcons_animated.flr';
  String animationString = 'sun_animated';
  String weatherBackground;
  bool isAnimating = false;
  Color textColour = Colors.blueGrey[900];

  AnimationController _animationController;
  FlareController controller;
  FlareActor flareActorSun, flareActorMoon;

  @override
  void initState() {
    super.initState();

    timeDilation = 2.0;
    Duration duration = Duration(seconds: 1);

    //Animate the clock
    _animationController = new AnimationController(vsync: this, duration: duration);
    _animationController.repeat();

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
      location = widget.model.location;
      date = widget.model.date;
      weatherCondition = widget.model.weatherString;
      temperature = widget.model.temperatureString;
      high = widget.model.highString;
      low = widget.model.lowString;
      unit = widget.model.unitString;
      isDay = widget.model.dayNightString;
      findDayOrNight();
      getWeatherData();
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  void findDayOrNight() {
    if (isDay) {
      weatherBackground = 'assets/Sunny.gif';
      weatherIcon = 'assets/iconSunny.png';
      textColour = Colors.black87;
    }
    else {
      weatherBackground = 'assets/Moon.gif';
      weatherIcon = 'assets/iconMoon.gif';
      textColour = Colors.grey[50];
    }
  }

  void getWeatherData() {
    switch (weatherCondition) {
      case 'Cloudy': {
        weatherBackground = 'assets/Cloudy.gif';
        textColour = Colors.black87;
      }
      break;
      case 'Foggy': {
        weatherBackground = 'assets/Foggy.gif';
        textColour = Colors.black87;
      }
      break;
      case 'Rainy': {
        weatherBackground = 'assets/Rainy.gif';
        textColour = Colors.black87;
      }
      break;
      case 'Snowy': {
        weatherBackground = 'assets/Snowy.gif';
        textColour = Colors.black87;
      }
      break;
      case 'Sunny': {
        findDayOrNight();
      }
      break;
      case 'Thunderstorm': {
        weatherBackground = 'assets/Thunderstrom.gif';
        textColour = Colors.grey[50];

      }
      break;
      case 'Windy': {
        weatherBackground = 'assets/Windy.gif';
        textColour = Colors.black87;
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour =
    DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);

    return SafeArea(
      child: Container(
//          color: colors[_Element.background],
          decoration: new BoxDecoration(
              image: DecorationImage(
                image: AssetImage(weatherBackground),
                fit: BoxFit.fill,
              )
          ),
          child: Column(
            children: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30.0, 30.0, 0.0, 0.0),
                        child: Text(
                          location,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColour,
                            fontSize: 20.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
                        child: Image(
                          image: AssetImage(weatherIcon),
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        )
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
                        child: Text(
                          date,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColour,
                            fontSize: 20.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    hour,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColour,
                      fontSize: 100.0,
                      letterSpacing: 3.0,
                    ),
                  ),
                  FadeTransition(
                    opacity: _animationController,
                    child: Text(
                      ':',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColour,
                          fontSize: 56.0,
                          letterSpacing: 3.0
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    minute,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColour,
                        fontSize: 100.0,
                        letterSpacing: 3.0
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    temperature,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColour,
                      fontSize: 20.0,
                      letterSpacing: 3.0,
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  Text(
                    weatherCondition,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColour,
                      fontSize: 20.0,
                      letterSpacing: 3.0,
                    ),
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }
}
