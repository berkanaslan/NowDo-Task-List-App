import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/ui.dart';
import 'package:to_do_list_app/utils/database_helper.dart';

class NewTask extends StatefulWidget {
  Task task;

  NewTask([this.task]);

  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  DatabaseHelper databaseHelper;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textFieldController;

  int _charCount = 0;
  TaskTemplate taskTemplate;

  _onChanged(String value) {
    setState(() {
      _charCount = value.length;
    });
  }

  @override
  void initState() {
    databaseHelper = DatabaseHelper();
    taskTemplate = TaskTemplate();
    _charCount = widget.task != null ? widget.task.taskDetail.length : 0;
    _textFieldController =
        TextEditingController(text: widget.task != null ? widget.task.taskDetail : "");
    super.initState();
  }

  Future<bool> _onBackPressed() {
    if (widget.task != null || _charCount > 0) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          title: Text("Aman dikkat!"),
          contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          content: Text("Eğer geriye dönerseniz yaptığınız değişikler kaybolacak."),
          actions: <Widget>[
            FlatButton(
              splashColor: Colors.grey.shade200,
              child: Text(
                "Görevlere dön",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
            FlatButton(
              splashColor: Colors.grey.shade200,
              child: Text(
                "Devam et",
                style: TextStyle(color: Color(0xff5c2fd4)),
              ),
              onPressed: () => Navigator.pop(context, false),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String newTask;
    return _charCount > 0
        ? WillPopScope(
            onWillPop: _onBackPressed,
            child: buildScaffold(context, newTask),
          )
        : buildScaffold(context, newTask);
  }

  Scaffold buildScaffold(BuildContext context, String newTask) {
    return Scaffold(
      appBar: AppBar(
        title: widget.task == null ? Text("Yeni görev ekle") : Text("Görevi güncelle"),
        actions: <Widget>[
          widget.task != null
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    databaseHelper.deleteTask(widget.task.taskID).then((value) {
                      Navigator.pop(context, 1);
                    });
                  },
                )
              : Center(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        tooltip: "Kaydet",
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          if (_formKey.currentState.validate() && widget.task == null) {
            _formKey.currentState.save();
            var now = DateTime.now();
            databaseHelper.addTask(Task(newTask, now.toString(), 0)).then((value) {
              if (value > 0) {
                Navigator.pop(context, 1);
              }
            });
          } else if (_formKey.currentState.validate() && widget.task != null) {
            _formKey.currentState.save();
            var now = DateTime.now();
            int isDone = widget.task.taskIsDone == 0 ? 0 : 1;
            databaseHelper
                .updateTask(
                    Task.withID(widget.task.taskID, newTask, now.toString(), isDone))
                .then((value) {
              if (value > 0) {
                Navigator.pop(context, 1);
              }
            });
          }
        },
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                style: TextStyle(fontSize: 15),
                maxLines: null,
                controller: _textFieldController,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  errorMaxLines: 4,
                  errorStyle: TextStyle(fontSize: 15),
                  border: InputBorder.none,
                  hintText: "Ne kaydetmek istiyorsan onu yaz...",
                  hintStyle: TextStyle(fontSize: 15),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Görev kaydetmek için bir şeyler yazmalısınız!';
                  } else {
                    return newTask;
                  }
                },
                onSaved: (value) {
                  setState(() {
                    newTask = value;
                  });
                },
              ),
              Text(
                _charCount.toString() + " karakter",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
