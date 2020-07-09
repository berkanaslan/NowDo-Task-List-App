import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/ui.dart';

void main() => runApp(TasksApp());

class TasksApp extends StatefulWidget {
  @override
  _TasksAppState createState() => _TasksAppState();
}

class _TasksAppState extends State<TasksApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tasks List App",
      theme: ThemeData(
        fontFamily: "RobotoCondensed",
        primaryColor: Color(0xff5c2fd4),
        accentColor: Color(0xff3E4369),
        canvasColor: Color(0xffffffff),
      ),
      home: TaskTemplate(),
    );
  }
}
