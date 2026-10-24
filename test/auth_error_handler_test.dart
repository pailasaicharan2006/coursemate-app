import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/core/utils/auth_error_handler.dart';

void main() {
  group('AuthErrorHandler tests', () {
    test('returns friendly message for incorrect credentials', () {
      final errors = [
        const AuthException('Invalid login credentials'),
        const AuthException('invalid_credentials', code: 'invalid_credentials'),
        const AuthException('Invalid username or password'),
        const AuthException('Wrong password'),
        const AuthException('User not found', code: 'user_not_found'),
        const AuthException('invalid grant', code: 'invalid_grant'),
      ];

      for (final error in errors) {
        expect(
          AuthErrorHandler.getFriendlyMessage(error),
          'Incorrect email or password. Please check your credentials and try again.',
        );
      }
    });

    test('returns friendly message for invalid email', () {
      final errors = [
        const AuthException('Unable to validate email address'),
        const AuthException('Invalid email address'),
        const AuthException('invalid_email', code: 'invalid_email'),
        const AuthException('Validation failed: email is invalid', code: 'validation_failed'),
      ];

      for (final error in errors) {
        expect(
          AuthErrorHandler.getFriendlyMessage(error),
          'Please enter a valid email address.',
        );
      }
    });

    test('returns friendly message for already registered user', () {
      final errors = [
        const AuthException('User already registered'),
        const AuthException('user_already_exists', code: 'user_already_exists'),
        const AuthException('Email address already in use'),
        const AuthException('User already exists'),
      ];

      for (final error in errors) {
        expect(
          AuthErrorHandler.getFriendlyMessage(error),
          'An account with this email already exists. Please sign in instead.',
        );
      }
    });

    test('returns friendly message for weak password', () {
      final errors = [
        const AuthException('Password should be at least 6 characters'),
        const AuthException('weak_password', code: 'weak_password'),
        const AuthException('Password is too short'),
      ];

      for (final error in errors) {
        expect(
          AuthErrorHandler.getFriendlyMessage(error),
          'Password is too weak. Please use at least 6 characters.',
        );
      }
    });

    test('returns friendly message for unconfirmed email', () {
      final errors = [
        const AuthException('Email not confirmed'),
        const AuthException('email_not_confirmed', code: 'email_not_confirmed'),
        const AuthException('Please confirm your email address'),
        const AuthException('Email is not verified'),
      ];

      for (final error in errors) {
        expect(
          AuthErrorHandler.getFriendlyMessage(error),
          'Please verify your email address before signing in. Check your inbox for the confirmation link.',
        );
      }
    });

    test('returns friendly message for network failures (cross-platform)', () {
      final errors = [
        Exception('ClientException with SocketException: Failed host lookup: frbklensppyhysetzlnn.supabase.co'),
        Exception('XMLHttpRequest error.'),
        Exception('ClientException: Connection refused'),
        Exception('Connection reset by peer'),
        Exception('Network request timed out'),
        const AuthException('Network error', code: 'network_timeout'),
      ];

      for (final error in errors) {
        expect(
          AuthErrorHandler.getFriendlyMessage(error),
          'Unable to connect to the server. Please check your internet connection and try again.',
        );
      }
    });

    test('returns friendly message for rate limit exceeded', () {
      final errors = [
        const AuthException('over_request_rate_limit', code: 'over_request_rate_limit'),
        const AuthException('Too many requests, slow down'),
      ];

      for (final error in errors) {
        expect(
          AuthErrorHandler.getFriendlyMessage(error),
          'Too many attempts. Please wait a few moments and try again.',
        );
      }
    });

    test('returns safe generic fallback without leaking raw database or backend details', () {
      final errors = [
        Exception('PostgrestException: syntax error at or near "FROM"'),
        Exception('Fatal internal error in pgbouncer socket connection 500'),
        const AuthException('Unknown database constraint violated on foreign key auth.users'),
        null,
      ];

      for (final error in errors) {
        final message = AuthErrorHandler.getFriendlyMessage(error);
        expect(
          message,
          'An unexpected error occurred. Please try again later.',
        );
        expect(message.contains('PostgrestException'), isFalse);
        expect(message.contains('syntax error'), isFalse);
        expect(message.contains('pgbouncer'), isFalse);
        expect(message.contains('constraint'), isFalse);
      }
    });
  });
}
