import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConstatScreen extends StatefulWidget {
  const ConstatScreen({super.key});

  @override
  State<ConstatScreen> createState() => _ConstatScreenState();
}

class _ConstatScreenState extends State<ConstatScreen>
    with TickerProviderStateMixin {
  late AnimationController _mascotController;
  late AnimationController _timelineController;
  late Animation<double> _mascotAnimation;
  late Animation<double> _timelineAnimation;

  int currentStep = 0;
  bool isRecording = false;
  bool isProcessing = false;

  final List<ConstatStep> steps = [
    ConstatStep(
      title: "Scan Other Driver",
      description:
          "Let's start by getting the other driver's information. You can scan their QR code if they have the app, or scan their license plate.",
      icon: Icons.qr_code_scanner,
      completed: false,
    ),
    ConstatStep(
      title: "Scan Vehicle Damage",
      description:
          "Now, let's document the damage to both vehicles. Take photos of all damaged areas.",
      icon: Icons.camera_alt,
      completed: false,
    ),
    ConstatStep(
      title: "Draw the Accident",
      description:
          "Help me understand what happened by drawing the accident scene using our drag and drop tools.",
      icon: Icons.draw,
      completed: false,
    ),
    ConstatStep(
      title: "Review & Submit",
      description:
          "Perfect! Let's review everything and submit your constat for processing.",
      icon: Icons.check_circle,
      completed: false,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _mascotController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _timelineController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _mascotAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _mascotController,
      curve: Curves.easeInOut,
    ));

    _timelineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _timelineController,
      curve: Curves.easeOutCubic,
    ));

    _timelineController.forward();
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        steps[currentStep].completed = true;
        currentStep++;
      });
      HapticFeedback.lightImpact();
    } else {
      _submitConstat();
    }
  }

  void _submitConstat() {
    setState(() {
      steps[currentStep].completed = true;
      isProcessing = true;
    });

    // Simulate processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Constat Submitted!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        content: Text(
          'Your constat has been submitted successfully and is now under review. You\'ll receive updates on its status.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _toggleRecording() {
    setState(() {
      isRecording = !isRecording;
    });

    HapticFeedback.mediumImpact();

    if (isRecording) {
      // Start voice recording logic here
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isRecording = false;
          });
        }
      });
    }
  }

  void _navigateToStepAction() {
    switch (currentStep) {
      case 0:
        _navigateToScanDriver();
        break;
      case 1:
        _navigateToScanDamage();
        break;
      case 2:
        _navigateToDrawAccident();
        break;
      case 3:
        _nextStep();
        break;
    }
  }

  void _navigateToScanDriver() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
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
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Scan Other Driver',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'QR Code',
                    'Other driver has the app',
                    Icons.qr_code_scanner,
                    () {
                      Navigator.pop(context);
                      _simulateQRScan();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    'License Plate',
                    'Scan license plate',
                    Icons.directions_car,
                    () {
                      Navigator.pop(context);
                      _simulatePlateScan();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToScanDamage() {
    // Navigate to ScanAccidentScreen or show camera interface
    _simulateDamageScan();
  }

  void _navigateToDrawAccident() {
    // Navigate to drawing interface
    _simulateDrawingAccident();
  }

  void _simulateQRScan() {
    setState(() => isProcessing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isProcessing = false);
        _showInfoExtractedDialog("QR Code scanned successfully!");
        _nextStep();
      }
    });
  }

  void _simulatePlateScan() {
    setState(() => isProcessing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isProcessing = false);
        _showInfoExtractedDialog("License plate information extracted!");
        _nextStep();
      }
    });
  }

  void _simulateDamageScan() {
    setState(() => isProcessing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isProcessing = false);
        _showInfoExtractedDialog("Vehicle damage documented!");
        _nextStep();
      }
    });
  }

  void _simulateDrawingAccident() {
    setState(() => isProcessing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isProcessing = false);
        _showInfoExtractedDialog("Accident scene drawn successfully!");
        _nextStep();
      }
    });
  }

  void _showInfoExtractedDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildActionCard(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Constat',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              'Step ${currentStep + 1} of ${steps.length}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Timeline
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Mascot Section
                        AnimatedBuilder(
                          animation: _mascotAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _mascotAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Mascot Avatar
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.support_agent,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Lumi Assistant',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      steps[currentStep].description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Timeline Steps
                        AnimatedBuilder(
                          animation: _timelineAnimation,
                          builder: (context, child) {
                            return Column(
                              children: List.generate(
                                steps.length,
                                (index) => _buildTimelineStep(index),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Action Buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Voice Recording Button
                      GestureDetector(
                        onTap: _toggleRecording,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isRecording
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isRecording
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).dividerColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            color: isRecording
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Main Action Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              isProcessing ? null : _navigateToStepAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isProcessing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Processing...'),
                                  ],
                                )
                              : Text(
                                  currentStep < steps.length - 1
                                      ? 'Continue'
                                      : 'Submit Constat',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(int index) {
    final step = steps[index];
    final isActive = index == currentStep;
    final isCompleted = step.completed;
    final isPending = index > currentStep;

    return Opacity(
      opacity: _timelineAnimation.value,
      child: Transform.translate(
        offset: Offset(0, (1 - _timelineAnimation.value) * 50),
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : isActive
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2)
                              : Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted || isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : step.icon,
                      color: isCompleted
                          ? Colors.black
                          : isActive
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                  if (index < steps.length - 1)
                    Container(
                      width: 2,
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Step content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).cardColor
                        : Theme.of(context).cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: isActive
                        ? Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isPending
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6)
                                      : null,
                                ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Current step',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                      if (isCompleted) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConstatStep {
  final String title;
  final String description;
  final IconData icon;
  bool completed;

  ConstatStep({
    required this.title,
    required this.description,
    required this.icon,
    this.completed = false,
  });
}
