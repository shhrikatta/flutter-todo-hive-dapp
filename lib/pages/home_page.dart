import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todolist_hivedb/data/database.dart';
import 'package:todolist_hivedb/utils/create_dialog.dart';
import 'package:todolist_hivedb/utils/todo_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ToDoDataBase db = ToDoDataBase();
  var myBox = Hive.box('box');
  final _controller = TextEditingController();

  @override
  void initState() {
    // if this is 1st time ever opening this app
    myBox.get(ToDoDataBase.key) == null
        ? db.createInitialData()
        : db.loadData();

    super.initState();
  }

  void onCheckBoxChanged(bool? value, int index) {
    setState(() {
      db.listToDo[index][1] = !db.listToDo[index][1];
    });

    db.updateData();
  }

  void onSave() {
    setState(() {
      db.listToDo.add([_controller.text, false]);
      _controller.clear();
    });

    Navigator.of(context).pop();
    db.updateData();
  }

  void onCancel() => Navigator.of(context).pop();

  void createNewTask() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onCancel: onCancel,
            onSave: onSave,
          );
        });
  }

  void deleteTask(int index) {
    setState(() {
      db.listToDo.removeAt(index);
    });

    db.updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        elevation: 0,
        title: const Text("To-Do"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: db.listToDo.length,
        itemBuilder: (context, index) {
          return ToDoTile(
            taskName: db.listToDo[index][0],
            isTaskCompleted: db.listToDo[index][1],
            onChanged: (value) => onCheckBoxChanged(value, index),
            deleteItem: (context) => deleteTask(index),
          );
        },
      ),
    );
  }
}
