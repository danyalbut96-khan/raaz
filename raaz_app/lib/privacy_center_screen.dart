import 'package:flutter/material.dart';
import 'core/supabase_client.dart';

class PrivacyCenterScreen extends StatefulWidget {
  const PrivacyCenterScreen({super.key});

  @override
  State<PrivacyCenterScreen> createState() => _PrivacyCenterScreenState();
}

class _PrivacyCenterScreenState extends State<PrivacyCenterScreen> {
  String _selectedLevel = 'high';
  bool _isLoading = true;
  bool _isSaving = false;

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);

  @override
  void initState() {
    super.initState();
    _loadSavedLevel();
  }

  Future<void> _loadSavedLevel() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final res = await supabase
            .from('user_settings')
            .select('privacy_level')
            .eq('user_id', userId)
            .maybeSingle();
        if (res != null && mounted) {
          setState(() => _selectedLevel = res['privacy_level'] as String? ?? 'high');
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveLevel(String level) async {
    setState(() { _isSaving = true; _selectedLevel = level; });
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('user_settings').upsert({
          'user_id': userId,
          'privacy_level': level,
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Privacy level set to ${level[0].toUpperCase()}${level.substring(1)}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primary,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Privacy Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Choose your privacy level',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _primary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This controls how your anonymous identity behaves across RAAZ.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF434655)),
                ),
                const SizedBox(height: 20),
                _buildPrivacyOption(
                  level: 'high',
                  title: 'High (Recommended)',
                  desc: 'Fully anonymous. Pseudonym changes periodically. Maximum protection.',
                  icon: Icons.security,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildPrivacyOption(
                  level: 'medium',
                  title: 'Medium',
                  desc: 'Pseudonym stays consistent within a session. Allows building a recognizable persona.',
                  icon: Icons.shield_outlined,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildPrivacyOption(
                  level: 'ghost',
                  title: 'Ghost Mode',
                  desc: 'No pseudonym. Posts are completely detached and cannot be replied to directly.',
                  icon: Icons.visibility_off,
                  color: Colors.grey,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: _primary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Current level: ${_selectedLevel[0].toUpperCase()}${_selectedLevel.substring(1)}',
                          style: const TextStyle(fontSize: 13, color: _primary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPrivacyOption({
    required String level,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedLevel == level;
    return GestureDetector(
      onTap: _isSaving ? null : () => _saveLevel(level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primary : const Color(0xFFc3c6d7),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: _primary.withValues(alpha: 0.12), blurRadius: 10)]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isSelected ? _primary : color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? _primary : color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _primary : const Color(0xFF141B2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF434655))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? const Icon(Icons.check_circle, color: _primary, key: ValueKey('check'))
                  : const Icon(Icons.radio_button_unchecked, color: Color(0xFFc3c6d7), key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}
