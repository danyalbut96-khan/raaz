import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class RateShareAppScreen extends StatelessWidget {
  const RateShareAppScreen({super.key});

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);

  static const _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.cloudexify.raaz';
  static const _shareText =
      'Check out RAAZ — share secrets anonymously in a safe, supportive community. 🔒';

  Future<void> _rateApp(BuildContext context) async {
    final uri = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Play Store'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: '$_shareText\n$_playStoreUrl'));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Share text copied to clipboard!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primary,
        ),
      );
    }
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _playStoreUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied!'), behavior: SnackBarBehavior.floating, backgroundColor: _primary),
      );
    }
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
        title: const Text('Rate & Share',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, const Color(0xFF2563eb)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(Icons.security, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text('Love RAAZ?',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 8),
                  Text(
                    'Help us grow a safe anonymous community by rating and sharing with friends.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _actionTile(
              context,
              icon: Icons.star_outline,
              title: 'Rate on Play Store',
              subtitle: 'Leave a review — it helps others find us',
              onTap: () => _rateApp(context),
            ),
            const SizedBox(height: 12),
            _actionTile(
              context,
              icon: Icons.share_outlined,
              title: 'Share RAAZ',
              subtitle: 'Invite friends to the anonymous community',
              onTap: () => _shareApp(context),
            ),
            const SizedBox(height: 12),
            _actionTile(
              context,
              icon: Icons.link,
              title: 'Copy App Link',
              subtitle: _playStoreUrl,
              onTap: () => _copyLink(context),
            ),
            const Spacer(),
            Text('Your identity is never shared when you invite others.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: _onSurfaceVariant.withValues(alpha: 0.7))),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
                    Text(subtitle,
                        style: const TextStyle(fontSize: 12, color: _onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFc3c6d7)),
            ],
          ),
        ),
      ),
    );
  }
}
