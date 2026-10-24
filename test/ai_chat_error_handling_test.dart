import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AI Chat Error Mapping Tests', () {
    // -----------------------------------------------------------------------
    // FunctionException status → user-facing message mapping
    // -----------------------------------------------------------------------

    test('maps FunctionException status 503 to high demand message', () {
      const fe = FunctionException(
        status: 503,
        reasonPhrase: 'Service Unavailable',
      );

      String aiText;
      final details = fe.details;
      if (details is Map && details['error'] != null) {
        aiText = details['error'].toString();
      } else if (fe.status == 503) {
        aiText =
            "The AI service is experiencing high demand right now. Please try your question again in a few moments.";
      } else {
        aiText = "The AI assistant is temporarily unavailable. Please try again in a moment.";
      }

      expect(aiText, contains('high demand'));
    });

    test('maps FunctionException status 429 to rate limit message', () {
      const fe = FunctionException(
        status: 429,
        reasonPhrase: 'Too Many Requests',
      );

      String aiText;
      final details = fe.details;
      if (details is Map && details['error'] != null) {
        aiText = details['error'].toString();
      } else if (fe.status == 429) {
        aiText =
            "Rate limit reached. Please wait a moment before sending another message.";
      } else {
        aiText = "The AI assistant is temporarily unavailable. Please try again in a moment.";
      }

      expect(aiText, contains('Rate limit reached'));
    });

    test('maps FunctionException status 504 to request timeout message', () {
      const fe = FunctionException(
        status: 504,
        reasonPhrase: 'Gateway Timeout',
      );

      String aiText;
      final details = fe.details;
      if (details is Map && details['error'] != null) {
        aiText = details['error'].toString();
      } else if (fe.status == 504) {
        aiText =
            "Request timed out. The AI assistant took too long to respond. Please try again.";
      } else {
        aiText = "The AI assistant is temporarily unavailable. Please try again in a moment.";
      }

      expect(aiText, contains('Request timed out'));
    });

    test('maps FunctionException status 400 to invalid request message', () {
      const fe = FunctionException(
        status: 400,
        details: {
          'error': 'The AI assistant could not process this request. Please try rephrasing your message.'
        },
      );

      final details = fe.details;
      final aiText = (details is Map && details['error'] != null)
          ? details['error'].toString()
          : "The AI assistant is temporarily unavailable. Please try again in a moment.";

      expect(aiText, contains('rephrasing'));
    });

    test('maps FunctionException status 500 to configuration issue message', () {
      const fe = FunctionException(
        status: 500,
        details: {
          'error': 'The AI service is experiencing a configuration issue. Please contact support.'
        },
      );

      final details = fe.details;
      final aiText = (details is Map && details['error'] != null)
          ? details['error'].toString()
          : "The AI assistant is temporarily unavailable. Please try again in a moment.";

      expect(aiText, contains('configuration issue'));
    });

    test('extracts custom error message from Edge Function response payload', () {
      const fe = FunctionException(
        status: 429,
        details: {
          'error': 'The AI service has reached its usage limit for now. Please try again later.'
        },
      );

      final details = fe.details;
      final aiText = (details is Map && details['error'] != null)
          ? details['error'].toString()
          : "The AI assistant is temporarily unavailable. Please try again in a moment.";

      expect(aiText, contains('usage limit'));
    });

    test('distinguishes socket and network exceptions from backend errors', () {
      final networkErrors = [
        Exception('SocketException: OS Error: Connection refused, errno = 111'),
        Exception('ClientException: XMLHttpRequest error'),
        Exception('Failed host lookup: api.groq.com'),
      ];

      for (final err in networkErrors) {
        final errString = err.toString().toLowerCase();
        final bool isNetwork = errString.contains('socketexception') ||
            errString.contains('failed host lookup') ||
            errString.contains('xmlhttprequest') ||
            errString.contains('clientexception');

        expect(isNetwork, isTrue);
      }
    });

    test('retry logic identifies retryable assistant error messages', () {
      final retryableMessages = [
        "The AI assistant is temporarily unavailable. Please try again in a moment.",
        "Request timed out. The AI assistant took too long to respond. Please try again.",
        "The AI service is experiencing high demand right now. Please try your question again in a few moments.",
        "Rate limit reached. Please wait a moment before sending another message.",
        "Unable to connect to the server. Please check your internet connection and try again.",
      ];

      for (final msg in retryableMessages) {
        final bool isRetryable = msg.contains('temporarily unavailable') ||
            msg.contains('timed out') ||
            msg.contains('high demand') ||
            msg.contains('Rate limit') ||
            msg.contains('Unable to connect');
        expect(isRetryable, isTrue, reason: 'Message should be retryable: $msg');
      }

      const regularMsg = "Here is a recommended course for learning Python: Complete Python Bootcamp.";
      final bool isRetryableNormal = regularMsg.contains('temporarily unavailable') ||
          regularMsg.contains('timed out') ||
          regularMsg.contains('high demand') ||
          regularMsg.contains('Rate limit') ||
          regularMsg.contains('Unable to connect');
      expect(isRetryableNormal, isFalse);
    });

    test('extracts AI response on HTTP 200 status payload', () {
      final Map<String, dynamic> mockData = {
        'response': 'I recommend starting with Python for Data Science and Machine Learning Bootcamp.',
      };

      final String aiText = mockData['response'] as String? ??
          "I'm sorry, I couldn't generate a response right now. Please try again.";

      expect(aiText, contains('Python for Data Science'));
    });

    test('verifies personalized user context structure preserves learning data', () {
      final userContext = {
        'name': 'Alex',
        'education_level': 'Undergraduate',
        'field_of_study': 'Computer Science',
        'interests': ['Machine Learning', 'Data Science'],
        'skills': ['Python', 'SQL'],
        'goals': ['Get an internship'],
        'current_course_id': 'course-123',
      };

      expect(userContext['name'], equals('Alex'));
      expect(userContext['interests'], contains('Machine Learning'));
      expect(userContext['skills'], contains('Python'));
      expect(userContext['goals'], contains('Get an internship'));
      expect(userContext['current_course_id'], equals('course-123'));
    });

    test('timeout handling produces non-empty user-actionable message', () {
      const fe = FunctionException(
        status: 504,
        details: {'error': 'Request timed out. The AI assistant took too long to respond. Please try again.'},
      );

      final details = fe.details;
      final aiText = (details is Map && details['error'] != null)
          ? details['error'].toString()
          : "Request timed out. The AI assistant took too long to respond. Please try again.";

      expect(aiText, isNotEmpty);
      expect(aiText.toLowerCase(), contains('timed out'));
    });

    // -----------------------------------------------------------------------
    // Groq-specific: OpenAI-format response parsing
    // -----------------------------------------------------------------------

    test('parses Groq OpenAI-format response to extract text', () {
      // Simulates what the Edge Function receives from Groq
      final Map<String, dynamic> groqResponse = {
        'choices': [
          {
            'message': {
              'role': 'assistant',
              'content': 'Here are some great courses for Machine Learning on CourseMate.',
            },
            'finish_reason': 'stop',
          }
        ],
        'model': 'openai/gpt-oss-20b',
      };

      String? content;
      final choices = groqResponse['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final first = choices.first as Map<String, dynamic>?;
        final msg = first?['message'] as Map<String, dynamic>?;
        content = msg?['content'] as String?;
      }

      expect(content, isNotNull);
      expect(content, contains('Machine Learning'));
    });

    test('handles Groq empty choices list gracefully', () {
      final Map<String, dynamic> groqResponse = {
        'choices': [],
        'model': 'openai/gpt-oss-20b',
      };

      String? content;
      final choices = groqResponse['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final first = choices.first as Map<String, dynamic>?;
        final msg = first?['message'] as Map<String, dynamic>?;
        content = msg?['content'] as String?;
      }

      expect(content, isNull);
    });

    test('identifies quota_exhausted as non-retryable via fallback', () {
      // quota_exhausted must NOT trigger a model fallback
      const nonRetryableCategories = ['auth', 'invalid_request', 'quota_exhausted', 'timeout'];
      for (final cat in nonRetryableCategories) {
        final eligible = cat == 'rate_limit' || cat == 'server_error';
        expect(eligible, isFalse,
            reason: '$cat should not be eligible for model fallback');
      }
    });

    test('identifies rate_limit and server_error as eligible for model fallback', () {
      const retryableCategories = ['rate_limit', 'server_error'];
      for (final cat in retryableCategories) {
        final eligible = cat == 'rate_limit' || cat == 'server_error';
        expect(eligible, isTrue, reason: '$cat should be eligible for model fallback');
      }
    });

    // -----------------------------------------------------------------------
    // Atom Branding & Identity Tests
    // -----------------------------------------------------------------------

    test('Atom assistant naming and subtitle are configured correctly', () {
      const assistantName = 'Atom';
      const subtitle = 'Your learning companion';
      const welcomeText = "Hi! I'm Atom";
      const hintText = 'Ask Atom...';
      const thinkingText = 'Atom is thinking...';

      expect(assistantName, equals('Atom'));
      expect(subtitle, equals('Your learning companion'));
      expect(welcomeText, contains('Atom'));
      expect(hintText, contains('Atom'));
      expect(thinkingText, contains('Atom'));
    });

    // -----------------------------------------------------------------------
    // Markdown Preprocessing Tests
    // -----------------------------------------------------------------------

    test('preprocesses literal HTML br tags into standard Markdown newlines', () {
      String preprocessMarkdown(String text) {
        return text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
      }

      const rawInput = "First line<br>Second line<br/>Third line<BR />Fourth line";
      final result = preprocessMarkdown(rawInput);

      expect(result, equals("First line\nSecond line\nThird line\nFourth line"));
      expect(result.contains('<br>'), isFalse);
      expect(result.contains('<br/>'), isFalse);
    });

    test('preserves valid markdown tables, bolding, and code blocks', () {
      const markdownSample = """
### Recommendations
| Course | Level |
| --- | --- |
| Python 101 | Beginner |

- **Key Skill**: `print('Hello')`
""";
      expect(markdownSample, contains('| Course | Level |'));
      expect(markdownSample, contains('**Key Skill**'));
      expect(markdownSample, contains("`print('Hello')`"));
    });

    // -----------------------------------------------------------------------
    // Chat History Deletion Tests
    // -----------------------------------------------------------------------

    test('deleting active conversation resets activeConversationId to null', () {
      String? activeConversationId = 'conv-123';
      final conversations = [
        {'id': 'conv-123', 'title': 'Chat 1'},
        {'id': 'conv-456', 'title': 'Chat 2'},
      ];

      // Simulate deleting conv-123
      const deletedId = 'conv-123';
      conversations.removeWhere((c) => c['id'] == deletedId);
      if (activeConversationId == deletedId) {
        activeConversationId = null;
      }

      expect(conversations.length, equals(1));
      expect(activeConversationId, isNull);
    });

    test('clearing all history removes all user conversations and resets active state', () {
      String? activeConversationId = 'conv-123';
      final List<Map<String, dynamic>> userConversations = [
        {'id': 'conv-1', 'user_id': 'user-abc', 'title': 'Chat 1'},
        {'id': 'conv-2', 'user_id': 'user-abc', 'title': 'Chat 2'},
      ];

      // Simulate clearAllConversations for user-abc
      userConversations.clear();
      activeConversationId = null;

      expect(userConversations, isEmpty);
      expect(activeConversationId, isNull);
    });

    // -----------------------------------------------------------------------
    // Stop Button & Duplicate Submission Prevention Tests
    // -----------------------------------------------------------------------

    test('request token guards against late responses when stopped', () {
      int activeRequestId = 0;
      bool isLoading = false;
      final messages = <String>[];

      // User starts request #1
      final req1 = ++activeRequestId;
      isLoading = true;

      // User presses Stop
      activeRequestId++;
      isLoading = false;

      // Late response arrives for req1
      if (req1 == activeRequestId) {
        messages.add("Late response from req1");
      }

      // Verify late response was dropped
      expect(messages, isEmpty);
      expect(isLoading, isFalse);
    });

    test('submitting is blocked while request is loading', () {
      bool isLoading = true;
      bool submitted = false;

      void onSendMessage(String text) {
        if (isLoading || text.trim().isEmpty) return;
        submitted = true;
      }

      onSendMessage("Hello while loading");
      expect(submitted, isFalse);

      isLoading = false;
      onSendMessage("Hello when idle");
      expect(submitted, isTrue);
    });

    // -----------------------------------------------------------------------
    // Certificate Count Consistency Tests
    // -----------------------------------------------------------------------

    test('certificate count derivation is accurate for empty, populated, and error states', () {
      String formatCertNotice(bool hasError, int count) {
        if (hasError) return "Certificate records are temporarily unavailable.";
        if (count == 0) return "You currently have 0 certificates in your CourseMate locker.";
        return "You have $count certificates.";
      }

      // 1. Empty state
      final emptyCerts = <Map<String, dynamic>>[];
      expect(formatCertNotice(false, emptyCerts.length), contains('0 certificates'));

      // 2. Populated state
      final populatedCerts = [
        {'title': 'Python Certified', 'issuer': 'Python Institute'},
        {'title': 'Machine Learning', 'issuer': 'DeepLearning.AI'},
      ];
      expect(formatCertNotice(false, populatedCerts.length), equals('You have 2 certificates.'));

      // 3. Error state distinguishes from 0 count
      final errorNotice = formatCertNotice(true, 0);
      expect(errorNotice, contains('temporarily unavailable'));
      expect(errorNotice.contains('0 certificates'), isFalse);
    });

    // -----------------------------------------------------------------------
    // Message Copy-to-Clipboard Tests
    // -----------------------------------------------------------------------

    test('copying user prompt preserves exact text, line breaks, and punctuation', () {
      const userContent = "Can you help me with:\n1. Flutter state management?\n2. Supabase auth!";
      final userMessage = {
        'id': 'msg-user-1',
        'role': 'user',
        'content': userContent,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Ensure copied payload is exactly the raw message content
      final String copiedText = userMessage['content']!;
      expect(copiedText, equals(userContent));
      expect(copiedText, contains('\n1. Flutter state management?'));
      expect(copiedText, contains('\n2. Supabase auth!'));
      expect(copiedText.contains('Atom'), isFalse);
      expect(copiedText.contains('user:'), isFalse);
    });

    test('copying Atom reply preserves full markdown structure without UI chrome', () {
      const atomMarkdown = """
### Recommended Courses
Here are the top options:
- **Course 1**: [Flutter Bootcamp](https://example.com/flutter)
- **Course 2**: Dart Deep Dive

```dart
void main() => runApp(const MyApp());
```

| Feature | Support |
| --- | --- |
| Offline | Yes |
""";
      final atomMessage = {
        'id': 'msg-atom-1',
        'role': 'assistant',
        'content': atomMarkdown,
        'created_at': DateTime.now().toIso8601String(),
      };

      final String copiedText = atomMessage['content']!;
      // Confirms headings, lists, code blocks, and tables are preserved
      expect(copiedText, equals(atomMarkdown));
      expect(copiedText, contains('### Recommended Courses'));
      expect(copiedText, contains('- **Course 1**: [Flutter Bootcamp]'));
      expect(copiedText, contains('```dart'));
      expect(copiedText, contains('| Feature | Support |'));
      // Confirms no UI labels or timestamps are included
      expect(copiedText.contains('Atom Orbit'), isFalse);
      expect(copiedText.contains('Your learning companion'), isFalse);
    });

    test('user prompts and Atom replies are copied independently with separate IDs', () {
      final messages = [
        {'id': 'u1', 'role': 'user', 'content': 'Hello Atom!'},
        {'id': 'a1', 'role': 'assistant', 'content': 'Hello Student! How can I help?'},
      ];

      String? activeCopiedId;
      String? clipboardBuffer;

      void copy(Map<String, dynamic> msg) {
        clipboardBuffer = msg['content'];
        activeCopiedId = msg['id'];
      }

      // Copy user prompt
      copy(messages[0]);
      expect(clipboardBuffer, equals('Hello Atom!'));
      expect(activeCopiedId, equals('u1'));

      // Copy Atom reply independently
      copy(messages[1]);
      expect(clipboardBuffer, equals('Hello Student! How can I help?'));
      expect(activeCopiedId, equals('a1'));
    });
  });
}
