import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';

/// Handles anonymous authentication as per PRD Section 3.
/// No email/phone/social credentials in V1 — pure anonymous auth.
class AuthService {
  /// Signs in anonymously if no active session exists.
  /// Called from SplashScreen on first launch.
  static Future<void> ensureSignedIn() async {
    final existing = supabase.auth.currentSession;
    if (existing != null && !_isExpired(existing)) return;

    await supabase.auth.signInAnonymously();
  }

  static bool _isExpired(Session session) {
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch / 1000 >= expiresAt;
  }

  static String? get currentUserId => supabase.auth.currentUser?.id;
  static bool get isSignedIn => supabase.auth.currentUser != null;

  static Stream<AuthState> get authStateStream =>
      supabase.auth.onAuthStateChange;
}
