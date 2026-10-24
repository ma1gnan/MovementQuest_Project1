class WorkoutPlan {
  final int? id;
  final String name;
  final String exercise;
  final String equipment;
  final int sets;
  final int reps;
  final int intensity;

  const WorkoutPlan({
    this.id,
    required this.name,
    required this.exercise,
    required this.equipment,
    required this.sets,
    required this.reps,
    required this.intensity,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'exercise': exercise,
      'equipment': equipment,
      'sets': sets,
      'reps': reps,
      'intensity': intensity,
    };
  }

  factory WorkoutPlan.fromMap(Map<String, Object?> map) {
    return WorkoutPlan(
      id: map['id'] as int?,
      name: map['name'] as String,
      exercise: map['exercise'] as String,
      equipment: map['equipment'] as String,
      sets: map['sets'] as int,
      reps: map['reps'] as int,
      intensity: map['intensity'] as int,
    );
  }

  WorkoutPlan copyWith({
    int? id,
    String? name,
    String? exercise,
    String? equipment,
    int? sets,
    int? reps,
    int? intensity,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      exercise: exercise ?? this.exercise,
      equipment: equipment ?? this.equipment,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      intensity: intensity ?? this.intensity,
    );
  }
}
