import 'dart:math';

/// Generates ephemeral anonymous pseudonyms for posts/comments.
/// PRD Section 9: "Posts are assigned dynamic pseudonyms."
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

  static String generate() {
    final adj = _adjectives[_rand.nextInt(_adjectives.length)];
    final noun = _nouns[_rand.nextInt(_nouns.length)];
    return '$adj $noun';
  }
}
