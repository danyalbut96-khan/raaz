import 'package:flutter/material.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String _selectedTheme = 'System default';

  @override
  Widget build(BuildContext context) {
    const Color _surface = Color(0xFFf9f9ff);

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeOption('System default'),
          const SizedBox(height: 12),
          _buildThemeOption('Light Mode'),
          const SizedBox(height: 12),
          _buildThemeOption('Dark Mode'),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title) {
    final isSelected = _selectedTheme == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTheme = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF004ac6) : const Color(0xFFc3c6d7)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFF004ac6) : const Color(0xFF141B2B)))),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF004ac6)),
          ],
        ),
      ),
    );
  }
}
