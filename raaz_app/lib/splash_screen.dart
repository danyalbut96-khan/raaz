import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart'; // To navigate to MainNavigationScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _taglineController;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // Pulse animation for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Tagline fade and slide animation
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    // Progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Start tagline and progress animations after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _taglineController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressController.forward();
      }
    });

    // Navigate to next screen after animations complete
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _taglineController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colors matching the Tailwind theme provided
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFF8FAFC);
    final Color onSurfaceVariant = const Color(0xFF434655);
    final Color surfaceVariant = const Color(0xFFdce2f7);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Stack(
        children: [
          // Background ambient elements
          Positioned(
            top: -100,
            left: -50,
            child: _buildAmbientGlow(primaryColor.withOpacity(0.05), 300),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: _buildAmbientGlow(const Color(0xFF0058be).withOpacity(0.05), 350),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.security,
                        size: 64,
                        color: primaryColor,
                      ),
                      Text(
                        'RAAZ',
                        style: TextStyle(
                          fontSize: 57,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.25,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tagline Section
                SlideTransition(
                  position: _taglineSlide,
                  child: FadeTransition(
                    opacity: _taglineOpacity,
                    child: Text(
                      'Share Your Secrets. Stay Anonymous.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.15,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Progress Indicator
                Container(
                  width: 192,
                  height: 4,
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressController.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Footer
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: onSurfaceVariant.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'END-TO-END ENCRYPTED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                    color: onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 120,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}
