import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coursemate_app/models/chat_conversation.dart';
import 'package:coursemate_app/models/chat_message.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/services/ai_chat_service.dart';

final aiChatServiceProvider = Provider<AiChatService>((ref) {
  return AiChatService();
});

final conversationsProvider = FutureProvider<List<ChatConversation>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(aiChatServiceProvider).getConversations(user.id);
});

final messagesProvider = FutureProvider.family<List<ChatMessage>, String>((ref, conversationId) async {
  return ref.read(aiChatServiceProvider).getMessages(conversationId);
});
