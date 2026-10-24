import 'package:supabase_flutter/supabase_flutter.dart';

/// Central utility to map raw authentication exceptions (Supabase, network, etc.)
/// into clear, user-friendly, and safe messages without exposing sensitive details.
class AuthErrorHandler {
  /// Converts any auth exception or error object into a user-friendly message.
  static String getFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred. Please try again later.';
    }

    final String rawMessage;
    String? code;

    if (error is AuthException) {
      rawMessage = error.message;
      code = error.code?.toLowerCase();
    } else {
      rawMessage = error.toString();
    }

    final lowerMessage = rawMessage.toLowerCase();
    final lowerCode = code ?? '';

    // 1. Network / Connection failures (Cross-platform Web & Android safe)
    if (lowerMessage.contains('socketexception') ||
        lowerMessage.contains('failed host lookup') ||
        lowerMessage.contains('network') ||
        lowerMessage.contains('clientexception') ||
        lowerMessage.contains('connection refused') ||
        lowerMessage.contains('connection reset') ||
        lowerMessage.contains('xmlhttprequest') ||
        lowerMessage.contains('timed out') ||
        lowerMessage.contains('timeout') ||
        lowerCode.contains('network') ||
        lowerCode.contains('timeout')) {
      return 'Unable to connect to the server. Please check your internet connection and try again.';
    }

    // 2. Incorrect credentials
    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid_credentials') ||
        lowerCode == 'invalid_credentials' ||
        lowerMessage.contains('invalid grant') ||
        lowerCode == 'invalid_grant' ||
        lowerMessage.contains('user not found') ||
        lowerCode == 'user_not_found' ||
        lowerMessage.contains('invalid username or password') ||
        lowerMessage.contains('wrong password')) {
      return 'Incorrect email or password. Please check your credentials and try again.';
    }

    // 3. Email confirmation required
    if (lowerMessage.contains('email not confirmed') ||
        lowerMessage.contains('email_not_confirmed') ||
        lowerCode == 'email_not_confirmed' ||
        lowerMessage.contains('confirm your email') ||
        lowerMessage.contains('not verified')) {
      return 'Please verify your email address before signing in. Check your inbox for the confirmation link.';
    }

    // 4. Existing account / User already registered
    if (lowerMessage.contains('user already registered') ||
        lowerMessage.contains('already registered') ||
        lowerMessage.contains('already in use') ||
        lowerMessage.contains('user already exists') ||
        lowerMessage.contains('user_already_exists') ||
        lowerCode == 'user_already_exists' ||
        lowerCode == 'email_exists') {
      return 'An account with this email already exists. Please sign in instead.';
    }

    // 5. Invalid email address
    if (lowerMessage.contains('invalid email') ||
        lowerMessage.contains('valid email') ||
        lowerMessage.contains('unable to validate email') ||
        lowerCode == 'invalid_email' ||
        lowerCode == 'validation_failed') {
      return 'Please enter a valid email address.';
    }

    // 6. Weak password / Password requirements
    if (lowerMessage.contains('password should be at least') ||
        lowerMessage.contains('weak_password') ||
        lowerMessage.contains('password is too short') ||
        lowerMessage.contains('weak password') ||
        lowerCode == 'weak_password') {
      return 'Password is too weak. Please use at least 6 characters.';
    }

    // 7. Rate limits
    if (lowerMessage.contains('rate limit') ||
        lowerMessage.contains('too many requests') ||
        lowerCode == 'over_request_rate_limit' ||
        lowerCode == 'rate_limit_exceeded') {
      return 'Too many attempts. Please wait a few moments and try again.';
    }

    // 8. Safe generic fallback
    return 'An unexpected error occurred. Please try again later.';
  }
}
