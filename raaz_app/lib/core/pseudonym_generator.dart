import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Generates ephemeral anonymous pseudonyms for posts/comments.
/// Now persists the pseudonym locally so the user keeps the same name across sessions.
class PseudonymGenerator {
  static const List<String> _adjectives = [
    'Silent', 'Wandering', 'Brave', 'Quiet', 'Hidden',
    'Midnight', 'Ancient', 'Wild', 'Curious', 'Gentle',
    'Restless', 'Distant', 'Crimson', 'Cosmic', 'Hollow',
    'Mystic', 'Fading', 'Golden', 'Shattered', 'Fleeting',
  ];

  static const List<String> _nouns = [
    'Fox', 'Owl', 'Wolf', 'Leaf', 'Wave',
    'Star', 'River', 'Cloud', 'Cipher', 'Ghost',
    'Flame', 'Thorn', 'Abyss', 'Sentry', 'Pilgrim',
    'Echo', 'Dusk', 'Comet', 'Lantern', 'Raven',
  ];

  static final _rand = Random.secure();
  static const _key = 'user_pseudonym';

  static Future<String> generate() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Return existing pseudonym if we already generated one for this device
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      // Sync to Supabase in background to make sure database has it
      _syncToSupabase(existing);
      return existing;
    }

    // Otherwise generate a new one and save it
    final newName = _generateRandomName();
    
    await prefs.setString(_key, newName);
    await _syncToSupabase(newName);
    return newName;
  }

  static Future<String> regenerate() async {
    final prefs = await SharedPreferences.getInstance();
    final newName = _generateRandomName();
    
    await prefs.setString(_key, newName);
    await _syncToSupabase(newName);
    return newName;
  }

  static String _generateRandomName() {
    final adj = _adjectives[_rand.nextInt(_adjectives.length)];
    final noun = _nouns[_rand.nextInt(_nouns.length)];
    return '$adj $noun';
  }

  static Future<void> _syncToSupabase(String pseudonym) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        final existingMeta = currentUser.userMetadata?['pseudonym'];
        if (existingMeta != pseudonym) {
          await supabase.auth.updateUser(
            UserAttributes(
              data: {'pseudonym': pseudonym},
            ),
          );
        }
      }
    } catch (e) {
      print('Error syncing pseudonym to Supabase: $e');
    }
  }
}
