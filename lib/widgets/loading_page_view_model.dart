import 'dart:async';
import 'dart:math';
import 'package:mvvm_plus/mvvm_plus.dart';

/// ViewModel that manages cycling loading messages with timed transitions
class LoadingPageViewModel extends ViewModel {
  /// the duration for displaying each loading message
  static const int _messageDisplayDuration = 2800; // milliseconds
  /// the duration for the transition between loading messages
  static const int _messageTransitionDuration = 500; // milliseconds

  LoadingPageViewModel(this.text);

  /// Optional initial message to display
  final String? text;

  /// Random number generator for shuffling messages
  final Random _random = Random();

  /// Standard loading messages to display
  /// These messages are shuffled each time the loading view is shown
  /// to provide variety and keep the user engaged
  static const List<String> _standardMessages = [
    "Calculating jump to hyperspace...",
    "Consulting the Oracle...",
    "Expecto Data-trum!",
    "Beaming up, Scotty...",
    "Assembling the Avengers...",
    "Hold onto your butts...",
  ];

  /// Messages that display after a longer load time
  /// These messages are shown in sequence after the standard messages
  static const List<String> _longLoadMessages = [
    "Running at 0.5x speed for dramatic effect...",
    "Investigating where the last 1% went...",
    "I'm getting tired...",
  ];

  // Messages that display after the randomized sequence
  late final List<String> longLoadTimeMessages =
      List<String>.unmodifiable(_longLoadMessages);

  // Full list of loading messages with optional intro and trailing long-load messages
  late final List<String> loadingMessages = _buildLoadingMessages();

  // Reactive properties
  late final currentMessage = createProperty<String>(loadingMessages.first);
  late final isTransitioning = createProperty<bool>(false);

  // Timing variables
  final Duration messageDuration =
      const Duration(milliseconds: _messageDisplayDuration);
  final Duration transitionDuration =
      const Duration(milliseconds: _messageTransitionDuration);
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

  /// Builds the full list of loading messages
  /// Includes optional initial message and appends long-load messages
  List<String> _buildLoadingMessages() {
    // Shuffle standard messages for variety
    final shuffledMessages = List<String>.from(_standardMessages)
      ..shuffle(_random);
    // create ordered list for use this time
    final orderedMessages = <String>[];

    // Include the optional initial message if provided
    if (text != null && text!.trim().isNotEmpty) {
      orderedMessages.add(text!);
    }

    // Append shuffled standard messages and long-load messages
    orderedMessages
      ..addAll(shuffledMessages)
      ..addAll(longLoadTimeMessages);

    return orderedMessages;
  }

  @override
  void dispose() {
    // Clean up timer
    _messageTimer?.cancel();
    super.dispose();
  }
}
