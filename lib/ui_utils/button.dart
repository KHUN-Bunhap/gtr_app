import 'package:flutter/material.dart';
import 'color_size_style.dart';

/// Common button styles for the GTR app
class AppButtonStyles {
  /// Primary button style (filled with GTR color) - requires context
  static ButtonStyle primary(BuildContext context) => ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Theme.of(context).primaryColor,
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.spacingL,
      vertical: AppSizes.spacingM,
    ),
    minimumSize: const Size(120, 48),
    textStyle: ThemeTextStyles.button(context),
  );

  /// Secondary button style (outlined)
  static ButtonStyle secondary(BuildContext context) =>
      OutlinedButton.styleFrom(
        side: const BorderSide(width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingL,
          vertical: AppSizes.spacingM,
        ),
        minimumSize: const Size(120, 48),
        textStyle: ThemeTextStyles.button(context),
      );

  /// Success button style (green)
  static ButtonStyle success(BuildContext context) => ElevatedButton.styleFrom(
    backgroundColor: AppColors.success,
    foregroundColor: AppColors.white,
    elevation: 2,
    shadowColor: AppColors.success.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.spacingL,
      vertical: AppSizes.spacingM,
    ),
    minimumSize: const Size(120, 48),
    textStyle: ThemeTextStyles.button(context),
  );

  /// Warning button style (orange)
  static ButtonStyle warning(BuildContext context) => ElevatedButton.styleFrom(
    backgroundColor: AppColors.warning,
    foregroundColor: AppColors.white,
    elevation: 2,
    shadowColor: AppColors.warning.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.spacingL,
      vertical: AppSizes.spacingM,
    ),
    minimumSize: const Size(120, 48),
    textStyle: ThemeTextStyles.button(context),
  );

  /// Error/danger button style (red)
  static ButtonStyle error(BuildContext context) => ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: AppColors.white,
    elevation: 2,
    shadowColor: AppColors.error.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.spacingL,
      vertical: AppSizes.spacingM,
    ),
    minimumSize: const Size(120, 48),
    textStyle: ThemeTextStyles.button(context),
  );

  /// Text button style (no background)
  static ButtonStyle get text => TextButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.spacingM,
      vertical: AppSizes.spacingS,
    ),
  );

  /// Small button style
  static ButtonStyle small(BuildContext context) => primary(context).copyWith(
    minimumSize: WidgetStateProperty.all(const Size(80, 36)),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingS,
      ),
    ),
    textStyle: WidgetStateProperty.all(
      ThemeTextStyles.button(context).copyWith(fontSize: 14),
    ),
  );

  /// Large button style
  static ButtonStyle large(BuildContext context) => primary(context).copyWith(
    minimumSize: WidgetStateProperty.all(const Size(200, 56)),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingXl,
        vertical: AppSizes.spacingL,
      ),
    ),
    textStyle: WidgetStateProperty.all(
      ThemeTextStyles.button(context).copyWith(fontSize: 18),
    ),
  );

  /// Responsive button style that adapts to screen size
  static ButtonStyle responsiveStyle({
    required BuildContext context,
    required bool isTablet,
    bool isComputer = false,
    Color? backgroundColor,
    Color? foregroundColor,
    ButtonStyle? baseStyle,
  }) {
    final base = baseStyle ?? primary(context);

    return base.copyWith(
      minimumSize: WidgetStateProperty.all(
        Size(
          isComputer ? 160 : (isTablet ? 140 : 120),
          isComputer ? 56 : (isTablet ? 52 : 48),
        ),
      ),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: isComputer
              ? AppSizes.spacingXl
              : (isTablet ? AppSizes.spacingL : AppSizes.spacingM),
          vertical: isComputer ? AppSizes.spacingL : AppSizes.spacingM,
        ),
      ),
      textStyle: WidgetStateProperty.all(
        ThemeTextStyles.button(
          context,
        ).copyWith(fontSize: isComputer ? 18 : (isTablet ? 16 : 14)),
      ),
      backgroundColor: backgroundColor != null
          ? WidgetStateProperty.all(backgroundColor)
          : null,
      foregroundColor: foregroundColor != null
          ? WidgetStateProperty.all(foregroundColor)
          : null,
    );
  }
}

/// Common button widgets with predefined styles
class GTRButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const GTRButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    // If custom height is set, adjust the button style to remove vertical padding and minimumSize
    final adjustedStyle = (height != null && style == null)
        ? AppButtonStyles.primary(context).copyWith(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingL,
                vertical: 0,
              ),
            ),
            minimumSize: WidgetStateProperty.all(const Size(0, 0)),
          )
        : (height != null && style != null)
        ? style!.copyWith(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingL,
                vertical: 0,
              ),
            ),
            minimumSize: WidgetStateProperty.all(const Size(0, 0)),
          )
        : style ?? AppButtonStyles.primary(context);

    if (icon != null) {
      button = ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    adjustedStyle.foregroundColor?.resolve({}) ?? Colors.white,
                  ),
                ),
              )
            : Icon(icon),
        label: Text(text),
        style: adjustedStyle,
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: adjustedStyle,
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      adjustedStyle.foregroundColor?.resolve({}) ??
                          Colors.white,
                    ),
                  ),
                )
              : Text(text),
        ),
      );
    }

    // Wrap button with SizedBox for custom dimensions
    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: button);
    }

    return button;
  }

  // Factory constructors for common button types
  factory GTRButton.primary({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return GTRButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }

  // Note: For secondary and success styles, use GTRButton constructor directly
  // with style: AppButtonStyles.secondary(context) or AppButtonStyles.success(context)
  // since factory constructors cannot access BuildContext
}
