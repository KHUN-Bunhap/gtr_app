// Flutter core imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App utilities
import '../../ui_utils/utils.dart';

// Services
// import '../../services/notification_service.dart';

// Scene imports
import '../Home_Scene/view.dart' as home;
import '../Menu_Scene/view.dart' as menu;
import '../Profile_Scene/view.dart' as profile;
// import '../Notification_Scene/view.dart' as notification;

// System UI helper class
class SystemUIHelper {
  // Hide all system UI
  static void hideAll() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  // Hide navigation bar only
  static void hideNavigationBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );
  }

  // Show all system UI
  static void showAll() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  // Toggle navigation bar visibility
  static void toggleNavigationBar(bool hide) {
    if (hide) {
      hideNavigationBar();
    } else {
      showAll();
    }
  }
}

// Main Scene with tabs and navigation drawer
class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider setup for state management
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<ViewModel>();
          return LayoutBuilder(
            builder: (context, constraints) {
              // Simplified responsive design detection
              final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                constraints,
              );

              return DefaultTabController(
                length: 3,
                child: Scaffold(
                  // App bar with tabs using UIHelpers
                  appBar: UIHelpers.gtrAppBar(
                    title: 'Génie Télécoms et Réseaux',
                    centerTitle: false,
                    context: context,
                    isBold: true,
                    actions: [
                      // Theme toggle button
                      IconButton(
                        icon: Image.asset(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'lib/assets/gtr_logo.png'
                              : 'lib/assets/itc_logo.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        onPressed: () => vm.isDarkTheme = !vm.isDarkTheme,
                      ),
                    ],
                    tabs: [
                      Tab(
                        icon: Icon(
                          Icons.home,
                          size: ResponsiveUtils.responsiveScale(
                            mobile: 24.0,
                            deviceType: deviceType,
                          ),
                        ),
                      ),
                      Tab(
                        icon: Icon(
                          Icons.person,
                          size: ResponsiveUtils.responsiveScale(
                            mobile: 24.0,
                            deviceType: deviceType,
                          ),
                        ),
                      ),
                      Tab(
                        icon: Icon(
                          Icons.menu,
                          size: ResponsiveUtils.responsiveScale(
                            mobile: 24.0,
                            deviceType: deviceType,
                          ),
                        ),
                      ),

                      // Notifications tab as the last tab with badge
                      // Tab(
                      //   icon: StreamBuilder<int>(
                      //     stream: NotificationService().getUnreadCount(),
                      //     builder: (context, snapshot) {
                      //       final unread = snapshot.data ?? 0;
                      //       return Stack(
                      //         clipBehavior: Clip.none,
                      //         children: [
                      //           Icon(
                      //             Icons.notifications_outlined,
                      //             size: ResponsiveUtils.responsiveScale(
                      //               mobile: 24.0,
                      //               deviceType: deviceType,
                      //             ),
                      //           ),
                      //           if (unread > 0)
                      //             Positioned(
                      //               right: -6,
                      //               top: -6,
                      //               child: Container(
                      //                 padding: const EdgeInsets.all(4),
                      //                 decoration: const BoxDecoration(
                      //                   color: Colors.red,
                      //                   shape: BoxShape.circle,
                      //                 ),
                      //                 constraints: const BoxConstraints(
                      //                   minWidth: 18,
                      //                   minHeight: 18,
                      //                 ),
                      //                 child: Text(
                      //                   unread > 99 ? '99+' : '$unread',
                      //                   style: const TextStyle(
                      //                     color: Colors.white,
                      //                     fontSize: 10,
                      //                     fontWeight: FontWeight.bold,
                      //                   ),
                      //                   textAlign: TextAlign.center,
                      //                 ),
                      //               ),
                      //             ),
                      //         ],
                      //       );
                      //     },
                      //   ),
                      // ),
                    ],
                  ),

                  // Tab content
                  body: TabBarView(
                    children: [
                      home.View(),
                      profile.View(),
                      menu.View(),
                      // notification.View(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ViewModel for main scene state management
class ViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  bool _hideNavigationBar = true;

  // SharedPreferences instance
  SharedPreferences? _prefs;

  // Theme settings
  bool _isDarkTheme = false;
  bool get isDarkTheme => _isDarkTheme;
  set isDarkTheme(bool value) {
    _isDarkTheme = value;
    _saveThemePreference(value); // Save to SharedPreferences
    ThemeManager().setTheme(value);
    notifyListeners();
  }

  ViewModel() {
    _initPrefs();
  }

  // Initialize SharedPreferences and load saved theme setting
  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Load saved theme preference
      _isDarkTheme = _prefs?.getBool('darkTheme') ?? false;

      // Apply loaded theme setting
      ThemeManager().setTheme(_isDarkTheme);

      // Notify listeners after loading preferences
      notifyListeners();
    } catch (e) {
      // Error initializing SharedPreferences
    }
  }

  // Save theme preference
  Future<void> _saveThemePreference(bool isDark) async {
    try {
      await _prefs?.setBool('darkTheme', isDark);
    } catch (e) {
      // Error saving theme preference
    }
  }

  bool get hideNavigationBar => _hideNavigationBar;

  // Toggle navigation bar
  void toggleNavigationBar() {
    _hideNavigationBar = !_hideNavigationBar;
    SystemUIHelper.toggleNavigationBar(_hideNavigationBar);
    notifyListeners();
  }
}
