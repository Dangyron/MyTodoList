import 'package:flutter/material.dart';
import 'package:my_todo_list/folder.dart';

class Task {
  String text;
  bool isCompleted;

  Task({required this.text, this.isCompleted = false});
}

class TaskListScreen extends StatefulWidget {
  final Folder folder;

  const TaskListScreen({super.key, required this.folder});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();

  void _addTask(String taskText) {
    setState(() {
      widget.folder.tasks.add(Task(text: taskText));
    });
    _taskController.clear();
  }

  void _editTask(Task task, String newText) {
    setState(() {
      task.text = newText;
    });
  }

  void _removeTask(int index) {
    setState(() {
      widget.folder.tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Add a task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      _addTask(_taskController.text);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.folder.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.folder.tasks[index];
                return ListTile(
                  title: Text(
                    task.text,
                    style: TextStyle(
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      setState(() {
                        task.isCompleted = value ?? false;
                      });
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(task);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeTask(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Task task) {
    final TextEditingController editController =
        TextEditingController(text: task.text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Task',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  _editTask(task, editController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
