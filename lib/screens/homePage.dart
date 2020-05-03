import 'package:flutter/material.dart';

import 'course.dart';
import '../player.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: const Text('Idiomi'),
        ),
        body: new Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(flex: 2,
                child: Placeholder(

                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    audioPlayerButton()
                  ],
                ),
              ),
            ]
          )
        ),
      );
  }

  MaterialButton audioPlayerButton() => MaterialButton(
    color: Theme.of(context).primaryColor,
    textColor: Colors.white,
    onPressed: audioPlayerPressed, 
    child: Text(
      "Go to Lessons",
      style: new TextStyle(
        fontSize: 20.0,
      ),
      
      ),
    );


  void audioPlayerPressed() async {
    Navigator.pushNamed(context, '/course', arguments: CourseArguments("f34232432", "Complete Spanish"));
    //Navigator.pushNamed(context, '/courses');


  }

}