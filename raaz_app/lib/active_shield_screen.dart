import 'package:flutter/material.dart';

class ActiveShieldScreen extends StatelessWidget {
  const ActiveShieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color _primary = Color(0xFF004ac6);
    const Color _surface = Color(0xFFf9f9ff);
    const Color _onSurface = Color(0xFF141B2B);

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Active Shield', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.security, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text('Shield is Active', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Your identity is fully protected. Data is encrypted and pseudonyms are actively rotating.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildShieldFeature(Icons.lock, 'End-to-End Encryption', 'All your posts and messages are encrypted.'),
            const SizedBox(height: 16),
            _buildShieldFeature(Icons.masks, 'Pseudonym Rotation', 'Your anonymous name changes automatically.'),
            const SizedBox(height: 16),
            _buildShieldFeature(Icons.visibility_off, 'No IP Tracking', 'Your location and IP address are never logged.'),
          ],
        ),
      ),
    );
  }

  Widget _buildShieldFeature(IconData icon, String title, String desc) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF004ac6).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF004ac6)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF141B2B))),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF434655))),
            ],
          ),
        ),
      ],
    );
  }
}
