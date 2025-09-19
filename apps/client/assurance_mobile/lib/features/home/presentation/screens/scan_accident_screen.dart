import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

class ScanAccidentScreen extends StatefulWidget {
  final String scanType; // 'qr', 'plate', 'damage', 'draw'
  final Function(Map<String, dynamic>) onScanComplete;

  const ScanAccidentScreen({
    super.key,
    required this.scanType,
    required this.onScanComplete,
  });

  @override
  State<ScanAccidentScreen> createState() => _ScanAccidentScreenState();
}

class _ScanAccidentScreenState extends State<ScanAccidentScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;

  // Camera related
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;

  bool isScanning = false;
  bool isProcessing = false;
  String statusMessage = '';
  List<String> capturedImages = [];
  List<Map<String, dynamic>> drawings = [];
  List<Offset> currentDrawing = [];
  List<List<Offset>> allDrawings = [];

  // Damage scan comments
  final List<String> damageComments = [
    "Parfait ! Maintenant zoomez sur les détails",
    "Excellent angle ! Essayez depuis le côté",
    "Très bien ! Photographiez depuis le haut",
    "Belle prise ! Capturez l'autre côté du dégât",
    "Parfait ! Une vue d'ensemble maintenant",
    "Dernière photo ! Vue générale du véhicule"
  ];

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _initializeScanType();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Only initialize camera for non-drawing scan types
    if (widget.scanType != 'draw') {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        try {
          await _cameraController!.initialize();
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
            });
          }
        } catch (e) {
          print('Error initializing camera: $e');
        }
      }
    }
  }

  void _initializeScanType() {
    switch (widget.scanType) {
      case 'qr':
        statusMessage = 'Positionnez le code QR dans le cadre';
        break;
      case 'plate':
        statusMessage = "Positionnez la plaque d'immatriculation dans le cadre";
        break;
      case 'damage':
        statusMessage = 'Photographiez tous les dégâts visibles';
        break;
      case 'draw':
        statusMessage = "Dessinez la scène d'accident";
        break;
      default:
        statusMessage = 'Prêt à scanner';
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  String _getTitle() {
    switch (widget.scanType) {
      case 'qr':
        return 'Scanner le code QR';
      case 'plate':
        return "Scanner la plaque d'immatriculation";
      case 'damage':
        return 'Documenter les dégâts';
      case 'draw':
        return "Dessiner l'accident";
      default:
        return 'Scanner';
    }
  }

  String _getInstruction() {
    switch (widget.scanType) {
      case 'qr':
        return 'Demandez à l\'autre conducteur d\'afficher son code QR et positionnez-le dans le cadre ci-dessous.';
      case 'plate':
        return 'Positionnez la plaque d\'immatriculation de l\'autre véhicule dans le cadre pour extraire automatiquement les informations.';
      case 'damage':
        return 'Prenez des photos claires de tous les dégâts sur les deux véhicules. Appuyez sur le bouton pour capturer chaque angle.';
      case 'draw':
        return 'Utilisez vos doigts pour dessiner la scène d\'accident. Montrez la position des véhicules et la direction du mouvement.';
      default:
        return 'Suivez les instructions à l\'écran.';
    }
  }

  void _startScanning() {
    setState(() {
      isScanning = true;
      statusMessage = _getScanningMessage();
    });

    _scanController.repeat();
    HapticFeedback.lightImpact();

    // Simulate scanning process
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _processScan();
      }
    });
  }

  String _getScanningMessage() {
    switch (widget.scanType) {
      case 'qr':
        return 'Recherche du code QR...';
      case 'plate':
        return 'Lecture de la plaque...';
      case 'damage':
        return 'Analyse des dégâts...';
      case 'draw':
        return 'Traitement du dessin...';
      default:
        return 'Scan en cours...';
    }
  }

  void _processScan() {
    setState(() {
      isScanning = false;
      isProcessing = true;
      statusMessage = 'Traitement en cours...';
    });

    _scanController.stop();

    // Longer processing time (5+ seconds)
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        _completeScan();
      }
    });
  }

  void _completeScan() {
    Map<String, dynamic> result = {};

    switch (widget.scanType) {
      case 'qr':
        result = {
          'type': 'qr',
          'data': {
            'driverId': 'DR123456789',
            'name': 'Jean Dupont',
            'insurance': 'Assurance XYZ',
            'policyNumber': 'POL789456123',
          },
        };
        break;
      case 'plate':
        result = {
          'type': 'plate',
          'data': {
            'plateNumber': 'AB-123-CD',
            'vehicleMake': 'Renault',
            'vehicleModel': 'Clio',
            'year': '2020',
          },
        };
        break;
      case 'damage':
        result = {
          'type': 'damage',
          'data': {
            'images': capturedImages,
            'damageAreas': [
              'Pare-chocs avant',
              'Phare gauche',
              'Aile avant gauche'
            ],
            'severity': 'Modéré',
          },
        };
        break;
      case 'draw':
        result = {
          'type': 'draw',
          'data': {
            'drawing': allDrawings,
            'description': 'Collision frontale à l\'intersection',
            'vehicles': 2,
          },
        };
        break;
    }

    setState(() {
      isProcessing = false;
      statusMessage = 'Terminé avec succès !';
    });

    // Complete the scan after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onScanComplete(result);
        Navigator.pop(context);
      }
    });
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile image = await _cameraController!.takePicture();
        setState(() {
          capturedImages.add(image.path);
        });
        HapticFeedback.lightImpact();

        // Show progressive comment based on capture count
        String comment = '';
        if (capturedImages.length <= damageComments.length) {
          comment = damageComments[capturedImages.length - 1];
        } else {
          comment = 'Image ${capturedImages.length} capturée';
        }

        // Show success feedback with progressive comments
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(comment),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Auto-complete after 6 images
        if (capturedImages.length >= 6) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _completeScan();
            }
          });
        }
      } catch (e) {
        print('Error taking picture: $e');
      }
    } else {
      // Fallback for when camera is not available
      setState(() {
        capturedImages.add('image_${capturedImages.length + 1}.jpg');
      });
      HapticFeedback.lightImpact();

      String comment = '';
      if (capturedImages.length <= damageComments.length) {
        comment = damageComments[capturedImages.length - 1];
      } else {
        comment = 'Image ${capturedImages.length} capturée';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(comment),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      if (capturedImages.length >= 6) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _completeScan();
          }
        });
      }
    }
  }

  void _clearDrawing() {
    setState(() {
      currentDrawing.clear();
      allDrawings.clear();
    });
  }

  void _undoLastStroke() {
    if (allDrawings.isNotEmpty) {
      setState(() {
        allDrawings.removeLast();
      });
    }
  }

  void _finishDrawing() {
    if (allDrawings.isNotEmpty) {
      _completeScan();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Veuillez dessiner la scène d\'accident avant de continuer'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getTitle(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Text(
                _getInstruction(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Main Content Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isScanning
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600]!,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildScanContent(),
                ),
              ),
            ),

            // Status Message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                statusMessage,
                style: TextStyle(
                  color: isProcessing
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanContent() {
    switch (widget.scanType) {
      case 'qr':
        return _buildQRScanView();
      case 'plate':
        return _buildPlateScanView();
      case 'damage':
        return _buildDamageScanView();
      case 'draw':
        return _buildDrawView();
      default:
        return _buildDefaultScanView();
    }
  }

  Widget _buildCameraView() {
    if (_cameraController != null && _isCameraInitialized) {
      return CameraPreview(_cameraController!);
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initialisation de la caméra...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildQRScanView() {
    return Stack(
      children: [
        // Camera view
        _buildCameraView(),

        // QR Code overlay
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner brackets
                ...List.generate(4, (index) {
                  return Positioned(
                    top: index < 2 ? 0 : null,
                    bottom: index >= 2 ? 0 : null,
                    left: index % 2 == 0 ? 0 : null,
                    right: index % 2 == 1 ? 0 : null,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          top: index < 2
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 4,
                                )
                              : BorderSide.none,
                          bottom: index >= 2
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 4,
                                )
                              : BorderSide.none,
                          left: index % 2 == 0
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 4,
                                )
                              : BorderSide.none,
                          right: index % 2 == 1
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 4,
                                )
                              : BorderSide.none,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Scanning line animation
        if (isScanning)
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(
                top: 50 +
                    (MediaQuery.of(context).size.height * 0.4 - 100) *
                        _scanAnimation.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPlateScanView() {
    return Stack(
      children: [
        // Camera view
        _buildCameraView(),

        // License plate overlay
        Center(
          child: Container(
            width: 300,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'PLAQUE D\'IMMATRICULATION',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        // Scanning overlay
        if (isScanning)
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.3 +
                    (100 * _scanAnimation.value),
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDamageScanView() {
    return Stack(
      children: [
        // Camera view
        _buildCameraView(),

        // Captured images overlay
        if (capturedImages.isNotEmpty)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${capturedImages.length}/6 images capturées',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),

        // Progress indicator
        if (capturedImages.isNotEmpty)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${capturedImages.length}/6',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        // Camera focus indicator
        if (!isScanning)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Center(
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDrawView() {
    return Stack(
      children: [
        // Drawing canvas
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                currentDrawing = [details.localPosition];
              });
            },
            onPanUpdate: (details) {
              setState(() {
                currentDrawing.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              setState(() {
                allDrawings.add(List.from(currentDrawing));
                currentDrawing.clear();
              });
            },
            child: CustomPaint(
              painter: DrawingPainter(
                drawings: allDrawings,
                currentDrawing: currentDrawing,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // Drawing tools
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton(
                mini: true,
                heroTag: "undo",
                onPressed: _undoLastStroke,
                backgroundColor: Colors.black87,
                child: const Icon(Icons.undo, color: Colors.white),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                heroTag: "clear",
                onPressed: _clearDrawing,
                backgroundColor: Colors.black87,
                child: const Icon(Icons.clear, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultScanView() {
    return _buildCameraView();
  }

  Widget _buildActionButtons() {
    if (widget.scanType == 'draw') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearDrawing,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Effacer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isProcessing ? null : _finishDrawing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text(
                      'Terminer',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      );
    }

    if (widget.scanType == 'damage') {
      return Column(
        children: [
          // Capture button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: GestureDetector(
                  onTap: capturedImages.length >= 6 ? null : _captureImage,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: capturedImages.length >= 6
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Icon(
                      capturedImages.length >= 6
                          ? Icons.check
                          : Icons.camera_alt,
                      size: 32,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (capturedImages.isNotEmpty && capturedImages.length < 6)
            Text(
              'Continue de photographier (${capturedImages.length}/6)',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          if (capturedImages.length >= 6)
            const Text(
              'Toutes les photos sont prises !',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      );
    }

    // For QR and plate scanning
    return ElevatedButton(
      onPressed: (isScanning || isProcessing) ? null : _startScanning,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: (isScanning || isProcessing)
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isScanning ? 'Scan en cours...' : 'Traitement...',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : const Text(
              'Commencer le scan',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> drawings;
  final List<Offset> currentDrawing;

  DrawingPainter({required this.drawings, required this.currentDrawing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw completed drawings
    for (final drawing in drawings) {
      if (drawing.length > 1) {
        final path = Path();
        path.moveTo(drawing.first.dx, drawing.first.dy);
        for (int i = 1; i < drawing.length; i++) {
          path.lineTo(drawing[i].dx, drawing[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Draw current drawing
    if (currentDrawing.length > 1) {
      final path = Path();
      path.moveTo(currentDrawing.first.dx, currentDrawing.first.dy);
      for (int i = 1; i < currentDrawing.length; i++) {
        path.lineTo(currentDrawing[i].dx, currentDrawing[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
