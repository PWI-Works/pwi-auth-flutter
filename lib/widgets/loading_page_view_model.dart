import 'dart:async';
import 'package:mvvm_plus/mvvm_plus.dart';

/// ViewModel that manages cycling loading messages with timed transitions
class LoadingPageViewModel extends ViewModel {
  final String text;

  // List of loading messages to cycle through
  late final List<String> loadingMessages = [
    text,
    "🚀 Calculating jump to hyperspace...",
    "🔮 Consulting the Oracle...",  
    "🪄 Expecto Data-trum!",
    "🖖 Beaming up, Scotty..."
    "🤖 Assembling the Avengers...",
    "🦖 Hold onto your butts...",
    "🐢 Running at 0.5x speed for dramatic effect...",
    "🕵️ Investigating where the last 1% went..."
  ];

  LoadingPageViewModel(this.text);

  // Reactive properties
  late final currentMessage = createProperty<String>(text);
  late final isTransitioning = createProperty<bool>(false);

  // Timing variables
  final Duration messageDuration = const Duration(milliseconds: 2500);
  final Duration transitionDuration = const Duration(milliseconds: 500);
  Timer? _messageTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set initial message
    currentMessage.value = loadingMessages.first;
    // Start cycling through messages
    _startMessageCycling();
  }

  /// Starts the timer to cycle through loading messages
  void _startMessageCycling() {
    _messageTimer = Timer.periodic(messageDuration, (_) {
      _cycleToNextMessage();
    });
  }

  /// Transitions to the next message with fade effect
  void _cycleToNextMessage() async {
    // Start fade out transition
    isTransitioning.value = true;

    // Wait for fade out to complete
    await Future.delayed(transitionDuration);

    // Update to next message
    _currentIndex = (_currentIndex + 1) % loadingMessages.length;
    currentMessage.value = loadingMessages[_currentIndex];

    // Start fade in transition
    isTransitioning.value = false;
  }

  @override
  void dispose() {
    // Clean up timer
    _messageTimer?.cancel();
    super.dispose();
  }
}
