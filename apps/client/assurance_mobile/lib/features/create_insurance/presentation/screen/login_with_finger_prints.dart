import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'dart:async';

extension ResponsiveContext on BuildContext {
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
}

class LoginWithFingerPrints extends StatefulWidget {
  const LoginWithFingerPrints({super.key});

  @override
  State<LoginWithFingerPrints> createState() => _LoginWithFingerPrintsState();
}

class _LoginWithFingerPrintsState extends State<LoginWithFingerPrints>
    with TickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();

  late AnimationController _pulseController;
  late AnimationController _processingController;
  late AnimationController _successController;
  late AnimationController _backgroundController;
  late AnimationController _fadeController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _processingAnimation;
  late Animation<double> _successAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _fadeAnimation;

  bool _isProcessing = false;
  bool _isAuthenticated = false;
  String _statusMessage = 'Appuyez sur l\'empreinte pour vous authentifier';
  int _countdown = 4;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Pulse animation for fingerprint icon
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Processing animation
    _processingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _processingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _processingController,
        curve: Curves.elasticOut,
      ),
    );

    // Success animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: Curves.bounceOut,
      ),
    );

    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );

    // Fade animation for smooth transitions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _fadeController.forward();
  }

  Future<void> _checkBiometrics() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (!canCheck || availableBiometrics.isEmpty) {
        setState(() {
          _statusMessage =
              'Aucune biométrie disponible ou configurée sur cet appareil.';
        });
      }
    } on PlatformException catch (e) {
      print('Error checking biometrics: $e');
      setState(() {
        _statusMessage =
            'Une erreur est survenue lors de la vérification des biométries.';
      });
    }
  }

  Future<void> _authenticate() async {
    final availableBiometrics = await _localAuth.getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      setState(() {
        _statusMessage =
            'Veuillez enregistrer une empreinte digitale dans les paramètres.';
      });
      return;
    }

    try {
      final bool isAuthorized = await _localAuth.authenticate(
        localizedReason: 'Scannez votre empreinte pour vous authentifier',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (mounted) {
        if (isAuthorized) {
          setState(() {
            _isAuthenticated = true;
            _isProcessing = false;
            _statusMessage = 'Authentification réussie !';
          });

          // Start success animations
          _successController.forward();
          _backgroundController.forward();

          // Start countdown
          _startCountdown();

          print('Authentication successful! Starting 4-second countdown...');
        } else {
          setState(() {
            _isProcessing = false;
            _statusMessage = 'Authentification échouée. Veuillez réessayer.';
          });
          print('Authentication failed.');
          _pulseController.repeat(reverse: true);
        }
      }
    } on PlatformException catch (e) {
      print('PlatformException caught: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isAuthenticated = false;
          if (e.code == auth_error.notAvailable ||
              e.code == auth_error.notEnrolled ||
              e.code == auth_error.passcodeNotSet) {
            _statusMessage = 'Veuillez configurer votre empreinte digitale.';
          } else if (e.code == auth_error.otherOperatingSystem) {
            _statusMessage = 'Fonctionnalité non prise en charge sur cet OS.';
          } else {
            _statusMessage = 'Une erreur est survenue: ${e.message}';
          }
        });
        _pulseController.repeat(reverse: true);
      }
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        _statusMessage = 'Redirection vers l\'accueil dans $_countdown...';
      });

      if (_countdown <= 0) {
        timer.cancel();
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _processingController.dispose();
    _successController.dispose();
    _backgroundController.dispose();
    _fadeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isAuthenticated
                    ? [
                        const Color(0xFF0F1419),
                        Color.lerp(
                            const Color(0xFF0F1419),
                            const Color(0xFF00D084).withOpacity(0.1),
                            _backgroundAnimation.value)!,
                        const Color(0xFF0F1419),
                      ]
                    : [
                        const Color(0xFF0F1419),
                        const Color(0xFF1E2A32),
                        const Color(0xFF0F1419),
                      ],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // App Logo/Title with animation
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              transform: Matrix4.identity()
                                ..translate(
                                    0.0, _isAuthenticated ? -20.0 : 0.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.security,
                                      size: 32,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Authentification Sécurisée',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Utilisez votre empreinte digitale pour accéder',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.7),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Fingerprint Section
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Fingerprint container with enhanced design
                            GestureDetector(
                              onTap: () {
                                if (!_isProcessing && !_isAuthenticated) {
                                  setState(() {
                                    _isProcessing = true;
                                    _statusMessage =
                                        'Authentification en cours...';
                                  });
                                  _pulseController.stop();
                                  _processingController.forward();
                                  _authenticate();
                                }
                              },
                              child: Container(
                                width: context.width * 0.4,
                                height: context.width * 0.4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: _isAuthenticated
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: _isAuthenticated
                                      ? [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.3),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: _buildFingerprintWidget(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Status message with enhanced styling
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _statusMessage,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: _isAuthenticated
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_isAuthenticated && _countdown > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: LinearProgressIndicator(
                                        value: (4 - _countdown) / 4,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.2),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom section
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Touchez l\'icône d\'empreinte pour commencer',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFingerprintWidget() {
    if (_isAuthenticated) {
      return AnimatedBuilder(
        animation: _successAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _successAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.check_circle,
                size: context.width * 0.15,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      );
    } else if (_isProcessing) {
      return AnimatedBuilder(
        animation: _processingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (_processingAnimation.value * 0.3),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: context.width * 0.15,
                  height: context.width * 0.15,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Icon(
                  Icons.fingerprint,
                  size: context.width * 0.08,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.fingerprint,
                size: context.width * 0.15,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      );
    }
  }
}
