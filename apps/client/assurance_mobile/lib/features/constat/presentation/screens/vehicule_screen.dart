import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VehiculeScreen extends StatefulWidget {
  const VehiculeScreen({super.key});

  @override
  State<VehiculeScreen> createState() => _VehiculeScreenState();
}

class _VehiculeScreenState extends State<VehiculeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  // Mock vehicle data - replace with actual data from your database
  final Map<String, String> _vehicleData = {
    'marque': 'Peugeot',
    'modele': '208',
    'annee': '2021',
    'matricule': '31-123-456',
    'chassis': 'VF3XXXXXXXX123456',
    'energie': 'Essence',
    'puissance': '7 CV',
    'places': '5',
    'valeur_venale': '1,850,000 DA',
    'wilaya': 'Alger',
    'type_matricule': 'Permanent',
    'couleur': 'Blanc',
    'transmission': 'Manuelle',
  };

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _staggerController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _floatingController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFFE0E6ED),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Ma Voiture',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_rounded,
              color: Color(0xFF00D084),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showEditDialog();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildVehicleHeader(),
                ),
                SliverToBoxAdapter(
                  child: _buildVehicleDetails(),
                ),
                SliverToBoxAdapter(
                  child: _buildMaintenanceSection(),
                ),
                SliverToBoxAdapter(
                  child: _buildActionsSection(),
                ),
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

  Widget _buildVehicleHeader() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -3 * _floatingAnimation.value),
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00D084),
                  Color(0xFF00B872),
                  Color(0xFF009B63),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D084).withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  // Car Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Vehicle Info
                  Text(
                    '${_vehicleData['marque']} ${_vehicleData['modele']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Matricule: ${_vehicleData['matricule']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Quick Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickStat('Année', _vehicleData['annee']!),
                      _buildQuickStat('Puissance', _vehicleData['puissance']!),
                      _buildQuickStat('Places', _vehicleData['places']!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleDetails() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _staggerController.value)),
          child: Opacity(
            opacity: _staggerController.value,
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Détails du Véhicule',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF253339),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF3A4A52),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Châssis', _vehicleData['chassis']!,
                            Icons.settings_input_component_rounded),
                        _buildDivider(),
                        _buildDetailRow('Énergie', _vehicleData['energie']!,
                            Icons.local_gas_station_rounded),
                        _buildDivider(),
                        _buildDetailRow(
                            'Valeur vénale',
                            _vehicleData['valeur_venale']!,
                            Icons.account_balance_wallet_rounded),
                        _buildDivider(),
                        _buildDetailRow('Wilaya', _vehicleData['wilaya']!,
                            Icons.location_on_rounded),
                        _buildDivider(),
                        _buildDetailRow(
                            'Type matricule',
                            _vehicleData['type_matricule']!,
                            Icons.badge_rounded),
                        _buildDivider(),
                        _buildDetailRow('Couleur', _vehicleData['couleur']!,
                            Icons.palette_rounded),
                        _buildDivider(),
                        _buildDetailRow(
                            'Transmission',
                            _vehicleData['transmission']!,
                            Icons.settings_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00D084).withOpacity(0.2),
                  const Color(0xFF00D084).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D084).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00D084),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B7C85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFF3A4A52),
      height: 24,
      thickness: 1,
    );
  }

  Widget _buildMaintenanceSection() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _staggerController.value)),
          child: Opacity(
            opacity: _staggerController.value,
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maintenance',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF253339),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF3A4A52),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMaintenanceItem(
                          'Dernière vidange',
                          '15,000 KM',
                          'Il y a 2 mois',
                          Icons.oil_barrel_rounded,
                          const Color(0xFF4A90E2),
                        ),
                        _buildDivider(),
                        _buildMaintenanceItem(
                          'Contrôle technique',
                          'Valide',
                          'Expire dans 8 mois',
                          Icons.verified_rounded,
                          const Color(0xFF00D084),
                        ),
                        _buildDivider(),
                        _buildMaintenanceItem(
                          'Prochaine révision',
                          '20,000 KM',
                          'Dans 5,000 KM',
                          Icons.build_rounded,
                          const Color(0xFFE2A044),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaintenanceItem(
      String title, String status, String detail, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Color(0xFF6B7C85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    final actions = [
      {
        'title': 'Historique des sinistres',
        'subtitle': 'Consultez vos anciens dossiers',
        'icon': Icons.history_rounded,
        'onTap': () => _navigateToHistory(),
      },
      {
        'title': 'Ajouter un conducteur',
        'subtitle': 'Autoriser une personne',
        'icon': Icons.person_add_alt_1_rounded,
        'onTap': () => _navigateToAddDriver(),
      },
      {
        'title': 'Documents du véhicule',
        'subtitle': 'Carte grise, attestations',
        'icon': Icons.folder_rounded,
        'onTap': () => _navigateToDocuments(),
      },
      {
        'title': 'Signaler un problème',
        'subtitle': 'Panne, accident, vol',
        'icon': Icons.report_problem_rounded,
        'onTap': () => _navigateToReport(),
      },
    ];

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - _staggerController.value)),
          child: Opacity(
            opacity: _staggerController.value,
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actions Rapides',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...actions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final action = entry.value;
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 600 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(30 * (1 - value), 0),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF253339),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF3A4A52),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    (action['onTap'] as VoidCallback)();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF00D084)
                                                    .withOpacity(0.2),
                                                const Color(0xFF00D084)
                                                    .withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF00D084)
                                                    .withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            action['icon'] as IconData,
                                            color: const Color(0xFF00D084),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                action['title'] as String,
                                                style: const TextStyle(
                                                  color: Color(0xFFFFFFFF),
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                action['subtitle'] as String,
                                                style: const TextStyle(
                                                  color: Color(0xFF6B7C85),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3A4A52),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Color(0xFF6B7C85),
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF253339),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D084).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 28,
                    color: Color(0xFF00D084),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Modifier les informations',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Vous souhaitez modifier les informations de votre véhicule ?',
                  style: TextStyle(
                    color: Color(0xFF6B7C85),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3A4A52)),
                          foregroundColor: const Color(0xFFE0E6ED),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate to edit vehicle screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D084),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Modifier'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Navigation methods
  void _navigateToHistory() {
    // Navigate to history screen
    Navigator.pushNamed(context, '/vehicle_history');
  }

  void _navigateToAddDriver() {
    // Navigate to add driver screen
    Navigator.pushNamed(context, '/conducteur');
  }

  void _navigateToDocuments() {
    // Navigate to documents screen
    Navigator.pushNamed(context, '/vehicle_documents');
  }

  void _navigateToReport() {
    // Navigate to report problem screen
    Navigator.pushNamed(context, '/constat');
  }
}
