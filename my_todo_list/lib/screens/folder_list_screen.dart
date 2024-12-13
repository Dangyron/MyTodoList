import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_todo_list/services/auth_service.dart';
import 'package:my_todo_list/services/data_service.dart';
import 'package:my_todo_list/utils/extentions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/folder.dart';
import '../utils/constants.dart';

class FolderListScreen extends ConsumerStatefulWidget {
  const FolderListScreen({super.key});

  @override
  ConsumerState<FolderListScreen> createState() => _FolderListScreenState();
}

class _FolderListScreenState extends ConsumerState<FolderListScreen> {
  final _authService = AuthService();
  final _dataService = DataService();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Folder> _folders;

  @override
  void initState() {
    super.initState();
    _requestIOSPermissions();
    _folders = _dataService.folders;
    _folders.pinnedSort();
  }

  Future<void> _requestIOSPermissions() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const iosDetails = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(iOS: iosDetails);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    final permissionsGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions();
    if (permissionsGranted == false) {
      log("Permission denied");
    }
  }

  Future<void> _addFolder() async {
    final name = await showDialog(
      context: context,
      builder: (context) => const _FolderInputDialog(title: 'Add Folder'),
    );
    if (name == null || name.isEmpty) return;

    final newFolder = await _dataService.createFolder(folderName: name);
    setState(() {
      _folders.add(newFolder);
      _listKey.currentState?.insertItem(_folders.length - 1);
    });
  }

  Future<void> _renameFolder(int index) async {
    final folder = _folders[index];
    final newName = await showDialog(
      context: context,
      builder: (context) =>
          _FolderInputDialog(title: 'Rename Folder', initialValue: folder.name),
    );
    if (newName == null || newName.isEmpty || newName == folder.name) return;

    setState(() => folder.name = newName);
    await _dataService.renameFolder(folder.id, newName);
  }

  void _removeFolder(int index) async {
    final folder = _folders.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildFolderTile(folder, animation, index),
    );
    await _dataService.deleteFolder(folder.id);
  }

  void _togglePinFolder(int index) async {
    final folder = _folders[index];
    await _dataService.togglePinFolder(folder.id);
    setState(() {
      _folders.pinnedSort();
    });
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'theme',
          child: ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Theme'),
          ),
        ),
        if (_authService.currentUser?.isAnonymous == true)
          const PopupMenuItem(
            value: 'signin',
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('Sign in / Sign up'),
            ),
          ),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'theme') {
          _showThemeDialog();
        } else if (value == 'signin') {
          Navigator.pushNamed(context, Constants.loginRoute);
        } else if (value == 'logout') {
          await _authService.signOut();
          if (mounted) {
            Navigator.popAndPushNamed(context, Constants.initialRoute);
          }
        }
      },
    );
  }

  Widget _buildFolderTile(
      Folder folder, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 15, right: 5),
        title: Text(folder.name),
        leading: GestureDetector(
          onTap: () => _togglePinFolder(index),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              folder.isPinned ? Icons.star : Icons.star_border,
              key: ValueKey(folder.isPinned),
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _renameFolder(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeFolder(index),
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
  }

  Future<void> _showThemeDialog() async {
    final selectedTheme = await showDialog<String>(
      context: context,
      builder: (context) => _ThemeDialog(),
    );

    if (selectedTheme != null) {
      ref.read(themeModeProvider.notifier).state =
          ThemeMode.values.firstWhere((mode) => mode.name == selectedTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-do Folders'),
        actions: [_buildPopupMenu()],
      ),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: _folders.length,
        itemBuilder: (context, index, animation) {
          final folder = _folders[index];
          return _buildFolderTile(folder, animation, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFolder,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FolderInputDialog extends StatelessWidget {
  final String title;
  final String? initialValue;

  const _FolderInputDialog({required this.title, this.initialValue});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return AlertDialog(
      title: Text(title),
      content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Folder Name')),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save')),
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
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();

    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    if (!_prefs.containsKey('theme')) {
      await _prefs.setString('theme', 'system');
    }
    setState(() {
      _selectedTheme = _prefs.getString('theme')!;
    });
  }

  void _saveTheme(String theme) {
    _prefs.setString('theme', theme);
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
