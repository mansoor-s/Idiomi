import 'dart:io';

import 'package:idiomi/screens/course.dart';
import 'package:idiomi/screens/homePage.dart';
import 'package:idiomi/screens/coursesPage.dart';
import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';

import 'player.dart';

void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  //sleep(const Duration(milliseconds: 2000));
  
  //sleep(const Duration(milliseconds: 1000));
  //Player.start();

  runApp(MaterialApp(
    title: 'Idiomi',
    // Start the app with the "/" named route. In this case, the app starts
    // on the FirstScreen widget.
    theme: ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blueGrey
    ),
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => AudioServiceWidget(child: HomePage()),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/courses': (context) => CoursesPage(),
      '/course': (context) => AudioServiceWidget(child: CoursePage()),
    },
  ));
}