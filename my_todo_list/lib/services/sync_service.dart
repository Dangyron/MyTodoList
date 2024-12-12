import 'dart:developer';

import 'package:my_todo_list/services/data_service.dart';

class SyncService {
  final DataService _dataService = DataService();

  Future<void> syncFromFirebase() async {
    try {
      final firebaseFolders = await _dataService.fetchAllFoldersFromFirebase();

      await _dataService.clearLocalData();

      for (var folder in firebaseFolders) {
        await _dataService.addFolder(folder);
      }

      log('Sync from Firebase to Hive completed.');
    } catch (e) {
      log('Error syncing from Firebase: $e');
    }
  }

  Future<void> syncToFirebase() async {
    try {
      final localFolders = _dataService.folders;

      for (var folder in localFolders) {
        await _dataService.addOrUpdateFolderToFirebase(folder);
      }

      log('Sync from Hive to Firebase completed.');
    } catch (e) {
      log('Error syncing to Firebase: $e');
    }
  }
}
