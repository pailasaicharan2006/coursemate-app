import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/models/chat_conversation.dart';
import 'package:coursemate_app/models/chat_message.dart';

class AiChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ChatConversation>> getConversations(String userId) async {
    try {
      final response = await _supabase
          .from('chat_conversations')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);
      return (response as List)
          .map((e) => ChatConversation.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  Future<ChatConversation> createConversation(
    String userId,
    String title, {
    String? courseId,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'title': title,
        if (courseId != null) 'course_id': courseId,
      };
      final response = await _supabase
          .from('chat_conversations')
          .insert(data)
          .select()
          .single();
      return ChatConversation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);
      return (response as List)
          .map((e) => ChatMessage.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  Future<ChatMessage> sendMessage(
    String conversationId,
    String userId,
    String userMessage, {
    Map<String, dynamic>? userContext,
  }) async {
    try {
      // Save user message to DB
      await _supabase.from('chat_messages').insert({
        'conversation_id': conversationId,
        'role': 'user',
        'content': userMessage,
      });

      // Call Edge Function with explicit FunctionException handling
      String aiText;
      try {
        final response = await _supabase.functions.invoke(
          'chat-with-ai',
          body: {
            'message': userMessage,
            'conversation_id': conversationId,
            'user_context': userContext ?? {},
          },
        );

        if (response.status == 200 && response.data != null) {
          aiText = response.data['response'] as String? ??
              "I'm sorry, I couldn't generate a response right now. Please try again.";
        } else {
          final data = response.data;
          if (data is Map && data['error'] != null) {
            aiText = data['error'].toString();
          } else {
            aiText =
                "I'm experiencing high demand right now. Please try your question again in a moment.";
          }
        }
      } on FunctionException catch (fe) {
        final details = fe.details;
        if (details is Map && details['error'] != null) {
          aiText = details['error'].toString();
        } else if (fe.status == 503) {
          aiText =
              "The AI service is experiencing high demand right now. Please try your question again in a few moments.";
        } else if (fe.status == 504) {
          aiText =
              "Request timed out. The AI assistant took too long to respond. Please try again.";
        } else if (fe.status == 429) {
          aiText =
              "Rate limit reached. Please wait a moment before sending another message.";
        } else if (fe.status == 401) {
          aiText =
              "Your session has expired. Please sign in again to continue chatting.";
        } else if (fe.status == 500) {
          aiText =
              "The AI service is experiencing a configuration issue. Please contact support.";
        } else {
          aiText =
              "The AI assistant is temporarily unavailable. Please try again in a moment.";
        }
      } catch (err) {
        // Distinguish genuine local socket/network failure from generic errors
        final errString = err.toString().toLowerCase();
        if (errString.contains('socketexception') ||
            errString.contains('failed host lookup') ||
            errString.contains('xmlhttprequest') ||
            errString.contains('clientexception')) {
          aiText =
              "Unable to connect to the server. Please check your internet connection and try again.";
        } else {
          aiText =
              "The AI assistant is temporarily unavailable. Please try again in a moment.";
        }
      }

      // Save AI response to DB
      final savedResponse = await _supabase
          .from('chat_messages')
          .insert({
            'conversation_id': conversationId,
            'role': 'assistant',
            'content': aiText,
          })
          .select()
          .single();

      // Update conversation last_message and updated_at
      await _supabase.from('chat_conversations').update({
        'last_message': aiText.length > 100
            ? '${aiText.substring(0, 100)}...'
            : aiText,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);

      return ChatMessage.fromJson(savedResponse);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> updateConversationTitle(
    String conversationId,
    String title,
  ) async {
    try {
      await _supabase
          .from('chat_conversations')
          .update({'title': title})
          .eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to update conversation title: $e');
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _supabase
          .from('chat_conversations')
          .delete()
          .eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  Future<void> clearAllConversations(String userId) async {
    try {
      await _supabase
          .from('chat_conversations')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to clear conversations: $e');
    }
  }
}
