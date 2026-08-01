import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);
  
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    _loadLang();
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLang = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _setLang(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
    setState(() {
      _selectedLang = code;
    });
  }

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
        title: const Text('Settings',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: _onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Display Language', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _onSurface)),
            const SizedBox(height: 8),
            const Text('Choose your preferred language for the interface and shared content.',
                style: TextStyle(fontSize: 14, color: _onSurfaceVariant)),
            const SizedBox(height: 32),
            _buildLangOption('English (US)', 'English', 'en'),
            const SizedBox(height: 12),
            _buildLangOption('Urdu', 'اردو', 'ur'),
            const SizedBox(height: 12),
            _buildLangOption('Arabic', 'العربية', 'ar'),
            const SizedBox(height: 40),
            
            Row(
              children: [
                const Text('COMING SOON', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _onSurfaceVariant, letterSpacing: 1.0)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 1, color: _outlineVariant)),
              ],
            ),
            const SizedBox(height: 16),
            _buildLockedOption('Spanish', 'Español'),
            const SizedBox(height: 12),
            _buildLockedOption('French', 'Français'),
            const SizedBox(height: 12),
            _buildLockedOption('Hindi', 'हिन्दी'),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption(String title, String subtitle, String code) {
    final isSelected = _selectedLang == code;
    return GestureDetector(
      onTap: () => _setLang(code),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _primary.withOpacity(0.05) : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? _primary : Colors.transparent, width: 2),
          boxShadow: isSelected ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurface)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: _onSurfaceVariant)),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? _primary : _outlineVariant, width: 2),
              ),
              child: isSelected
                  ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle)))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFdce2f7).withOpacity(0.5), shape: BoxShape.circle),
            child: const Icon(Icons.public, color: _onSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurface.withOpacity(0.6))),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: _onSurfaceVariant.withOpacity(0.6))),
              ],
            ),
          ),
          Icon(Icons.lock, color: _outlineVariant, size: 20),
        ],
      ),
    );
  }
}
