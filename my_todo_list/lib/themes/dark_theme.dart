import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.amberAccent,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: const AppBarTheme(
    color: Colors.amberAccent,
    foregroundColor: Colors.black,
    elevation: 4,
    shadowColor: Colors.black26,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.amberAccent,
    foregroundColor: Colors.black,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.amberAccent,
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.amberAccent,
      side: const BorderSide(color: Colors.amberAccent),
    ),
  ),
  textButtonTheme: const TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(Colors.amberAccent),
    )
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
      borderSide: BorderSide(color: Colors.amberAccent.shade100),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.amberAccent),
    ),
    labelStyle: const TextStyle(color: Colors.amberAccent),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
    headlineSmall: TextStyle(fontSize: 20.0, color: Colors.amberAccent),
  ),
  cardTheme: CardTheme(
    color: Colors.grey[850],
    shadowColor: Colors.black.withOpacity(0.5),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.amberAccent),
  dividerColor: Colors.amberAccent.shade100,
);

