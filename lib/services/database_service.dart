import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shooter/models/shot.dart';
import 'package:shooter/models/training_session.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // Singleton constructor
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Use different path handling strategy based on platform
    String dbPath;

    if (Platform.isIOS) {
      // For iOS, use getApplicationDocumentsDirectory
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      dbPath = join(documentsDirectory.path, 'shooter_database.db');
    } else {
      // For Android and others, use getDatabasesPath
      dbPath = join(await getDatabasesPath(), 'shooter_database.db');
    }

    return await openDatabase(dbPath, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    // Create training_sessions table
    await db.execute('''
      CREATE TABLE training_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        duration INTEGER NOT NULL,
        shot_count INTEGER NOT NULL
      )
    ''');

    // Create shots table with foreign key to training_sessions
    await db.execute('''
      CREATE TABLE shots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        time_from_start INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES training_sessions (id) ON DELETE CASCADE
      )
    ''');
  }

  // Save a new training session with its shots
  Future<int> saveTrainingSession(TrainingSession session) async {
    try {
      final db = await database;

      // Begin transaction
      await db.transaction((txn) async {
        // Insert session first to get the ID
        final sessionId = await txn.insert(
          'training_sessions',
          session.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Insert all shots with the session ID
        for (final shot in session.shots) {
          await txn.insert('shots', {
            'session_id': sessionId,
            'time_from_start': shot.timeFromStart.inMilliseconds,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        // Return the session ID after successful transaction
        return sessionId;
      });

      return 1; // Success
    } catch (e) {
      debugPrint('Error saving training session: $e');
      return -1; // Error
    }
  }

  // Get all training sessions
  Future<List<TrainingSession>> getAllSessions() async {
    try {
      final db = await database;

      // Get all sessions
      final List<Map<String, dynamic>> sessionMaps = await db.query(
        'training_sessions',
        orderBy: 'date DESC',
      );

      // Convert the maps to TrainingSession objects
      return Future.wait(
        sessionMaps.map((sessionMap) async {
          // Get shots for each session
          final List<Map<String, dynamic>> shotMaps = await db.query(
            'shots',
            where: 'session_id = ?',
            whereArgs: [sessionMap['id']],
            orderBy: 'time_from_start',
          );

          // Convert shot maps to Shot objects
          final shots =
              shotMaps.map((shotMap) {
                final timeFromStart = Duration(
                  milliseconds: shotMap['time_from_start'],
                );

                return Shot(
                  timestamp: DateTime.now(), // We don't store exact timestamps
                  timeFromStart: timeFromStart,
                  timeFromPreviousShot: null, // Will calculate below
                );
              }).toList();

          // Calculate split times
          for (int i = 1; i < shots.length; i++) {
            final currentShot = shots[i];
            final previousShot = shots[i - 1];

            // Create a new Shot with the calculated timeFromPreviousShot
            shots[i] = Shot(
              timestamp: currentShot.timestamp,
              timeFromStart: currentShot.timeFromStart,
              timeFromPreviousShot:
                  currentShot.timeFromStart - previousShot.timeFromStart,
            );
          }

          // Create and return the TrainingSession with its shots
          return TrainingSession(
            id: sessionMap['id'],
            date: DateTime.parse(sessionMap['date']),
            duration: Duration(milliseconds: sessionMap['duration']),
            shots: shots,
          );
        }).toList(),
      );
    } catch (e) {
      debugPrint('Error getting training sessions: $e');
      return [];
    }
  }

  // Delete a training session by ID
  Future<bool> deleteSession(int id) async {
    try {
      final db = await database;

      // Delete session (shots will be cascade deleted due to foreign key)
      await db.delete('training_sessions', where: 'id = ?', whereArgs: [id]);

      return true;
    } catch (e) {
      debugPrint('Error deleting training session: $e');
      return false;
    }
  }
}
