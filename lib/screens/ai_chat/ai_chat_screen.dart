import 'package:flutter/material.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coursemate_app/models/chat_conversation.dart';
import 'package:coursemate_app/models/chat_message.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/chat_provider.dart';
import 'package:coursemate_app/providers/profile_provider.dart';
import 'package:coursemate_app/widgets/atom_orbit_avatar.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  final String? courseId;
  final String? conversationId;

  const AiChatScreen({super.key, this.courseId, this.conversationId});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _activeConversationId;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showBanner = true;

  // Active request token to safely drop late responses upon Stop/Cancellation
  int _activeRequestId = 0;
  bool _isDeletingHistory = false;
  String? _copiedMessageId;

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;
    if (_activeConversationId != null) {
      _loadExistingMessages(_activeConversationId!);
    }
  }

  Future<void> _loadExistingMessages(String conversationId) async {
    try {
      final messages =
          await ref.read(aiChatServiceProvider).getMessages(conversationId);
      if (mounted) {
        setState(() {
          _messages = messages;
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _initConversationIfNeeded(String firstMessage) async {
    if (_activeConversationId != null) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final title = firstMessage.length > 30
        ? '${firstMessage.substring(0, 30)}...'
        : firstMessage;

    final conv = await ref.read(aiChatServiceProvider).createConversation(
          user.id,
          title,
          courseId: widget.courseId,
        );
    _activeConversationId = conv.id;
    ref.invalidate(conversationsProvider);
  }

  void _stopGenerating() {
    if (!_isLoading) return;
    setState(() {
      _activeRequestId++; // Invalidate active request token
      _isLoading = false;
    });
  }

  void _sendMessage(String text, {bool isRetry = false}) async {
    if (_isLoading) return;
    if (text.trim().isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final userMessageText = text.trim();
    final currentRequestId = ++_activeRequestId;

    if (!isRetry) {
      _controller.clear();
      final tempUserMsg = ChatMessage(
        id: DateTime.now().toIso8601String(),
        conversationId: _activeConversationId ?? '',
        role: 'user',
        content: userMessageText,
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.add(tempUserMsg);
        _isLoading = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
    _scrollToBottom();

    try {
      await _initConversationIfNeeded(userMessageText);

      // Collect user context (interests, skills, goals) for personalized advice
      final profile = ref.read(userProfileProvider).value;
      final interests = ref.read(userInterestsProvider).value ?? [];
      final skills = ref.read(userSkillsProvider).value ?? [];
      final goals = ref.read(userGoalsProvider).value ?? [];

      final userContext = {
        if (profile != null) 'name': profile.name,
        if (profile != null) 'education_level': profile.educationLevel,
        if (profile != null) 'field_of_study': profile.fieldOfStudy,
        'interests': interests,
        'skills': skills,
        'goals': goals,
        if (widget.courseId != null) 'current_course_id': widget.courseId,
      };

      final aiResponseMsg = await ref.read(aiChatServiceProvider).sendMessage(
            _activeConversationId!,
            user.id,
            userMessageText,
            userContext: userContext,
          );

      // If user stopped or navigated away while request was in-flight, discard late response
      if (mounted && currentRequestId == _activeRequestId) {
        setState(() {
          _messages.add(aiResponseMsg);
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted && currentRequestId == _activeRequestId) {
        final errText = e.toString().toLowerCase();
        final String userFriendlyError;
        if (errText.contains('socketexception') ||
            errText.contains('clientexception') ||
            errText.contains('failed host lookup') ||
            errText.contains('xmlhttprequest') ||
            errText.contains('network')) {
          userFriendlyError =
              "Unable to connect to the server. Please check your internet connection and try again.";
        } else if (errText.contains('timeout') || errText.contains('timed out')) {
          userFriendlyError =
              "Request timed out. The AI assistant took too long to respond. Please try again.";
        } else {
          userFriendlyError =
              "The AI assistant is temporarily unavailable. Please try again in a moment.";
        }

        setState(() {
          _messages.add(ChatMessage(
            id: DateTime.now().toIso8601String(),
            conversationId: _activeConversationId ?? '',
            role: 'assistant',
            content: userFriendlyError,
            createdAt: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    } finally {
      if (mounted && currentRequestId == _activeRequestId) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _confirmDeleteConversation(ChatConversation conv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCardBg : Colors.white,
          title: const Text('Delete conversation?'),
          content: Text(
            'This will permanently delete "${conv.title}" and its messages.',
            style: TextStyle(
              color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF63667E),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(aiChatServiceProvider).deleteConversation(conv.id);
        if (_activeConversationId == conv.id) {
          setState(() {
            _activeConversationId = null;
            _messages.clear();
          });
        }
        ref.invalidate(conversationsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conversation deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete conversation: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmClearAllHistory() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _isDeletingHistory) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCardBg : Colors.white,
          title: const Text('Clear all history?'),
          content: Text(
            'Are you sure you want to permanently delete all your chat conversations? This action cannot be undone.',
            style: TextStyle(
              color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF63667E),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Clear all'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeletingHistory = true);
      try {
        await ref.read(aiChatServiceProvider).clearAllConversations(user.id);
        setState(() {
          _activeConversationId = null;
          _messages.clear();
        });
        ref.invalidate(conversationsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All chat history cleared')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to clear history: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isDeletingHistory = false);
        }
      }
    }
  }

  String _preprocessMarkdown(String text) {
    // Convert literal HTML break tags to standard markdown newlines
    return text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppTheme.darkBgMain : const Color(0xFFF5F6FA);
    final appBarBg = isDark ? AppTheme.darkCardBg : Colors.white;
    final textPrimary = isDark ? Colors.white : AppTheme.darkTextPrimary;
    final textSecondary = isDark ? Colors.grey : const Color(0xFF63667E);
    final hasCourseContext = widget.courseId != null && _showBanner;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const AtomOrbitAvatar(size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atom',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Your learning companion',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: textPrimary),
            tooltip: 'Chat history',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _buildHistoryDrawer(),
      body: Column(
        children: [
          if (hasCourseContext) _buildContextBanner(),
          Expanded(
            child: _messages.isEmpty ? _buildWelcomeState() : _buildChatBody(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildContextBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.darkTextPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.cyanPrimary.withAlpha(isDark ? 51 : 30),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.cyanPrimary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Asking in context of selected course',
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: isDark ? Colors.grey : const Color(0xFF63667E), size: 20),
            onPressed: () => setState(() => _showBanner = false),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppTheme.darkTextPrimary;
    final textSecondary = isDark ? Colors.grey : const Color(0xFF63667E);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AtomOrbitAvatar(size: 72),
            const SizedBox(height: 24),
            Text(
              "Hi! I'm Atom",
              style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "I can help you with:",
              style: TextStyle(color: textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('What should I learn next?'),
                _buildSuggestionChip('Recommend a learning path for ML'),
                _buildSuggestionChip('Help me prepare for tech interviews'),
                _buildSuggestionChip('How do I become a Flutter developer?'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? AppTheme.darkCardBg : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.darkTextPrimary;
    return ActionChip(
      label: Text(text, style: TextStyle(color: textColor, fontSize: 12)),
      backgroundColor: chipBg,
      side: const BorderSide(color: AppTheme.cyanPrimary),
      onPressed: () => _sendMessage(text),
    );
  }

  Widget _buildChatBody() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildTypingIndicator();
        }
        final msg = _messages[index];
        return _buildMessageBubble(msg);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.role == 'user';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aiBubbleBg = isDark ? AppTheme.darkCardBg : Colors.white;
    final aiTextColor = isDark ? Colors.white : AppTheme.darkTextPrimary;
    final aiBorderColor = isDark ? null : const Color(0xFFE2E4ED);
    final accentCyan = isDark ? const Color(0xFF4FC3F7) : const Color(0xFF0288D1);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.cyanPrimary : aiBubbleBg,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
          ),
          border: (!isUser && aiBorderColor != null) ? Border.all(color: aiBorderColor) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AtomOrbitAvatar(size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Atom',
                      style: TextStyle(
                        color: accentCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (isUser)
              Text(
                msg.content,
                style: const TextStyle(color: Colors.white, height: 1.4),
              )
            else
              MarkdownBody(
                data: _preprocessMarkdown(msg.content),
                selectable: true,
                shrinkWrap: true,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: TextStyle(color: aiTextColor, fontSize: 14, height: 1.45),
                  h1: TextStyle(color: aiTextColor, fontSize: 18, fontWeight: FontWeight.bold),
                  h2: TextStyle(color: aiTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                  h3: TextStyle(color: aiTextColor, fontSize: 15, fontWeight: FontWeight.bold),
                  h4: TextStyle(color: aiTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                  strong: TextStyle(color: aiTextColor, fontWeight: FontWeight.bold),
                  em: TextStyle(color: aiTextColor, fontStyle: FontStyle.italic),
                  listBullet: TextStyle(color: accentCyan, fontSize: 14),
                  a: TextStyle(color: accentCyan, decoration: TextDecoration.underline),
                  code: TextStyle(
                    color: isDark ? const Color(0xFF80D8FF) : const Color(0xFF0277BD),
                    backgroundColor: isDark ? const Color(0xFF2A2A4A) : const Color(0xFFE8EAF6),
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                  ),
                  codeblockPadding: const EdgeInsets.all(10),
                  codeblockDecoration: BoxDecoration(
                    color: isDark ? const Color(0xFF14142B) : const Color(0xFFECEFF1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF2E2E50) : const Color(0xFFCFD8DC)),
                  ),
                  tableBorder: TableBorder.all(
                    color: isDark ? const Color(0xFF3E3E66) : const Color(0xFFCFD8DC),
                    width: 1,
                  ),
                  tableHead: TextStyle(color: aiTextColor, fontWeight: FontWeight.bold, fontSize: 13),
                  tableBody: TextStyle(color: aiTextColor, fontSize: 12.5),
                  blockquote: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(left: BorderSide(color: accentCyan, width: 3)),
                  ),
                ),
                onTapLink: (text, href, title) {
                  if (href != null) {
                    final uri = Uri.tryParse(href);
                    if (uri != null) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
              ),
            if (!isUser &&
                (msg.content.contains('temporarily unavailable') ||
                 msg.content.contains('timed out') ||
                 msg.content.contains('high demand') ||
                 msg.content.contains('Rate limit') ||
                 msg.content.contains('Unable to connect')))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                  onTap: _isLoading
                      ? null
                      : () {
                          final lastUserMsg = _messages
                              .reversed
                              .where((m) => m.role == 'user')
                              .firstOrNull;
                          if (lastUserMsg != null) {
                            _sendMessage(lastUserMsg.content, isRetry: true);
                          }
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cyanPrimary.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.cyanPrimary.withAlpha(100)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 14, color: AppTheme.cyanPrimary),
                        SizedBox(width: 4),
                        Text(
                          'Retry',
                          style: TextStyle(
                            color: AppTheme.cyanPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: isUser
                  ? [
                      Text(
                        "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: Colors.white.withAlpha(128),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildCopyButton(msg, isUser: true),
                    ]
                  : [
                      _buildCopyButton(msg, isUser: false),
                      const SizedBox(width: 8),
                      Text(
                        "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: aiTextColor.withAlpha(100),
                          fontSize: 10,
                        ),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyMessage(ChatMessage msg) async {
    try {
      await Clipboard.setData(ClipboardData(text: msg.content));
      if (!mounted) return;
      setState(() {
        _copiedMessageId = msg.id;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _copiedMessageId == msg.id) {
          setState(() {
            _copiedMessageId = null;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildCopyButton(ChatMessage msg, {required bool isUser}) {
    final isCopied = _copiedMessageId == msg.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isCopied
        ? const Color(0xFF4CAF50)
        : (isUser
            ? Colors.white.withAlpha(160)
            : (isDark ? Colors.grey[400] : const Color(0xFF63667E)));

    return Tooltip(
      message: isCopied ? 'Copied!' : 'Copy message',
      child: InkWell(
        onTap: () => _copyMessage(msg),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCopied ? Icons.check_rounded : Icons.content_copy_rounded,
                size: 13,
                color: iconColor,
              ),
              if (isCopied) ...[
                const SizedBox(width: 4),
                Text(
                  'Copied',
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleBg = isDark ? AppTheme.darkCardBg : Colors.white;
    final textColor = isDark ? Colors.grey : const Color(0xFF63667E);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cyanPrimary),
            ),
            const SizedBox(width: 8),
            Text('Atom is thinking...', style: TextStyle(color: textColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barBg = isDark ? AppTheme.darkCardBg : Colors.white;
    final borderColor = isDark ? AppTheme.darkBgMain : const Color(0xFFE2E4ED);
    final inputFillColor = isDark ? AppTheme.darkBgMain : const Color(0xFFECEFF5);
    final inputTextColor = isDark ? Colors.white : AppTheme.darkTextPrimary;
    final hintColor = isDark ? Colors.grey : const Color(0xFF8F92A8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: TextStyle(color: inputTextColor),
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Ask Atom...',
                  hintStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor: inputFillColor,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
                onSubmitted: _isLoading ? null : _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.cyanPrimary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isLoading ? Icons.stop_rounded : Icons.arrow_upward,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: _isLoading ? 'Stop generating' : 'Send message',
                onPressed: _isLoading ? _stopGenerating : () => _sendMessage(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerBg = isDark ? AppTheme.darkBgMain : const Color(0xFFF5F6FA);
    final textPrimary = isDark ? Colors.white : AppTheme.darkTextPrimary;
    final textSecondary = isDark ? Colors.grey : const Color(0xFF63667E);
    final dividerColor = isDark ? AppTheme.darkCardBg : const Color(0xFFE2E4ED);
    final conversationsAsync = ref.watch(conversationsProvider);

    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chat History',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textPrimary),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
            Divider(color: dividerColor),
            ListTile(
              leading: const Icon(Icons.add, color: AppTheme.cyanPrimary),
              title: const Text('New Conversation', style: TextStyle(color: AppTheme.cyanPrimary)),
              onTap: () {
                setState(() {
                  _activeConversationId = null;
                  _messages.clear();
                });
                context.pop();
              },
            ),
            Expanded(
              child: conversationsAsync.when(
                data: (convs) {
                  if (convs.isEmpty) {
                    return Center(
                      child: Text('No previous chats', style: TextStyle(color: textSecondary)),
                    );
                  }
                  return ListView.builder(
                    itemCount: convs.length,
                    itemBuilder: (context, index) {
                      final conv = convs[index];
                      return ListTile(
                        leading: Icon(Icons.chat_bubble_outline, color: textSecondary),
                        title: Text(conv.title, style: TextStyle(color: textPrimary), maxLines: 1),
                        subtitle: conv.lastMessage != null
                            ? Text(
                                conv.lastMessage!,
                                style: TextStyle(color: textSecondary, fontSize: 11),
                                maxLines: 1,
                              )
                            : null,
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, size: 20, color: textSecondary),
                          tooltip: 'Delete conversation',
                          onPressed: () => _confirmDeleteConversation(conv),
                        ),
                        onTap: () {
                          setState(() {
                            _activeConversationId = conv.id;
                            _messages.clear();
                          });
                          _loadExistingMessages(conv.id);
                          context.pop();
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.cyanPrimary)),
                error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: textSecondary))),
              ),
            ),
            Divider(color: dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: _isDeletingHistory
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                        )
                      : const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 18),
                  label: Text(
                    _isDeletingHistory ? 'Clearing...' : 'Clear all history',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  onPressed: _isDeletingHistory ? null : _confirmClearAllHistory,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
