// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

// ignore: must_be_immutable
class CameraScanScreen extends StatefulWidget {
  final String documentType;

  const CameraScanScreen({
    super.key,
    required this.documentType,
  });

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _cornerController;
  late AnimationController _successController;

  late Animation<double> _scanLineAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _cornerAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successOpacityAnimation;

  bool _isScanning = false;
  bool _isProcessing = false;
  bool _scanComplete = false;

  Timer? _scanTimer;
  Timer? _processingTimer;

  // New camera-related properties
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {});
          _startScanning();
        }
      }
    } on CameraException catch (e) {
      // Handle camera initialization errors
      debugPrint('Error initializing camera: $e');
    }
  }

  void _setupAnimations() {
    // Scan line animation
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for the scanning border
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Corner animation
    _cornerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cornerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cornerController,
      curve: Curves.elasticOut,
    ));

    // Success animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _successScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));
    _successOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.easeIn,
    ));
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    // Start animations
    _cornerController.forward();
    _scanLineController.repeat();
    _pulseController.repeat(reverse: true);

    // Simulate scanning completion after 3 seconds
    _scanTimer = Timer(const Duration(seconds: 3), () {
      _completeScanning();
    });
  }

  void _completeScanning() {
    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _isProcessing = true;
    });

    // Stop scanning animations
    _scanLineController.stop();
    _pulseController.stop();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Start success animation
    _successController.forward();

    // Process the document (simulate processing time)
    _processingTimer = Timer(const Duration(seconds: 2), () {
      _returnWithResults();
    });
  }

  void _returnWithResults() {
    if (!mounted) return;

    setState(() {
      _scanComplete = true;
    });

    // Generate mock data based on document type
    final Map<String, dynamic> mockData = _generateMockData();

    // Return to previous screen with results
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop(mockData);
      }
    });
  }

  Map<String, dynamic> _generateMockData() {
    if (widget.documentType == 'carte_grise') {
      return {
        'marque': 'Peugeot',
        'modele': '208',
        'annee': '2020',
        'wilaya': 'Alger',
        'num_chassis': 'VF3XXXXXXXXXXXXXXX',
        'energie': 'Essence',
        'type_matricule': 'permanent 11 digits',
      };
    } else if (widget.documentType == 'permis_conduire') {
      return {
        'nom': 'Benali',
        'prenom': 'Ahmed',
        'date_naissance': '15/03/1990',
        'num_permis': 'DZ123456789',
        'date_permis': '20/05/2015',
        'type_permis': 'B',
      };
    }
    return {};
  }

  String _getDocumentTitle() {
    switch (widget.documentType) {
      case 'carte_grise':
        return 'Carte Grise';
      case 'permis_conduire':
        return 'Permis de Conduire';
      default:
        return 'Document';
    }
  }

  IconData _getDocumentIcon() {
    switch (widget.documentType) {
      case 'carte_grise':
        return Icons.directions_car;
      case 'permis_conduire':
        return Icons.credit_card;
      default:
        return Icons.document_scanner;
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    _cornerController.dispose();
    _successController.dispose();
    _scanTimer?.cancel();
    _processingTimer?.cancel();
    _cameraController?.dispose(); // Dispose of the camera controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      // You can return a loading indicator while the camera is initializing
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Scanner ${_getDocumentTitle()}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera preview background
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),

          // Scanning overlay
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: [
                  // Document frame
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isScanning ? _pulseAnimation.value : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isScanning
                                  ? Theme.of(context).colorScheme.primary
                                  : _scanComplete
                                      ? Colors.green
                                      : Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: _isScanning || _scanComplete
                                ? [
                                    BoxShadow(
                                      color: (_scanComplete
                                              ? Colors.green
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary)
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    },
                  ),

                  // Corner indicators
                  AnimatedBuilder(
                    animation: _cornerAnimation,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          // Top-left corner
                          Positioned(
                            top: -2,
                            left: -2,
                            child: Transform.scale(
                              scale: _cornerAnimation.value,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 4,
                                    ),
                                    left: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Top-right corner
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Transform.scale(
                              scale: _cornerAnimation.value,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 4,
                                    ),
                                    right: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Bottom-left corner
                          Positioned(
                            bottom: -2,
                            left: -2,
                            child: Transform.scale(
                              scale: _cornerAnimation.value,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 4,
                                    ),
                                    left: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Bottom-right corner
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Transform.scale(
                              scale: _cornerAnimation.value,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 4,
                                    ),
                                    right: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Scanning line
                  if (_isScanning)
                    AnimatedBuilder(
                      animation: _scanLineAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: MediaQuery.of(context).size.height *
                                  0.6 *
                                  _scanLineAnimation.value -
                              2,
                          left: 8,
                          right: 8,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Theme.of(context).colorScheme.primary,
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // Document icon in center
                  Center(
                    child: AnimatedOpacity(
                      opacity: _isScanning ? 0.3 : 0.6,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _getDocumentIcon(),
                        size: 80,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Success checkmark
          if (_isProcessing || _scanComplete)
            Center(
              child: AnimatedBuilder(
                animation: _successController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _successScaleAnimation.value,
                    child: Opacity(
                      opacity: _successOpacityAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Bottom instruction panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _buildStatusWidget(),
                  ),
                  const SizedBox(height: 16),
                  if (_isScanning)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Analyse en cours...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Processing overlay
          if (_isProcessing && !_scanComplete)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Traitement du document...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Extraction des données en cours',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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

  Widget _buildStatusWidget() {
    if (_scanComplete) {
      return const Column(
        key: ValueKey('complete'),
        children: [
          Text(
            'Document scanné avec succès!',
            style: TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'Retour automatique...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (_isProcessing) {
      return Column(
        key: const ValueKey('processing'),
        children: [
          Text(
            'Document détecté!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Extraction des informations...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return Column(
        key: const ValueKey('scanning'),
        children: [
          Text(
            'Placez votre ${_getDocumentTitle().toLowerCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'dans le cadre et maintenez-le stable',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }
}