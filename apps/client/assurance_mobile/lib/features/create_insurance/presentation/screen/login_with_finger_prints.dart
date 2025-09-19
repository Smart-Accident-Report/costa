import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

// Extension for responsive design
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
  late Animation<double> _pulseAnimation;
  late Animation<double> _processingAnimation;

  bool _isProcessing = false;
  bool _isAuthenticated = false;
  String _statusMessage = 'Appuyez sur l\'empreinte pour vous authentifier';

  @override
  void initState() {
    super.initState();

    // Pulse animation for fingerprint icon
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Processing animation
    _processingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _processingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _processingController,
      curve: Curves.easeInOut,
    ));

    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool isAvailable = await _localAuth.isDeviceSupported();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (!isAvailable || !canCheckBiometrics) {
        setState(() {
          _statusMessage = 'Authentification biométrique non disponible';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur lors de la vérification de la disponibilité';
      });
    }
  }

  Future<void> _authenticateWithFingerprint() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Placez votre doigt sur le capteur';
    });

    _pulseController.stop();

    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            'Veuillez vous authentifier pour accéder à votre compte',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        setState(() {
          _isAuthenticated = true;
          _statusMessage = 'Authentification réussie !';
        });

        // Start processing animation
        await _processingController.forward();

        // Navigate to home after processing animation
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        _resetToInitialState();
        setState(() {
          _statusMessage = 'Authentification échouée. Réessayez.';
        });
      }
    } catch (e) {
      _resetToInitialState();
      String errorMessage = 'Erreur d\'authentification';

      if (e is PlatformException) {
        switch (e.code) {
          case auth_error.notAvailable:
            errorMessage = 'Authentification biométrique non disponible';
            break;
          case auth_error.notEnrolled:
            errorMessage = 'Aucune empreinte enregistrée sur cet appareil';
            break;
          case auth_error.lockedOut:
            errorMessage = 'Trop de tentatives. Réessayez plus tard.';
            break;
          default:
            errorMessage = 'Authentification annulée ou échouée';
        }
      }

      setState(() {
        _statusMessage = errorMessage;
      });
    }
  }

  void _resetToInitialState() {
    setState(() {
      _isProcessing = false;
      _isAuthenticated = false;
    });
    _processingController.reset();
    _pulseController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _processingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Connexion Sécurisée',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.width * 0.08,
            vertical: context.height * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Title
              Text(
                'Authentification\nBiométrique',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.height * 0.02),

              // Subtitle
              Text(
                'Utilisez votre empreinte digitale pour accéder à votre compte en toute sécurité',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.height * 0.08),

              // Fingerprint Icon with Animation
              GestureDetector(
                onTap: _authenticateWithFingerprint,
                child: Container(
                  width: context.width * 0.4,
                  height: context.width * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isAuthenticated
                          ? [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.8)
                            ]
                          : [
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1)
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: _isProcessing
                      ? _buildProcessingIndicator()
                      : _buildFingerprintIcon(),
                ),
              ),

              SizedBox(height: context.height * 0.06),

              // Status Message
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isAuthenticated
                            ? Theme.of(context).colorScheme.primary
                            : _statusMessage.contains('Erreur') ||
                                    _statusMessage.contains('échouée') ||
                                    _statusMessage.contains('annulée')
                                ? Colors.red.shade400
                                : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: context.height * 0.08),

              // Alternative Login Button
              if (!_isProcessing && !_isAuthenticated)
                Container(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Utiliser un mot de passe',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ),

              SizedBox(height: context.height * 0.04),

              // Help text
              if (!_isProcessing && !_isAuthenticated)
                Text(
                  'Vous rencontrez des difficultés ? Contactez notre support.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFingerprintIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Icon(
            Icons.fingerprint,
            size: context.width * 0.15,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  Widget _buildProcessingIndicator() {
    return AnimatedBuilder(
      animation: _processingAnimation,
      builder: (context, child) {
        if (_isAuthenticated) {
          return Transform.scale(
            scale: _processingAnimation.value,
            child: Icon(
              Icons.check_circle,
              size: context.width * 0.15,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          return SizedBox(
            width: context.width * 0.15,
            height: context.width * 0.15,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              strokeWidth: context.width * 0.01,
            ),
          );
        }
      },
    );
  }
}
