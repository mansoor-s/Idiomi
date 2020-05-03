import 'package:flutter/material.dart';

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => new _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  @override
  Widget build(BuildContext context) {
    var coursesList = ListView.separated(
      itemCount: 20,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text('item $index'),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Available Languages"),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10),
              Flexible(child: coursesList)
            ],
          )
      ),
    );
  }
}
