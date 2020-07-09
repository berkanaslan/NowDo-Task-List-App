import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animated_card/animated_card_direction.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:animated_card/animated_card.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:to_do_list_app/new_and_update_task.dart';
import 'package:to_do_list_app/utils/database_helper.dart';
import 'models/task.dart';
import 'package:enhanced_future_builder/enhanced_future_builder.dart';
import 'package:flushbar/flushbar.dart';

class TaskTemplate extends StatefulWidget {
  @override
  _TaskTemplateState createState() => _TaskTemplateState();
}

class _TaskTemplateState extends State<TaskTemplate> {
  DatabaseHelper databaseHelper;
  Future<List<Task>> _future;
  int totalTask = 0;
  int isDone;
  bool firstOpening = true;
  bool refreshList;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Null> refreshTaskList() async {
    refreshKey.currentState?.show(atTop: true);
    await Future.delayed(Duration(milliseconds: 0));
    setState(() {
      _future = getList();
    });

    return null;
  }

  @override
  void initState() {
    databaseHelper = DatabaseHelper();
    _future = getList();
    super.initState();
  }

  Future<List<Task>> getList() async {
    return databaseHelper.getTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshTaskList,
        child: Stack(
          children: <Widget>[
            CustomScrollView(
              slivers: <Widget>[
                buildSliverStickyHeader(),
              ],
            ),
            addTaskButton(),
          ],
        ),
      ),
    );
  }

  SliverStickyHeader buildSliverStickyHeader() {
    return SliverStickyHeader(
      sticky: false,
      header: Container(
        height: 150.0,
        color: Colors.white,
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            headerTitle(),
            SizedBox(height: 15),
            headerDescription(),
          ],
        ),
      ),
      sliver: futureBuilder(),
    );
  }

  Text headerTitle() {
    return Text(
      "NowDo",
      style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(62, 67, 105, 1)),
    );
  }

  RichText headerDescription() {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Color.fromRGBO(143, 143, 169, 1), fontSize: 16.00),
        children: <TextSpan>[
          TextSpan(text: 'Tamamlanması gereken'),
          TextSpan(
              text: " ",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color.fromRGBO(62, 67, 105, 1))),
          TextSpan(text: 'görevler var.'),
        ],
      ),
    );
  }

  Widget addTaskButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: Color(0xff5c2fd4),
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NewTask()))
                  .then((value) => value == 1 ? refreshTaskList() : value = 0);
            },
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Container(
              height: 50,
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Yeni görev",
                    style: TextStyle(
                        fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  futureBuilder() {
    return EnhancedFutureBuilder(
      future: _future,
      rememberFutureResult: false,
      whenDone: (List<Task> item) {
        return SliverStaggeredGrid.countBuilder(
            crossAxisCount: 2,
            itemCount: item.length,
            itemBuilder: (BuildContext context, int index) {
              if (firstOpening == true) {
                return AnimatedCard(
                  direction: AnimatedCardDirection.right,
                  curve: Curves.linearToEaseOut,
                  onRemove: () {
                    deleteTask(item, index, context);
                  },
                  child: taskCardTemplate(item, index),
                );
              } else {
                return AnimatedCard(
                  initOffset: Offset.zero,
                  onRemove: () {
                    deleteTask(item, index, context);
                  },
                  child: taskCardTemplate(item, index),
                );
              }
            },
            staggeredTileBuilder: (int index) => StaggeredTile.fit(1));
      },
      whenNotDone: SliverStaggeredGrid.count(crossAxisCount: 2),
    );
  }

  void deleteTask(List<Task> item, int index, BuildContext context) {
    databaseHelper.deleteTask(item[index].taskID).then((value) {
      if (value > 0) {
        Flushbar(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 100),
          borderRadius: 10,
          message: "Görev silindi.",
          duration: Duration(seconds: 2),
        ).show(context);
      }
    });
  }

  Container taskCardTemplate(List<Task> item, int index) {
    return Container(
      margin: EdgeInsets.all(10),
      color: Colors.transparent,
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NewTask(item[index])))
                .then((value) => value == 1 ? refreshTaskList() : value = 0);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                      child: buildCheckbox(item, index),
                    ),
                    item[index].taskDetail.length <= 140
                        ? Text(
                            item[index].taskDetail,
                            style: TextStyle(
                                fontSize: 14.00,
                                decoration: item[index].taskIsDone == 0
                                    ? TextDecoration.none
                                    : TextDecoration.lineThrough,
                                color: item[index].taskIsDone == 0
                                    ? Colors.black
                                    : Colors.grey),
                          )
                        : Text(
                            item[index].taskDetail.substring(0, 140) + "...",
                            style: TextStyle(
                                fontSize: 14.00,
                                decoration: item[index].taskIsDone == 0
                                    ? TextDecoration.none
                                    : TextDecoration.lineThrough,
                                color: item[index].taskIsDone == 0
                                    ? Colors.black
                                    : Colors.grey),
                          ),
                    SizedBox(height: 10),
                    Text(
                      databaseHelper.dateFormat(DateTime.parse(item[index].taskDate)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildCheckbox(List<Task> item, int index) {
    List<Color> colors = [
      Color(0xff423E37),
      Color(0xffE3B23C),
      Color(0xff7D84B2),
      Color(0xff8E9DCC),
      Color(0xff6D2E46),
      Color(0xffA26769),
      Color(0xff040F0F),
      Color(0xffd7aefc),
      Color(0xff85BDBF),
      Color(0xff0A2E36),
      Color(0xffE54B4B),
      Color(0xffD7263D),
      Color(0xff2E294E),
      Color(0xffC5D86D),
      Color(0xff1B998B),
    ];

    var rnd = new Random();
    int i = rnd.nextInt(15);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        RoundCheckBox(
          size: 20,
          borderColor: item[index].taskIsDone == 0 ? colors[i] : Color(0xff5c2fd4),
          checkedColor: Color(0xff5c2fd4),
          onTap: (value) {
            setState(() {
              firstOpening = false;
              if (item[index].taskIsDone == 0) {
                item[index].taskIsDone = 1;
                var now = DateTime.now();
                databaseHelper.updateTaskIsDone(item[index].taskID, 1);
              } else {
                item[index].taskIsDone = 0;
                databaseHelper.updateTaskIsDone(item[index].taskID, 0);
              }
            });
          },
          isChecked: item[index].taskIsDone == 0 ? false : true,
        ),
      ],
    );
  }
}
