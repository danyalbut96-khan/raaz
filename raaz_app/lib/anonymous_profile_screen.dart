import 'package:flutter/material.dart';
import 'core/pseudonym_generator.dart';
import 'core/supabase_client.dart';
import 'data/repositories/post_repository.dart';
import 'achievements_screen.dart';

class AnonymousProfileScreen extends StatefulWidget {
  const AnonymousProfileScreen({super.key});

  @override
  State<AnonymousProfileScreen> createState() => _AnonymousProfileScreenState();
}

class _AnonymousProfileScreenState extends State<AnonymousProfileScreen> {
  final _postRepo = PostRepository();
  String _pseudonym = 'Loading...';
  int _reputationScore = 0;
  int _totalPosts = 0;
  bool _isLoading = true;

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      // Load pseudonym
      final name = await PseudonymGenerator.generate();
      // Load post count
      final posts = await _postRepo.getMyPosts();
      // Load reputation from profiles table
      int reputation = 0;
      if (userId != null) {
        final profileRes = await supabase
            .from('profiles')
            .select('reputation_score')
            .eq('user_id', userId)
            .maybeSingle();
        reputation = profileRes?['reputation_score'] as int? ?? 0;
        // If 0, calculate from post reactions
        if (reputation == 0 && posts.isNotEmpty) {
          reputation = posts.fold(0, (sum, p) => sum + p.reactionCount + p.commentCount * 2);
          // Update the profile with calculated score
          await supabase.from('profiles').upsert({
            'user_id': userId,
            'reputation_score': reputation,
          });
        }
      }
      if (mounted) {
        setState(() {
          _pseudonym = name;
          _totalPosts = posts.length;
          _reputationScore = reputation;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getImpactLabel() {
    if (_reputationScore >= 500) return 'High';
    if (_reputationScore >= 100) return 'Medium';
    return 'Growing';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Anonymous Identity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: _primary,
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                      child: Column(
                        children: [
                          Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2170e4),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: const Icon(Icons.person_outline, size: 45, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(_pseudonym, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _onSurface)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: _primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.security, size: 14, color: _primary),
                                SizedBox(width: 6),
                                Text('Identity Protected', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _primary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats — REAL DATA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(child: _buildStatCard('Reputation', '$_reputationScore', Icons.star_border, Colors.orange)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Total Shares', '$_totalPosts', Icons.article_outlined, _primary)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Impact', _getImpactLabel(), Icons.trending_up, Colors.green)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Badges section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Earned Badges', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _onSurface)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          if (_totalPosts >= 1) _buildBadge('First Share', Icons.rocket_launch, Colors.purple),
                          if (_totalPosts >= 1) const SizedBox(width: 12),
                          if (_reputationScore >= 100) _buildBadge('Top Contributor', Icons.emoji_events, Colors.orange),
                          if (_reputationScore >= 100) const SizedBox(width: 12),
                          _buildBadge('Anonymous', Icons.masks, Colors.blue),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                          ),
                          icon: const Icon(Icons.emoji_events_outlined, color: _primary),
                          label: const Text('View All Achievements', style: TextStyle(color: _primary)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: _primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: const Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: _onSurfaceVariant, size: 20),
                                SizedBox(width: 12),
                                Expanded(child: Text('About your anonymous identity', style: TextStyle(fontWeight: FontWeight.w600, color: _onSurface))),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Your pseudonym changes periodically to ensure complete anonymity. Your reputation score and badges carry over across pseudonyms, but cannot be linked to you personally.',
                              style: TextStyle(fontSize: 13, height: 1.5, color: _onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _onSurface)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: _onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildBadge(String name, IconData icon, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _onSurface)),
        ],
      ),
    );
  }
}
