import 'package:flutter_test/flutter_test.dart';
import 'package:my_workout_partner/models/training_log.dart';
import 'package:my_workout_partner/models/workout_plan.dart';
import 'package:my_workout_partner/services/next_quest_recommender.dart';

void main() {
  WorkoutPlan plan(
    int id,
    String name, {
    String equipment = 'None',
    int intensity = 5,
  }) {
    return WorkoutPlan(
      id: id,
      name: name,
      exercise: 'Squats',
      equipment: equipment,
      sets: 3,
      reps: 12,
      intensity: intensity,
    );
  }

  TrainingLog log(int workoutId, DateTime date) {
    return TrainingLog(
      workoutPlanId: workoutId,
      completedSets: 3,
      actualReps: 36,
      completedAt: date.toIso8601String(),
      reflection: '',
    );
  }

  final now = DateTime(2026, 10, 24, 12);

  test('Empty catalog returns no recommendation', () {
    final result = NextQuestRecommender.recommend(
      workouts: [],
      logs: [],
      preferredEquipment: 'None',
      preferredIntensity: 5,
      now: now,
    );

    expect(result, isNull);
  });

  test('Exact equipment and intensity match wins', () {
    final result = NextQuestRecommender.recommend(
      workouts: [
        plan(1, 'Other', equipment: 'Resistance Bands', intensity: 9),
        plan(2, 'Match', equipment: 'Dumbbells', intensity: 7),
      ],
      logs: [],
      preferredEquipment: 'Dumbbells',
      preferredIntensity: 7,
      now: now,
    );

    expect(result?.workout.name, 'Match');
    expect(result?.score, 100);
  });

  test('Compatible equipment wins over mismatch', () {
    final result = NextQuestRecommender.recommend(
      workouts: [
        plan(1, 'Mismatch', equipment: 'Resistance Bands'),
        plan(2, 'Compatible', equipment: 'Dumbbells'),
      ],
      logs: [],
      preferredEquipment: 'Dumbbells',
      preferredIntensity: 5,
      now: now,
    );

    expect(result?.workout.name, 'Compatible');
  });

  test('Older session is preferred over recent session', () {
    final result = NextQuestRecommender.recommend(
      workouts: [plan(1, 'Recent'), plan(2, 'Older')],
      logs: [log(1, now), log(2, now.subtract(const Duration(days: 8)))],
      preferredEquipment: 'None',
      preferredIntensity: 5,
      now: now,
    );

    expect(result?.workout.name, 'Older');
  });

  test('Less frequent workout is preferred', () {
    final logs = [
      log(1, now.subtract(const Duration(days: 8))),
      for (int i = 0; i < 6; i++) log(2, now.subtract(Duration(days: 8 + i))),
    ];

    final result = NextQuestRecommender.recommend(
      workouts: [plan(2, 'Frequent'), plan(1, 'Less Frequent')],
      logs: logs,
      preferredEquipment: 'None',
      preferredIntensity: 5,
      now: now,
    );

    expect(result?.workout.name, 'Less Frequent');
  });
}
