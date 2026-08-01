import 'package:flutter/material.dart';
import 'core/supabase_client.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);

  bool _pushEnabled = true;
  bool _reactionsEnabled = true;
  bool _commentsEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final res = await supabase
            .from('user_settings')
            .select('notifications_enabled, reactions_enabled, comments_enabled')
            .eq('user_id', userId)
            .maybeSingle();
        if (res != null && mounted) {
          setState(() {
            _pushEnabled = res['notifications_enabled'] as bool? ?? true;
            _reactionsEnabled = res['reactions_enabled'] as bool? ?? true;
            _commentsEnabled = res['comments_enabled'] as bool? ?? true;
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('user_settings').upsert({
          'user_id': userId,
          'notifications_enabled': _pushEnabled,
          'reactions_enabled': _reactionsEnabled,
          'comments_enabled': _commentsEnabled,
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification preferences saved'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
              ),
            )
          else
            TextButton(onPressed: _saveSettings, child: const Text('Save', style: TextStyle(color: _primary))),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Receive alerts on your device'),
                  activeTrackColor: _primary.withValues(alpha: 0.5),
                  thumbColor: WidgetStateProperty.resolveWith((s) =>
                      s.contains(WidgetState.selected) ? _primary : null),
                  value: _pushEnabled,
                  onChanged: (val) => setState(() => _pushEnabled = val),
                ),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Alert Types', style: TextStyle(fontWeight: FontWeight.w600, color: _primary)),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Reactions'),
                  subtitle: const Text('When someone reacts to your posts'),
                  activeTrackColor: _primary.withValues(alpha: 0.5),
                  thumbColor: WidgetStateProperty.resolveWith((s) =>
                      s.contains(WidgetState.selected) ? _primary : null),
                  value: _reactionsEnabled,
                  onChanged: _pushEnabled ? (val) => setState(() => _reactionsEnabled = val) : null,
                ),
                SwitchListTile(
                  title: const Text('Comments'),
                  subtitle: const Text('When someone comments on your posts'),
                  activeTrackColor: _primary.withValues(alpha: 0.5),
                  thumbColor: WidgetStateProperty.resolveWith((s) =>
                      s.contains(WidgetState.selected) ? _primary : null),
                  value: _commentsEnabled,
                  onChanged: _pushEnabled ? (val) => setState(() => _commentsEnabled = val) : null,
                ),
              ],
            ),
    );
  }
}
