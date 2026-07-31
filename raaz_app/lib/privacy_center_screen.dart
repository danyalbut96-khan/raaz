import 'package:flutter/material.dart';

class PrivacyCenterScreen extends StatelessWidget {
  const PrivacyCenterScreen({super.key});

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
        title: const Text('Privacy Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Your Privacy Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _primary)),
          const SizedBox(height: 16),
          _buildPrivacyOption('High (Recommended)', 'Fully anonymous. Pseudonym changes periodically.', true),
          const SizedBox(height: 12),
          _buildPrivacyOption('Medium', 'Pseudonym stays consistent. Allows building a recognizable persona.', false),
          const SizedBox(height: 12),
          _buildPrivacyOption('Ghost Mode', 'No pseudonym. Posts are completely detached and cannot be replied to directly.', false),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption(String title, String desc, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? const Color(0xFF004ac6) : const Color(0xFFc3c6d7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF004ac6) : const Color(0xFF141B2B))),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF434655))),
              ],
            ),
          ),
          if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF004ac6)),
        ],
      ),
    );
  }
}
