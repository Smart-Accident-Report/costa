import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DepanageScreen extends StatefulWidget {
  const DepanageScreen({super.key});

  @override
  _DepanageScreenState createState() => _DepanageScreenState();
}

class _DepanageScreenState extends State<DepanageScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  String selectedService = 'Dépannage Standard';
  String currentLocation = 'Alger Centre, Algérie';
  bool isEmergency = false;

  final List<Map<String, dynamic>> depanageCompanies = [
    {
      'name': 'Dépannage Express Alger',
      'rating': 4.8,
      'reviews': 247,
      'estimatedTime': '15-25 min',
      'price': '3500 DA',
      'distance': '2.3 km',
      'services': ['Remorquage', 'Réparation sur place', 'Batterie'],
      'available24h': true,
      'phoneNumber': '+213 555 123 456',
      'image': 'assets/images/company1.png',
    },
    {
      'name': 'Auto Assistance DZ',
      'rating': 4.6,
      'reviews': 189,
      'estimatedTime': '20-30 min',
      'price': '3200 DA',
      'distance': '3.7 km',
      'services': ['Remorquage', 'Changement de roue', 'Carburant'],
      'available24h': true,
      'phoneNumber': '+213 555 789 012',
      'image': 'assets/images/company2.png',
    },
    {
      'name': 'SOS Panne Auto',
      'rating': 4.9,
      'reviews': 312,
      'estimatedTime': '10-20 min',
      'price': '4000 DA',
      'distance': '1.8 km',
      'services': ['Remorquage', 'Diagnostic', 'Réparation complète'],
      'available24h': true,
      'phoneNumber': '+213 555 345 678',
      'image': 'assets/images/company3.png',
    },
    {
      'name': 'Mécanique Mobile',
      'rating': 4.4,
      'reviews': 156,
      'estimatedTime': '25-35 min',
      'price': '2800 DA',
      'distance': '4.2 km',
      'services': ['Réparation sur place', 'Entretien', 'Pièces détachées'],
      'available24h': false,
      'phoneNumber': '+213 555 901 234',
      'image': 'assets/images/company4.png',
    },
  ];

  final List<String> serviceTypes = [
    'Dépannage Standard',
    'Remorquage',
    'Panne de batterie',
    'Crevaison',
    'Panne sèche',
    'Clés enfermées',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(),
                SliverToBoxAdapter(child: _buildLocationCard()),
                SliverToBoxAdapter(child: _buildServiceSelector()),
                SliverToBoxAdapter(child: _buildEmergencyToggle()),
                SliverToBoxAdapter(child: _buildCompaniesHeader()),
                _buildCompaniesList(),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0F1419),
      elevation: 0,
      pinned: false,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF253339),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A4A52)),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFFE0E6ED)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        'Service Dépannage',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE24A4A),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE24A4A).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.emergency, color: Colors.white),
                  onPressed: () => _showEmergencyDialog(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D084), Color(0xFF00B872)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Votre position actuelle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'GPS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentLocation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showLocationPicker(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_location_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Modifier l\'adresse',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildServiceSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Type de service',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: serviceTypes.length,
              itemBuilder: (context, index) {
                final service = serviceTypes[index];
                final isSelected = service == selectedService;

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 600 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00D084)
                              : const Color(0xFF253339),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00D084)
                                : const Color(0xFF3A4A52),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00D084)
                                        .withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                selectedService = service;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _getServiceIcon(service),
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF00D084),
                                    size: 28,
                                  ),
                                  const Spacer(),
                                  Text(
                                    service,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFE0E6ED),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }

  Widget _buildEmergencyToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF253339),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A4A52)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEmergency
                  ? const Color(0xFFE24A4A)
                  : const Color(0xFF3A4A52),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.priority_high_rounded,
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
                  'Intervention d\'urgence',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Priorité maximale (+50% sur le tarif)',
                  style: TextStyle(
                    color: Color(0xFF6B7C85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEmergency,
            onChanged: (value) {
              HapticFeedback.mediumImpact();
              setState(() {
                isEmergency = value;
              });
            },
            activeColor: const Color(0xFFE24A4A),
            inactiveThumbColor: const Color(0xFF6B7C85),
            inactiveTrackColor: const Color(0xFF3A4A52),
          ),
        ],
      ),
    );
  }

  Widget _buildCompaniesHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Services disponibles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00D084),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${depanageCompanies.length} disponibles',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompaniesList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final company = depanageCompanies[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 800 + (index * 150)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildCompanyCard(company, index),
                ),
              );
            },
          );
        },
        childCount: depanageCompanies.length,
      ),
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company, int index) {
    final basePrice = int.parse(company['price'].replaceAll(' DA', ''));
    final finalPrice = isEmergency ? (basePrice * 1.5).round() : basePrice;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF253339),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A4A52)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showCompanyDetails(company),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00D084).withOpacity(0.2),
                            const Color(0xFF00D084).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Color(0xFF00D084),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  company['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (company['available24h'])
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00D084),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '24H/24',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Color(0xFFFFD700), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${company['rating']}',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${company['reviews']})',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7C85),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Color(0xFF6B7C85), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    company['distance'],
                                    style: const TextStyle(
                                      color: Color(0xFF6B7C85),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A4A52),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.access_time,
                                color: Color(0xFF00D084), size: 20),
                            const SizedBox(height: 4),
                            Text(
                              company['estimatedTime'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Arrivée',
                              style: TextStyle(
                                color: Color(0xFF6B7C85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A4A52),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.attach_money,
                                color: Color(0xFF00D084), size: 20),
                            const SizedBox(height: 4),
                            Text(
                              '$finalPrice DA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration:
                                    isEmergency && finalPrice != basePrice
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            if (isEmergency && finalPrice != basePrice)
                              Text(
                                '${company['price']}',
                                style: const TextStyle(
                                  color: Color(0xFF6B7C85),
                                  fontSize: 10,
                                ),
                              )
                            else
                              const Text(
                                'Estimation',
                                style: TextStyle(
                                  color: Color(0xFF6B7C85),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00D084), Color(0xFF00B872)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00D084).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _bookService(company),
                            child: const Center(
                              child: Text(
                                'Réserver',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4A52),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4A5A62)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _callCompany(company['phoneNumber']),
                          child: const Icon(
                            Icons.phone_rounded,
                            color: Color(0xFF00D084),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String service) {
    switch (service) {
      case 'Dépannage Standard':
        return Icons.build_rounded;
      case 'Remorquage':
        return Icons.local_shipping_rounded;
      case 'Panne de batterie':
        return Icons.battery_alert_rounded;
      case 'Crevaison':
        return Icons.tire_repair_rounded;
      case 'Panne sèche':
        return Icons.local_gas_station_rounded;
      case 'Clés enfermées':
        return Icons.key_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF253339),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Color(0xFFE24A4A)),
            SizedBox(width: 12),
            Text(
              'Urgence',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Composez le 14 pour les services d\'urgence ou contactez directement un dépanneur pour une intervention rapide.',
          style: TextStyle(color: Color(0xFFE0E6ED)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris',
                style: TextStyle(color: Color(0xFF00D084))),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker() {
    // Implementation for location picker
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de géolocalisation en développement'),
        backgroundColor: Color(0xFF00D084),
      ),
    );
  }

  void _showCompanyDetails(Map<String, dynamic> company) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF192228),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A4A52),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00D084).withOpacity(0.2),
                          const Color(0xFF00D084).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Color(0xFF00D084),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Color(0xFFFFD700), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${company['rating']}',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${company['reviews']} avis)',
                              style: const TextStyle(
                                color: Color(0xFF6B7C85),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Services offerts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: (company['services'] as List<String>)
                    .map((service) => _buildServiceChip(service))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailCard(
                      icon: Icons.access_time,
                      label: 'Temps estimé',
                      value: company['estimatedTime'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(
                      icon: Icons.location_on,
                      label: 'Distance',
                      value: company['distance'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'À propos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cette entreprise de dépannage est spécialisée dans les interventions rapides et efficaces. Elle propose un service 24h/24 et 7j/7 pour toutes vos urgences routières.',
                style: TextStyle(
                  color: Color(0xFFE0E6ED),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              _buildBookButton(company),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceChip(String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF253339),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A4A52)),
      ),
      child: Text(
        service,
        style: const TextStyle(
          color: Color(0xFFE0E6ED),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF253339),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A4A52)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00D084), size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7C85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(Map<String, dynamic> company) {
    final basePrice = int.parse(company['price'].replaceAll(' DA', ''));
    final finalPrice = isEmergency ? (basePrice * 1.5).round() : basePrice;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D084), Color(0xFF00B872)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D084).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
            Navigator.pop(context); // Close the bottom sheet
            _bookService(company);
          },
          child: Center(
            child: Text(
              'Réserver pour $finalPrice DA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _callCompany(String phoneNumber) async {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impossible de lancer l\'appel'),
        backgroundColor: Color(0xFFE24A4A),
      ),
    );
  }

  void _bookService(Map<String, dynamic> company) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Réservation de "${company['name']}" confirmée!'),
        backgroundColor: const Color(0xFF00D084),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
