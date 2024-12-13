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

  final GlobalKey<AnimatedListState> _uncompletedListKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _completedListKey =
      GlobalKey<AnimatedListState>();

  List<Task> uncompletedTasks = [];
  List<Task> completedTasks = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final list = ModalRoute.of(context)!.settings.arguments as Set<String>;
    folderId = list.first;
    folderName = list.last;

    _updateTaskLists();
  }

  void _updateTaskLists() {
    final tasks = _dataService.folders
        .firstWhere((folder) => folder.id == folderId)
        .tasks;

    setState(() {
      uncompletedTasks =
          tasks.where((task) => !task.isCompleted).toList(growable: true);
      completedTasks =
          tasks.where((task) => task.isCompleted).toList(growable: true);
    });
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

    Task task = await _dataService.createTask(
        folderId: folderId, title: title, reminderDate: reminderDate);

    if (task.reminderDate != null) {
      NotificationHelper().scheduleReminderNotification(task);
    }

    setState(() {
      uncompletedTasks.add(task);
      _uncompletedListKey.currentState?.insertItem(uncompletedTasks.length - 1);
    });
  }

  Future<void> toggleTaskCompletion(Task task) async {
    await _dataService.toggleTaskCompletion(folderId, task.id);

    if (task.isCompleted) {
      final index = uncompletedTasks.indexOf(task);
      final removedTask = uncompletedTasks.removeAt(index);
      _uncompletedListKey.currentState?.removeItem(
        index,
        (context, animation) => _buildTaskCard(removedTask, animation),
      );

      completedTasks.insert(0, task);
      _completedListKey.currentState?.insertItem(0);
    } else {
      final index = completedTasks.indexOf(task);
      final removedTask = completedTasks.removeAt(index);
      _completedListKey.currentState?.removeItem(
        index,
        (context, animation) => _buildTaskCard(removedTask, animation),
      );

      uncompletedTasks.insert(0, task);
      _uncompletedListKey.currentState?.insertItem(0);
    }

    setState(() {});
  }

  Future<void> deleteTask(Task task, bool isCompleted) async {
    await _dataService.deleteTask(folderId, task.id);

    if (isCompleted) {
      final index = completedTasks.indexOf(task);
      final removedTask = completedTasks.removeAt(index);
      _completedListKey.currentState?.removeItem(
        index,
            (context, animation) => _buildTaskCard(removedTask, animation),
      );
    } else {
      final index = uncompletedTasks.indexOf(task);
      final removedTask = uncompletedTasks.removeAt(index);
      _uncompletedListKey.currentState?.removeItem(
        index,
            (context, animation) => _buildTaskCard(removedTask, animation),
      );
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (uncompletedTasks.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Uncompleted Tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            AnimatedList(
              key: _uncompletedListKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index, animation) {
                return _buildTaskCard(uncompletedTasks[index], animation);
              },
              initialItemCount: uncompletedTasks.length,
            ),
            if (completedTasks.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Completed Tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            AnimatedList(
              key: _completedListKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index, animation) {
                return _buildTaskCard(completedTasks[index], animation);
              },
              initialItemCount: completedTasks.length,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await addTask(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskCard(Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ListTile(
          contentPadding: EdgeInsets.only(left: 2),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => toggleTaskCompletion(task),
          ),
          title: Text(task.title),
          subtitle: task.reminderDate != null
              ? Text('Reminder: ${task.reminderDate}')
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async => await _editTask(task),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteTask(task, task.isCompleted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editTask(Task task) async {
    final updatedTaskDetails = await showDialog(
      context: context,
      builder: (context) => _EditTaskDialog(task),
    );
    if (updatedTaskDetails != null) {
      final updatedTitle = updatedTaskDetails['title'];
      final updatedReminder = updatedTaskDetails['reminderDate'];
      if (updatedTitle != null && updatedTitle.isNotEmpty) {
        task.title = updatedTitle;
        task.reminderDate = updatedReminder;
        await task.save();
        if (task.reminderDate != null) {
          NotificationHelper().scheduleReminderNotification(task);
        }
        setState(() {});
      }
    }
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 0.0),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(task.title),
        subtitle: task.reminderDate != null
            ? Text('Reminder: ${task.reminderDate}')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
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
