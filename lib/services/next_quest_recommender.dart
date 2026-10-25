import '../models/training_log.dart';
import '../models/workout_plan.dart';

class QuestRecommendation {
  final WorkoutPlan workout;
  final int score;
  final List<String> reasons;

  const QuestRecommendation({
    required this.workout,
    required this.score,
    required this.reasons,
  });

  String get explanation => reasons.join(' ');
}

class NextQuestRecommender {
  // A transparent, rule-based recommendation helper.
  // This is not a trained machine-learning model.

  static QuestRecommendation? recommend({
    required List<WorkoutPlan> workouts,
    required List<TrainingLog> logs,
    required String preferredEquipment,
    required int preferredIntensity,
    DateTime? now,
  }) {
    if (workouts.isEmpty) return null;

    final currentTime = now ?? DateTime.now();

    final recommendations = workouts.map((workout) {
      int score = 0;
      final reasons = <String>[];

      // RULE 1: Equipment compatibility (40 points).
      //
      // A workout requiring no equipment can always be done.
      // A workout requiring equipment must match the user's
      // selected equipment.
      final equipmentMatches =
          workout.equipment == 'None' ||
          workout.equipment == preferredEquipment;

      if (equipmentMatches) {
        score += 40;
        reasons.add(
          workout.equipment == 'None'
              ? 'This workout requires no equipment.'
              : 'It matches your preferred equipment.',
        );
      } else {
        score -= 40;
        reasons.add(
          'It requires ${workout.equipment}, which differs '
          'from your preferred equipment.',
        );
      }

      // RULE 2: Preferred intensity (up to 30 points).
      final difference = (workout.intensity - preferredIntensity).abs();

      final intensityPoints = (30 - difference * 5).clamp(0, 30);

      score += intensityPoints;

      if (difference == 0) {
        reasons.add('Its intensity exactly matches your preference.');
      } else if (difference <= 2) {
        reasons.add('Its intensity is close to your preferred level.');
      } else {
        reasons.add('Its intensity differs from your preferred level.');
      }

      // Find previous sessions for this workout.
      final workoutLogs = logs
          .where((log) => log.workoutPlanId == workout.id)
          .toList();

      // RULE 3: Training recency (up to 20 points).
      if (workoutLogs.isEmpty) {
        score += 20;
        reasons.add('You have not completed this workout yet.');
      } else {
        final dates = workoutLogs
            .map((log) => DateTime.tryParse(log.completedAt))
            .whereType<DateTime>()
            .toList();

        if (dates.isEmpty) {
          reasons.add('Recent activity could not be determined.');
        } else {
          dates.sort();
          final latest = dates.last;

          final daysSince = currentTime.difference(latest).inDays;

          if (daysSince >= 7) {
            score += 20;
            reasons.add('You have not completed this workout recently.');
          } else if (daysSince >= 3) {
            score += 10;
            reasons.add('It has been a few days since your last session.');
          } else {
            reasons.add('You completed this workout recently.');
          }
        }
      }

      // RULE 4: Training frequency (up to 10 points).
      if (workoutLogs.isEmpty) {
        score += 10;
      } else if (workoutLogs.length <= 2) {
        score += 7;
        reasons.add('You have completed this workout only a few times.');
      } else if (workoutLogs.length <= 5) {
        score += 3;
      } else {
        reasons.add('This workout appears frequently in your history.');
      }

      return QuestRecommendation(
        workout: workout,
        score: score,
        reasons: reasons,
      );
    }).toList();

    // Highest score wins. Ties preserve the workout list order.
    recommendations.sort((a, b) => b.score.compareTo(a.score));

    return recommendations.first;
  }
}
