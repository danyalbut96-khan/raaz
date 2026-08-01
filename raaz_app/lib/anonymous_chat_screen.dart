import 'package:flutter/material.dart';

class AnonymousChatScreen extends StatelessWidget {
  const AnonymousChatScreen({super.key});

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);
  static const Color _primaryContainer = Color(0xFF2563eb);
  static const Color _onPrimaryContainer = Color(0xFFeeefff);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            Icon(Icons.shield, color: _primary, size: 22),
            SizedBox(width: 8),
            Text('Anonymous Chat',
                style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: _primary),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusBanner(),
            const SizedBox(height: 32),
            _buildIllustration(),
            const SizedBox(height: 32),
            const Text(
              'Connect with others in temporary, anonymous rooms based on shared experiences.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: _onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTag('Private'),
                const SizedBox(width: 8),
                _buildTag('Encrypted'),
                const SizedBox(width: 8),
                _buildTag('Ephemeral'),
              ],
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Live Rooms Preview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurface.withOpacity(0.6))),
            ),
            const SizedBox(height: 16),
            _buildRoomCard('Overcoming Loss', '24 Active Listeners', 'Active', true),
            const SizedBox(height: 12),
            _buildRoomCard('Work Stress Support', '8 Active Listeners', 'Waiting', false),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You will be notified when this feature is released!')),
                  );
                },
                icon: const Icon(Icons.notifications),
                label: const Text('Notify Me on Release', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryContainer,
                  foregroundColor: _onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Production Ready Architecture • End-to-End Encrypted',
                style: TextStyle(fontSize: 11, color: _outlineVariant)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('PHASE 6 • RAAZ', style: TextStyle(fontSize: 11, color: Colors.white70, letterSpacing: 1.2)),
              SizedBox(height: 4),
              Text('Coming Soon', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _onPrimaryContainer)),
            ],
          ),
          const Icon(Icons.lock_clock, size: 40, color: Colors.white30),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF2170e4).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
            border: Border.all(color: _outlineVariant.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFFdce2f7), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Container(width: 60, height: 12, decoration: BoxDecoration(color: const Color(0xFFe9edff), borderRadius: BorderRadius.circular(6))),
                ],
              ),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft, child: Container(width: 100, height: 24, decoration: const BoxDecoration(color: Color(0xFFd8e2ff), borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8), bottomRight: Radius.circular(8))))),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerLeft, child: Container(width: 80, height: 24, decoration: const BoxDecoration(color: Color(0xFFd8e2ff), borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8), bottomRight: Radius.circular(8))))),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerRight, child: Container(width: 90, height: 24, decoration: BoxDecoration(color: _primaryContainer.withOpacity(0.2), borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8), bottomLeft: Radius.circular(8))))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFe1e8fd),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primary.withOpacity(0.1)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, color: _primary, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildRoomCard(String title, String subtitle, String status, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isActive ? 1.0 : 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant.withOpacity(0.2)),
        boxShadow: [if (isActive) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _primary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.groups, size: 14, color: Color(0xFF737686)),
                      const SizedBox(width: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF737686))),
                    ],
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF2170e4).withOpacity(0.1) : _outlineVariant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? const Color(0xFF0058be) : const Color(0xFF737686), letterSpacing: 1.0)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildAvatarPile(isActive ? [Icons.face, Icons.sentiment_satisfied, Icons.account_circle] : [Icons.face_3, Icons.account_circle]),
              const SizedBox(width: 8),
              Text(isActive ? '+12 more' : '+3 more', style: const TextStyle(fontSize: 11, color: Color(0xFF737686))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAvatarPile(List<IconData> icons) {
    return Row(
      children: List.generate(icons.length, (i) {
        return Align(
          widthFactor: 0.6,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFe9edff),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(icons[i], size: 16, color: _onSurfaceVariant),
          ),
        );
      }),
    );
  }
}
