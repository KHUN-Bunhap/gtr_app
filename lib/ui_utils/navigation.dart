import 'package:flutter/material.dart';
import 'color_size_style.dart';

/// Navigation helper for consistent navigation patterns throughout the app
class NavigationHelper {
  /// Navigate to a new page and replace the current page
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget destination, {
    RouteSettings? settings,
  }) {
    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute(builder: (context) => destination, settings: settings),
    );
  }

  /// Navigate to a new page
  static Future<T?> push<T>(
    BuildContext context,
    Widget destination, {
    RouteSettings? settings,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => destination, settings: settings),
    );
  }

  /// Navigate to a new page and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget destination, {
    RouteSettings? settings,
  }) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (context) => destination, settings: settings),
      (route) => false,
    );
  }

  /// Pop the current page
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Pop until a specific condition is met
  static void popUntil(
    BuildContext context,
    bool Function(Route<dynamic>) predicate,
  ) {
    Navigator.popUntil(context, predicate);
  }

  /// Pop to the first route (usually the home page)
  static void popToFirst(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  /// Show a confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show an information dialog
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show an error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.error),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show a success dialog
  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show a loading dialog
  static void showLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  /// Show a bottom sheet
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => child,
    );
  }

  /// Show a snackbar
  static void showSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
      ),
    );
  }

  /// Show an error snackbar
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    showSnackBar(
      context,
      message: message,
      duration: duration,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }

  /// Show a success snackbar
  static void showSuccessSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message: message,
      duration: duration,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
  }
}
