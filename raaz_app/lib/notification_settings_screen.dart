import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _reactionsEnabled = true;
  bool _commentsEnabled = true;

  @override
  Widget build(BuildContext context) {
    const Color _primary = Color(0xFF004ac6);
    const Color _surface = Color(0xFFf9f9ff);

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Receive alerts on your device'),
            activeColor: _primary,
            value: _pushEnabled,
            onChanged: (val) => setState(() => _pushEnabled = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Email Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Receive weekly digests'),
            activeColor: _primary,
            value: _emailEnabled,
            onChanged: (val) => setState(() => _emailEnabled = val),
          ),
          const SizedBox(height: 24),
          const Text('Alert Types', style: TextStyle(fontWeight: FontWeight.w600, color: _primary)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Reactions'),
            subtitle: const Text('When someone reacts to your posts'),
            activeColor: _primary,
            value: _reactionsEnabled,
            onChanged: _pushEnabled ? (val) => setState(() => _reactionsEnabled = val) : null,
          ),
          SwitchListTile(
            title: const Text('Comments'),
            subtitle: const Text('When someone comments on your posts'),
            activeColor: _primary,
            value: _commentsEnabled,
            onChanged: _pushEnabled ? (val) => setState(() => _commentsEnabled = val) : null,
          ),
        ],
      ),
    );
  }
}
