import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);
  static const Color _outline = Color(0xFF737686);
  static const Color _secondary = Color(0xFF0058be);
  static const Color _tertiary = Color(0xFF00569c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Achievements',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroProgress(),
            const SizedBox(height: 32),
            _buildSectionTitle(Icons.verified, 'Achievements', _primary),
            const SizedBox(height: 16),
            _buildUnlockedGrid(),
            const SizedBox(height: 32),
            _buildSectionTitle(Icons.lock, 'In Progress', _outline),
            const SizedBox(height: 16),
            _buildInProgressList(),
            const SizedBox(height: 32),
            _buildMysteriousRewards(),
            const SizedBox(height: 32),
            _buildStatsGrid(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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

  Widget _buildHeroProgress() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Your Journey', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _onSurface)),
                  SizedBox(height: 4),
                  Text('Level 12 • Guardian of Secrets', style: TextStyle(fontSize: 14, color: _onSurfaceVariant)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Text('2,450 XP', style: TextStyle(color: _primary, fontWeight: FontWeight.w600, fontSize: 13)),
              )
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFdce2f7), borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Expanded(
                  flex: 72,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _primary, 
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 10)]
                    ),
                  ),
                ),
                Expanded(flex: 28, child: Container()),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('72% to Level 13', style: TextStyle(fontSize: 11, color: _outline)),
              Text('550 XP remaining', style: TextStyle(fontSize: 11, color: _outline)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUnlockedGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildBadgeCard('Explorer', 'Visited 50 secret circles', Icons.explore, _secondary, const Color(0xFF2170e4).withOpacity(0.2)),
        _buildBadgeCard('Writer', 'Shared 100 deep thoughts', Icons.edit_note, _primary, _primary.withOpacity(0.1)),
        _buildBadgeCard('Supporter', 'Gave 500 digital hugs', Icons.favorite, _tertiary, const Color(0xFFd4e3ff)),
        _buildBadgeCard('Kind Soul', 'Reported 0 violations', Icons.auto_awesome, Colors.green.shade600, Colors.green.shade100),
      ],
    );
  }

  Widget _buildBadgeCard(String title, String subtitle, IconData icon, Color iconColor, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
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
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: _onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildInProgressList() {
    return Column(
      children: [
        _buildProgressRow('Truth Seeker', '8/10', Icons.search, 80),
        const SizedBox(height: 12),
        _buildProgressRow('Night Owl', '15/30', Icons.dark_mode, 50),
      ],
    );
  }

  Widget _buildProgressRow(String title, String progressText, IconData icon, int percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant.withOpacity(0.3)),
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
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
                    Text(progressText, style: const TextStyle(fontSize: 12, color: _outline)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFFe9edff), borderRadius: BorderRadius.circular(3)),
                  child: Row(
                    children: [
                      Expanded(flex: percentage, child: Container(decoration: BoxDecoration(color: _outline, borderRadius: BorderRadius.circular(3)))),
                      Expanded(flex: 100 - percentage, child: Container()),
                    ],
                  ),
                ),
              ],
            ),
          )
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
            color: _primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _primary.withOpacity(0.2), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.help_center, color: Color(0xFF2563eb), size: 48),
              const SizedBox(height: 12),
              const Text('Hidden Achievement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _primary)),
              const SizedBox(height: 8),
              const Text('Continue sharing authentically to reveal this.',
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
        Expanded(child: _buildStatColumn('42', 'STREAKS')),
        Container(width: 1, height: 40, color: _outlineVariant.withOpacity(0.3)),
        Expanded(child: _buildStatColumn('1.2k', 'KARMA')),
        Container(width: 1, height: 40, color: _outlineVariant.withOpacity(0.3)),
        Expanded(child: _buildStatColumn('8', 'BADGES')),
      ],
    );
  }

  Widget _buildStatColumn(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: _outline, letterSpacing: 1.0, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
