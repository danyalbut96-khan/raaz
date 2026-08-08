import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _challengesChannel;
  bool _isLoading = true;
  List<Map<String, dynamic>> _challenges = [];
  List<String> _completedTitles = [];

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);
  static const Color _secondary = Color(0xFF0058be);

  @override
  void initState() {
    super.initState();
    _loadChallenges();
    _setupRealtime();
  }

  void _setupRealtime() {
    _challengesChannel = _supabase.channel('public:daily_challenges').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'daily_challenges',
      callback: (payload) => _loadChallenges(),
    )
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'user_challenges',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: _supabase.auth.currentUser?.id ?? '',
      ),
      callback: (payload) => _loadChallenges(),
    )
    ..subscribe();
  }

  @override
  void dispose() {
    _challengesChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final data = await _supabase
          .from('daily_challenges')
          .select()
          .order('date', ascending: false)
          .limit(10);
      
      final completedData = userId != null ? await _supabase
          .from('user_challenges')
          .select('challenge_title')
          .eq('user_id', userId) : [];

      if (mounted) {
        setState(() {
          _challenges = List<Map<String, dynamic>>.from(data);
          _completedTitles = (completedData as List).map((c) => c['challenge_title'] as String).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = _challenges.length;
    int completed = _challenges.where((c) => _completedTitles.contains(c['title'])).length;
    double progress = total > 0 ? (completed / total) * 100 : 0;

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Daily Challenge',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressSection(completed, total, progress),
                  const SizedBox(height: 24),
                  _buildAchievementsStrip(),
                  const SizedBox(height: 24),
                  const Text('Active Challenges',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurfaceVariant)),
                  const SizedBox(height: 16),
                  
                  if (_challenges.isEmpty)
                    const Center(child: Text('No daily challenges available.'))
                  else
                    ..._challenges.map((c) {
                      final isCompleted = _completedTitles.contains(c['title']);
                      if (isCompleted) {
                        return _buildCompletedCard(c);
                      } else {
                        return _buildActiveCard(c);
                      }
                    }),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressSection(int completed, int total, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Daily Challenge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _onSurface)),
                  SizedBox(height: 4),
                  Text('2 of 3 completed today', style: TextStyle(fontSize: 14, color: _onSurfaceVariant)),
                ],
              ),
              const Text('66%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _primary)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFdce2f7), borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: [
                Expanded(
                  flex: 66,
                  child: Container(
                    decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                Expanded(flex: 34, child: Container()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.stars, color: _secondary, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Keep going! Complete 1 more to earn your Weekly Badge.', style: TextStyle(color: _secondary, fontSize: 13, fontWeight: FontWeight.w500))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAchievementsStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Achievements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurfaceVariant)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildBadge('Day 1', Icons.verified, true),
              const SizedBox(width: 12),
              _buildBadge('Early Bird', Icons.emoji_events, true),
              const SizedBox(width: 12),
              _buildBadge('Honesty', Icons.military_tech, true),
              const SizedBox(width: 12),
              _buildBadge('Locked', Icons.lock, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, IconData icon, bool active) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFe9edff) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active ? _outlineVariant.withOpacity(0.3) : _outlineVariant, style: active ? BorderStyle.solid : BorderStyle.none),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? _primary : _outlineVariant, size: 32),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? _onSurfaceVariant : _outlineVariant)),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(Map<String, dynamic> challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: _primary, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFF2563eb).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.sentiment_satisfied, color: Color(0xFF2563eb)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
                const SizedBox(height: 2),
                Text('Completed • ${challenge['xp_reward'] ?? 50} XP earned', style: const TextStyle(fontSize: 13, color: _onSurfaceVariant)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: _primary, size: 28),
        ],
      ),
    );
  }

  Widget _buildActiveCard(Map<String, dynamic> challenge) {
    final title = challenge['title'] ?? '';
    final desc = challenge['description'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: Color(0xFF2170e4), shape: BoxShape.circle),
                child: const Icon(Icons.psychology, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
                    const SizedBox(height: 2),
                    const Text('Expiring in 4 hours', style: TextStyle(fontSize: 13, color: _onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFd4e3ff), borderRadius: BorderRadius.circular(12)),
                child: const Text('High Value', style: TextStyle(fontSize: 11, color: Color(0xFF004883), fontWeight: FontWeight.w600)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(desc, style: const TextStyle(fontSize: 14, color: _onSurfaceVariant, height: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: const Text('Start Challenge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUpcomingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFf1f3ff),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: Color(0xFFdce2f7), shape: BoxShape.circle),
            child: const Icon(Icons.forum, color: _onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Reply to 3 anonymous posts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF737686))),
                SizedBox(height: 2),
                Text('Unlocks at 8:00 PM', style: TextStyle(fontSize: 13, color: Color(0xFF737686))),
              ],
            ),
          ),
          const Icon(Icons.lock_clock, color: Color(0xFF737686)),
        ],
      ),
    );
  }
}
