import 'package:flutter/material.dart';

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => new _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  @override
  Widget build(BuildContext context) {
    var list1 = ListView.separated(
      itemCount: 7,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text('item $index'),
          subtitle: Text("Testtt"),
        );
      },
    );

    var list2 = ListView.separated(
      itemCount: 10,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text('item $index'),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen"),
      ),
      body: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              SizedBox(height: 30,
                child: Text("Downloaded Courses", style: Theme.of(context).textTheme.headline,),
                
              ),
              SizedBox(
                height: 200,
                child: list1,
              ),
              SizedBox(height: 10),
              SizedBox(height: 30,
                child: Text("All Courses", style: Theme.of(context).textTheme.headline,),
              
              ),
              Flexible(child: list2)
            ],
          )
      ),
    );
  }
}
