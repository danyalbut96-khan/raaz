import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

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
      return existing;
    }

    // Otherwise generate a new one and save it
    final adj = _adjectives[_rand.nextInt(_adjectives.length)];
    final noun = _nouns[_rand.nextInt(_nouns.length)];
    final newName = '$adj $noun';
    
    await prefs.setString(_key, newName);
    return newName;
  }
}
