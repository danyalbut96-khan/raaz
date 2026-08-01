import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/supabase_client.dart';
import 'legal_screens.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);

  String _version = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final res = await supabase
          .from('app_config')
          .select('value')
          .eq('key', 'app_version')
          .maybeSingle();
      if (res != null && mounted) {
        setState(() => _version = res['value'] as String? ?? 'v1.0.0');
      }
    } catch (_) {}
  }

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
        title: const Text('About RAAZ',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
              ),
              child: Column(
                children: [
                  Icon(Icons.security, size: 64, color: _primary),
                  const SizedBox(height: 12),
                  Text('RAAZ',
                      style: TextStyle(
                          fontSize: 36, fontWeight: FontWeight.w700, color: _primary, letterSpacing: -1)),
                  const SizedBox(height: 4),
                  Text(_version, style: const TextStyle(fontSize: 14, color: _onSurfaceVariant)),
                  const SizedBox(height: 16),
                  const Text(
                    'Share Secrets Secretly & Anonymously.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: _onSurfaceVariant, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              icon: Icons.business_outlined,
              title: 'Built by CloudExify',
              subtitle: 'Ethical, privacy-first application development.',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.favorite_outline,
              title: 'Our Mission',
              subtitle:
                  'Empower individuals to express authentic truths without fear of judgment, fostering a safe global community.',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.code,
              title: 'Technology',
              subtitle: 'Flutter • Supabase • Anonymous Auth • End-to-end privacy by design.',
            ),
            const SizedBox(height: 24),
            _buildLinkRow(context, 'Terms of Service', const TermsOfServiceScreen()),
            const SizedBox(height: 8),
            _buildLinkRow(context, 'Privacy Policy', const PrivacyPolicyScreen()),
            const SizedBox(height: 32),
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: _version));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Version copied'), behavior: SnackBarBehavior.floating),
                );
              },
              child: Text('© 2026 CloudExify. All rights reserved.',
                  style: TextStyle(fontSize: 11, color: _outlineVariant)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(fontSize: 13, color: _onSurfaceVariant, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(BuildContext context, String title, Widget screen) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title, style: const TextStyle(color: _onSurface)),
      trailing: const Icon(Icons.chevron_right, color: _outlineVariant),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
    );
  }
}
