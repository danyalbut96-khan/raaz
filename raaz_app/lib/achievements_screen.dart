import 'package:flutter/material.dart';
import 'core/supabase_client.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outline = Color(0xFF737686);
  static const Color _secondary = Color(0xFF0058be);
  static const Color _tertiary = Color(0xFF00569c);

  bool _isLoading = true;
  int _totalXp = 0;
  int _unlockedCount = 0;
  List<Map<String, dynamic>> _unlocked = [];
  List<Map<String, dynamic>> _inProgress = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      final allAchievements = await supabase.from('achievements').select().order('xp_reward');

      if (userId != null) {
        final userRows = await supabase
            .from('user_achievements')
            .select('*, achievements (*)')
            .eq('user_id', userId);

        final userList = List<Map<String, dynamic>>.from(userRows);
        final unlocked = <Map<String, dynamic>>[];
        final inProgress = <Map<String, dynamic>>[];
        var xp = 0;

        for (final row in userList) {
          final achievement = row['achievements'] as Map<String, dynamic>?;
          if (achievement == null) continue;
          final merged = {...achievement, ...row};
          if (row['unlocked_at'] != null) {
            unlocked.add(merged);
            xp += achievement['xp_reward'] as int? ?? 0;
          } else {
            inProgress.add(merged);
          }
        }

        // Achievements with no user row yet
        final trackedIds = userList.map((r) => r['achievement_id']).toSet();
        for (final a in allAchievements) {
          if (!trackedIds.contains(a['id']) && a['is_hidden'] != true) {
            inProgress.add({...a, 'progress': 0});
          }
        }

        if (mounted) {
          setState(() {
            _unlocked = unlocked;
            _inProgress = inProgress;
            _totalXp = xp;
            _unlockedCount = unlocked.length;
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _inProgress = List<Map<String, dynamic>>.from(allAchievements);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _iconFromName(String? name) {
    switch (name) {
      case 'explore':
        return Icons.explore;
      case 'edit_note':
        return Icons.edit_note;
      case 'favorite':
        return Icons.favorite;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'search':
        return Icons.search;
      case 'dark_mode':
        return Icons.dark_mode;
      case 'campaign':
        return Icons.campaign;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = (_totalXp / 200).floor() + 1;
    final xpInLevel = _totalXp % 200;
    final progress = xpInLevel / 200;

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface.withValues(alpha: 0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Achievements',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _onSurfaceVariant),
            onPressed: _loadAchievements,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : RefreshIndicator(
              color: _primary,
              onRefresh: _loadAchievements,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroProgress(level, progress),
                    const SizedBox(height: 32),
                    _buildSectionTitle(Icons.verified, 'Achievements', _primary),
                    const SizedBox(height: 16),
                    _unlocked.isEmpty ? _buildEmptyUnlocked() : _buildUnlockedGrid(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(Icons.lock, 'In Progress', _outline),
                    const SizedBox(height: 16),
                    _inProgress.isEmpty ? _buildEmptyProgress() : _buildInProgressList(),
                    const SizedBox(height: 32),
                    _buildMysteriousRewards(),
                    const SizedBox(height: 32),
                    _buildStatsGrid(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyUnlocked() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text('Complete challenges to unlock your first badge!',
          style: TextStyle(color: _onSurfaceVariant)),
    );
  }

  Widget _buildEmptyProgress() {
    return const Text('All achievements unlocked!', style: TextStyle(color: _onSurfaceVariant));
  }

  Widget _buildSectionTitle(IconData icon, String title, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _onSurface)),
      ],
    );
  }

  Widget _buildHeroProgress(int level, double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Journey',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _onSurface)),
                  const SizedBox(height: 4),
                  Text('Level $level • Guardian of Secrets',
                      style: const TextStyle(fontSize: 14, color: _onSurfaceVariant)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$_totalXp XP',
                    style: const TextStyle(color: _primary, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFdce2f7),
              color: _primary,
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).round()}% to Level ${level + 1}',
              style: const TextStyle(fontSize: 11, color: _outline)),
        ],
      ),
    );
  }

  Widget _buildUnlockedGrid() {
    final colors = [_secondary, _primary, _tertiary, Colors.green.shade600];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: _unlocked.length,
      itemBuilder: (_, i) {
        final a = _unlocked[i];
        final color = colors[i % colors.length];
        return _buildBadgeCard(
          a['title'] as String? ?? 'Badge',
          a['description'] as String? ?? '',
          _iconFromName(a['icon'] as String?),
          color,
          color.withValues(alpha: 0.15),
        );
      },
    );
  }

  Widget _buildBadgeCard(String title, String subtitle, IconData icon, Color iconColor, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: _onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildInProgressList() {
    return Column(
      children: _inProgress.take(5).map((a) {
        final req = a['requirement_count'] as int? ?? 1;
        final prog = a['progress'] as int? ?? 0;
        final pct = req > 0 ? ((prog / req) * 100).clamp(0, 100).round() : 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildProgressRow(
            a['title'] as String? ?? 'Achievement',
            '$prog/$req',
            _iconFromName(a['icon'] as String?),
            pct,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressRow(String title, String progressText, IconData icon, int percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFc3c6d7).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: Color(0xFFe9edff), shape: BoxShape.circle),
            child: Icon(icon, color: _outline, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
                    Text(progressText, style: const TextStyle(fontSize: 12, color: _outline)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFe9edff),
                    color: _outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMysteriousRewards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.help_outline, 'Mysterious Rewards', _primary),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _primary.withValues(alpha: 0.2), width: 2),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_center, color: Color(0xFF2563eb), size: 48),
              SizedBox(height: 12),
              Text('Hidden Achievement',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _primary)),
              SizedBox(height: 8),
              Text('Continue sharing authentically to reveal this.',
                  style: TextStyle(fontSize: 13, color: _onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatColumn('0', 'STREAKS')),
        Container(width: 1, height: 40, color: const Color(0xFFc3c6d7).withValues(alpha: 0.3)),
        Expanded(child: _buildStatColumn('$_totalXp', 'KARMA')),
        Container(width: 1, height: 40, color: const Color(0xFFc3c6d7).withValues(alpha: 0.3)),
        Expanded(child: _buildStatColumn('$_unlockedCount', 'BADGES')),
      ],
    );
  }

  Widget _buildStatColumn(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _primary)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: _outline, letterSpacing: 1.0, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
