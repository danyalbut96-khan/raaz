import 'package:flutter/material.dart';
import 'dart:math';

class ImageConfessionScreen extends StatefulWidget {
  const ImageConfessionScreen({super.key});

  @override
  State<ImageConfessionScreen> createState() => _ImageConfessionScreenState();
}

class _ImageConfessionScreenState extends State<ImageConfessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Row(
            children: [
              Icon(Icons.shield, color: primaryColor, size: 22),
              const SizedBox(width: 6),
            ],
          ),
        ),
        leadingWidth: 48,
        title: Text('RAAZ', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700, letterSpacing: -0.5, fontSize: 22)),
        actions: [
          Icon(Icons.workspace_premium, color: onSurfaceVariant),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase Badge + Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFd3e4ff),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 14, color: Color(0xFF0058be)),
                  const SizedBox(width: 4),
                  const Text('Phase 6: Image Confessions', style: TextStyle(fontSize: 12, color: Color(0xFF0058be), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Secure Visual Sharing', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF141b2b))),
            const SizedBox(height: 8),
            Text('Post photos with zero-knowledge encryption, ensuring even we can\'t see your memories.',
                style: TextStyle(fontSize: 14, color: onSurfaceVariant, height: 1.5)),

            const SizedBox(height: 24),

            // Coming Soon Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Coming Soon', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Stay tuned for the safest way to share.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Icon(Icons.image, size: 80, color: Colors.white.withOpacity(0.15)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Premium Confession Card Preview
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 24, spreadRadius: 2),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Image area with encryption overlay
                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background blurred image placeholder
                          Container(
                            color: const Color(0xFF141b2b),
                            child: Opacity(
                              opacity: 0.4,
                              child: CustomPaint(painter: _DiagonalLinesPainter()),
                            ),
                          ),
                          // Bottom fade
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, surfaceColor],
                                ),
                              ),
                            ),
                          ),
                          // Center lock icon with float animation
                          Center(
                            child: AnimatedBuilder(
                              animation: _floatAnimation,
                              builder: (ctx, child) => Transform.translate(
                                offset: Offset(0, _floatAnimation.value),
                                child: child,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                                    ),
                                    child: const Icon(Icons.lock_outlined, size: 48, color: Colors.white),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('AES-256 Encrypted', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Card content
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white.withOpacity(0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(color: Color(0xFFe9edff), shape: BoxShape.circle),
                                child: const Icon(Icons.account_circle, color: Color(0xFF004ac6)),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Anonymous User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Text('2 hours ago', style: TextStyle(fontSize: 12, color: Color(0xFF737686))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '"Some secrets are better kept in pixels that only the heart can decode. Finally, a space where my visual memories are truly mine."',
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.favorite_border, size: 20, color: Color(0xFF434655)),
                              const SizedBox(width: 4),
                              const Text('42', style: TextStyle(fontSize: 14, color: Color(0xFF434655))),
                              const SizedBox(width: 16),
                              const Icon(Icons.chat_bubble_outline, size: 20, color: Color(0xFF434655)),
                              const SizedBox(width: 4),
                              const Text('12', style: TextStyle(fontSize: 14, color: Color(0xFF434655))),
                              const Spacer(),
                              const Icon(Icons.share, size: 20, color: Color(0xFF434655)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user, color: primaryColor, size: 18),
                      const SizedBox(width: 8),
                      const Text('Production Ready', style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: Color(0xFF434655))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Powered by CloudExify Identity Protocol',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DiagonalLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563eb).withOpacity(0.15)
      ..strokeWidth = 1;
    for (double i = -size.height; i < size.width + size.height; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
