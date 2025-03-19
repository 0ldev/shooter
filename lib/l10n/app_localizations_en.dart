// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shooter Timer';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get reset => 'Reset';

  @override
  String get settings => 'Settings';

  @override
  String get micSensitivity => 'Microphone Sensitivity';

  @override
  String get language => 'Language';

  @override
  String get countdown => 'Countdown (seconds)';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Portuguese (Brazil)';

  @override
  String get shot => 'Shot';

  @override
  String get drawTime => 'Draw Time';

  @override
  String get shotTime => 'Shot Time';

  @override
  String get splitTime => 'Split Time';

  @override
  String get ready => 'Ready';

  @override
  String get set => 'Set';

  @override
  String get go => 'Go!';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get developedBy => 'Developed by Albert Katri';

  @override
  String get permissionDenied => 'Microphone permission denied';

  @override
  String get errorStartingMic => 'Error starting microphone';

  @override
  String get history => 'History';

  @override
  String get noHistory => 'No training history available';

  @override
  String get sessionDetails => 'Session Details';

  @override
  String get date => 'Date';

  @override
  String get duration => 'Duration';

  @override
  String get totalDuration => 'Total Duration';

  @override
  String get shotCount => 'Shot Count';

  @override
  String get averageSplitTime => 'Average Split Time';

  @override
  String get sessionSaved => 'Training session saved successfully';

  @override
  String get sessionDeleted => 'Session deleted';

  @override
  String get errorSavingSession => 'Error saving training session';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get noShotsToSave => 'No shots to save';

  @override
  String get saveSession => 'Save Session';

  @override
  String get clearShots => 'Clear Shots';

  @override
  String get shots => 'shots';

  @override
  String get trainingMode => 'Training Mode';

  @override
  String get saveTrain => 'Save Training';

  @override
  String get quickTrain => 'Quick Training';

  @override
  String get saveTrainDesc => 'Save sessions for analysis later';

  @override
  String get quickTrainDesc => 'Quick practice without saving data';

  @override
  String get noShotsRecorded => 'No shots recorded';

  @override
  String get mustClearOrSaveBeforeStart => 'Please save or clear shots before starting a new session';
}
