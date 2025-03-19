import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class MicService {
  static const MethodChannel _channel = MethodChannel('shooter.mic_service');
  Timer? _processTimer;

  // Stream controller for detected shots
  final _shotDetectedController = StreamController<double>.broadcast();
  Stream<double> get shotDetected => _shotDetectedController.stream;

  // Threshold multiplier based on sensitivity (0-100%)
  double _sensitivityMultiplier = 0.5; // Default 50%

  bool _isListening = false;
  bool get isListening => _isListening;

  // Noise burst tracking
  int _consecutiveHighLevels = 0;
  static const _requiredConsecutiveHighLevels =
      2; // Number of high readings to confirm a shot

  // Beep detection handling
  bool _ignoreAudio = false;
  Timer? _ignoreTimer;

  // Set sensitivity level (0-100%)
  void setSensitivity(double sensitivity) {
    _sensitivityMultiplier = sensitivity / 100;
    debugPrint('Sensitivity set to: $_sensitivityMultiplier');
  }

  // Start listening for noise
  Future<bool> startListening() async {
    // Request microphone permission
    if (!await _checkPermission()) {
      return false;
    }

    try {
      // Reset shot detection state
      _consecutiveHighLevels = 0;

      // Start microphone monitoring - platform specific
      await _channel.invokeMethod('startAudioMonitoring');

      _isListening = true;

      // Start a timer to periodically check audio levels
      _processTimer = Timer.periodic(const Duration(milliseconds: 50), (
        _,
      ) async {
        try {
          final audioLevel = await _getAudioLevel();
          _processAudioLevel(audioLevel);
        } catch (e) {
          debugPrint('Error processing audio: $e');
        }
      });

      return true;
    } catch (e) {
      debugPrint('Error starting microphone: $e');
      _isListening = false;
      return false;
    }
  }

  // Stop listening for noise
  Future<void> stopListening() async {
    _processTimer?.cancel();
    _processTimer = null;
    _ignoreTimer?.cancel();
    _ignoreTimer = null;

    if (_isListening) {
      try {
        await _channel.invokeMethod('stopAudioMonitoring');
      } catch (e) {
        debugPrint('Error stopping microphone: $e');
      }
    }

    _isListening = false;
    _ignoreAudio = false;
  }

  // Temporarily ignore audio input (for beep playback)
  void ignoreAudioDuringBeep(int milliseconds) {
    if (!_isListening) return;

    _ignoreAudio = true;
    debugPrint('Ignoring audio input for beep playback');

    // Cancel any existing ignore timer
    _ignoreTimer?.cancel();

    // Set a timer to stop ignoring audio after specified duration
    _ignoreTimer = Timer(Duration(milliseconds: milliseconds), () {
      _ignoreAudio = false;
      debugPrint('Resumed audio processing after beep');
    });
  }

  // Get current audio level (0-100)
  Future<double> _getAudioLevel() async {
    try {
      final level = await _channel.invokeMethod('getAudioLevel');
      return (level as double?) ?? 0.0;
    } catch (e) {
      debugPrint('Error getting audio level: $e');
      return 0.0;
    }
  }

  // Process audio level to detect shots
  void _processAudioLevel(double level) {
    if (!_isListening || _ignoreAudio) return;

    // Dynamically calculate threshold based on sensitivity and platform
    // iOS and Android handle audio levels differently
    double adjustedThreshold;

    if (Platform.isIOS) {
      // iOS: Levels are already normalized to 0-100 in the Swift code
      adjustedThreshold =
          80.0 - (_sensitivityMultiplier * 40); // Ranges from 40-80
    } else {
      // Android: Using previous threshold calculation
      final baseThreshold = 75.0;
      adjustedThreshold = baseThreshold - (_sensitivityMultiplier * 30);
    }

    // Check if level exceeds threshold
    if (level > adjustedThreshold) {
      _consecutiveHighLevels++;

      // Check if we have enough consecutive high readings to count as a shot
      if (_consecutiveHighLevels >= _requiredConsecutiveHighLevels) {
        _detectShot(level);
        _consecutiveHighLevels = 0; // Reset after detection
      }
    } else {
      // Reset counter if level drops below threshold
      _consecutiveHighLevels = 0;
    }
  }

  // Detect a shot without debouncing to allow rapid fire detection
  void _detectShot(double level) {
    _shotDetectedController.add(level);
    debugPrint('Shot detected! Level: $level');
  }

  // Check and request microphone permission
  Future<bool> _checkPermission() async {
    // Check if permission is granted
    if (await Permission.microphone.isGranted) {
      return true;
    }

    // Request permission
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  void dispose() {
    stopListening();
    _ignoreTimer?.cancel();
    _shotDetectedController.close();
  }
}
