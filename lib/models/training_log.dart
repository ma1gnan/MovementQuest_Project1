class TrainingLog {
  final int? id;
  final int workoutPlanId;
  final int completedSets;
  final int actualReps;
  final String completedAt;
  final String reflection;

  const TrainingLog({
    this.id,
    required this.workoutPlanId,
    required this.completedSets,
    required this.actualReps,
    required this.completedAt,
    required this.reflection,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'workout_plan_id': workoutPlanId,
      'completed_sets': completedSets,
      'actual_reps': actualReps,
      'completed_at': completedAt,
      'reflection': reflection,
    };
  }

  factory TrainingLog.fromMap(Map<String, Object?> map) {
    return TrainingLog(
      id: map['id'] as int?,
      workoutPlanId: map['workout_plan_id'] as int,
      completedSets: map['completed_sets'] as int,
      actualReps: map['actual_reps'] as int,
      completedAt: map['completed_at'] as String,
      reflection: map['reflection'] as String,
    );
  }
}
