class Shot {
  final DateTime timestamp;
  final Duration timeFromStart;
  final Duration? timeFromPreviousShot;

  Shot({
    required this.timestamp,
    required this.timeFromStart,
    this.timeFromPreviousShot,
  });

  @override
  String toString() {
    return 'Shot(timestamp: $timestamp, timeFromStart: $timeFromStart, timeFromPreviousShot: $timeFromPreviousShot)';
  }
}