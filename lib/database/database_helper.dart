import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/workout_plan.dart';
import '../models/training_log.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String workoutTable = 'workout_plans';
  static const String logTable = 'training_logs';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'movement_quest.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE workout_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            exercise TEXT NOT NULL,
            equipment TEXT NOT NULL,
            sets INTEGER NOT NULL CHECK(sets > 0),
            reps INTEGER NOT NULL CHECK(reps > 0),
            intensity INTEGER NOT NULL
              CHECK(intensity BETWEEN 1 AND 10)
          )
        ''');

        await db.execute('''
          CREATE TABLE training_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            workout_plan_id INTEGER NOT NULL,
            completed_sets INTEGER NOT NULL
              CHECK(completed_sets >= 0),
            actual_reps INTEGER NOT NULL
              CHECK(actual_reps >= 0),
            completed_at TEXT NOT NULL,
            reflection TEXT NOT NULL DEFAULT '',
            FOREIGN KEY(workout_plan_id)
              REFERENCES workout_plans(id)
              ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // WORKOUT PLAN CRUD

  Future<int> insertWorkout(WorkoutPlan workout) async {
    final db = await database;
    final values = workout.toMap()..remove('id');
    return db.insert(workoutTable, values);
  }

  Future<List<WorkoutPlan>> getAllWorkouts() async {
    final db = await database;
    final rows = await db.query(workoutTable, orderBy: 'id ASC');

    return rows.map(WorkoutPlan.fromMap).toList();
  }

  Future<int> updateWorkout(WorkoutPlan workout) async {
    if (workout.id == null) {
      throw ArgumentError('Workout ID is required for updates');
    }

    final db = await database;
    final values = workout.toMap()..remove('id');

    return db.update(
      workoutTable,
      values,
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<int> deleteWorkout(int id) async {
    final db = await database;

    return db.delete(workoutTable, where: 'id = ?', whereArgs: [id]);
  }

  // TRAINING LOG CRUD

  Future<int> insertTrainingLog(TrainingLog log) async {
    final db = await database;
    final values = log.toMap()..remove('id');

    return db.insert(logTable, values);
  }

  Future<List<TrainingLog>> getAllTrainingLogs() async {
    final db = await database;
    final rows = await db.query(logTable, orderBy: 'id DESC');

    return rows.map(TrainingLog.fromMap).toList();
  }

  Future<List<TrainingLog>> getLogsForWorkout(int workoutId) async {
    final db = await database;

    final rows = await db.query(
      logTable,
      where: 'workout_plan_id = ?',
      whereArgs: [workoutId],
      orderBy: 'id DESC',
    );

    return rows.map(TrainingLog.fromMap).toList();
  }

  Future<int> updateTrainingLog(TrainingLog log) async {
    if (log.id == null) {
      throw ArgumentError('Training log ID is required');
    }

    final db = await database;
    final values = log.toMap()..remove('id');

    return db.update(logTable, values, where: 'id = ?', whereArgs: [log.id]);
  }

  Future<int> deleteTrainingLog(int id) async {
    final db = await database;

    return db.delete(logTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCompletedSessionCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM training_logs',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
