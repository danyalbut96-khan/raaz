import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // To navigate to MainNavigationScreen
import 'legal_screens.dart'; // For TermsOfServiceScreen and PrivacyPolicyScreen

class ContinueAsGuestScreen extends StatefulWidget {
  const ContinueAsGuestScreen({super.key});

  @override
  State<ContinueAsGuestScreen> createState() => _ContinueAsGuestScreenState();
}

class _ContinueAsGuestScreenState extends State<ContinueAsGuestScreen> {
  bool _isLoading = false;

  void _handleContinue() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate network delay for guest login
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_completed', true);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFf8fafc);
    final Color onSurfaceVariant = const Color(0xFF434655);
    final Color outlineVariant = const Color(0xFFc3c6d7);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withOpacity(0.85),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.security, color: primaryColor, size: 24),
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
      ),
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.5 - 250,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.05),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.05), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration container
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFe9edff), width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.person_outline, size: 80, color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                              ),
                              child: Icon(Icons.visibility_off, color: primaryColor, size: 24),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                              ),
                              child: const Icon(Icons.verified_user, color: Color(0xFF0058be), size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Typography
                    Text(
                      'Your Secrets,\nPerfectly Safe.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF141b2b),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Share your thoughts anonymously in a premium, secure space.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: onSurfaceVariant,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Actions
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              width: 24, 
                              height: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Continue as Guest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(child: Divider(color: outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('OR', style: TextStyle(color: outlineVariant, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
                        ),
                        Expanded(child: Divider(color: outlineVariant)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sign in coming soon!')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: outlineVariant, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Sign in to Account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF141b2b)),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our\n',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF737686), height: 1.5),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()));
                              },
                              child: Text('Terms of Service', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                              },
                              child: Text('Privacy Policy', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
