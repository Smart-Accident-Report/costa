import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final String userName = "Benali";
  final String userInitials = "B";

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 18) {
      return 'Bon après-midi';
    } else {
      return 'Bonsoir';
    }
  }

  @override
  Widget build(BuildContext context) {
    //final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419), // Background color from theme
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                // Header Section
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                // Quick Actions Card
                SliverToBoxAdapter(
                  child: _buildQuickActionsCard(),
                ),

                // Main Features Grid
                SliverToBoxAdapter(
                  child: _buildMainFeatures(),
                ),

                // Recent Activity Section
                SliverToBoxAdapter(
                  child: _buildRecentActivity(),
                ),

                // Additional Features
                SliverToBoxAdapter(
                  child: _buildAdditionalFeatures(),
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with profile and notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D084), Color(0xFF00B872)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D084).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Notifications
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF253339),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF3A4A52),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      // Handle notifications tap
                    },
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFFE0E6ED),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Greeting
          Text(
            '${_getGreeting()}, $userName',
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Gérez votre assurance auto en toute simplicité',
            style: TextStyle(
              color: Color(0xFF6B7C85),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00D084), Color(0xFF00B872)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D084).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Action Urgente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Besoin d\'aide immédiate ?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Navigate to emergency constat
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00D084),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Démarrer un Constat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatures() {
    final features = [
      {
        'title': 'Mes Constats',
        'subtitle': '3 en cours',
        'icon': Icons.description_outlined,
        'color': const Color(0xFF4A90E2),
        'onTap': () => _navigateToConstats(),
      },
      {
        'title': 'Conducteurs',
        'subtitle': 'Ajouter/Gérer',
        'icon': Icons.person_add_outlined,
        'color': const Color(0xFFE2A044),
        'onTap': () => _navigateToConducteurs(),
      },
      {
        'title': 'Ma Voiture',
        'subtitle': 'Informations',
        'icon': Icons.directions_car_outlined,
        'color': const Color(0xFFE24A4A),
        'onTap': () => _navigateToVehicle(),
      },
      {
        'title': 'Assurance',
        'subtitle': 'Contrat & Détails',
        'icon': Icons.shield_outlined,
        'color': const Color(0xFF9B59B6),
        'onTap': () => _navigateToInsurance(),
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services Principaux',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return _buildFeatureCard(
                title: feature['title'] as String,
                subtitle: feature['subtitle'] as String,
                icon: feature['icon'] as IconData,
                color: feature['color'] as Color,
                onTap: feature['onTap'] as VoidCallback,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF253339),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3A4A52),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7C85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activité Récente',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF253339),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF3A4A52),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildActivityItem(
                  title: 'Constat #2024-001',
                  subtitle: 'En cours de traitement',
                  icon: Icons.pending_actions,
                  color: const Color(0xFFE2A044),
                  time: 'Il y a 2h',
                ),
                const Divider(color: Color(0xFF3A4A52), height: 32),
                _buildActivityItem(
                  title: 'Paiement mensuel',
                  subtitle: 'Prélevé avec succès',
                  icon: Icons.payment,
                  color: const Color(0xFF00D084),
                  time: 'Hier',
                ),
                const Divider(color: Color(0xFF3A4A52), height: 32),
                _buildActivityItem(
                  title: 'Nouveau conducteur',
                  subtitle: 'Jean Dupont ajouté',
                  icon: Icons.person_add,
                  color: const Color(0xFF4A90E2),
                  time: '3 jours',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7C85),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            color: Color(0xFF6B7C85),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalFeatures() {
    final additionalFeatures = [
      {
        'title': 'Assistance 24/7',
        'subtitle': 'Support d\'urgence disponible',
        'icon': Icons.support_agent,
      },
      {
        'title': 'Documents',
        'subtitle': 'Cartes vertes, attestations',
        'icon': Icons.file_download_outlined,
      },
      {
        'title': 'Historique Sinistres',
        'subtitle': 'Consultez vos anciens dossiers',
        'icon': Icons.history,
      },
      {
        'title': 'Modifier Contrat',
        'subtitle': 'Ajustez votre couverture',
        'icon': Icons.edit_document,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services Complémentaires',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...additionalFeatures
              .map((feature) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF253339),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3A4A52),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D084).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: const Color(0xFF00D084),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          feature['title'] as String,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          feature['subtitle'] as String,
                          style: const TextStyle(
                            color: Color(0xFF6B7C85),
                            fontSize: 13,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF6B7C85),
                          size: 16,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // Handle navigation
                        },
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  // Navigation methods - replace with your actual navigation logic
  void _navigateToConstats() {
    // Navigator.pushNamed(context, '/constats');
  }

  void _navigateToConducteurs() {
    // Navigator.pushNamed(context, '/conducteurs');
  }

  void _navigateToVehicle() {
    // Navigator.pushNamed(context, '/vehicle');
  }

  void _navigateToInsurance() {
    // Navigator.pushNamed(context, '/insurance');
  }
}
