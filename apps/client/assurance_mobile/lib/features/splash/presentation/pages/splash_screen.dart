import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assurance_mobile/core/extensions/extensions.dart';

import '../../../../core/constants/images.dart';
import '../bloc/splash_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _progressOpacityAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup animations
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _progressOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start animations sequence
    _startAnimations();

    context.read<SplashBloc>().add(const InitializeApp());
  }

  void _startAnimations() async {
    // Start logo animations
    _logoController.forward();
    _scaleController.forward();

    // Wait then start progress indicator
    await Future.delayed(const Duration(milliseconds: 1000));
    _progressController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F1419), // Dark background from theme
              Color(0xFF1E2A32), // Surface color
              Color(0xFF253339), // Card color
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: BlocListener<SplashBloc, SplashState>(
          listener: (context, state) {
            if (state is SplashLoaded) {
              // Start fade out animation before navigation
              _fadeController.forward().then((_) {
                Navigator.of(context).pushReplacementNamed(state.route);
              });
            } else if (state is SplashError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Erreur: ${state.message}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  backgroundColor:
                      const Color(0xFFFF4757), // Error color from theme
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top spacer
                      const Spacer(flex: 2),

                      // Logo section with enhanced animations
                      Expanded(
                        flex: 4,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _logoController,
                            _scaleController,
                          ]),
                          builder: (context, child) {
                            return SlideTransition(
                              position: _slideAnimation,
                              child: Transform.scale(
                                scale: _logoScaleAnimation.value,
                                child: Opacity(
                                  opacity: _logoOpacityAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00D084)
                                              .withOpacity(0.25),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                          offset: const Offset(0, 8),
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFF00B872)
                                              .withOpacity(0.15),
                                          blurRadius: 60,
                                          spreadRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      AppImages.logo,
                                      color: Colors.white,
                                      width: context.width * 0.4,
                                      height: context.width * 0.4,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // App name and enhanced tagline
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _slideAnimation,
                            child: Opacity(
                              opacity: _logoOpacityAnimation.value,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                          0xFF253339), // Card color from theme
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF00D084)
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Assurance Auto Intelligente',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: const Color(
                                                0xFF00D084), // Primary color
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Constat d\'accident simplifié',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: const Color(
                                              0xFFE0E6ED), // Secondary text color
                                          letterSpacing: 0.2,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Enhanced progress indicator section
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _progressOpacityAnimation.value,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Insurance-themed progress indicator
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                            0xFF1E2A32), // Surface color
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: const Color(0xFF00D084)
                                              .withOpacity(0.2),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00B872)
                                                .withOpacity(0.1),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Color(0xFF00D084), // Primary green
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Loading text with insurance feel
                                    Text(
                                      'Initialisation de votre protection...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: const Color(
                                                0xFFE0E6ED), // Primary text
                                            letterSpacing: 0.3,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sécurisation de vos données',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: const Color(
                                                0xFF8A9BA8), // Hint text
                                            letterSpacing: 0.2,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Bottom section with subtle branding
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _progressOpacityAnimation.value * 0.7,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.security,
                                    size: 16,
                                    color: const Color(0xFF00D084)
                                        .withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Votre sécurité, notre priorité',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: const Color(0xFF8A9BA8),
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
