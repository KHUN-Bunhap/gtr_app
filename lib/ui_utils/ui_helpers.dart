// Common UI helper functions and widgets
import 'package:flutter/material.dart';
import 'color_size_style.dart';
import 'device_font.dart';

class UIHelpers {
  // Common spacing widgets
  static Widget verticalSpace(double height) => SizedBox(height: height);
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  // Responsive spacing
  static Widget responsiveVerticalSpace({required DeviceType deviceType}) {
    final height = ResponsiveUtils.responsiveScale(
      mobile: AppSizes.spacingM,
      deviceType: deviceType,
    );
    return SizedBox(height: height);
  }

  static Widget responsiveHorizontalSpace({required DeviceType deviceType}) {
    final width = ResponsiveUtils.responsiveScale(
      mobile: AppSizes.spacingM,
      deviceType: deviceType,
    );
    return SizedBox(width: width);
  }

  // Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // App bar
  static PreferredSizeWidget gtrAppBar({
    required String title,
    List<Widget>? actions,
    bool centerTitle = true,
    required BuildContext context,
    List<Widget>? tabs,
    bool? isBold,
    bool? isDarkMode,
  }) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isBold == true ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      elevation: 2,
      centerTitle: centerTitle,
      actions: actions,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Theme.of(context).primaryColor,
      iconTheme: IconThemeData(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).primaryColor
            : Colors.white,
      ),
      bottom: tabs != null
          ? TabBar(
              tabs: tabs,
              indicatorColor: Colors.white,
              labelColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).primaryColor
                  : Colors.white,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onPrimary.withOpacity(0.7),
            )
          : null,
    );
  }

  // Loading indicator - now uses theme color if no color specified
  static Widget loadingIndicator({Color? color, BuildContext? context}) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        color ??
            (context != null ? Theme.of(context).primaryColor : Colors.blue),
      ),
    );
  }

  // Error widget - now uses AppColors.error status color
  static Widget errorWidget({
    required String message,
    required BuildContext context,
    VoidCallback? onRetry,
    bool isTablet = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 64 : 48,
            color: AppColors.error,
          ),
          verticalSpace(AppSizes.spacingM),
          Text(
            message,
            style: ThemeTextStyles.body1(context),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            verticalSpace(AppSizes.spacingM),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }

  // Empty state widget
  static Widget emptyStateWidget({
    required String message,
    required BuildContext context,
    IconData icon = Icons.inbox,
    bool isTablet = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isTablet ? 64 : 48, color: Colors.grey[400]),
          verticalSpace(AppSizes.spacingM),
          Text(
            message,
            style: ThemeTextStyles.body1(
              context,
            ).copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
