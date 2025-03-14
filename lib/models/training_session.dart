import 'package:shooter/models/shot.dart';

class TrainingSession {
  final int? id; // Nullable because it will be null before saving to DB
  final DateTime date;
  final Duration duration;
  final List<Shot> shots;

  TrainingSession({
    this.id,
    required this.date,
    required this.duration,
    required this.shots,
  });

  // Convert to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'duration': duration.inMilliseconds,
      'shot_count': shots.length,
    };
  }

  // Create a TrainingSession from a map
  factory TrainingSession.fromMap(Map<String, dynamic> map, List<Shot> shots) {
    return TrainingSession(
      id: map['id'],
      date: DateTime.parse(map['date']),
      duration: Duration(milliseconds: map['duration']),
      shots: shots,
    );
  }

  @override
  String toString() {
    return 'TrainingSession(id: $id, date: $date, duration: $duration, shotCount: ${shots.length})';
  }
}