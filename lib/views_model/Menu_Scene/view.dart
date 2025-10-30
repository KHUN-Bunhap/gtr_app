import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ui_utils/utils.dart';
import '../Setting_Scene/view.dart' as setting;
import '../Credit_Scene/view.dart' as credit;
import '../About_Scene/view.dart' as about;
import '../QR_Generate/view.dart' as generateqr;
import '../QR_Scan/view.dart' as scanqr;
import '../Schedule_Scene/view.dart' as schedule;

class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Builder(
        builder: (context) {
          // ignore: unused_local_variable
          final vm = context.watch<ViewModel>();

          return LayoutBuilder(
            builder: (context, constraints) {
              // Simplified responsive design detection
              final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                constraints,
              );

              return Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.responsiveScale(
                        mobile: AppSizes.spacingM,
                        deviceType: deviceType,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menu',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.responsiveScale(
                                  mobile: 20,
                                  deviceType: deviceType,
                                ),
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.settings,
                                size: ResponsiveUtils.scaledIconSize(
                                  mobile: 24,
                                  deviceType: deviceType,
                                ),
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () => vm.navigateToSettings(context),
                            ),
                          ],
                        ),
                        Divider(),
                        // Add responsive vertical spacing
                        UIHelpers.responsiveVerticalSpace(
                          deviceType: deviceType,
                        ),

                        // Using List.generate for menu items - MVVM pattern
                        ...List.generate(vm.menuItems.length, (index) {
                          final menuItem = vm.menuItems[index];
                          return Column(
                            children: [
                              _buildCard(
                                context,
                                menuItem.title,
                                menuItem.icon,
                                deviceType,
                                onTap: () =>
                                    vm.navigateToScene(context, menuItem),
                              ),
                              if (index < vm.menuItems.length - 1)
                                UIHelpers.responsiveVerticalSpace(
                                  deviceType: deviceType,
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    DeviceType deviceType, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: AppSizes.spacingXs),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveScale(
              mobile: 16,
              deviceType: deviceType,
            ),
            height: 2.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.outline,
        ),
        onTap:
            onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title selected'),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            },
      ),
    );
  }
}

// Menu item
class MenuItem {
  final String title;
  final IconData icon;
  final Widget Function() navigateTo;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.navigateTo,
  });
}

class ViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  // Menu items data - following MVVM pattern
  List<MenuItem> get menuItems => [
    MenuItem(
      title: 'Schedule',
      icon: Icons.schedule,
      navigateTo: () => const schedule.View(),
    ),
    MenuItem(
      title: 'Generate QR Scene',
      icon: Icons.qr_code,
      navigateTo: () => const generateqr.View(),
    ),
    MenuItem(
      title: 'Scan QR Scene',
      icon: Icons.qr_code_scanner,
      navigateTo: () => const scanqr.View(),
    ),
    MenuItem(
      title: 'Credits',
      icon: Icons.person,
      navigateTo: () => const credit.View(),
    ),
    MenuItem(
      title: 'About',
      icon: Icons.info,
      navigateTo: () => const about.View(),
    ),
  ];

  // Navigation method following MVVM pattern
  void navigateToScene(BuildContext context, MenuItem menuItem) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => menuItem.navigateTo()),
    );
  }

  // Settings navigation
  void navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const setting.View()),
    );
  }
}
