// Import Flutter material design package
import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  // Singleton pattern implementation
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  /// Light Theme Configuration
  ThemeData get lightTheme => ThemeData.light().copyWith(
    primaryColor: const Color.fromARGB(255, 3, 52, 92),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 3, 52, 92),
      brightness: Brightness.light,
    ),
  );

  /// Dark Theme Configuration
  ThemeData get darkTheme => ThemeData.dark().copyWith(
    primaryColor: const Color.fromARGB(255, 44, 125, 192),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 44, 125, 192),
      brightness: Brightness.dark,
    ),
  );

  // Private field to track current theme state
  bool _isDarkTheme = false;

  // Getter to access current theme state
  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners(); // Update all UI components using this theme
  }

  void setTheme(bool isDark) {
    _isDarkTheme = isDark;
    notifyListeners(); // Update all UI components using this theme
  }

  ThemeData get currentTheme => _isDarkTheme ? darkTheme : lightTheme;
}
