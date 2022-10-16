import 'package:hive/hive.dart';
import 'package:todolist_hivedb/data/todolist_model.dart';

class ToDoDataBase {
  // List<Task> listToDo = [];
  var myBox = Hive.box('box');
  static const String key = "TODOLIST";

  // execute for 1st ever launch of the app
/*
  void createInitialData() {
    listToDo = [
      Task(id: 0, name: "To Do 1", isCompleted: false),
    ];
  }
*/

  List<Task> loadData() {
    return myBox.get(key);
    // return listToDo;
  }

  void updateData(List<Task> listToDo) {
    myBox.put(key, listToDo);
  }
}
