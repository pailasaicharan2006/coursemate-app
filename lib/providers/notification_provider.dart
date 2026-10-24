import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coursemate_app/models/notification_model.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(notificationServiceProvider).getNotifications(user.id);
});

final unreadCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
