import 'dart:async';
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
  
  // Debounce mechanism to prevent multiple detections in short succession
  DateTime? _lastShotTime;
  static const _debounceMilliseconds = 300; // Minimum time between shots
  
  // Noise burst tracking
  int _consecutiveHighLevels = 0;
  static const _requiredConsecutiveHighLevels = 2; // Number of high readings to confirm a shot
  
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
      _lastShotTime = null;
      _consecutiveHighLevels = 0;
      
      // Start microphone monitoring
      await _channel.invokeMethod('startAudioMonitoring');
      
      _isListening = true;
      
      // Start a timer to periodically check audio levels
      _processTimer = Timer.periodic(const Duration(milliseconds: 50), (_) async {
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
    
    if (_isListening) {
      try {
        await _channel.invokeMethod('stopAudioMonitoring');
      } catch (e) {
        debugPrint('Error stopping microphone: $e');
      }
    }
    
    _isListening = false;
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
    if (!_isListening) return;
    
    // Dynamically calculate threshold based on sensitivity
    // Lower sensitivity = higher threshold (harder to trigger)
    final baseThreshold = 75.0;
    final adjustedThreshold = baseThreshold - (_sensitivityMultiplier * 30);
    
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
  
  // Detect a shot with debouncing to prevent multiple triggers
  void _detectShot(double level) {
    final now = DateTime.now();
    
    // Check if enough time has passed since last shot (debouncing)
    if (_lastShotTime == null || 
        now.difference(_lastShotTime!).inMilliseconds > _debounceMilliseconds) {
      _lastShotTime = now;
      _shotDetectedController.add(level);
      debugPrint('Shot detected! Level: $level');
    }
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
    _shotDetectedController.close();
  }
}