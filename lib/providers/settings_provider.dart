import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  double _microphoneSensitivity = 50.0; // Default 50%
  String _language = 'en'; // Default language: English
  int _countdownSeconds = 3; // Default countdown seconds before beep
  bool _isSaveTrainingMode = false; // Default to quick training mode

  double get microphoneSensitivity => _microphoneSensitivity;
  String get language => _language;
  int get countdownSeconds => _countdownSeconds;
  bool get isSaveTrainingMode => _isSaveTrainingMode;

  // Constants for SharedPreferences keys
  static const String _micSensitivityKey = 'micSensitivity';
  static const String _languageKey = 'language';
  static const String _countdownSecondsKey = 'countdownSeconds';
  static const String _saveTrainingModeKey = 'saveTrainingMode';
  
  // Flag to track if settings have been loaded
  bool _initialized = false;
  bool get initialized => _initialized;

  // Initialize settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _microphoneSensitivity = prefs.getDouble(_micSensitivityKey) ?? 50.0;
      _language = prefs.getString(_languageKey) ?? 'en';
      _countdownSeconds = prefs.getInt(_countdownSecondsKey) ?? 3;
      _isSaveTrainingMode = prefs.getBool(_saveTrainingModeKey) ?? false;
      
      _initialized = true;
      debugPrint('Settings loaded: mic=$_microphoneSensitivity, lang=$_language, countdown=$_countdownSeconds, saveMode=$_isSaveTrainingMode');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Use defaults if settings couldn't be loaded
    }
  }

  // Save settings to SharedPreferences
  Future<bool> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setDouble(_micSensitivityKey, _microphoneSensitivity);
      await prefs.setString(_languageKey, _language);
      await prefs.setInt(_countdownSecondsKey, _countdownSeconds);
      await prefs.setBool(_saveTrainingModeKey, _isSaveTrainingMode);
      
      debugPrint('Settings saved: mic=$_microphoneSensitivity, lang=$_language, countdown=$_countdownSeconds, saveMode=$_isSaveTrainingMode');
      return true;
    } catch (e) {
      debugPrint('Error saving settings: $e');
      return false;
    }
  }

  // Update microphone sensitivity
  Future<bool> setMicrophoneSensitivity(double sensitivity) async {
    if (sensitivity < 0) sensitivity = 0;
    if (sensitivity > 100) sensitivity = 100;
    
    _microphoneSensitivity = sensitivity;
    final success = await _saveSettings();
    notifyListeners();
    return success;
  }

  // Update language
  Future<bool> setLanguage(String language) async {
    _language = language;
    final success = await _saveSettings();
    notifyListeners();
    return success;
  }

  // Update countdown seconds
  Future<bool> setCountdownSeconds(int seconds) async {
    if (seconds < 0) seconds = 0;
    _countdownSeconds = seconds;
    final success = await _saveSettings();
    notifyListeners();
    return success;
  }
  
  // Update training mode
  Future<bool> setSaveTrainingMode(bool isSaveMode) async {
    _isSaveTrainingMode = isSaveMode;
    final success = await _saveSettings();
    notifyListeners();
    return success;
  }
}