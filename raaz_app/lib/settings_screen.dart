import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            Container(
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
                            Text(
                              'Anonymous User',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: onSurface),
                            ),
                            Text(
                              'Active Security Shield: Enabled',
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
                      Text('Privacy Level: High', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
                      Text('Upgrade Protection', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor)),
                    ],
                  ),
                ],
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
                  _buildSettingItem(icon: Icons.palette_outlined, title: 'Theme', value: 'System default', color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant),
                  Divider(height: 1, color: outlineVariant.withOpacity(0.3), indent: 16, endIndent: 16),
                  _buildSettingItem(icon: Icons.language, title: 'Language', value: 'English (US)', color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant),
                  Divider(height: 1, color: outlineVariant.withOpacity(0.3), indent: 16, endIndent: 16),
                  _buildSettingItem(icon: Icons.lock_outline, title: 'Privacy', color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSettingItem(icon: Icons.description_outlined, title: 'Terms of Service', color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant),
                  Divider(height: 1, color: outlineVariant.withOpacity(0.3), indent: 16, endIndent: 16),
                  _buildSettingItem(icon: Icons.info_outline, title: 'About RAAZ', value: 'v2.4.1', color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant),
                  Divider(height: 1, color: outlineVariant.withOpacity(0.3), indent: 16, endIndent: 16),
                  _buildSettingItem(icon: Icons.mail_outline, title: 'Contact Us', color: onSurface, onSurfaceVariant: onSurfaceVariant, outlineVariant: outlineVariant),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
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

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    required Color color,
    required Color onSurfaceVariant,
    required Color outlineVariant,
  }) {
    return InkWell(
      onTap: () {},
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
