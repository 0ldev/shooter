import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooter/models/shot.dart';
import 'package:shooter/models/training_session.dart';
import 'package:shooter/providers/settings_provider.dart';
import 'package:shooter/services/audio_service.dart';
import 'package:shooter/services/database_service.dart';
import 'package:shooter/services/mic_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioService _audioService = AudioService();
  final MicService _micService = MicService();
  final DatabaseService _databaseService = DatabaseService();
  
  // Timer related variables
  DateTime? _startTime;
  Timer? _timer;
  String _elapsedTimeStr = "00:00.000";
  
  // Shot tracking
  List<Shot> _shots = [];
  StreamSubscription<double>? _shotSubscription;
  
  // State variables
  bool _isRunning = false;
  bool _isCountingDown = false;
  int _countdownValue = 0;
  Timer? _countdownTimer;
  
  // To track when session is stopped and in saved mode
  bool _isSessionCompleted = false;

  @override
  void initState() {
    super.initState();
    _setupShotDetection();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update mic sensitivity based on settings
    final sensitivity = Provider.of<SettingsProvider>(context).microphoneSensitivity;
    _micService.setSensitivity(sensitivity);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _shotSubscription?.cancel();
    _audioService.dispose();
    _micService.dispose();
    super.dispose();
  }

  // Set up shot detection through mic service
  void _setupShotDetection() {
    _shotSubscription = _micService.shotDetected.listen((decibel) {
      if (_isRunning && !_isCountingDown) {
        _recordShot();
      }
    });
  }

  // Toggle timer between start and stop
  void _toggleTimer() async {
    if (_isRunning) {
      _stopTimer();
    } else {
      await _startTimer();
    }
  }

  // Start the timer with countdown if set
  Future<void> _startTimer() async {
    if (_isRunning) return;
    
    final countdownSeconds = Provider.of<SettingsProvider>(context, listen: false).countdownSeconds;
    final isSaveMode = Provider.of<SettingsProvider>(context, listen: false).isSaveTrainingMode;
    
    setState(() {
      // In quick training mode, always clear shots when starting
      // In save mode, we don't clear shots - this requires user to clear them manually
      if (!isSaveMode) {
        _shots = [];
      }
      
      _isRunning = true;
      _isSessionCompleted = false;
      
      if (countdownSeconds > 0) {
        _isCountingDown = true;
        _countdownValue = countdownSeconds;
      } else {
        // Play beep first, then start timer after 500ms
        _playBeepAndStartTimer();
      }
    });
    
    // Start microphone listening
    if (!await _micService.startListening()) {
      _showPermissionError();
      _stopTimer();
      return;
    }
    
    // Handle countdown if enabled
    if (countdownSeconds > 0) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _countdownValue--;
        });
        
        if (_countdownValue <= 0) {
          _countdownTimer?.cancel();
          // Play beep first, then start timer after 500ms
          _playBeepAndStartTimer();
        }
      });
    }
  }
  
  // Play beep sound and start timer after a delay
  void _playBeepAndStartTimer() {
    // Play beep sound immediately
    _audioService.playBeep();
    
    // Start the timer after 500ms delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return; // Check if widget is still mounted
      _startTimerNow();
    });
  }
  
  // Actually start the timer after countdown completes and beep delay
  void _startTimerNow() {
    setState(() {
      _isCountingDown = false;
      _startTime = DateTime.now();
    });
    
    // Start timer to update UI
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_startTime != null) {
        final now = DateTime.now();
        final elapsed = now.difference(_startTime!);
        
        setState(() {
          _elapsedTimeStr = _formatDuration(elapsed);
        });
      }
    });
  }
  
  // Stop the timer and microphone
  void _stopTimer() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _micService.stopListening();
    
    setState(() {
      _isRunning = false;
      _isCountingDown = false;
      _isSessionCompleted = true;
    });
  }
  
  // Clear the shots list
  void _clearShots() {
    setState(() {
      _shots = [];
      _isSessionCompleted = false;
    });
  }
  
  // Save the current training session to the database
  Future<void> _saveSession() async {
    if (_shots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noShotsToSave),
        ),
      );
      return;
    }
    
    // Calculate total duration based on the last shot time
    final duration = _shots.isNotEmpty 
        ? _shots.last.timeFromStart 
        : const Duration(seconds: 0);
    
    final session = TrainingSession(
      date: DateTime.now(),
      duration: duration,
      shots: List.from(_shots), // Create a copy of the shots list
    );
    
    final result = await _databaseService.saveTrainingSession(session);
    
    if (result > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.sessionSaved),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {
        _shots = [];
        _isSessionCompleted = false;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorSavingSession),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Record a new shot
  void _recordShot() {
    if (_startTime == null) return;
    
    final now = DateTime.now();
    final timeFromStart = now.difference(_startTime!);
    
    // Calculate time from previous shot
    Duration? timeFromPreviousShot;
    if (_shots.isNotEmpty) {
      timeFromPreviousShot = timeFromStart - _shots.last.timeFromStart;
    }
    
    final shot = Shot(
      timestamp: now,
      timeFromStart: timeFromStart,
      timeFromPreviousShot: timeFromPreviousShot,
    );
    
    setState(() {
      _shots.add(shot);
    });
  }
  
  // Format duration to MM:SS.mmm
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return "$minutes:$seconds.$milliseconds";
  }
  
  // Show error if microphone permission is denied
  void _showPermissionError() {
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.permissionDenied),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSaveMode = Provider.of<SettingsProvider>(context).isSaveTrainingMode;
    
    // Determine if the start button should be disabled
    // In save mode, if there are shots and not currently running, disable start
    final bool disableStartButton = isSaveMode && _shots.isNotEmpty && !_isRunning;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timer display
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: _isRunning
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: _isCountingDown
                  ? Text(
                      _countdownValue.toString(),
                      style: Theme.of(context).textTheme.displayLarge,
                    )
                  : Text(
                      _elapsedTimeStr,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
            ),
            const SizedBox(height: 16),
            // Single control button that toggles between Start/Stop
            ElevatedButton(
              onPressed: disableStartButton ? null : _toggleTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(
                _isRunning ? l10n.stop : l10n.start,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            // Display a hint text when start is disabled
            if (disableStartButton)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  l10n.mustClearOrSaveBeforeStart,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Shots list header
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      l10n.shot,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      l10n.drawTime,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      l10n.splitTime,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            // Shots list
            Expanded(
              child: _shots.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noShotsRecorded,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _shots.length,
                      itemBuilder: (context, index) {
                        final shot = _shots[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Row(
                              children: [
                                // Shot number
                                Expanded(
                                  flex: 2,
                                  child: Text('${index + 1}'),
                                ),
                                // Shot time from start
                                Expanded(
                                  flex: 4,
                                  child: Text(_formatDuration(shot.timeFromStart)),
                                ),
                                // Split time (time from previous shot)
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    shot.timeFromPreviousShot != null
                                        ? _formatDuration(shot.timeFromPreviousShot!)
                                        : '-',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Save/Clear buttons only shown in save training mode and when there are shots
            if (isSaveMode && _shots.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isRunning ? null : _saveSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(l10n.saveSession),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isRunning ? null : _clearShots,
                        child: Text(l10n.clearShots),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}