import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/innpo_splash_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.58, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.62, curve: Curves.easeOutCubic),
      ),
    );
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.36, 1, curve: Curves.easeOut),
    );
    _textOffset = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.36, 1, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 1850), () {
      if (mounted) {
        context.go('/onboarding');
      }
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
      backgroundColor: AppColors.darkNavy,
      body: InnpoSplashScreen(
        logoOpacity: _logoOpacity,
        logoScale: _logoScale,
        textOpacity: _textOpacity,
        textOffset: _textOffset,
      ),
    );
  }
}
