import 'package:flutter/material.dart';
import 'package:my_todo_list/folder.dart';

class TodoListApp extends StatelessWidget {
  const TodoListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FolderListScreen(),
    );
  }
}
