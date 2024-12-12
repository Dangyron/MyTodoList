import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_todo_list/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'folder_list_screen.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool? isUserLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkUserAuthStatus();
  }

  Future<void> _checkUserAuthStatus() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    final prefs = await SharedPreferences.getInstance();
    bool? isLocallyStoredUser = prefs.getBool(Constants.isLoggedInPref);

    if (firebaseUser != null || (isLocallyStoredUser ?? false)) {
      setState(() {
        isUserLoggedIn = true;
      });
    } else {
      setState(() {
        isUserLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isUserLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (isUserLoggedIn == true) {
      return const FolderListScreen();
    } else {
      return HomeScreen();
    }
  }
}
