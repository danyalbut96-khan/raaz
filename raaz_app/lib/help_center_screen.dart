import 'package:flutter/material.dart';
import 'community_guidelines_screen.dart';
import 'contact_us_screen.dart';
import 'permissions_center_screen.dart';
import 'privacy_center_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);

  static const _faqs = [
    (
      'How does anonymity work?',
      'RAAZ generates a temporary pseudonym for each post. Your real identity is never linked to your content.',
    ),
    (
      'Can I delete my posts?',
      'Yes. Go to My Posts, tap a post, and choose Delete. Deleted posts are removed from the public feed.',
    ),
    (
      'What happens when I report content?',
      'Reports are reviewed by moderators. You can track status under Reported Posts in Settings.',
    ),
    (
      'Is my data sold to advertisers?',
      'No. RAAZ does not sell personal data. Optional ads are served without behavioral profiling.',
    ),
    (
      'How do I recover my account?',
      'Export your recovery key from Privacy Center. Use Import Key on onboarding to restore your session.',
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
        title: const Text('Help Center',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, const Color(0xFF2563eb)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent, color: Colors.white, size: 36),
                SizedBox(height: 12),
                Text('How can we help?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                SizedBox(height: 4),
                Text('Find answers or reach our support team.',
                    style: TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Quick Links',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurfaceVariant)),
          const SizedBox(height: 12),
          _linkTile(context, Icons.gavel_outlined, 'Community Guidelines', const CommunityGuidelinesScreen()),
          _linkTile(context, Icons.lock_outline, 'Privacy Center', const PrivacyCenterScreen()),
          _linkTile(context, Icons.admin_panel_settings_outlined, 'Permissions', const PermissionsCenterScreen()),
          _linkTile(context, Icons.mail_outline, 'Contact Support', const ContactUsScreen()),
          const SizedBox(height: 24),
          const Text('Frequently Asked Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurfaceVariant)),
          const SizedBox(height: 8),
          ..._faqs.map((faq) => _faqTile(faq.$1, faq.$2)),
        ],
      ),
    );
  }

  Widget _linkTile(BuildContext context, IconData icon, String title, Widget screen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: _primary),
        title: Text(title, style: const TextStyle(fontSize: 15, color: _onSurface)),
        trailing: const Icon(Icons.chevron_right, color: _outlineVariant),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(question,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _onSurface)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(fontSize: 13, color: _onSurfaceVariant, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
