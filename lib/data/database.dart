import 'package:hive/hive.dart';

class ToDoDataBase {
  List listToDo = [];
  var myBox = Hive.box('box');
  static const String key = "TODOLIST";

  // execute for 1st ever launch of the app
  void createInitialData() {
    listToDo = [
      ["To Do 1", false],
      ["To Do 2", false],
    ];
  }

  void loadData() {
    listToDo = myBox.get(key);
  }

  void updateData() {
    myBox.put(key, listToDo);
  }
}
