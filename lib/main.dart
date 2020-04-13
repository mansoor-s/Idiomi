import 'package:idiomi/screens/homePage.dart';
import 'package:idiomi/screens/coursesPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Idiomi',
    // Start the app with the "/" named route. In this case, the app starts
    // on the FirstScreen widget.
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => HomePage(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/courses': (context) => CoursesPage(),
    },
  ));
}