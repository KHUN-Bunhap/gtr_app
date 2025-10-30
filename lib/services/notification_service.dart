import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

/// Notification Service
/// Handles both push notifications (FCM) and in-app notifications
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  String? _androidNotificationIcon;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initialize notification service
  Future<void> initialize() async {
    // Request permission for notifications
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Configure FCM
    await _configureFCM();

    // Get and save FCM token
    await _saveFCMToken();
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission: ${settings.authorizationStatus}');
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    // Try several possible Android icon resource names (some projects use
    // different naming). If initialization fails for one, try the next.
    final List<String> iconCandidates = [
      'ic_launcher',
      'launcher_icon',
      '@mipmap/ic_launcher',
    ];

    String? chosenIcon;
    bool initialized = false;

    for (final iconName in iconCandidates) {
      try {
        final AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings(iconName);

        final DarwinInitializationSettings iosSettings =
            const DarwinInitializationSettings(
              requestAlertPermission: true,
              requestBadgePermission: true,
              requestSoundPermission: true,
            );

        final InitializationSettings settings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );

        await _localNotifications.initialize(
          settings,
          onDidReceiveNotificationResponse: _onNotificationTapped,
        );

        chosenIcon = iconName;
        initialized = true;
        debugPrint('Local notifications initialized with icon: $iconName');
        break;
      } catch (e) {
        debugPrint('Local notifications init failed with icon $iconName: $e');
      }
    }

    if (!initialized) {
      debugPrint(
        'Local notifications could not be initialized with any icon candidate. Continuing without local notifications.',
      );
      return;
    }

    // Save chosen icon for use when showing notifications
    _androidNotificationIcon = chosenIcon;

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'gtr_app_channel', // id
      'GTR App Notifications', // name
      description: 'Notifications for GTR App posts and announcements',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
      _saveNotificationToFirestore(message);
    });

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Background message tapped: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // Handle notification tap when app was terminated
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Save FCM token to user document
  Future<void> _saveFCMToken() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      String? token = await _fcm.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('FCM Token saved: $token');
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        _firestore.collection('users').doc(userId).update({
          'fcmToken': newToken,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// Show local notification when app is in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      'gtr_app_channel',
      'GTR App Notifications',
      channelDescription: 'Notifications for GTR App posts and announcements',
      importance: Importance.high,
      priority: Priority.high,
      icon: _androidNotificationIcon ?? '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      details,
      payload: message.data['postId'] ?? message.data['type'],
    );
  }

  /// Save notification to Firestore for in-app display
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': message.notification?.title ?? 'Notification',
        'body': message.notification?.body ?? '',
        'type': message.data['type'] ?? 'general',
        'postId': message.data['postId'],
        'commentId': message.data['commentId'],
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving notification to Firestore: $e');
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // TODO: Navigate to appropriate screen based on notification type
    // You can add navigation logic here later
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen
  }

  /// Get unread notification count
  Stream<int> getUnreadCount() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get all notifications for current user
  Stream<QuerySnapshot> getUserNotifications() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  /// Send notification to specific user (for admin/teacher use)
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
    String? postId,
    String? commentId,
  }) async {
    try {
      // Save to Firestore for in-app notification
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'postId': postId,
        'commentId': commentId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // TODO: Send push notification via Cloud Functions
      // You'll need to set up Cloud Functions to send FCM messages
      print('Notification sent to user: $userId');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Send notification to all users (for announcements)
  Future<void> sendNotificationToAll({
    required String title,
    required String body,
    String type = 'announcement',
    String? postId,
  }) async {
    try {
      // Get all users
      final users = await _firestore.collection('users').get();

      final batch = _firestore.batch();
      for (var user in users.docs) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': user.id,
          'title': title,
          'body': body,
          'type': type,
          'postId': postId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      print('Announcement sent to all users');
    } catch (e) {
      print('Error sending announcement: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.title}');
}
