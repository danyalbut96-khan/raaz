import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SharePostPreviewScreen extends StatefulWidget {
  const SharePostPreviewScreen({super.key});

  @override
  State<SharePostPreviewScreen> createState() => _SharePostPreviewScreenState();
}

class _SharePostPreviewScreenState extends State<SharePostPreviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 100), () => _animController.forward());
  }

  @override
  void dispose() {
    _animController.dispose();
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
        title: Text('Share Preview', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: -0.5)),
        actions: [
          Icon(Icons.security, color: primaryColor),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            const Text('Ready to Share', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Your secret is locked and ready for the world to see anonymously.', style: TextStyle(fontSize: 14, color: onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 24),

            // Animated share card preview
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.5,
                        colors: [Color(0xFFf1f3ff), Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: primaryColor.withOpacity(0.15), blurRadius: 32, offset: const Offset(0, 12)),
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                      border: Border.all(color: const Color(0xFFe9edff).withOpacity(0.5)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Stack(
                      children: [
                        // Atmospheric background element
                        Positioned(
                          top: -8, right: -8,
                          child: Icon(Icons.security, size: 120, color: primaryColor.withOpacity(0.06)),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header branding
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32, height: 32,
                                      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
                                      child: const Icon(Icons.security, color: Colors.white, size: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('RAAZ', style: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                                  ],
                                ),
                                Text('Verified Anonymous', style: TextStyle(fontSize: 10, color: const Color(0xFF737686), letterSpacing: 1, fontWeight: FontWeight.w500)),
                              ],
                            ),

                            // Content area
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.format_quote, size: 36, color: primaryColor.withOpacity(0.3)),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "I've been working in tech for 10 years, and I still haven't told anyone that I actually learned everything from a single YouTube tutorial series in 2014.",
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.4),
                                    ),
                                    const SizedBox(height: 20),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFd8e2ff), borderRadius: BorderRadius.circular(20)),
                                          child: const Text('#TechSecrets', style: TextStyle(fontSize: 12, color: Color(0xFF004ac6), fontWeight: FontWeight.w500)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFf1f3ff), borderRadius: BorderRadius.circular(20)),
                                          child: const Text('2 mins ago', style: TextStyle(fontSize: 12, color: Color(0xFF737686))),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Footer with QR placeholder
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Scan to Read More', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF004ac6))),
                                        Text('Join the conversation on RAAZ', style: TextStyle(fontSize: 12, color: Color(0xFF434655))),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 56, height: 56,
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe9edff))),
                                    child: Center(
                                      child: Icon(Icons.qr_code_2, size: 40, color: primaryColor.withOpacity(0.4)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saving image... (mock)'), behavior: SnackBarBehavior.floating),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Save as Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening share sheet...'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0xFFc3c6d7)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: 'https://raaz.app/post/12345'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard!'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    icon: const Icon(Icons.content_copy),
                    label: const Text('Link'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0xFFc3c6d7)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
