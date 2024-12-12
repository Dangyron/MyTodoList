import 'package:hive/hive.dart';
import 'task.dart';

part 'folder.g.dart';

@HiveType(typeId: 0)
class Folder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isPinned;

  @HiveField(3)
  String userId;

  @HiveField(4)
  List<Task> tasks;

  Folder({
    required this.id,
    required this.name,
    this.isPinned = false,
    required this.userId,
    List<Task>? tasks,
  }) : tasks = tasks ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isPinned': isPinned,
      'userId': userId,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      name: json['name'],
      isPinned: json['isPinned'] ?? false,
      userId: json['userId'],
      tasks: (json['tasks'] as List<dynamic>)
          .map((taskJson) => Task.fromJson(taskJson))
          .toList(),
    );
  }
}
