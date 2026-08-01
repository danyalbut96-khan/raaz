import 'package:flutter/material.dart';

class VoiceConfessionScreen extends StatefulWidget {
  const VoiceConfessionScreen({super.key});

  @override
  State<VoiceConfessionScreen> createState() => _VoiceConfessionScreenState();
}

class _VoiceConfessionScreenState extends State<VoiceConfessionScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _waveControllers;
  late List<Animation<double>> _waveAnimations;
  bool _deepAnonymitySelected = true;
  final int _barCount = 12;

  @override
  void initState() {
    super.initState();
    _waveControllers = List.generate(_barCount, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800 + (i * 100)),
      )..repeat(reverse: true);
    });
    _waveAnimations = _waveControllers.map((c) {
      return Tween<double>(begin: 10.0, end: 40.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var c in _waveControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFf9f9ff);
    final Color onSurfaceVariant = const Color(0xFF434655);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Voice Confessions', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 20)),
        actions: [
          Icon(Icons.workspace_premium, color: primaryColor),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dark glass hero card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xE6141B2B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Coming Soon badge
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFd8e2ff),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('COMING SOON', style: TextStyle(fontSize: 10, color: Color(0xFF004ac6), fontWeight: FontWeight.w700, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Mic icon + title
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563eb),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.mic, color: Colors.white, size: 32),
                            ),
                            const SizedBox(height: 16),
                            const Text('Secure Audio Shadows', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 8),
                            const Text('Share your voice while preserving your identity with real-time voice morphing.',
                                textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF8B9AB8), height: 1.5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Wave visualizer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('ENCRYPTED STREAM', style: TextStyle(fontSize: 11, color: Color(0xFF8B9AB8), letterSpacing: 1)),
                                Text('00:12:45', style: TextStyle(fontSize: 12, color: primaryColor, fontFamily: 'monospace')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 60,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(_barCount, (i) {
                                  return AnimatedBuilder(
                                    animation: _waveAnimations[i],
                                    builder: (ctx, _) => Container(
                                      width: 4,
                                      height: _waveAnimations[i].value,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(99),
                                        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 6)],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Morphing Options
                      _buildMorphOption(
                        icon: Icons.masks,
                        label: 'Deep Anonymity',
                        selected: _deepAnonymitySelected,
                        locked: false,
                        onTap: () => setState(() => _deepAnonymitySelected = true),
                      ),
                      const SizedBox(height: 8),
                      _buildMorphOption(
                        icon: Icons.waves,
                        label: 'Echo Chamber',
                        selected: !_deepAnonymitySelected,
                        locked: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Description Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf1f3ff),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFe9edff)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Production Ready', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                        'Our end-to-end encrypted audio engine is designed for zero-knowledge storage. Your original voice never touches our servers—only the morphed, anonymous output is shared.',
                        style: TextStyle(fontSize: 14, color: onSurfaceVariant, height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Features Bento
                Row(
                  children: [
                    Expanded(child: _buildFeatureCard(Icons.shield_outlined, 'Identity Guard')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFeatureCard(Icons.bolt, 'Instant Morph')),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMorphOption({required IconData icon, required String label, required bool selected, required bool locked, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: locked ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              const Spacer(),
              Icon(locked ? Icons.lock : Icons.check_circle, color: locked ? Colors.white38 : const Color(0xFF004ac6), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFf1f3ff),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe9edff)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF004ac6), size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
