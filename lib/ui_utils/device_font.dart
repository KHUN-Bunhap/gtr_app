import 'package:flutter/material.dart';

/// Device types for responsive design
enum DeviceType { mobile, tablet, computer }

class ResponsiveUtils {
  /// Breakpoints: Mobile < 600px < Tablet < 1200px < Computer
  static const double tabletBreakpoint = 600;
  static const double computerBreakpoint = 1200;

  /// Get device type from width (width can be from MediaQuery or BoxConstraints)
  static DeviceType getDeviceType(double width) {
    if (width >= computerBreakpoint) return DeviceType.computer;
    if (width >= tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// Convenient methods for BuildContext
  static DeviceType getDeviceTypeFromContext(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size.width);
  }

  /// Convenient methods for BoxConstraints (LayoutBuilder)
  static DeviceType getDeviceTypeFromConstraints(BoxConstraints constraints) {
    return getDeviceType(constraints.maxWidth);
  }

  /// Default scaling factors
  static const double defaultTabletScale = 1.25; // 25% larger than mobile
  static const double defaultComputerScale = 1.5; // 50% larger than mobile

  /// Scaled responsive value - only define mobile, others scale automatically
  static double responsiveScale({
    required double mobile,
    required DeviceType deviceType,
    double tabletScale = defaultTabletScale,
    double computerScale = defaultComputerScale,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return mobile * tabletScale;
      case DeviceType.computer:
        return mobile * computerScale;
    }
  }

  /// Scaled icon size (alias for responsiveScale, kept for semantic clarity)
  static double scaledIconSize({
    required double mobile,
    required DeviceType deviceType,
    double tabletScale = defaultTabletScale,
    double computerScale = defaultComputerScale,
  }) {
    return responsiveScale(
      mobile: mobile,
      deviceType: deviceType,
      tabletScale: tabletScale,
      computerScale: computerScale,
    );
  }
}
