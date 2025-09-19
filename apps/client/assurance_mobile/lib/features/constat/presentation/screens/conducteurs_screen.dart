import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConducteursScreen extends StatefulWidget {
  const ConducteursScreen({super.key});

  @override
  State<ConducteursScreen> createState() => _ConducteursScreenState();
}

class _ConducteursScreenState extends State<ConducteursScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _staggerAnimation;

  bool isGeneratingLink = false;
  String? generatedLink;

  // Mock data for enrolled drivers
  List<Driver> drivers = [
    Driver(
      id: '1',
      name: 'Benali Ahmed',
      email: 'benali.ahmed@email.com',
      phone: '+213 555 123 456',
      licenseNumber: 'DZ123456789',
      joinedDate: DateTime.now().subtract(const Duration(days: 365)),
      isOwner: true,
      status: DriverStatus.active,
    ),
    Driver(
      id: '2',
      name: 'Fatima Bensalem',
      email: 'fatima.bensalem@email.com',
      phone: '+213 555 987 654',
      licenseNumber: 'DZ987654321',
      joinedDate: DateTime.now().subtract(const Duration(days: 120)),
      isOwner: false,
      status: DriverStatus.active,
    ),
    Driver(
      id: '3',
      name: 'Mohamed Kaci',
      email: 'mohamed.kaci@email.com',
      phone: '+213 555 456 789',
      licenseNumber: 'DZ456789123',
      joinedDate: DateTime.now().subtract(const Duration(days: 45)),
      isOwner: false,
      status: DriverStatus.pending,
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
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _staggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeOutCubic,
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
      if (mounted) _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _generateInviteLink() async {
    setState(() {
      isGeneratingLink = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        isGeneratingLink = false;
        generatedLink = 'https://lumiassurance.dz/join/abc123xyz789';
      });

      _showInviteLinkDialog();
    }
  }

  void _showInviteLinkDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF253339),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D084), Color(0xFF00B872)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.link_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Lien d\'invitation',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Partagez ce lien avec le nouveau conducteur. Il sera valable pendant 7 jours.',
              style: TextStyle(
                color: Color(0xFF6B7C85),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3A4A52),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4A5A62),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      generatedLink ?? '',
                      style: const TextStyle(
                        color: Color(0xFFE0E6ED),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: generatedLink ?? ''));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lien copié dans le presse-papiers'),
                          backgroundColor: Color(0xFF00D084),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF00D084),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fermer',
              style: TextStyle(color: Color(0xFF6B7C85)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Share link via other methods
              Navigator.of(context).pop();
              _showShareOptions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D084),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Partager',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF253339),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A4A52),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Partager le lien',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  'Message',
                  Icons.message_rounded,
                  const Color(0xFF4A90E2),
                  () => Navigator.pop(context),
                ),
                _buildShareOption(
                  'Email',
                  Icons.email_rounded,
                  const Color(0xFFE24A4A),
                  () => Navigator.pop(context),
                ),
                _buildShareOption(
                  'WhatsApp',
                  Icons.chat_rounded,
                  const Color(0xFF25D366),
                  () => Navigator.pop(context),
                ),
                _buildShareOption(
                  'Plus',
                  Icons.more_horiz_rounded,
                  const Color(0xFF6B7C85),
                  () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE0E6ED),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _removeDriver(Driver driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF253339),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_rounded,
              color: Color(0xFFE24A4A),
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Retirer le conducteur',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir retirer ${driver.name} de votre assurance ? Cette action ne peut pas être annulée.',
          style: const TextStyle(
            color: Color(0xFF6B7C85),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Color(0xFF6B7C85)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                drivers.removeWhere((d) => d.id == driver.id);
              });
              Navigator.of(context).pop();
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${driver.name} a été retiré'),
                  backgroundColor: const Color(0xFFE24A4A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24A4A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Retirer',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
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
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF253339),
                            foregroundColor: const Color(0xFFE0E6ED),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conducteurs',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Gérez votre équipe de conducteurs',
                                style: TextStyle(
                                  color: Color(0xFF6B7C85),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Add Driver Section
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _staggerAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - _staggerAnimation.value)),
                        child: Opacity(
                          opacity: _staggerAnimation.value,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF00D084),
                                  Color(0xFF00B872),
                                  Color(0xFF009B63)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF00D084).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: isGeneratingLink
                                    ? null
                                    : _generateInviteLink,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: isGeneratingLink
                                            ? const CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              )
                                            : const Icon(
                                                Icons.person_add_alt_1_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isGeneratingLink
                                                  ? 'Génération du lien...'
                                                  : 'Ajouter un conducteur',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isGeneratingLink
                                                  ? 'Veuillez patienter'
                                                  : 'Envoyer une invitation',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isGeneratingLink)
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
                                          size: 20,
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
                  ),
                ),

                // Drivers List Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conducteurs inscrits',
                          style: TextStyle(
                            color: Color(0xFFE0E6ED),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final driver = drivers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: FadeTransition(
                          opacity: _staggerAnimation,
                          child: Transform.translate(
                            offset:
                                Offset(0, 50 * (1 - _staggerAnimation.value)),
                            child: DriverCard(
                              driver: driver,
                              onRemove: () => _removeDriver(driver),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: drivers.length,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Driver Card Widget
  Widget DriverCard({
    required Driver driver,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B262C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF253339),
          width: 1,
        ),
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
                  color: const Color(0xFF3A4A52),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFFE0E6ED),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      driver.licenseNumber,
                      style: const TextStyle(
                        color: Color(0xFF6B7C85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (driver.isOwner)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2A044),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Propriétaire',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            color: Color(0xFF253339),
            thickness: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _getStatusIcon(driver.status),
                color: _getStatusColor(driver.status),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(driver.status),
                style: TextStyle(
                  color: _getStatusColor(driver.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (driver.status != DriverStatus.active)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF253339),
                    foregroundColor: const Color(0xFFE0E6ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Renvoyer l\'invitation',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_rounded),
                color: const Color(0xFFE24A4A),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Enums and Helper Functions
  IconData _getStatusIcon(DriverStatus status) {
    switch (status) {
      case DriverStatus.active:
        return Icons.check_circle_rounded;
      case DriverStatus.pending:
        return Icons.pending_rounded;
      case DriverStatus.inactive:
        return Icons.cancel_rounded;
    }
  }

  Color _getStatusColor(DriverStatus status) {
    switch (status) {
      case DriverStatus.active:
        return const Color(0xFF00D084);
      case DriverStatus.pending:
        return const Color(0xFFE2A044);
      case DriverStatus.inactive:
        return const Color(0xFFE24A4A);
    }
  }

  String _getStatusText(DriverStatus status) {
    switch (status) {
      case DriverStatus.active:
        return 'Actif';
      case DriverStatus.pending:
        return 'En attente';
      case DriverStatus.inactive:
        return 'Inactif';
    }
  }
}

// Model Classes
class Driver {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String licenseNumber;
  final DateTime joinedDate;
  final bool isOwner;
  final DriverStatus status;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.joinedDate,
    required this.isOwner,
    required this.status,
  });
}

enum DriverStatus {
  active,
  pending,
  inactive,
}
