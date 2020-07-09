class Task {
  int taskID;
  String taskDetail;
  String taskDate;
  int taskIsDone;

  // for new task
  Task(this.taskDetail, this.taskDate, this.taskIsDone);

  // for current task
  Task.withID(this.taskID, this.taskDetail, this.taskDate, this.taskIsDone);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['taskID'] = taskID;
    map['taskDetail'] = taskDetail;
    map['taskDate'] = taskDate;
    map['taskIsDone'] = taskIsDone;
    return map;
  }

  Task.fromMap(Map<String, dynamic> map) {
    this.taskID = map['taskID'];
    this.taskDetail = map['taskDetail'];
    this.taskDate = map['taskDate'];
    this.taskIsDone = map['taskIsDone'];
  }

  @override
  String toString() {
    return 'Task{taskID: $taskID, taskDetail: $taskDetail, taskDate: $taskDate, taskIsDone: $taskIsDone}';
  }
}

