import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/folder.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class DataService {
  final _currentUser = AuthService().currentUser!;
  final folderBox = Hive.box<Folder>(Constants.hiveFoldersName);
  final folderCollection =
      FirebaseFirestore.instance.collection(Constants.hiveFoldersName);

  List<Folder> get folders => folderBox.values.toList();

  Future<Folder> createFolder({
    required String folderName,
    bool isPinned = false,
    List<Task>? tasks,
  }) async {
    final folder = Folder(
        id: const Uuid().v7(),
        name: folderName,
        userId: _currentUser.uid,
        isPinned: isPinned,
        tasks: tasks);

    await folderBox.put(folder.id, folder);
    if (!_currentUser.isAnonymous) {
      folderCollection.doc(folder.id).set(folder.toJson());
    }

    return folder;
  }

  Future<Folder> addFolder(Folder folder) async {
    await folderBox.put(folder.id, folder);

    return folder;
  }

  Future<void> deleteFolder(String folderId) async {
    final folder = folderBox.get(folderId);
    if (folder != null) {
      await folderBox.delete(folderId);

      if (!_currentUser.isAnonymous) {
        folderCollection.doc(folderId).delete();
      }
    }
  }

  Future<void> clearLocalData() {
    return folderBox.clear();
  }

  Future<List<Folder>> fetchAllFoldersFromFirebase() async {
    final snapshot = await folderCollection.where('userId', isEqualTo: _currentUser.uid).get();
    return snapshot.docs.map((doc) => Folder.fromJson(doc.data())).toList();
  }

  Future<void> addOrUpdateFolderToFirebase(Folder folder) {
    return folderCollection.doc(folder.id).set(folder.toJson());
  }

  Future<void> renameFolder(String folderId, String newName) async {
    final folder = folderBox.get(folderId);
    if (folder == null) return;

    folder.name = newName;
    await folder.save();

    if (!_currentUser.isAnonymous) {
      folderCollection.doc(folderId).update({'name': newName});
    }
  }

  Future<void> togglePinFolder(String folderId) async {
    final folder = folderBox.get(folderId);
    if (folder == null) return;

    folder.isPinned = !folder.isPinned;
    await folder.save();

    if (!_currentUser.isAnonymous) {
      folderCollection.doc(folderId).update({'isPinned': folder.isPinned});
    }
  }

  Future<Task> createTask({
    required String folderId,
    required String title,
    bool isCompleted = false,
    DateTime? reminderDate,
  }) async {
    final task = Task(
        id: const Uuid().v7(),
        title: title,
        isCompleted: isCompleted,
        reminderDate: reminderDate);

    final folder = folderBox.get(folderId);
    if (folder != null) {
      folder.tasks.add(task);
      await folder.save();

      if (!_currentUser.isAnonymous) {
        folderCollection.doc(folder.id).update(
            {'tasks': folder.tasks.map((task) => task.toJson()).toList()});
      }
    }

    return task;
  }

  Future<void> deleteTask(String folderId, String taskId) async {
    final folder = folderBox.get(folderId);
    if (folder != null) {
      folder.tasks.removeWhere((task) => task.id == taskId);
      await folder.save();

      if (!_currentUser.isAnonymous) {
        folderCollection.doc(folder.id).update(
            {'tasks': folder.tasks.map((task) => task.toJson()).toList()});
      }
    }
  }

  Future<void> updateTaskTitle(
      String folderId, String taskId, String newTitle) async {
    final folder = folderBox.get(folderId);
    final task = folder?.tasks.firstWhere((task) => task.id == taskId);
    if (task != null) {
      task.title = newTitle;
      await folder!.save();

      if (!_currentUser.isAnonymous) {
        folderCollection.doc(folder.id).update(
            {'tasks': folder.tasks.map((task) => task.toJson()).toList()});
      }
    }
  }

  Future<void> updateTaskReminder(
      String folderId, String taskId, DateTime? newReminderDate) async {
    final folder = folderBox.get(folderId);
    final task = folder?.tasks.firstWhere((task) => task.id == taskId);
    if (task != null) {
      task.reminderDate = newReminderDate;
      await folder!.save();

      if (!_currentUser.isAnonymous) {
        folderCollection.doc(folder.id).update(
            {'tasks': folder.tasks.map((task) => task.toJson()).toList()});
      }
    }
  }

  Future<void> toggleTaskCompletion(String folderId, String taskId) async {
    final folder = folderBox.get(folderId);
    final task = folder?.tasks.firstWhere((task) => task.id == taskId);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await folder!.save();

      if (!_currentUser.isAnonymous) {
        folderCollection.doc(folder.id).update(
            {'tasks': folder.tasks.map((task) => task.toJson()).toList()});
      }
    }
  }
}
