import 'package:flutter/material.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);

  static const _rules = [
    (
      Icons.favorite_outline,
      'Be Empathetic',
      'Respond with kindness. Remember there is a real person behind every anonymous post.',
    ),
    (
      Icons.block,
      'No Hate Speech',
      'Harassment, discrimination, and threats are strictly prohibited and will result in removal.',
    ),
    (
      Icons.person_off_outlined,
      'Protect Anonymity',
      'Never attempt to identify, dox, or expose other users. Do not share personal information.',
    ),
    (
      Icons.health_and_safety_outlined,
      'Safety First',
      'Do not post detailed self-harm instructions. Crisis resources are available in Help Center.',
    ),
    (
      Icons.report_outlined,
      'Report Responsibly',
      'Use the report feature for genuine violations. False reports may affect your reputation.',
    ),
    (
      Icons.no_photography_outlined,
      'Text-First Community',
      'Keep content text-based in v1. Media uploads are not supported to protect privacy.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface.withValues(alpha: 0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Community Guidelines',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFe1e8fd),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rules of RAAZ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _onSurface)),
                SizedBox(height: 8),
                Text(
                  'By using RAAZ, you agree to uphold these community standards. '
                  'Violations may result in content removal or account restrictions.',
                  style: TextStyle(fontSize: 14, color: _onSurfaceVariant, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._rules.map((rule) => _ruleCard(rule.$1, rule.$2, rule.$3)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFc3c6d7).withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user, color: _primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Moderators review reported content within 24 hours. '
                    'Repeat offenders are permanently banned.',
                    style: TextStyle(fontSize: 13, color: _onSurfaceVariant, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleCard(IconData icon, String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 13, color: _onSurfaceVariant, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
