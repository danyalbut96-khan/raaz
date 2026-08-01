import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionsCenterScreen extends StatefulWidget {
  const PermissionsCenterScreen({super.key});

  @override
  State<PermissionsCenterScreen> createState() => _PermissionsCenterScreenState();
}

class _PermissionsCenterScreenState extends State<PermissionsCenterScreen> {
  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);

  bool _notifications = true;
  bool _camera = false;
  bool _microphone = false;
  bool _storage = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('perm_notifications') ?? true;
      _camera = prefs.getBool('perm_camera') ?? false;
      _microphone = prefs.getBool('perm_microphone') ?? false;
      _storage = prefs.getBool('perm_storage') ?? true;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface.withValues(alpha: 0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Permissions Center',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 24),
            const Text('App Permissions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurfaceVariant)),
            const SizedBox(height: 12),
            _buildPermissionTile(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive alerts for reactions and comments',
              value: _notifications,
              onChanged: (v) {
                setState(() => _notifications = v);
                _setPref('perm_notifications', v);
              },
            ),
            const SizedBox(height: 12),
            _buildPermissionTile(
              icon: Icons.camera_alt_outlined,
              title: 'Camera',
              subtitle: 'For future image confessions (coming soon)',
              value: _camera,
              enabled: false,
              onChanged: (v) {},
            ),
            const SizedBox(height: 12),
            _buildPermissionTile(
              icon: Icons.mic_outlined,
              title: 'Microphone',
              subtitle: 'For voice confessions (coming soon)',
              value: _microphone,
              enabled: false,
              onChanged: (v) {},
            ),
            const SizedBox(height: 12),
            _buildPermissionTile(
              icon: Icons.folder_outlined,
              title: 'Local Storage',
              subtitle: 'Save drafts and cache feed for offline reading',
              value: _storage,
              onChanged: (v) {
                setState(() => _storage = v);
                _setPref('perm_storage', v);
              },
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFe1e8fd),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: _primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'RAAZ never requests contacts, location, or identity permissions. '
                      'You can revoke any permission in your device Settings at any time.',
                      style: TextStyle(fontSize: 13, color: _onSurfaceVariant.withValues(alpha: 0.9), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.admin_panel_settings, color: _primary),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Privacy, Your Control',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurface)),
                SizedBox(height: 4),
                Text('Manage what RAAZ can access on your device.',
                    style: TextStyle(fontSize: 13, color: _onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(icon, color: enabled ? _primary : _outlineVariant),
        title: Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: enabled ? _onSurface : _onSurfaceVariant)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: _onSurfaceVariant)),
        value: value,
        activeThumbColor: _primary,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
