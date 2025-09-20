import 'package:flutter/material.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';

class VoiceInterviewScreen extends StatefulWidget {
  final Deepgram deepgram;
  final FlutterTts flutterTts;
  final List<String> accidentQuestions;
  final Function(List<String>) onInterviewComplete;

  const VoiceInterviewScreen({
    super.key,
    required this.deepgram,
    required this.flutterTts,
    required this.accidentQuestions,
    required this.onInterviewComplete,
  });

  @override
  State<VoiceInterviewScreen> createState() => _VoiceInterviewScreenState();
}

class _VoiceInterviewScreenState extends State<VoiceInterviewScreen>
    with TickerProviderStateMixin {
  bool isListening = false;
  bool isSpeaking = false;
  int currentQuestionIndex = 0;
  List<String> userResponses = [];
  late final AudioRecorder _audioRecorder;
  DeepgramLiveListener? _deepgramListener;
  bool hasStarted = false;
  String currentTranscript = "";
  String interimTranscript = "";

  // Animation controllers for visual feedback
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _setupTTSHandlers();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupTTSHandlers() {
    widget.flutterTts.setCompletionHandler(() {
      print('TTS completed');
      if (mounted && !isListening) {
        _startListening();
      }
    });

    widget.flutterTts.setErrorHandler((msg) {
      print('TTS error: $msg');
      if (mounted && !isListening) {
        _startListening();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _audioRecorder.dispose();
    _deepgramListener?.close();
    widget.flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakText(String text) async {
    if (!mounted) return;

    setState(() {
      isSpeaking = true;
      isListening = false;
      currentTranscript = "";
      interimTranscript = "";
    });

    _waveController.repeat();

    try {
      await widget.flutterTts.speak(text);
      print('Started speaking: $text');
    } catch (e) {
      print('TTS failed to speak: $e');
      // If TTS fails, go directly to listening
      if (mounted) {
        _startListening();
      }
    }
  }

  Future<void> _startListening() async {
    if (!mounted) return;

    try {
      if (!await _audioRecorder.hasPermission()) {
        print('Microphone permission not granted.');
        _showPermissionError();
        return;
      }

      setState(() {
        isListening = true;
        isSpeaking = false;
        currentTranscript = "";
        interimTranscript = "";
      });

      _waveController.stop();
      _pulseController.repeat(reverse: true);

      // Close any existing listener first
      await _deepgramListener?.close();

      final sttStreamParams = {
        'model': 'nova-2-general',
        'language': 'fr',
        'smart_format': true,
        'interim_results': true, // Enable interim results for real-time display
        'encoding': 'linear16',
        'sample_rate': 16000,
        'channels': 1,
      };

      try {
        final micStream = await _audioRecorder.startStream(RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ));

        _deepgramListener = widget.deepgram.listen
            .liveListener(micStream, queryParams: sttStreamParams);

        _deepgramListener!.stream.listen(
          (result) {
            print(
                'Deepgram result: ${result.transcript}, isFinal: ${result.isFinal}');

            if (result.transcript != null &&
                result.transcript!.trim().isNotEmpty) {
              if (mounted) {
                setState(() {
                  if (result.isFinal) {
                    currentTranscript = result.transcript!.trim();
                    interimTranscript = "";
                  } else {
                    interimTranscript = result.transcript!.trim();
                  }
                });
              }

              if (result.isFinal) {
                _handleSpeechResult(result.transcript!.trim());
              }
            }
          },
          onError: (error) {
            print('Deepgram error: $error');
            _stopAndResetListening();
          },
          onDone: () {
            print('Deepgram listener closed.');
            _stopAndResetListening();
          },
        );

        await _deepgramListener!.start();
        print('Deepgram listener started.');

        // Auto-stop listening after 30 seconds
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted && isListening) {
            print('Auto-stopping listening after 30 seconds');
            _stopAndResetListening();
          }
        });
      } catch (e) {
        print('Error creating Deepgram listener: $e');
        _stopAndResetListening();
      }
    } catch (e) {
      print('Error during speech recognition setup: $e');
      _stopAndResetListening();
    }
  }

  void _handleSpeechResult(String transcript) async {
    if (!mounted) return;

    print('Processing transcript: $transcript');
    await _stopListening();

    userResponses.add(transcript);
    currentQuestionIndex++;

    if (currentQuestionIndex < widget.accidentQuestions.length) {
      // Move to next question
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _speakText(widget.accidentQuestions[currentQuestionIndex]);
      }
    } else {
      // Interview completed
      if (mounted) {
        widget.onInterviewComplete(userResponses);
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _stopListening() async {
    _pulseController.stop();
    try {
      if (isListening) {
        await _audioRecorder.stop();
      }
      if (_deepgramListener != null) {
        await _deepgramListener?.close();
        _deepgramListener = null;
      }
    } catch (e) {
      print('Error stopping listening: $e');
    }
  }

  void _stopAndResetListening() {
    _pulseController.stop();
    _waveController.stop();
    if (mounted) {
      setState(() {
        isListening = false;
        isSpeaking = false;
        currentTranscript = "";
        interimTranscript = "";
      });
    }
  }

  void _showPermissionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission requise'),
        content: const Text(
            'L\'accès au microphone est nécessaire pour l\'entretien vocal.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startInterview() {
    setState(() {
      hasStarted = true;
    });
    _speakText(widget.accidentQuestions[currentQuestionIndex]);
  }

  void _skipCurrentQuestion() {
    if (currentQuestionIndex < widget.accidentQuestions.length - 1) {
      userResponses.add(""); // Add empty response
      currentQuestionIndex++;
      _speakText(widget.accidentQuestions[currentQuestionIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Entretien vocal'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            await widget.flutterTts.stop();
            await _stopListening();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1} sur ${widget.accidentQuestions.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) /
                          widget.accidentQuestions.length,
                      backgroundColor: Theme.of(context).dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Current question display
              if (hasStarted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSpeaking
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).dividerColor,
                      width: isSpeaking ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.support_agent,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Assistant Lumi',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                          if (isSpeaking) ...[
                            const SizedBox(width: 8),
                            AnimatedBuilder(
                              animation: _waveAnimation,
                              builder: (context, child) {
                                return Icon(
                                  Icons.volume_up,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 20,
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.accidentQuestions[currentQuestionIndex],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Main interaction area
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Voice indicator with animation
                    AnimatedBuilder(
                      animation: isListening ? _pulseAnimation : _waveAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isListening ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: isListening
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2)
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
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context).dividerColor,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              isListening
                                  ? Icons.mic
                                  : isSpeaking
                                      ? Icons.volume_up
                                      : Icons.support_agent,
                              size: 60,
                              color: isListening
                                  ? Theme.of(context).colorScheme.primary
                                  : isSpeaking
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Status text
                    Text(
                      isListening
                          ? 'Je vous écoute...'
                          : isSpeaking
                              ? 'Assistant Lumi parle...'
                              : hasStarted
                                  ? 'En attente...'
                                  : 'Prêt à commencer l\'entretien',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Real-time transcript display
                    if (isListening &&
                        (currentTranscript.isNotEmpty ||
                            interimTranscript.isNotEmpty))
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Votre réponse',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      height: 1.4,
                                    ),
                                children: [
                                  if (currentTranscript.isNotEmpty)
                                    TextSpan(
                                      text: currentTranscript,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  if (interimTranscript.isNotEmpty) ...[
                                    if (currentTranscript.isNotEmpty)
                                      const TextSpan(text: ' '),
                                    TextSpan(
                                      text: interimTranscript,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (interimTranscript.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'En cours de transcription...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                    if (isListening &&
                        currentTranscript.isEmpty &&
                        interimTranscript.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Parlez maintenant, je vous écoute attentivement.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    if (isSpeaking)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),

              // Action buttons
              if (!hasStarted)
                ElevatedButton(
                  onPressed: _startInterview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Commencer l\'entretien',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

              if (hasStarted && (isListening || isSpeaking))
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (isListening &&
                        currentQuestionIndex <
                            widget.accidentQuestions.length - 1)
                      TextButton(
                        onPressed: _skipCurrentQuestion,
                        child: const Text('Passer cette question'),
                      ),
                    TextButton(
                      onPressed: () async {
                        await widget.flutterTts.stop();
                        await _stopListening();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Annuler'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
