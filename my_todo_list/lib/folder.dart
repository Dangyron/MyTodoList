import 'package:flutter/material.dart';
import 'package:my_todo_list/task.dart';

class Folder {
  String name;
  List<Task> tasks;
  bool isPinned;

  Folder({required this.name, List<Task>? tasks, this.isPinned = false})
      : tasks = tasks ?? [];
}

class FolderListScreen extends StatefulWidget {
  const FolderListScreen({super.key});

  @override
  FolderListScreenState createState() => FolderListScreenState();
}

class FolderListScreenState extends State<FolderListScreen> {
  final List<Folder> _folders = [];
  final TextEditingController _folderController = TextEditingController();

  void _addFolder(String folderName) {
    setState(() {
      _folders.add(Folder(name: folderName));
    });
    _folderController.clear();
  }

  void _togglePin(int index) {
    setState(() {
      _folders[index].isPinned = !_folders[index].isPinned;
      _folders.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });
    });
  }

  void _removeFolder(int index) {
    setState(() {
      _folders.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _folderController,
                    decoration: const InputDecoration(
                      labelText: 'Add a folder',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_folderController.text.isNotEmpty) {
                      _addFolder(_folderController.text);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_folders[index].name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _folders[index].isPinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                          color: _folders[index].isPinned ? Colors.blue : null,
                        ),
                        onPressed: () => _togglePin(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeFolder(index),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TaskListScreen(folder: _folders[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
