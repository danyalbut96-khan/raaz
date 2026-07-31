import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/pseudonym_generator.dart';
import 'core/supabase_client.dart';
import 'splash_screen.dart';
import 'privacy_center_screen.dart';
import 'active_shield_screen.dart';
import 'appearance_screen.dart';
import 'anonymous_profile_screen.dart';
import 'my_posts_screen.dart';
import 'bookmarks_screen.dart';
import 'legal_screens.dart';
import 'contact_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _pseudonym = 'Loading...';
  String _appVersion = 'v1.0.0';
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _loadPseudonym();
    _loadAppVersion();
  }

  Future<void> _loadPseudonym() async {
    setState(() {
      _isLoadingName = true;
    });
    // First try to check the Supabase currentUser metadata
    final currentUser = supabase.auth.currentUser;
    String? name = currentUser?.userMetadata?['pseudonym'];

    // Fallback to local storage/generation if not found
    if (name == null || name.isEmpty) {
      name = await PseudonymGenerator.generate();
    } else {
      // Sync it locally just in case
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pseudonym', name);
    }

    if (mounted) {
      setState(() {
        _pseudonym = name!;
        _isLoadingName = false;
      });
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final response = await supabase
          .from('app_config')
          .select('value')
          .eq('key', 'app_version')
          .maybeSingle();
      if (response != null && response['value'] != null) {
        if (mounted) {
          setState(() => _appVersion = response['value'] as String);
        }
        return;
      }
    } catch (_) {
      // Fallback if table or key doesn't exist
    }
    if (mounted) {
      setState(() => _appVersion = 'v1.0.0');
    }
  }

  Future<void> _regeneratePseudonym() async {
    setState(() {
      _isLoadingName = true;
    });
    final newName = await PseudonymGenerator.regenerate();
    if (mounted) {
      setState(() {
        _pseudonym = newName;
        _isLoadingName = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pseudonym updated to: $newName'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final Color primaryColor = const Color(0xFF004ac6);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Secure Log Out'),
          content: const Text(
            'Are you sure you want to log out? Your anonymous session and all local preferences will be completely cleared.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                
                // Clear onboarding completed & pseudonym locally
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('onboarding_completed');
                await prefs.remove('user_pseudonym');
                
                // Sign out of Supabase
                await supabase.auth.signOut();
                
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFf8fafc);
    final Color surfaceContainerLowest = Colors.white;
    final Color onSurface = const Color(0xFF141b2b);
    final Color onSurfaceVariant = const Color(0xFF434655);
    final Color outlineVariant = const Color(0xFFc3c6d7);
    final Color secondaryContainer = const Color(0xFF2170e4);
    final Color errorContainer = const Color(0xFFffdad6);
    final Color onErrorContainer = const Color(0xFF93000a);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withOpacity(0.85),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.security, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              'RAAZ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section (Bento Style Intro)
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnonymousProfileScreen())),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.account_circle, size: 32, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _isLoadingName ? 'Loading...' : _pseudonym,
                                      style: TextStyle(
                                        fontSize: 20, 
                                        fontWeight: FontWeight.w600, 
                                        color: onSurface,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  if (!_isLoadingName)
                                    IconButton(
                                      icon: Icon(Icons.refresh, size: 20, color: primaryColor),
                                      tooltip: 'Regenerate Pseudonym',
                                      onPressed: _regeneratePseudonym,
                                    ),
                                ],
                              ),
                              Text(
                                'Anonymous User',
                                style: TextStyle(fontSize: 14, color: onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFdce2f7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.75,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyCenterScreen())),
                          child: Text('Privacy Level: High', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveShieldScreen())),
                          child: Text('Active Shield', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account & Preferences
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text('Account & Preferences', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor)),
            ),
            Container(
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.palette_outlined, title: 'Theme', value: 'System default', color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearanceScreen())),
                  ),
                  Divider(height: 1, color: outlineVariant.withOpacity(0.3), indent: 16, endIndent: 16),
                  _buildSettingItem(icon: Icons.language, title: 'Language', value: 'English (US)', color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant),
                  Divider(height: 1, color: outlineVariant.withOpacity(0.3), indent: 16, endIndent: 16),
                  _buildSettingItem(
                    icon: Icons.lock_outline, title: 'Privacy', color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyCenterScreen())),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Content & Activity
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text('Content & Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor)),
            ),
            Container(
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.article_outlined, title: 'My Posts', color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPostsScreen())),
                  ),
                  Divider(height: 1, color: outlineVariant.withOpacity(0.3), indent: 16, endIndent: 16),
                  _buildSettingItem(
                    icon: Icons.bookmark_border, title: 'Saved Posts', color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen())),
                  ),

                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Legal & Support
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text('Legal & Support', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor)),
            ),
            Container(
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.description_outlined, title: 'Terms of Service',
                    color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen())),
                  ),
                  Divider(height: 1, color: outlineVariant.withValues(alpha: 0.3), indent: 16, endIndent: 16),
                  _buildSettingItem(
                    icon: Icons.privacy_tip_outlined, title: 'Privacy Policy',
                    color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  ),
                  Divider(height: 1, color: outlineVariant.withValues(alpha: 0.3), indent: 16, endIndent: 16),
                  _buildSettingItem(
                    icon: Icons.mail_outline, title: 'Contact Us',
                    color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen())),
                  ),
                  Divider(height: 1, color: outlineVariant.withValues(alpha: 0.3), indent: 16, endIndent: 16),
                  _buildSettingItem(
                    icon: Icons.bug_report_outlined, title: 'Report a Bug',
                    color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant,
                    onTap: () => _showBugReport(context),
                  ),
                  Divider(height: 1, color: outlineVariant.withValues(alpha: 0.3), indent: 16, endIndent: 16),
                  _buildSettingItem(
                    icon: Icons.info_outline, title: 'About RAAZ', value: _appVersion,
                    color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant,
                    onTap: _loadAppVersion,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: Icon(Icons.logout, color: onErrorContainer),
                label: Text('Secure Log Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onErrorContainer)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorContainer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Your session is encrypted and will be fully cleared upon logout.',
                style: TextStyle(fontSize: 11, color: const Color(0xFF737686)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showBugReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _BugReportSheet(),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    required Color color,
    required Color onSurfaceVariant,
    required Color outlineVariant,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 16, color: color)),
            ),
            if (value != null) ...[
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right, color: outlineVariant),
          ],
        ),
      ),
    );
  }
}

class _BugReportSheet extends StatefulWidget {
  const _BugReportSheet();
  @override
  State<_BugReportSheet> createState() => _BugReportSheetState();
}

class _BugReportSheetState extends State<_BugReportSheet> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      await supabase.from('bug_reports').insert({
        'user_id': userId,
        'description': text,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Bug report submitted. Thank you! 🙏'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF004ac6),
        ));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to submit. Please email bugs@raazapp.com'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Color(0xFF004ac6)),
              const SizedBox(width: 8),
              const Text('Report a Bug', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Describe what happened', style: TextStyle(fontSize: 13, color: Color(0xFF434655))),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFf1f3ff), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'E.g. "When I tap on a post, the app crashes..."',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004ac6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
