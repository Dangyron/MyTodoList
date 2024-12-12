import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class SingInScreen extends StatelessWidget {
  static const buttonWidth = 300.0;
  static const buttonHeight = 10.0;

  const SingInScreen({super.key});

  Widget _signButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: SingInScreen.buttonWidth,
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
        title: const Text('Login'),
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
          ],
        ),
      ),
    );
  }
}
