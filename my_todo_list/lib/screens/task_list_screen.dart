import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_todo_list/services/data_service.dart';
import '../models/folder.dart';
import '../models/task.dart';
import '../utils/notification_helper.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late String folderId;
  late String folderName;
  final _dataService = DataService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final list = ModalRoute.of(context)!.settings.arguments as Set<String>;
    folderId = list.first;
    folderName = list.last;
  }

  Future<void> addTask() async {
    final taskDetails = await showDialog(
      context: context,
      builder: (context) => _AddTaskDialog(),
    );

    if (taskDetails == null) return;

    final title = taskDetails['title'];
    final reminderDate = taskDetails['reminderDate'];

    if (title == null || title.isEmpty) return;
    Task task;
    task = await _dataService.createTask(
        folderId: folderId, title: title, reminderDate: reminderDate);
    if (task.reminderDate != null) {
      NotificationHelper().scheduleReminderNotification(task);
    }
    setState((){});
  }

  Future<void> deleteTask(String taskId) {
    return _dataService.deleteTask(folderId, taskId);
  }

  Future<void> toggleTaskCompletion(String taskId) {
    return _dataService.toggleTaskCompletion(folderId, taskId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async => await addTask(),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _dataService.folderBox.listenable(),
        builder: (context, Box<Folder> box, _) {
          final tasks = _dataService.folders
              .firstWhere((folder) => folder.id == folderId)
              .tasks;
          final uncompletedTasks =
              tasks.where((task) => !task.isCompleted).toList();
          final completedTasks =
              tasks.where((task) => task.isCompleted).toList();

          return ListView.builder(
            itemCount: uncompletedTasks.length +
                1 +
                (completedTasks.isNotEmpty ? 1 : 0),
            // +1 for the "Completed" section header
            itemBuilder: (context, index) {
              if (index < uncompletedTasks.length) {
                // Handle uncompleted tasks
                final task = uncompletedTasks[index];
                return Container(
                  width: double.infinity,
                  // Ensures the ListTile takes full width
                  margin: const EdgeInsets.symmetric(vertical: 0),
                  // Optional spacing between items
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    // Removes extra padding around the ListTile
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => toggleTaskCompletion(task.id),
                    ),
                    title: Text(task.title),
                    subtitle: task.reminderDate != null
                        ? Text('Reminder: ${task.reminderDate}')
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final updatedTaskDetails = await showDialog(
                              context: context,
                              builder: (context) => _EditTaskDialog(task),
                            );
                            if (updatedTaskDetails != null) {
                              final updatedTitle = updatedTaskDetails['title'];
                              final updatedReminder =
                                  updatedTaskDetails['reminderDate'];
                              if (updatedTitle != null &&
                                  updatedTitle.isNotEmpty) {
                                task.title = updatedTitle;
                                task.reminderDate = updatedReminder;
                                await task.save();

                                if(task.reminderDate != null) {
                                  NotificationHelper().scheduleReminderNotification(task);
                                }
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteTask(task.id),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (index == uncompletedTasks.length) {
                return completedTasks.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ExpansionTile(
                          shape: const Border(),
                          title: const Text('Completed'),
                          children: completedTasks.map((task) {
                            return SizedBox(
                              width: double.infinity,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                // Removes extra padding
                                leading: Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (_) =>
                                      toggleTaskCompletion(task.id),
                                ),
                                title: Text(task.title),
                                subtitle: task.reminderDate != null
                                    ? Text('Reminder: ${task.reminderDate}')
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () async {
                                        final updatedTaskDetails =
                                            await showDialog(
                                          context: context,
                                          builder: (context) =>
                                              _EditTaskDialog(task),
                                        );
                                        if (updatedTaskDetails != null) {
                                          final updatedTitle =
                                              updatedTaskDetails['title'];
                                          final updatedReminder =
                                              updatedTaskDetails[
                                                  'reminderDate'];
                                          if (updatedTitle != null &&
                                              updatedTitle.isNotEmpty) {
                                            task.title = updatedTitle;
                                            task.reminderDate = updatedReminder;
                                            await task.save();
                                          }
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => deleteTask(task.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : const SizedBox();
              }
              return const SizedBox();
            },
          );
        },
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  @override
  State<_AddTaskDialog> createState() => __AddTaskDialogState();
}

class __AddTaskDialogState extends State<_AddTaskDialog> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDateTime;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Task Title'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _selectDateTime(context),
            child: const Text('Pick Date & Time'),
          ),
          if (_selectedDateTime != null)
            Text('Reminder: ${_selectedDateTime!.toLocal()}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'title': _controller.text,
              'reminderDate': _selectedDateTime,
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _EditTaskDialog extends StatefulWidget {
  final Task task;

  const _EditTaskDialog(this.task);

  @override
  State<_EditTaskDialog> createState() => __EditTaskDialogState();
}

class __EditTaskDialogState extends State<_EditTaskDialog> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.task.title;
    _selectedDateTime = widget.task.reminderDate;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Task Title'),
          ),
          ElevatedButton(
            onPressed: () => _selectDateTime(context),
            child: const Text('Pick Date & Time'),
          ),
          if (_selectedDateTime != null)
            Text('Reminder: ${_selectedDateTime!.toLocal()}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'title': _controller.text,
              'reminderDate': _selectedDateTime,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
