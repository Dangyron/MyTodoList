import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.deepPurple,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: const AppBarTheme(
    color: Colors.deepPurple,
    foregroundColor: Colors.white,
    elevation: 4,
    shadowColor: Colors.black26,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.tealAccent,
      side: const BorderSide(color: Colors.tealAccent),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[800],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.teal.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.teal),
    ),
    labelStyle: const TextStyle(color: Colors.tealAccent),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
    headlineSmall: TextStyle(fontSize: 20.0, color: Colors.tealAccent),
  ),
  cardTheme: CardTheme(
    color: Colors.grey[850],
    shadowColor: Colors.black.withOpacity(0.5),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.tealAccent),
  dividerColor: Colors.teal.shade100,
);
