import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'scan_accident_screen.dart';

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
  String? selectedScanType;
  late Deepgram deepgram;
  late FlutterTts flutterTts;
  bool isListening = false;
  bool isSpeaking = false;
  int currentQuestionIndex = 0;
  late final AudioRecorder _audioRecorder;
  DeepgramLiveListener? _deepgramListener;

  List<String> accidentQuestions = [
    "Bonjour ! Je suis votre assistant Lumi. Pouvez-vous me décrire comment l'accident s'est produit ?",
    "Où étiez-vous au moment de l'accident ? Sur quelle route ou intersection ?",
    "À quelle heure approximativement l'accident a-t-il eu lieu ?",
    "Quelles étaient les conditions météorologiques au moment de l'accident ?",
    "Y a-t-il eu des blessés dans cet accident ?",
    "Avez-vous d'autres détails importants à ajouter concernant l'accident ?",
    "Merci pour ces informations. Votre déclaration a été enregistrée avec succès."
  ];
  List<String> userResponses = [];

  final List<ConstatStep> steps = [
    ConstatStep(
      title: "Scanner l'autre conducteur",
      description:
          "Commençons par obtenir les informations de l'autre conducteur. Vous pouvez scanner son QR code s'il a l'application, ou scanner sa plaque d'immatriculation.",
      icon: Icons.qr_code_scanner,
      completed: false,
    ),
    ConstatStep(
      title: "Scanner les dégâts du véhicule",
      description:
          "Maintenant, documentons les dégâts sur les deux véhicules. Prenez des photos de toutes les zones endommagées.",
      icon: Icons.camera_alt,
      completed: false,
    ),
    ConstatStep(
      title: "Dessiner l'accident",
      description:
          "Aidez-moi à comprendre ce qui s'est passé en dessinant la scène d'accident avec nos outils de glisser-déposer.",
      icon: Icons.draw,
      completed: false,
    ),
    ConstatStep(
      title: "Réviser et soumettre",
      description:
          "Parfait ! Révisons tout et soumettons votre constat pour traitement.",
      icon: Icons.check_circle,
      completed: false,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _audioRecorder = AudioRecorder();

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
    _initializeSpeechAndTTS();
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _timelineController.dispose();
    flutterTts.stop();
    _audioRecorder.dispose();
    _deepgramListener?.close();
    super.dispose();
  }

  void _initializeSpeechAndTTS() async {
    // Initialize Deepgram Speech-to-Text
    deepgram = Deepgram('YOUR_DEEPGRAM_API_KEY');

    // Initialize Flutter TTS
    flutterTts = FlutterTts();
    await flutterTts.setLanguage('fr-FR');
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.5);

    // Set TTS completion callback
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
      if (currentQuestionIndex < accidentQuestions.length - 1) {
        _startListening();
      }
    });
  }

  Future<void> _speakText(String text) async {
    setState(() {
      isSpeaking = true;
    });
    await flutterTts.speak(text);
  }

  Future<void> _startListening() async {
    try {
      setState(() {
        isListening = true;
      });

      if (await _audioRecorder.hasPermission()) {
        final sttStreamParams = {
          'model': 'nova-2-general',
          'language': 'fr',
          'smart_format': true,
          'interim_results': false,
        };

        final micStream = await _audioRecorder.startStream(RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ));

        _deepgramListener = deepgram.listen
            .liveListener(micStream, queryParams: sttStreamParams);

        _deepgramListener!.stream.listen((result) {
          if (result.isFinal &&
              result.transcript != null &&
              result.transcript!.isNotEmpty) {
            _handleSpeechResult(result.transcript!);
            _deepgramListener
                ?.close(); // Close the listener after a final result
          }
        });

        _deepgramListener!.start();
      } else {
        print('Microphone permission not granted');
        setState(() {
          isListening = false;
        });
      }
    } catch (e) {
      print('Error during speech recognition: $e');
      setState(() {
        isListening = false;
      });
    }
  }

  void _handleSpeechResult(String transcript) {
    userResponses.add(transcript);
    currentQuestionIndex++;

    if (currentQuestionIndex < accidentQuestions.length) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _speakText(accidentQuestions[currentQuestionIndex]);
      });
    } else {
      // Interview completed
      Navigator.of(context).pop();
      _showInterviewCompletedDialog();
    }
  }

  void _showInterviewCompletedDialog() {
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
              'Entretien terminé !',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        content: Text(
          'Votre déclaration vocale a été enregistrée avec succès. Ces informations complètent votre constat d\'accident.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        steps[currentStep].completed = true;
        currentStep++;
        selectedScanType = null; // Reset scan type for new step
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
              'Constat soumis !',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        content: Text(
          'Votre constat a été soumis avec succès et est maintenant en cours de révision. Vous recevrez des mises à jour sur son statut.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Terminé'),
          ),
        ],
      ),
    );
  }

  void _toggleRecording() {
    // Check if all steps are completed before allowing voice interview
    bool allStepsCompleted =
        steps.take(steps.length - 1).every((step) => step.completed);

    if (!allStepsCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Veuillez d\'abord terminer toutes les étapes avant de commencer l\'entretien vocal.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    _showVoiceInterviewDialog();
  }

  // Add this new method
  void _showVoiceInterviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  Icons.record_voice_over,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Entretien vocal',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isListening
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : isSpeaking
                            ? Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.2)
                            : Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isListening
                          ? Theme.of(context).colorScheme.primary
                          : isSpeaking
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isListening
                        ? Icons.mic
                        : isSpeaking
                            ? Icons.volume_up
                            : Icons.support_agent,
                    size: 40,
                    color: isListening
                        ? Theme.of(context).colorScheme.primary
                        : isSpeaking
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isListening
                      ? 'Je vous écoute...'
                      : isSpeaking
                          ? 'Assistant Lumi parle...'
                          : 'Prêt à commencer l\'entretien',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Question ${currentQuestionIndex + 1} sur ${accidentQuestions.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (isListening || isSpeaking)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              if (currentQuestionIndex == 0 && !isListening && !isSpeaking)
                ElevatedButton(
                  onPressed: () {
                    _speakText(accidentQuestions[currentQuestionIndex]);
                  },
                  child: const Text('Commencer'),
                ),
              TextButton(
                onPressed: () {
                  flutterTts.stop();
                  _deepgramListener?.close();
                  setState(() {
                    isListening = false;
                    isSpeaking = false;
                    currentQuestionIndex = 0;
                    userResponses.clear();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Annuler'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToStepAction() {
    switch (currentStep) {
      case 0:
        _navigateToScanDriver();
        break;
      case 1:
        _navigateToScanScreen('damage');
        break;
      case 2:
        _navigateToScanScreen('draw');
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
              "Scanner l'autre conducteur",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Code QR',
                    "L'autre conducteur a l'application",
                    Icons.qr_code_scanner,
                    () {
                      Navigator.pop(context);
                      _navigateToScanScreen('qr');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    "Plaque d'immatriculation",
                    "Scanner la plaque d'immatriculation",
                    Icons.directions_car,
                    () {
                      Navigator.pop(context);
                      _navigateToScanScreen('plate');
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

  void _navigateToScanScreen(String scanType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanAccidentScreen(
          scanType: scanType,
          onScanComplete: (result) {
            // Handle scan result
            _handleScanResult(scanType, result);
          },
        ),
      ),
    );
  }

  void _handleScanResult(String scanType, Map<String, dynamic> result) {
    String message;
    switch (scanType) {
      case 'qr':
        message = "Code QR scanné avec succès !";
        break;
      case 'plate':
        message = "Informations de la plaque d'immatriculation extraites !";
        break;
      case 'damage':
        message = "Dégâts du véhicule documentés !";
        break;
      case 'draw':
        message = "Scène d'accident dessinée avec succès !";
        break;
      default:
        message = "Opération terminée avec succès !";
    }

    _showInfoExtractedDialog(message);
    _nextStep();
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
                              'Créer un constat',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              'Étape ${currentStep + 1} sur ${steps.length}',
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
                                      'Assistant Lumi',
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
                                    const Text('Traitement en cours...'),
                                  ],
                                )
                              : Text(
                                  currentStep < steps.length - 1
                                      ? 'Continuer'
                                      : 'Soumettre le constat',
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
                          'Étape actuelle',
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
                              'Terminé',
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
