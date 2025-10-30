import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../ui_utils/utils.dart';

/// UI helper methods specific to Post Scene
class PostSceneUI {
  // Private constructor to prevent instantiation
  PostSceneUI._();

  /// Base method for responsive font sizes
  static double getResponsiveFontSize({
    required double mobile,
    required double tablet,
    required double computer,
    required DeviceType deviceType,
  }) {
    return ResponsiveUtils.responsiveScale(
      mobile: mobile,
      deviceType: deviceType,
    );
  }

  /// Body font size (14/16/18) - Most common text
  static double getBodyFontSize(DeviceType deviceType) {
    return getResponsiveFontSize(
      mobile: 14,
      tablet: 16,
      computer: 18,
      deviceType: deviceType,
    );
  }

  /// Small font size (12/14/16) - Button labels, small text
  static double getSmallFontSize(DeviceType deviceType) {
    return getResponsiveFontSize(
      mobile: 12,
      tablet: 14,
      computer: 16,
      deviceType: deviceType,
    );
  }

  /// Large font size (16/18/20) - Headers, large text
  static double getLargeFontSize(DeviceType deviceType) {
    return getResponsiveFontSize(
      mobile: 16,
      tablet: 18,
      computer: 20,
      deviceType: deviceType,
    );
  }

  /// Helper text font size (10/12/14) - Small helper text
  static double getHelperFontSize(DeviceType deviceType) {
    return getResponsiveFontSize(
      mobile: 10,
      tablet: 12,
      computer: 14,
      deviceType: deviceType,
    );
  }

  // ==================== RESPONSIVE SIZING ====================

  /// Standard padding (12/16/16)
  static double getResponsivePadding(DeviceType deviceType) {
    return ResponsiveUtils.responsiveScale(mobile: 12, deviceType: deviceType);
  }

  /// Icon sizing (18/20/20)
  static double getResponsiveIconSize(DeviceType deviceType) {
    return ResponsiveUtils.responsiveScale(mobile: 18, deviceType: deviceType);
  }

  /// Small spacing (8/12/12)
  static double getResponsiveSpacing(DeviceType deviceType) {
    return ResponsiveUtils.responsiveScale(mobile: 8, deviceType: deviceType);
  }

  // ==================== PREVIEW WIDGETS ====================

  /// Builds Math (LaTeX) preview widget
  static Widget buildMathPreview(String content, DeviceType deviceType) {
    try {
      return Math.tex(
        content,
        mathStyle: MathStyle.display,
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(
            mobile: 14,
            tablet: 16,
            computer: 16,
            deviceType: deviceType,
          ),
        ),
      );
    } catch (e) {
      return Container(
        padding: EdgeInsets.all(getResponsiveSpacing(deviceType)),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: ResponsiveUtils.responsiveScale(
                mobile: 16,
                deviceType: deviceType,
              ),
            ),
            SizedBox(
              width: ResponsiveUtils.responsiveScale(
                mobile: 6,
                deviceType: deviceType,
              ),
            ),
            Text(
              'Invalid LaTeX syntax',
              style: TextStyle(
                color: AppColors.error,
                fontSize: getResponsiveFontSize(
                  mobile: 12,
                  tablet: 14,
                  computer: 14,
                  deviceType: deviceType,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
