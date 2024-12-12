import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_todo_list/services/auth_service.dart';
import 'package:my_todo_list/services/data_service.dart';
import '../main.dart';
import '../models/folder.dart';

import '../utils/constants.dart';

class FolderListScreen extends ConsumerStatefulWidget  {
  const FolderListScreen({super.key});

  @override
  ConsumerState<FolderListScreen> createState() => _FolderListScreenState();
}

class _FolderListScreenState extends ConsumerState<FolderListScreen> {
  final _authService = AuthService();
  final _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _requestIOSPermissions();
  }

  Future<void> _requestIOSPermissions() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const iosDetails = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);
    const initializationSettings = InitializationSettings(iOS: iosDetails);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permission for notifications on iOS
    final permissionsGranted = await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions();
    if (!permissionsGranted!) {
      print("Permission denied");
    }
  }

  Future<void> _addFolder() async {
    final name = await showDialog(
      context: context,
      builder: (context) => _AddFolderDialog(),
    );

    if (name == null || name.isEmpty) return;

    setState(() async {
      await _dataService.createFolder(folderName: name);
    });
  }

  Future<void> _renameFolder(String folderId, String currentName) async {
    final newName = await showDialog(
      context: context,
      builder: (context) => _RenameFolderDialog(currentName: currentName),
    );
    if (newName != null && newName.isNotEmpty && newName != currentName) {
      await _dataService.renameFolder(folderId, newName);
    }
  }

  void _showThemeDialog() async {
    String selectedTheme = await showDialog(
      context: context,
      builder: (context) => _ThemeDialog(),
    ) ?? 'system';

    switch (selectedTheme) {
      case 'light':
        ref.read(themeModeProvider.notifier).state = ThemeMode.light;
        break;
      case 'dark':
        ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
        break;
      case 'system':
        ref.read(themeModeProvider.notifier).state = ThemeMode.system;
        break;
    }
    log('Theme changed to: $selectedTheme');
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-do folders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFolder,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            padding: const EdgeInsets.all(0),
            itemBuilder: (BuildContext context) =>
            [
              const PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(Icons.color_lens, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Theme'),
                  ],
                ),
              ),
              if (_authService.currentUser!.isAnonymous)
                const PopupMenuItem(
                  value: 'signin',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.green),
                      SizedBox(width: 10),
                      Text('Sign in / Sign up'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'theme':
                  _showThemeDialog();
                  break;
                case 'signin':
                  Navigator.pushNamed(context, Constants.singInRoute);
                  log('Sign In / Sign Up selected');
                  break;
                case 'logout':
                  _authService.signOut();
                  break;
              }
            },
          ),
        ],
      )
      ,
      body: ValueListenableBuilder(
        valueListenable: _dataService.folderBox.listenable(),
        builder: (context, Box<Folder> box, _) {
          final folders = _dataService.folders;

          folders.sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            return 0;
          });

          return ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return SizedBox(
                width: double.infinity,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          folder.isPinned ? Icons.star : Icons.star_border,
                        ),
                        onPressed: () async =>
                        await _dataService.togglePinFolder(folder.id),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        folder.name,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async =>
                        await _renameFolder(folder.id, folder.name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async =>
                        // TODO check complited
                        await _dataService.deleteFolder(folder.id),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Constants.tasksRoute,
                      arguments: {folder.id, folder.name},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddFolderDialog extends StatefulWidget {
  @override
  State<_AddFolderDialog> createState() => __AddFolderDialogState();
}

class __AddFolderDialogState extends State<_AddFolderDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Folder'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Folder Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _RenameFolderDialog extends StatefulWidget {
  final String currentName;

  const _RenameFolderDialog({required this.currentName});

  @override
  State<_RenameFolderDialog> createState() => __RenameFolderDialogState();
}

class __RenameFolderDialogState extends State<_RenameFolderDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Folder'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'New Folder Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Rename'),
        ),
      ],
    );
  }
}


class _ThemeDialog extends StatefulWidget {
  @override
  State<_ThemeDialog> createState() => __ThemeDialogState();
}

class __ThemeDialogState extends State<_ThemeDialog> {
  late String _selectedTheme;

  @override
  void initState() {
    super.initState();

    _selectedTheme = Hive.box('settings').get('theme', defaultValue: 'system');
  }

  void _saveTheme(String theme) {
    Hive.box('settings').put('theme', theme);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose theme', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadioListTile(
            contentPadding: EdgeInsets.zero,
            value: 'light',
            groupValue: _selectedTheme,
            title: const Text('Light'),
            onChanged: (value) {
              setState(() => _selectedTheme = value as String);
              _saveTheme(_selectedTheme);
            },
          ),
          RadioListTile(
            contentPadding: EdgeInsets.zero,
            value: 'dark',
            groupValue: _selectedTheme,
            title: const Text('Dark'),
            onChanged: (value) {
              setState(() => _selectedTheme = value as String);
              _saveTheme(_selectedTheme);
            },
          ),
          RadioListTile(
            contentPadding: EdgeInsets.zero,
            value: 'system',
            groupValue: _selectedTheme,
            title: const Text('System'),
            onChanged: (value) {
              setState(() => _selectedTheme = value as String);
              _saveTheme(_selectedTheme);
            },
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          height: 30,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => Navigator.pop(context, _selectedTheme),
            child: const Text('OK'),
          ),
        ),
      ],
    );
  }
}
