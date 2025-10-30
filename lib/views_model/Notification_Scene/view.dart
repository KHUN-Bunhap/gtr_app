// Flutter imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// App utilities

// Services
import '../../services/notification_service.dart';

// Notification Scene - display all notifications
class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<ViewModel>();

          return Scaffold(
            appBar: null, // App bar removed — actions moved to floating buttons
            body: Stack(
              children: [
                // Main notifications list
                StreamBuilder<QuerySnapshot>(
                  stream: vm.notificationsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading notifications'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final notifications = snapshot.data?.docs ?? [];

                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final doc = notifications[index];
                        final data = doc.data() as Map<String, dynamic>;

                        return _NotificationTile(
                          notificationId: doc.id,
                          title: data['title'] ?? 'Notification',
                          body: data['body'] ?? '',
                          type: data['type'] ?? 'general',
                          isRead: data['isRead'] ?? false,
                          createdAt: data['createdAt'] as Timestamp?,
                          onTap: () => vm.markAsRead(doc.id),
                          onDelete: () => vm.deleteNotification(doc.id),
                        );
                      },
                    );
                  },
                ),

                // Floating action buttons at bottom-right
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'markAll',
                        onPressed: vm.markAllAsRead,
                        tooltip: 'Mark all as read',
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.done_all),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        heroTag: 'clearAll',
                        onPressed: () => _showClearAllDialog(context, vm),
                        tooltip: 'Clear all',
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.clear_all),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, ViewModel vm) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text(
            'Are you sure you want to clear all notifications? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                vm.clearAllNotifications();
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String notificationId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final Timestamp? createdAt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo();

    return Dismissible(
      key: Key(notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isRead
              ? null
              : Theme.of(context).primaryColor.withOpacity(0.05),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getIconColor(),
              child: Icon(_getIcon(), color: Colors.white),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: !isRead
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case 'post':
        return Icons.article;
      case 'comment':
        return Icons.comment;
      case 'announcement':
        return Icons.campaign;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case 'post':
        return Colors.blue;
      case 'comment':
        return Colors.green;
      case 'announcement':
        return Colors.orange;
      case 'schedule':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo() {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final dateTime = createdAt!.toDate();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

class ViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  Stream<QuerySnapshot> get notificationsStream =>
      _notificationService.getUserNotifications();

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
  }

  Future<void> clearAllNotifications() async {
    try {
      final notifications = await _notificationService
          .getUserNotifications()
          .first;

      for (var doc in notifications.docs) {
        await _notificationService.deleteNotification(doc.id);
      }
    } catch (e) {
      print('Error clearing all notifications: $e');
    }
  }
}
