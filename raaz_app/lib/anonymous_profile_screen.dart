import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/pseudonym_generator.dart';
import 'data/models/post_model.dart';
import 'data/repositories/post_repository.dart';

class AnonymousProfileScreen extends StatefulWidget {
  const AnonymousProfileScreen({super.key});

  @override
  State<AnonymousProfileScreen> createState() => _AnonymousProfileScreenState();
}

class _AnonymousProfileScreenState extends State<AnonymousProfileScreen> {
  final _postRepo = PostRepository();
  String _pseudonym = 'Loading...';
  int _reputationScore = 482; // Placeholder for now
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
    final name = await PseudonymGenerator.generate();
    try {
      final posts = await _postRepo.getMyPosts();
      if (mounted) {
        setState(() {
          _pseudonym = name;
          _totalPosts = posts.length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pseudonym = name;
          _isLoading = false;
        });
      }
    }
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
      body: SingleChildScrollView(
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
                      boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.person_outline, size: 45, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(_pseudonym, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _onSurface)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: _primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.security, size: 14, color: _primary),
                        const SizedBox(width: 6),
                        const Text('Identity Protected', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard('Reputation', '$_reputationScore', Icons.star_border, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Total Shares', '$_totalPosts', Icons.article_outlined, _primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Impact', 'High', Icons.trending_up, Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Badges section
            _buildSectionHeader('Earned Badges'),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildBadge('Early Adopter', Icons.rocket_launch, Colors.purple),
                  const SizedBox(width: 12),
                  _buildBadge('Top Contributor', Icons.emoji_events, Colors.orange),
                  const SizedBox(width: 12),
                  _buildBadge('Good Samaritan', Icons.volunteer_activism, Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _outlineVariant.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: _onSurfaceVariant, size: 20),
                        SizedBox(width: 12),
                        Expanded(child: Text('About your anonymous identity', style: TextStyle(fontWeight: FontWeight.w600, color: _onSurface))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
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
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _onSurface)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: _onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _onSurface)),
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
        border: Border.all(color: _outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _onSurface)),
        ],
      ),
    );
  }
}
