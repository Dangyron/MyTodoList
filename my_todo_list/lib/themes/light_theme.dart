import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blueAccent,
  scaffoldBackgroundColor: Colors.grey[50],
  appBarTheme: const AppBarTheme(
    color: Colors.blueAccent,
    foregroundColor: Colors.white,
    elevation: 4,
    shadowColor: Colors.black26,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.blueAccent,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.blueAccent,
      side: const BorderSide(color: Colors.blueAccent),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blueAccent.shade100),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blueAccent),
    ),
    labelStyle: const TextStyle(color: Colors.blueAccent),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
    headlineSmall: TextStyle(fontSize: 20.0, color: Colors.blueAccent),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    shadowColor: Colors.grey.withOpacity(0.3),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.blueAccent),
  dividerColor: Colors.blueAccent.shade100,
);

