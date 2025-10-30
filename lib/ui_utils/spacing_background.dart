import 'package:flutter/material.dart';
import 'color_size_style.dart';
import 'device_font.dart';

/// Responsive layout wrapper that provides consistent spacing and background
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool hasBackground;
  final bool enableScrolling;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final Color? backgroundColor;
  final String? backgroundImage;
  final double backgroundOpacity;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.padding,
    this.hasBackground = true,
    this.enableScrolling = true,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.backgroundColor,
    this.backgroundImage,
    this.backgroundOpacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        image: hasBackground && backgroundImage != null
            ? DecorationImage(
                image: AssetImage(backgroundImage!),
                fit: BoxFit.contain,
                alignment: Alignment.center,
                opacity: backgroundOpacity,
              )
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
            constraints,
          );

          final responsivePadding = padding ?? _getDefaultPadding(deviceType);

          final content = Padding(
            padding: responsivePadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: deviceType == DeviceType.computer
                    ? 1200
                    : double.infinity,
                minHeight: enableScrolling
                    ? (MediaQuery.of(context).size.height > 200
                          ? MediaQuery.of(context).size.height - 200
                          : 400)
                    : 0,
              ),
              child: Column(
                crossAxisAlignment: crossAxisAlignment,
                mainAxisAlignment: mainAxisAlignment,
                children: enableScrolling ? [Expanded(child: child)] : [child],
              ),
            ),
          );

          return enableScrolling
              ? SingleChildScrollView(child: content)
              : Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: deviceType == DeviceType.computer
                          ? 1200
                          : double.infinity,
                    ),
                    child: content,
                  ),
                );
        },
      ),
    );
  }

  EdgeInsets _getDefaultPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.computer:
        return const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingXl * 2,
          vertical: AppSizes.spacingXl,
        );
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingXl,
          vertical: AppSizes.spacingL,
        );
      case DeviceType.mobile:
        return const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingM,
        );
    }
  }
}

/// Centered responsive layout for forms and content
class ResponsiveCenterLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final bool hasBackground;
  final Color? backgroundColor;

  const ResponsiveCenterLayout({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.hasBackground = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      padding: padding,
      hasBackground: hasBackground,
      backgroundColor: backgroundColor,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 500),
        child: child,
      ),
    );
  }
}

/// Grid layout that adapts based on screen size
class ResponsiveGridLayout extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? spacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? computerColumns;

  const ResponsiveGridLayout({
    super.key,
    required this.children,
    this.padding,
    this.spacing,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.computerColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      padding: padding,
      enableScrolling: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
            constraints,
          );

          int columns = mobileColumns!;
          switch (deviceType) {
            case DeviceType.computer:
              columns = computerColumns!;
              break;
            case DeviceType.tablet:
              columns = tabletColumns!;
              break;
            case DeviceType.mobile:
              columns = mobileColumns!;
              break;
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing ?? AppSizes.spacingM,
              mainAxisSpacing: spacing ?? AppSizes.spacingM,
              childAspectRatio: 1.0,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          );
        },
      ),
    );
  }
}
