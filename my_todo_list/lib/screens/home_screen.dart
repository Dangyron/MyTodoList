import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../services/sync_service.dart';
import '../models/folder.dart';

import '../services/auth_service.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  static const buttonWidth = 300.0;
  static const buttonHeight = 10.0;
  final AuthService _authService = AuthService();

  HomeScreen({super.key}) {
    _initLocalData();
  }

  Future<void> _initLocalData() async {
    await Hive.openBox<Folder>(Constants.hiveFoldersName);

    if (!_authService.currentUser!.isAnonymous) {
      await SyncService().syncFromFirebase();
    }
  }

  Widget _signButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: HomeScreen.buttonWidth,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do App'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _signButton(
              label: 'Login',
              onPressed: () {
                Navigator.pushNamed(context, Constants.loginRoute);
              },
            ),
            const SizedBox(height: buttonHeight),
            _signButton(
              label: 'Register',
              onPressed: () {
                Navigator.pushNamed(context, Constants.registerRoute);
              },
            ),
            const SizedBox(height: buttonHeight),
            _signButton(
              label: 'Continue as Guest',
              onPressed: () async {
                await _authService.signInAsGuest();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, Constants.foldersRoute);
              },
            ),
          ],
        ),
      ),
    );
  }
}
