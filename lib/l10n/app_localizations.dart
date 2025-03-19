import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Shooter Timer'**
  String get appTitle;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @micSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Microphone Sensitivity'**
  String get micSensitivity;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @countdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown (seconds)'**
  String get countdown;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Brazil)'**
  String get portuguese;

  /// No description provided for @shot.
  ///
  /// In en, this message translates to:
  /// **'Shot'**
  String get shot;

  /// No description provided for @drawTime.
  ///
  /// In en, this message translates to:
  /// **'Draw Time'**
  String get drawTime;

  /// No description provided for @shotTime.
  ///
  /// In en, this message translates to:
  /// **'Shot Time'**
  String get shotTime;

  /// No description provided for @splitTime.
  ///
  /// In en, this message translates to:
  /// **'Split Time'**
  String get splitTime;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go!'**
  String get go;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by Albert Katri'**
  String get developedBy;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get permissionDenied;

  /// No description provided for @errorStartingMic.
  ///
  /// In en, this message translates to:
  /// **'Error starting microphone'**
  String get errorStartingMic;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No training history available'**
  String get noHistory;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get sessionDetails;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total Duration'**
  String get totalDuration;

  /// No description provided for @shotCount.
  ///
  /// In en, this message translates to:
  /// **'Shot Count'**
  String get shotCount;

  /// No description provided for @averageSplitTime.
  ///
  /// In en, this message translates to:
  /// **'Average Split Time'**
  String get averageSplitTime;

  /// No description provided for @sessionSaved.
  ///
  /// In en, this message translates to:
  /// **'Training session saved successfully'**
  String get sessionSaved;

  /// No description provided for @sessionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Session deleted'**
  String get sessionDeleted;

  /// No description provided for @errorSavingSession.
  ///
  /// In en, this message translates to:
  /// **'Error saving training session'**
  String get errorSavingSession;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @noShotsToSave.
  ///
  /// In en, this message translates to:
  /// **'No shots to save'**
  String get noShotsToSave;

  /// No description provided for @saveSession.
  ///
  /// In en, this message translates to:
  /// **'Save Session'**
  String get saveSession;

  /// No description provided for @clearShots.
  ///
  /// In en, this message translates to:
  /// **'Clear Shots'**
  String get clearShots;

  /// No description provided for @shots.
  ///
  /// In en, this message translates to:
  /// **'shots'**
  String get shots;

  /// No description provided for @trainingMode.
  ///
  /// In en, this message translates to:
  /// **'Training Mode'**
  String get trainingMode;

  /// No description provided for @saveTrain.
  ///
  /// In en, this message translates to:
  /// **'Save Training'**
  String get saveTrain;

  /// No description provided for @quickTrain.
  ///
  /// In en, this message translates to:
  /// **'Quick Training'**
  String get quickTrain;

  /// No description provided for @saveTrainDesc.
  ///
  /// In en, this message translates to:
  /// **'Save sessions for analysis later'**
  String get saveTrainDesc;

  /// No description provided for @quickTrainDesc.
  ///
  /// In en, this message translates to:
  /// **'Quick practice without saving data'**
  String get quickTrainDesc;

  /// No description provided for @noShotsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No shots recorded'**
  String get noShotsRecorded;

  /// No description provided for @mustClearOrSaveBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'Please save or clear shots before starting a new session'**
  String get mustClearOrSaveBeforeStart;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
