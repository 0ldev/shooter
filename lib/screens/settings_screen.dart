import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooter/providers/settings_provider.dart';
import 'package:shooter/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _micSensitivity;
  late String _language;
  late int _countdownSeconds;
  late bool _isSaveTrainingMode;
  
  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _micSensitivity = settings.microphoneSensitivity;
    _language = settings.language;
    _countdownSeconds = settings.countdownSeconds;
    _isSaveTrainingMode = settings.isSaveTrainingMode;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Microphone sensitivity slider
            Text(
              l10n.micSensitivity,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.mic_none),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 100,
                    divisions: 20,
                    value: _micSensitivity,
                    label: '${_micSensitivity.toInt()}%',
                    onChanged: (value) async {
                      setState(() {
                        _micSensitivity = value;
                      });
                      // Save immediately when changed
                      await settings.setMicrophoneSensitivity(value);
                    },
                  ),
                ),
                const Icon(Icons.mic),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text('${_micSensitivity.toInt()}%'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Training mode selection
            Text(
              l10n.trainingMode,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(_isSaveTrainingMode ? l10n.saveTrain : l10n.quickTrain),
              subtitle: Text(_isSaveTrainingMode 
                ? l10n.saveTrainDesc 
                : l10n.quickTrainDesc),
              value: _isSaveTrainingMode,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) async {
                setState(() {
                  _isSaveTrainingMode = value;
                });
                await settings.setSaveTrainingMode(value);
              },
            ),
            const SizedBox(height: 32),
            
            // Language selection
            Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: Text(l10n.english),
              value: 'en',
              groupValue: _language,
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _language = value;
                  });
                  // Save immediately when changed
                  await settings.setLanguage(value);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.portuguese),
              value: 'pt',
              groupValue: _language,
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _language = value;
                  });
                  // Save immediately when changed
                  await settings.setLanguage(value);
                }
              },
            ),
            const SizedBox(height: 32),
            
            // Countdown seconds setting
            Text(
              l10n.countdown,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _countdownSeconds > 0
                      ? () async {
                          setState(() {
                            _countdownSeconds--;
                          });
                          // Save immediately
                          await settings.setCountdownSeconds(_countdownSeconds);
                        }
                      : null,
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '$_countdownSeconds',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _countdownSeconds < 10
                      ? () async {
                          setState(() {
                            _countdownSeconds++;
                          });
                          // Save immediately
                          await settings.setCountdownSeconds(_countdownSeconds);
                        }
                      : null,
                ),
              ],
            ),
            
            const Spacer(),
            
            // Developer info
            Center(
              child: Text(
                l10n.developedBy,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}