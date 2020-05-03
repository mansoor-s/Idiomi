import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';

import 'package:idiomi/playlist.dart';
import 'package:idiomi/player.dart';

import 'package:idiomi/playerWidget.dart';


class CourseArguments {
  final String id;
  final String name;
  
  CourseArguments(this.id, this.name);
}


class CoursePage extends StatefulWidget {
  //AudioPlayer player;
  CoursePage() {
    log('Course page initialized!');
    //this.player = player;
    // Set course here if first time clicking on this course. Otherwise load from system store to pick up where left off
  }

  @override
  _CoursePageState createState() => new _CoursePageState();
}


class _CoursePageState extends State<CoursePage> {
  @override
  Widget build(BuildContext context) {
    final CourseArguments args = ModalRoute.of(context).settings.arguments;

      return Scaffold(
        appBar: AppBar(
          title: Text(args.name),
        ),
        body: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                SizedBox(height: 180,
                  child: PlayerControlsWidget()
                  
                )
              ]
            )
        ),
      );

  }

  


}


