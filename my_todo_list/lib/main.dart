import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_todo_list/screens/auth_check.dart';
import 'package:my_todo_list/screens/folder_list_screen.dart';
import 'package:my_todo_list/screens/task_list_screen.dart';
import 'package:my_todo_list/services/sync_service.dart';
import 'package:my_todo_list/themes/dark_theme.dart';
import 'package:my_todo_list/themes/light_theme.dart';
import 'models/task.dart';
import 'models/folder.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'utils/constants.dart';

import 'package:timezone/data/latest.dart' as tz;

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(FolderAdapter());

  await Hive.openBox<Folder>(Constants.hiveFoldersName);

  final syncService = SyncService();

  await _initNotifications();

  runApp(const ProviderScope(child: TodoListApp()));
}

Future<void> _initNotifications() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iOSInitialization = DarwinInitializationSettings();
  const initializationSettings = InitializationSettings(
    android: androidInitialization,
    iOS: iOSInitialization,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  tz.initializeTimeZones();
}

class TodoListApp extends ConsumerWidget {
  const TodoListApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: Constants.initialRoute,
      routes: {
        Constants.initialRoute: (context) => const AuthCheck(),
        Constants.loginRoute: (context) => const LoginScreen(),
        Constants.registerRoute: (context) => const RegisterScreen(),
        Constants.foldersRoute: (context) => const FolderListScreen(),
        Constants.tasksRoute: (context) => const TaskListScreen(),
      },
    );
  }
}
