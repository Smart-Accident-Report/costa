import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MesConstatsScreen extends StatefulWidget {
  const MesConstatsScreen({super.key});

  @override
  State<MesConstatsScreen> createState() => _MesConstatsScreenState();
}

class _MesConstatsScreenState extends State<MesConstatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  String selectedFilter = 'Tous';
  final List<String> filters = ['Tous', 'En cours', 'Terminé', 'En attente'];

  // Sample data for constats
  final List<ConstatItem> constats = [
    ConstatItem(
      id: '2024-003',
      status: 'En cours',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      location: 'Avenue de l\'Indépendance, Alger',
      otherDriver: 'Mohammed Benaissa',
      vehicleType: 'Renault Clio',
      statusColor: const Color(0xFFE2A044),
      description: 'Collision légère à Ardis',
      completionPercentage: 75,
    ),
    ConstatItem(
      id: '2024-002',
      status: 'Terminé',
      date: DateTime.now().subtract(const Duration(days: 3)),
      location: 'L\'foire d\'Alger',
      otherDriver: 'Fatima Zohra',
      vehicleType: 'Peugeot 208',
      statusColor: const Color(0xFF00D084),
      description: 'Accrochage lors d\'un stationnement',
      completionPercentage: 100,
    ),
    ConstatItem(
      id: '2024-001',
      status: 'En attente',
      date: DateTime.now().subtract(const Duration(days: 7)),
      location: 'Route de Dar el beida, Alger',
      otherDriver: 'Ahmed Mansouri',
      vehicleType: 'Toyota Yaris',
      statusColor: const Color(0xFF4A90E2),
      description: 'Dommages au pare-chocs arrière',
      completionPercentage: 45,
    ),
    ConstatItem(
      id: '2023-158',
      status: 'Terminé',
      date: DateTime.now().subtract(const Duration(days: 30)),
      location: 'Centre-ville, Alger',
      otherDriver: 'Karim Belhadj',
      vehicleType: 'Hyundai i20',
      statusColor: const Color(0xFF00D084),
      description: 'Rayure sur la portière côté conducteur',
      completionPercentage: 100,
    ),
  ];

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

  List<ConstatItem> get filteredConstats {
    if (selectedFilter == 'Tous') {
      return constats;
    }
    return constats
        .where((constat) => constat.status == selectedFilter)
        .toList();
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
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),
                SliverToBoxAdapter(
                  child: _buildStatsOverview(),
                ),
                SliverToBoxAdapter(
                  child: _buildFilters(),
                ),
                SliverToBoxAdapter(
                  child: _buildConstatsList(),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -2 * _floatingAnimation.value),
            child: FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pushNamed('/constat');
              },
              backgroundColor: const Color(0xFF00D084),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text(
                'Nouveau Constat',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -2 * _floatingAnimation.value),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF253339),
                        foregroundColor: const Color(0xFFE0E6ED),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFE0E6ED)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              'Mes Constats',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Gérez tous vos constats d\'accident',
                            style: TextStyle(
                              color: Color(0xFF6B7C85),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
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
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showSearchDialog();
                          },
                          child: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFFE0E6ED),
                            size: 22,
                          ),
                        ),
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

  Widget _buildStatsOverview() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _staggerController.value)),
          child: Opacity(
            opacity: _staggerController.value,
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      '${constats.length}',
                      Icons.description_rounded,
                      const Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'En cours',
                      '${constats.where((c) => c.status == 'En cours').length}',
                      Icons.pending_actions_rounded,
                      const Color(0xFFE2A044),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Terminés',
                      '${constats.where((c) => c.status == 'Terminé').length}',
                      Icons.check_circle_rounded,
                      const Color(0xFF00D084),
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

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7C85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
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
                    'Filtrer par statut',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: filters.map((filter) {
                        final isSelected = filter == selectedFilter;
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setState(() {
                                  selectedFilter = filter;
                                });
                                HapticFeedback.lightImpact();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF00D084),
                                            Color(0xFF00B872),
                                          ],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : const Color(0xFF253339),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : const Color(0xFF3A4A52),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : const Color(0xFFE0E6ED),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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

  Widget _buildConstatsList() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _staggerController.value)),
          child: Opacity(
            opacity: _staggerController.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Liste des constats',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${filteredConstats.length} résultat${filteredConstats.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Color(0xFF6B7C85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...filteredConstats.asMap().entries.map((entry) {
                    final index = entry.key;
                    final constat = entry.value;
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 600 + (index * 150)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(30 * (1 - value), 0),
                          child: Opacity(
                            opacity: value,
                            child: _buildConstatCard(constat, index),
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

  Widget _buildConstatCard(ConstatItem constat, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            _showConstatDetails(constat);
          },
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            constat.statusColor.withOpacity(0.2),
                            constat.statusColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: constat.statusColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: constat.statusColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Constat #${constat.id}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: constat.statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: constat.statusColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  constat.status,
                                  style: TextStyle(
                                    color: constat.statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            constat.description,
                            style: const TextStyle(
                              color: Color(0xFF6B7C85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: const Color(0xFF6B7C85),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        constat.location,
                        style: const TextStyle(
                          color: Color(0xFF6B7C85),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: const Color(0xFF6B7C85),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      constat.otherDriver,
                      style: const TextStyle(
                        color: Color(0xFF6B7C85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.directions_car_outlined,
                      color: const Color(0xFF6B7C85),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      constat.vehicleType,
                      style: const TextStyle(
                        color: Color(0xFF6B7C85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (constat.status != 'Terminé') ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progression',
                            style: TextStyle(
                              color: Color(0xFF6B7C85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${constat.completionPercentage}%',
                            style: TextStyle(
                              color: constat.statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: constat.completionPercentage / 100,
                          backgroundColor: const Color(0xFF3A4A52),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            constat.statusColor,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(constat.date),
                      style: const TextStyle(
                        color: Color(0xFF6B7C85),
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Voir détails',
                          style: TextStyle(
                            color: Color(0xFF00D084),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF00D084),
                          size: 12,
                        ),
                      ],
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF253339),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Rechercher un constat',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Numéro de constat, nom du conducteur...',
            hintStyle: const TextStyle(color: Color(0xFF6B7C85)),
            filled: true,
            fillColor: const Color(0xFF3A4A52),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF6B7C85),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Color(0xFF6B7C85)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D084),
              foregroundColor: Colors.black,
            ),
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  void _showConstatDetails(ConstatItem constat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF253339),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4A52),
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: 20),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        constat.statusColor.withOpacity(0.2),
                        constat.statusColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: constat.statusColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Constat #${constat.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Créé le ${_formatDate(constat.date)}',
                      style: const TextStyle(
                        color: Color(0xFF6B7C85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              'Statut',
              constat.status,
              constat.statusColor,
              isStatus: true,
            ),
            _buildDetailRow(
              'Description',
              constat.description,
              const Color(0xFFE0E6ED),
            ),
            _buildDetailRow(
              'Conducteur adverse',
              constat.otherDriver,
              const Color(0xFFE0E6ED),
            ),
            _buildDetailRow(
              'Véhicule adverse',
              constat.vehicleType,
              const Color(0xFFE0E6ED),
            ),
            _buildDetailRow(
              'Lieu de l\'accident',
              constat.location,
              const Color(0xFFE0E6ED),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Action to open constat in edit mode or view
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D084),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                icon: const Icon(Icons.edit_rounded, size: 20),
                label: const Text(
                  'Modifier le constat',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor,
      {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7C85),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: valueColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: valueColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final constatDate = DateTime(date.year, date.month, date.day);

    if (constatDate == today) {
      return 'Aujourd\'hui à ${DateFormat('HH:mm').format(date)}';
    } else if (constatDate == yesterday) {
      return 'Hier à ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy à HH:mm').format(date);
    }
  }
}

class ConstatItem {
  final String id;
  final String status;
  final DateTime date;
  final String location;
  final String otherDriver;
  final String vehicleType;
  final Color statusColor;
  final String description;
  final int completionPercentage;

  ConstatItem({
    required this.id,
    required this.status,
    required this.date,
    required this.location,
    required this.otherDriver,
    required this.vehicleType,
    required this.statusColor,
    required this.description,
    required this.completionPercentage,
  });
}
