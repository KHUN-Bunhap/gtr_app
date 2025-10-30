// App colors and theme constants
import 'package:flutter/material.dart';

class AppColors {
  // Basic colors - prefer using Flutter's built-in Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Status colors - prefer using theme colors when possible
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color error = Colors.red;
  static const Color info = Colors.blue;

  // Theme-aware color getters - use these instead of static constants
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black54;

  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color surface(BuildContext context) => Theme.of(context).cardColor;

  static Color primary(BuildContext context) => Theme.of(context).primaryColor;

  // Category colors for posts
  static const Map<String, Color> categoryColors = {
    'general': Colors.blue,
    'academic': Colors.green,
    'events': Colors.orange,
    'announcements': Colors.red,
    'sports': Colors.purple,
    'technology': Colors.teal,
    'default': Colors.grey,
  };
}

class AppSizes {
  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;

  // Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXl = 16.0;

  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXl = 48.0;

  // Avatar sizes
  static const double avatarS = 32.0;
  static const double avatarM = 40.0;
  static const double avatarL = 56.0;
  static const double avatarXl = 72.0;
}

/// Theme-aware text styles that adapt to light/dark mode
class ThemeTextStyles {
  // Headings with theme-aware colors
  static TextStyle h1(BuildContext context) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).textTheme.headlineLarge?.color,
  );

  static TextStyle h2(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).textTheme.headlineMedium?.color,
  );

  static TextStyle h3(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).textTheme.headlineSmall?.color,
  );

  // Body text with theme-aware colors
  static TextStyle body1(BuildContext context) => TextStyle(
    fontSize: 16,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );

  static TextStyle body2(BuildContext context) => TextStyle(
    fontSize: 14,
    color: Theme.of(context).textTheme.bodyMedium?.color,
  );

  // Caption and labels with theme-aware colors
  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: 12,
    color: Theme.of(context).textTheme.bodySmall?.color,
  );

  static TextStyle label(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).textTheme.labelLarge?.color,
  );

  // Button text with theme-aware primary color
  static TextStyle button(BuildContext context) =>
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white);
}
