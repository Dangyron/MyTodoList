import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);

    try {
      await _authService.registerWithEmailAndPassword(
          _emailController.text, _passwordController.text);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Constants.foldersRoute, (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Text(
              'Create an Account!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sign up to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    style: theme.elevatedButtonTheme.style,
                    child: const Text('Register'),
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, Constants.loginRoute, (route) => false);
              },
              child: Text(
                'Already have an account? Log In',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.primaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _authService.signInAsGuest();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, Constants.foldersRoute, (route) => false);
              },
              child: Text(
                'Continue as a Guest',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
