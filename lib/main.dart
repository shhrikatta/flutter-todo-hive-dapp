import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todolist_hivedb/data/todolist_model.dart';

import 'pages/home_page.dart';

void main() async {
  // init hive DB
  await Hive.initFlutter();
  await Hive.openBox('box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ToDoListModel(),
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.yellow),
        home: const HomePage(),
      ),
    );
  }
}
