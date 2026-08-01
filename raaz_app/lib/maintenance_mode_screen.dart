import 'package:flutter/material.dart';
import 'core/supabase_client.dart';
import 'splash_screen.dart';

class MaintenanceModeScreen extends StatefulWidget {
  const MaintenanceModeScreen({super.key, this.message});

  final String? message;

  @override
  State<MaintenanceModeScreen> createState() => _MaintenanceModeScreenState();
}

class _MaintenanceModeScreenState extends State<MaintenanceModeScreen> {
  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);

  String _message = 'We are performing scheduled maintenance to improve your experience.';
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    if (widget.message != null) _message = widget.message!;
    _loadMessage();
  }

  Future<void> _loadMessage() async {
    try {
      final res = await supabase
          .from('app_config')
          .select('value')
          .eq('key', 'maintenance_message')
          .maybeSingle();
      if (res != null && mounted) {
        setState(() => _message = res['value'] as String? ?? _message);
      }
    } catch (_) {}
  }

  Future<void> _retry() async {
    setState(() => _isChecking = true);
    try {
      final res = await supabase
          .from('app_config')
          .select('value')
          .eq('key', 'maintenance_mode')
          .maybeSingle();
      final isMaintenance = res?['value'] == 'true';
      if (!isMaintenance && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isChecking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still under maintenance. Please try again later.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.construction, size: 48, color: _primary),
              ),
              const SizedBox(height: 32),
              const Text('Under Maintenance',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _onSurface)),
              const SizedBox(height: 16),
              Text(_message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: _onSurfaceVariant, height: 1.6)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Check Again', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Your data is safe and encrypted.',
                  style: TextStyle(fontSize: 12, color: _onSurfaceVariant.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ),
    );
  }
}
