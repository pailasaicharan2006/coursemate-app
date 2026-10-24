import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:coursemate_app/models/notification_model.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'recommendation': return Icons.auto_awesome;
      case 'reminder':       return Icons.alarm;
      case 'progress':       return Icons.trending_up;
      case 'completion':     return Icons.emoji_events;
      case 'update':         return Icons.info;
      default:               return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'recommendation': return AppTheme.cyanPrimary;
      case 'reminder':       return AppTheme.cyanSecondary;
      case 'progress':       return AppTheme.success;
      case 'completion':     return Colors.amber;
      case 'update':         return AppTheme.darkTextSecondary;
      default:               return AppTheme.cyanPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBgMain,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBgMain,
        elevation: 0,
        title: const Text('Notifications',
            style: TextStyle(
                color: AppTheme.darkTextPrimary,
                fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () async {
              if (user != null) {
                await ref
                    .read(notificationServiceProvider)
                    .markAllAsRead(user.id);
                ref.invalidate(notificationsProvider);
              }
            },
            child: const Text('Mark all read',
                style: TextStyle(color: AppTheme.cyanPrimary)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.cyanPrimary,
          labelColor: AppTheme.cyanPrimary,
          unselectedLabelColor: AppTheme.darkTextSecondary,
          isScrollable: true,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Recommendations'),
            Tab(text: 'Reminders'),
            Tab(text: 'Updates'),
          ],
        ),
      ),
      body: notificationsAsync.when(
        data: (notifications) => TabBarView(
          controller: _tabController,
          children: [
            _buildList(notifications),
            _buildList(notifications
                .where((n) => n.type.toLowerCase() == 'recommendation')
                .toList()),
            _buildList(notifications
                .where((n) => n.type.toLowerCase() == 'reminder')
                .toList()),
            _buildList(notifications
                .where((n) => n.type.toLowerCase() == 'update')
                .toList()),
          ],
        ),
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.cyanPrimary)),
        error: (e, _) => Center(
          child: Text('Error loading notifications: $e',
              style: const TextStyle(color: AppTheme.darkTextSecondary)),
        ),
      ),
    );
  }

  Widget _buildList(List<NotificationModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off,
                size: 64,
                color: AppTheme.darkTextSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('No notifications here',
                style: TextStyle(
                    color: AppTheme.darkTextSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final typeColor = _colorForType(item.type);

        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) async {
            await ref
                .read(notificationServiceProvider)
                .deleteNotification(item.id);
            ref.invalidate(notificationsProvider);
          },
          background: Container(
            color: AppTheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: GestureDetector(
            onTap: () async {
              if (!item.isRead) {
                await ref
                    .read(notificationServiceProvider)
                    .markAsRead(item.id);
                ref.invalidate(notificationsProvider);
              }
            },
            child: Container(
              color: item.isRead
                  ? AppTheme.darkBgMain
                  : AppTheme.darkCardBg,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: typeColor.withValues(alpha: 0.15),
                    child: Icon(_iconForType(item.type),
                        color: typeColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            color: AppTheme.darkTextPrimary,
                            fontWeight: item.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppTheme.darkTextSecondary,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getTimeAgo(item.createdAt),
                          style: const TextStyle(
                              color: AppTheme.darkTextHint, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (!item.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6, left: 6),
                      decoration: const BoxDecoration(
                        color: AppTheme.cyanPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
