import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shooter/models/training_session.dart';
import 'package:shooter/services/database_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<TrainingSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  // Load all saved sessions
  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessions = await _dbService.getAllSessions();
      setState(() {
        _sessions = sessions;
      });
    } catch (e) {
      debugPrint('Error loading sessions: $e');
      _showErrorSnackBar();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete a session
  Future<void> _deleteSession(TrainingSession session) async {
    if (session.id == null) return;

    final success = await _dbService.deleteSession(session.id!);
    
    if (success) {
      setState(() {
        _sessions.remove(session);
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.sessionDeleted)),
      );
    } else {
      _showErrorSnackBar();
    }
  }

  void _showErrorSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.errorOccurred),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Format a duration as MM:SS.mmm
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return "$minutes:$seconds.$milliseconds";
  }

  // Navigate to session detail view
  void _viewSessionDetails(TrainingSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailScreen(session: session),
      ),
    ).then((_) => _loadSessions()); // Refresh when we return
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(child: Text(l10n.noHistory))
              : ListView.builder(
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    final formattedDate = dateFormatter.format(session.date);
                    final formattedDuration = _formatDuration(session.duration);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text('$formattedDate (${session.shots.length} ${l10n.shots})'),
                        subtitle: Text('${l10n.duration}: $formattedDuration'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteSession(session),
                        ),
                        onTap: () => _viewSessionDetails(session),
                      ),
                    );
                  },
                ),
    );
  }
}

class SessionDetailScreen extends StatelessWidget {
  final TrainingSession session;

  const SessionDetailScreen({super.key, required this.session});

  // Format a duration as MM:SS.mmm
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return "$minutes:$seconds.$milliseconds";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionDetails),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.date}: ${dateFormatter.format(session.date)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.totalDuration}: ${_formatDuration(session.duration)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.shotCount}: ${session.shots.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (session.shots.isNotEmpty && session.shots.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${l10n.averageSplitTime}: ${_formatDuration(_calculateAverageSplitTime(session))}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Shots list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
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
          ),
          
          // Shots list
          Expanded(
            child: ListView.builder(
              itemCount: session.shots.length,
              itemBuilder: (context, index) {
                final shot = session.shots[index];
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
                      horizontal: 24,
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
        ],
      ),
    );
  }
  
  // Calculate average split time
  Duration _calculateAverageSplitTime(TrainingSession session) {
    if (session.shots.length <= 1) {
      return Duration.zero;
    }
    
    int totalMilliseconds = 0;
    int count = 0;
    
    for (final shot in session.shots) {
      if (shot.timeFromPreviousShot != null) {
        totalMilliseconds += shot.timeFromPreviousShot!.inMilliseconds;
        count++;
      }
    }
    
    if (count == 0) return Duration.zero;
    return Duration(milliseconds: totalMilliseconds ~/ count);
  }
}