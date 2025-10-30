// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'ui_utils/theme_manager.dart';
import 'views_model/Loading_Scene/view.dart' as loading_scene;
// import 'services/notification_service.dart';
// import 'views_model/Main_Scene/main.dart' as main_scene;

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

// App entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (fail gracefully)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    // Log initialization error but continue so app can still run for debugging
    debugPrint('Firebase init error: $e');
    debugPrint(st.toString());
  }

  // Initialize Firebase Cloud Messaging background handler
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('FCM background handler registration failed: $e');
  }

  // Initialize notification service (fail gracefully)
  // try {
  //   await NotificationService().initialize();
  // } catch (e, st) {
  //   debugPrint('NotificationService init error: $e');
  //   debugPrint(st.toString());
  // }

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top],
  );

  // Run app with theme management
  runApp(
    ChangeNotifierProvider<ThemeManager>(
      create: (_) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'GTR App',
            debugShowCheckedModeBanner: false,
            theme: themeManager.lightTheme,
            darkTheme: themeManager.darkTheme,
            themeMode: themeManager.isDarkTheme
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const loading_scene.View(),
            // home: const main_scene.View(),
          );
        },
      ),
    ),
  );
}
