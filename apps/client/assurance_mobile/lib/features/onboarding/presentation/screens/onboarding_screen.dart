import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/images.dart';
import '../../domain/entities/onboarding_page.dart';
import '../bloc/onboarding_bloc.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late final List<OnboardingPage> _pages;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _imageController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _imageOpacityAnimation;
  late Animation<Offset> _imageSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Pre-cache images for instant loading
    _precacheImages();

    // Initialize animation controllers with smoother durations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _imageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Smooth fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Clean slide animation for content
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    // Smooth image animations
    _imageOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _imageSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _pages = [
      OnboardingPage(
        title: "Assurance Auto Intelligente",
        description:
            "Souscrivez votre assurance auto en quelques minutes. Choisissez parmi nos partenaires assureurs et obtenez une couverture adaptée à vos besoins avec une authentification biométrique sécurisée.",
        assetPath: AppImages.onboarding1,
      ),
      OnboardingPage(
        title: "Constat d'Accident Simplifié",
        description:
            "Déclarez un accident en toute simplicité. Scannez les documents de l'autre partie, enregistrez les dégâts en vidéo, créez un croquis interactif et ajoutez votre témoignage vocal.",
        assetPath: AppImages.onboarding2,
      ),
      OnboardingPage(
        title: "Traitement Automatisé",
        description:
            "Notre IA analyse votre dossier instantanément. Obtenez une réponse rapide sur votre demande d'indemnisation et suivez le remboursement en temps réel grâce à notre mascotte guide.",
        assetPath: AppImages.onboarding3,
      ),
    ];

    // Start initial animations with staggered timing
    _startInitialAnimations();
  }

  void _startInitialAnimations() {
    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _imageController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });
  }

  // Pre-cache all images for instant loading
  void _precacheImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final imagePaths = [
        AppImages.onboarding1,
        AppImages.onboarding2,
        AppImages.onboarding3,
      ];

      for (String imagePath in imagePaths) {
        precacheImage(AssetImage(imagePath), context);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.read<OnboardingBloc>().add(CompleteOnboarding());
    }
  }

  void _onSkip() {
    context.read<OnboardingBloc>().add(CompleteOnboarding());
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);

    // Reset and restart animations with smooth timing
    _slideController.reset();
    _imageController.reset();

    // Staggered animation restart
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _imageController.forward();
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  Color _getPageAccentColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF00D084); // Primary color from theme
      case 1:
        return const Color(0xFF00B872); // Secondary color from theme
      case 2:
        return const Color(0xFF1A1A1A); // Accent color from theme
      default:
        return const Color(0xFF00D084);
    }
  }

  List<String> _getPageFeatures(int index) {
    switch (index) {
      case 0:
        return [
          '🚗 Inscription d\'une voiture',
          '👥 Conducteurs multiples',
          '🔐 Connexion biométrique'
        ];
      case 1:
        return [
          '📱 Scan QR de l\'autre partie',
          '📹 Enregistrement vidéo des dégâts',
          '✏️ Croquis interactif d\'accident'
        ];
      case 2:
        return [
          '🤖 Analyse IA instantanée',
          '⚡ Traitement automatisé',
          '💰 Remboursement rapide'
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double containerHeight = size.height * 0.55;
    final double imageAreaHeight =
        size.height - containerHeight + 32; // +32 for overlap

    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingComplete) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient - Full screen with theme colors
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0F1419), // Background color from theme
                      const Color(0xFF1E2A32), // Surface color from theme
                      _getPageAccentColor(_currentIndex).withOpacity(0.05),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // Images - Top area with smooth transitions
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: imageAreaHeight,
              child: SafeArea(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _imageController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _imageOpacityAnimation,
                          child: SlideTransition(
                            position: _imageSlideAnimation,
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                                child: Image.asset(
                                  _pages[index].assetPath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  gaplessPlayback: true,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: _getPageAccentColor(index)
                                            .withOpacity(0.1),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(24),
                                          bottomRight: Radius.circular(24),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 64,
                                        color: _getPageAccentColor(index),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Content Container - Bottom part
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: containerHeight,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF253339), // Card color from theme
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Handle bar
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 50,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A4A52), // Border color from theme
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          // Content Area
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(32, 32, 32, 16),
                              child: AnimatedBuilder(
                                animation: _slideAnimation,
                                builder: (context, child) {
                                  return SlideTransition(
                                    position: _slideAnimation,
                                    child: FadeTransition(
                                      opacity: _slideController,
                                      child: SingleChildScrollView(
                                        child: _buildPageContent(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Navigation Area
                          Container(
                            padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
                            child: Column(
                              children: [
                                // Page Indicators with smooth transitions
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _pages.length,
                                    (index) => AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeOutCubic,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      width: _currentIndex == index ? 32 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: _currentIndex == index
                                            ? const Color(0xFF00D084) // Primary color
                                            : const Color(0xFF3A4A52), // Border color
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Navigation Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildSkipButton(),
                                    _buildNextButton(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    final page = _pages[_currentIndex];
    final features = _getPageFeatures(_currentIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with smooth entrance
        Text(
          page.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFFFFF), // Primary text color from theme
                height: 1.2,
              ),
        ),

        const SizedBox(height: 20),

        // Description with subtle animation
        Text(
          page.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFE0E6ED), // Secondary text color from theme
                height: 1.6,
                fontSize: 16,
              ),
        ),

        const SizedBox(height: 28),

        // Features list with staggered animation
        ...features.asMap().entries.map((entry) {
          final int featureIndex = entry.key;
          final String feature = entry.value;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (featureIndex * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getPageAccentColor(_currentIndex),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            feature,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFFE0E6ED), // Secondary text color
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSkipButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: TextButton(
        onPressed: _onSkip,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF6B7C85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          'Passer',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7C85),
              ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final isLastPage = _currentIndex == _pages.length - 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D084), // Primary color from theme
            const Color(0xFF00B872), // Secondary color from theme
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D084).withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: _onNext,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLastPage ? 'Commencer' : 'Suivant',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _slideController.value * 0.1,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isLastPage ? Icons.check : Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}