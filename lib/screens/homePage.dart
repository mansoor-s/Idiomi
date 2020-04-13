import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:audio_service/audio_service.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connect();
  }

  @override
  void dispose() {
    disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        connect();
        log('connected');
        break;
      case AppLifecycleState.paused:
        log('disconnected');
        disconnect();
        break;
      default:
        break;
    }
  }

  void connect() async {
    await AudioService.connect();
  }

  void disconnect() {
    AudioService.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () {
          disconnect();
          return Future.value(true);
        },
        child: new Scaffold(
          appBar: new AppBar(
            title: const Text('Idiomi'),
          ),
          body: new Center(
            child: Container(
              child: audioPlayerButton(),
            ),
          ),
        ),
      );
  }

  RaisedButton audioPlayerButton() {
    //start audio player widget here
    return RaisedButton(onPressed: audioPlayerPressed, child: const Text("Get the show started!"),);
  }
  void audioPlayerPressed() {
    log('In audio button press!');
    Navigator.pushNamed(context, '/courses');
  }

}