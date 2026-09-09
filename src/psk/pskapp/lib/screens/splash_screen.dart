import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/psk_colors.dart';
import '../state/app_state.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  final AppState state;

  const SplashScreen({super.key, required this.state});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Navigate to MainNavigationScreen after splash duration
    Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) =>
              MainNavigationScreen(state: widget.state),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PskColors.bgDark,
      body: Stack(
        children: [
          // Background ambient radial gradient glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.15),
                  radius: 0.85,
                  colors: [
                    Color(0xFF1752BF),
                    Color(0xFF0E1A33),
                    PskColors.bgDark,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Central Animated PSK Logo
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Official Vector SVG Logo with subtle glow
                    Container(
                      width: 180,
                      height: 70,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: PskColors.brandBlueLight.withValues(alpha: 0.25),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/images/psk_logo.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Gold Tagline
                    const Text(
                      'SPORTS & CASINO',
                      style: TextStyle(
                        color: PskColors.accentGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Prva Sportska Kladionica',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Sleek loader
                    SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          minHeight: 2.5,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(PskColors.accentGold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Responsible Gaming note & version
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 13, color: PskColors.textMuted),
                    SizedBox(width: 5),
                    Text(
                      '18+ • Play Responsibly',
                      style: TextStyle(
                        color: PskColors.textMuted,
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.12.0 • PSK Mobile',
                  style: TextStyle(
                    color: PskColors.textMuted.withValues(alpha: 0.6),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
