import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password, String name) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  bool get isLoggedIn {
    return _supabase.auth.currentUser != null;
  }
}
