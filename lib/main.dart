import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shooter/providers/settings_provider.dart';
import 'package:shooter/screens/history_screen.dart';
import 'package:shooter/screens/home_screen.dart';
import 'package:shooter/screens/settings_screen.dart';
import 'package:shooter/l10n/app_localizations.dart'; // Updated import path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings provider
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settingsProvider,
      child: const ShooterApp(),
    ),
  );
}

class ShooterApp extends StatelessWidget {
  const ShooterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'Shooter Timer',
      locale: Locale(settingsProvider.language),
      supportedLocales: const [
        Locale('en'), // English
        Locale('pt'), // Portuguese
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // Use platform-adaptive properties
        appBarTheme: AppBarTheme(
          backgroundColor:
              Platform.isIOS ? CupertinoColors.systemGroupedBackground : null,
          foregroundColor: Platform.isIOS ? CupertinoColors.label : null,
        ),
        // Make buttons follow iOS styling when on iOS
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape:
                Platform.isIOS
                    ? const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    )
                    : null,
          ),
        ),
      ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
