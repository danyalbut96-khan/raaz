import 'package:flutter/material.dart';

class AiWritingAssistantScreen extends StatefulWidget {
  const AiWritingAssistantScreen({super.key});

  @override
  State<AiWritingAssistantScreen> createState() => _AiWritingAssistantScreenState();
}

class _AiWritingAssistantScreenState extends State<AiWritingAssistantScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool _notified = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onNotifyPressed() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() { _isLoading = false; _notified = true; });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFf9f9ff);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AI Writing Assistant', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated illustration area
              SizedBox(
                width: 280, height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background glow
                    Container(
                      width: 240, height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.04),
                        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.12), blurRadius: 60, spreadRadius: 20)],
                      ),
                    ),

                    // Glassmorphic main card
                    Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFFd8e2ff).withOpacity(0.5), shape: BoxShape.circle),
                            child: Icon(Icons.auto_awesome, size: 48, color: primaryColor),
                          ),
                          const SizedBox(height: 16),
                          // Shimmer text lines
                          AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (_, __) {
                              return Column(
                                children: [
                                  _buildShimmerBar(width: 120, opacity: 0.2 + 0.1 * _shimmerController.value),
                                  const SizedBox(height: 6),
                                  _buildShimmerBar(width: 160, opacity: 0.1 + 0.08 * _shimmerController.value),
                                  const SizedBox(height: 6),
                                  _buildShimmerBar(width: 90, opacity: 0.3 + 0.1 * _shimmerController.value),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Floating emoji badge top-left
                    Positioned(
                      top: 20, left: 10,
                      child: AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (_, child) => Transform.translate(offset: Offset(0, _bounceAnimation.value * 0.5), child: child),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
                          ),
                          child: Icon(Icons.sentiment_very_satisfied, color: const Color(0xFFd8e2ff), size: 24),
                        ),
                      ),
                    ),

                    // Floating shield badge bottom-right
                    Positioned(
                      bottom: 20, right: 10,
                      child: AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (_, child) => Transform.translate(offset: Offset(0, -_bounceAnimation.value * 0.5), child: child),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
                          ),
                          child: const Icon(Icons.shield, color: Color(0xFF006874), size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // "Coming Soon" badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFcce5ff),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.schedule, size: 16, color: Color(0xFF0058be)),
                    SizedBox(width: 6),
                    Text('Coming in Next Version', style: TextStyle(fontSize: 14, color: Color(0xFF0058be), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Refine Your Confessions',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Refine your confessions with AI that helps you express complex emotions clearly and safely. Our proprietary model ensures your voice remains yours, while offering clarity for the things hardest to say.',
                style: const TextStyle(fontSize: 16, color: Color(0xFF434655), height: 1.6),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              // CTA Button
              SizedBox(
                width: 240,
                child: ElevatedButton.icon(
                  onPressed: _notified ? null : (_isLoading ? null : _onNotifyPressed),
                  icon: _isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF004ac6)))
                      : Icon(_notified ? Icons.check_circle : Icons.notifications),
                  label: Text(_notified ? "You're on the list!" : (_isLoading ? 'Setting Alert...' : 'Notify Me'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _notified ? const Color(0xFFcce5ff) : const Color(0xFFd8e2ff),
                    foregroundColor: const Color(0xFF004ac6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    shadowColor: const Color(0xFF004ac6).withOpacity(0.3),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "You'll be the first to know when Phase 6 rolls out.",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBar({required double width, required double opacity}) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF004ac6).withOpacity(opacity),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
