import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_todo_list/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'folder_list_screen.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  Future<bool> _checkUserAuthStatus () async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(Constants.isLoggedInPref)) {
      await prefs.setBool(Constants.isLoggedInPref, false);
    }
    final isLocallyStoredUser = prefs.getBool(Constants.isLoggedInPref)!;

    return firebaseUser != null || isLocallyStoredUser;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkUserAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong!')),
          );
        } else if (snapshot.data == true) {
          return const FolderListScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
