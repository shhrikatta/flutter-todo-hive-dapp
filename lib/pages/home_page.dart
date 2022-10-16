import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:todolist_hivedb/data/todolist_model.dart';
import 'package:todolist_hivedb/utils/create_dialog.dart';
import 'package:todolist_hivedb/utils/todo_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ToDoDataBase db = ToDoDataBase();
  final _controller = TextEditingController();

  late ToDoListModel listModel;
  // ToDoListModel listModel = ToDoListModel();

  @override
  void initState() {
    // if this is 1st time ever opening this app
    // listModel.getTodos();

    // myBox.get(ToDoDataBase.key) == null ? db.listToDo : db.loadData();

    super.initState();
  }

  void onCheckBoxChanged(bool? value, int index) {
    var taskRequiredToUpdate = listModel.listToDo[index];
    listModel.toggleComplete(taskRequiredToUpdate.id);
  }

  void onSave() {
    Navigator.of(context).pop();
    listModel.addTask(_controller.text);
    _controller.clear();
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
    listModel.deleteTask(listModel.listToDo[index].id);
  }

  @override
  Widget build(BuildContext context) {
    listModel = Provider.of<ToDoListModel>(context, listen: true);

    return listModel.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
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
            body: LiquidPullToRefresh(
              onRefresh: () => listModel.getTodos(),
              showChildOpacityTransition: false,
              child: ListView.builder(
                itemCount: listModel.listToDo.length,
                itemBuilder: (context, index) {
                  return ToDoTile(
                    taskName: listModel.listToDo[index].name,
                    isTaskCompleted: listModel.listToDo[index].isCompleted,
                    onChanged: (value) => onCheckBoxChanged(value, index),
                    deleteItem: (context) => deleteTask(index),
                  );
                },
              ),
            ),
          );
  }
}
