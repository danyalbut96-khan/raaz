import 'package:flutter/material.dart';

class AdmobIntegrationScreen extends StatelessWidget {
  const AdmobIntegrationScreen({super.key});

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outline = Color(0xFF737686);

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
        title: const Text('Ad Preview',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFe1e8fd),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: _primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AdMob integration preview. Test ads will appear in Open Beta. '
                    'Ads are non-intrusive and never use behavioral tracking.',
                    style: TextStyle(fontSize: 13, color: _onSurfaceVariant, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Ad Placements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurfaceVariant)),
          const SizedBox(height: 12),
          _adPreview('Banner Ad', 'ADMOB_BANNER_UNIT', 60, Icons.view_day_outlined),
          const SizedBox(height: 12),
          _adPreview('Native Feed Ad', 'ADMOB_NATIVE_UNIT', 120, Icons.article_outlined),
          const SizedBox(height: 12),
          _adPreview('Interstitial', 'ADMOB_INTERSTITIAL_UNIT', 200, Icons.fullscreen),
          const SizedBox(height: 24),
          const Text('Policy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurfaceVariant)),
          const SizedBox(height: 8),
          ...['No dating, gambling, or political ads',
              'Ads never obscure post content or reactions',
              'Premium members can opt out (coming soon)']
              .map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, color: _primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p, style: const TextStyle(fontSize: 13, color: _onSurfaceVariant))),
                      ],
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _adPreview(String label, String unitId, double height, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFc3c6d7).withValues(alpha: 0.5), style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                Icon(icon, size: 16, color: _outline),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _onSurface)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('TEST', style: TextStyle(fontSize: 9, color: _primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Container(
            height: height,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFf1f3ff),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _outline.withValues(alpha: 0.3), style: BorderStyle.solid),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: _outline.withValues(alpha: 0.5), size: 28),
                  const SizedBox(height: 4),
                  Text(unitId, style: TextStyle(fontSize: 10, color: _outline.withValues(alpha: 0.6), fontFamily: 'monospace')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
