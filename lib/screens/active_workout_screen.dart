import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/training_log.dart';
import '../models/workout_plan.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutPlan workout;

  const ActiveWorkoutScreen({super.key, required this.workout});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int completedSets = 0;
  bool isSaving = false;

  int get targetSets => widget.workout.sets;

  double get progress {
    if (targetSets == 0) return 0;
    return completedSets / targetSets;
  }

  void _completeSet() {
    if (completedSets >= targetSets) return;

    setState(() {
      completedSets++;
    });
  }

  void _undoSet() {
    if (completedSets <= 0) return;

    setState(() {
      completedSets--;
    });
  }

  void _resetWorkout() {
    setState(() {
      completedSets = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout progress has been reset.')),
    );
  }

  Future<void> _finishWorkout() async {
    if (completedSets == 0 || isSaving) return;

    if (widget.workout.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This workout has not been saved yet.')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final log = TrainingLog(
      workoutPlanId: widget.workout.id!,
      completedSets: completedSets,
      actualReps: completedSets * widget.workout.reps,
      completedAt: DateTime.now().toIso8601String(),
      reflection: '',
    );

    try {
      await DatabaseHelper.instance.insertTrainingLog(log);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save workout session.')),
      );
    }
  }

  Future<bool> _confirmLeave() async {
    if (completedSets == 0) return true;

    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Workout?'),
        content: const Text('Your unfinished workout progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;

    return PopScope(
      canPop: completedSets == 0 && !isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || isSaving) return;

        final leave = await _confirmLeave();

        if (!mounted || !leave) return;

        Navigator.of(this.context).pop();
      },

      child: Scaffold(
        appBar: AppBar(title: const Text('Active Workout'), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              workout.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Complete your sets to finish this quest.'),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text('Exercise: ${workout.exercise}'),
                    Text('Equipment: ${workout.equipment}'),
                    Text('Target Sets: ${workout.sets}'),
                    Text('Reps per Set: ${workout.reps}'),
                    Text('Intensity: ${workout.intensity}/10'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Workout Progress',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      '$completedSets / $targetSets sets',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),

                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(8),
                    ),

                    const SizedBox(height: 20),

                    FilledButton.icon(
                      onPressed: completedSets < targetSets && !isSaving
                          ? _completeSet
                          : null,
                      icon: const Icon(Icons.check),
                      label: const Text('Complete Set'),
                    ),

                    const SizedBox(height: 8),

                    OutlinedButton.icon(
                      onPressed: completedSets > 0 && !isSaving
                          ? _undoSet
                          : null,
                      icon: const Icon(Icons.undo),
                      label: const Text('Undo Last Set'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: completedSets > 0 && !isSaving ? _resetWorkout : null,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset Progress'),
            ),

            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: completedSets > 0 && !isSaving ? _finishWorkout : null,
              icon: const Icon(Icons.flag),
              label: Text(isSaving ? 'Saving...' : 'Finish Quest'),
            ),
          ],
        ),
      ),
    );
  }
}
