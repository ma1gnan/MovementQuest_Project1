import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/training_log.dart';
import '../models/workout_plan.dart';

class TrainingHistoryScreen extends StatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  State<TrainingHistoryScreen> createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends State<TrainingHistoryScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<TrainingLog> logs = [];
  Map<int, WorkoutPlan> workoutLookup = {};

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final savedLogs = await _db.getAllTrainingLogs();
      final savedWorkouts = await _db.getAllWorkouts();

      if (!mounted) return;

      setState(() {
        logs = savedLogs;
        workoutLookup = {
          for (final workout in savedWorkouts)
            if (workout.id != null) workout.id!: workout,
        };
        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load training history.';
      });
    }
  }

  int get totalSets => logs.fold(0, (sum, log) => sum + log.completedSets);

  int get totalReps => logs.fold(0, (sum, log) => sum + log.actualReps);

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) return value;

    final local = date.toLocal();

    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');

    return '${local.year}-$month-$day';
  }

  Future<void> _editLog(TrainingLog log) async {
    final setsController = TextEditingController(
      text: log.completedSets.toString(),
    );

    final repsController = TextEditingController(
      text: log.actualReps.toString(),
    );

    final reflectionController = TextEditingController(text: log.reflection);

    final formKey = GlobalKey<FormState>();

    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Edit Training Log'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Completed Sets',
                    ),
                    validator: (value) {
                      final number = int.tryParse(value ?? '');

                      if (number == null || number < 0) {
                        return 'Enter a valid number of sets';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Repetitions',
                    ),
                    validator: (value) {
                      final number = int.tryParse(value ?? '');

                      if (number == null || number < 0) {
                        return 'Enter valid repetitions';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: reflectionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Workout Reflection',
                      hintText: 'How did your workout go?',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (!mounted || shouldSave != true) return;

      final updatedLog = TrainingLog(
        id: log.id,
        workoutPlanId: log.workoutPlanId,
        completedSets: int.parse(setsController.text),
        actualReps: int.parse(repsController.text),
        completedAt: log.completedAt,
        reflection: reflectionController.text.trim(),
      );

      await _db.updateTrainingLog(updatedLog);
      await _loadHistory();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Training log updated.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update training log.')),
      );
    } finally {
      // Delay disposal until the dialog has completed its exit animation.
      await Future<void>.delayed(const Duration(milliseconds: 300));

      setsController.dispose();
      repsController.dispose();
      reflectionController.dispose();
    }
  }

  Future<void> _deleteLog(TrainingLog log) async {
    if (log.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Training Log?'),
        content: const Text(
          'This completed workout record will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      await _db.deleteTrainingLog(log.id!);
      await _loadHistory();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Training log deleted.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete training log.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training History'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(errorMessage!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      setState(() => isLoading = true);
                      _loadHistory();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Your Workout Insights',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InsightCard(
                      label: 'Sessions',
                      value: '${logs.length}',
                      icon: Icons.emoji_events,
                    ),
                    _InsightCard(
                      label: 'Total Sets',
                      value: '$totalSets',
                      icon: Icons.fitness_center,
                    ),
                    _InsightCard(
                      label: 'Total Reps',
                      value: '$totalReps',
                      icon: Icons.repeat,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Completed Workouts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                if (logs.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No completed workouts yet. '
                        'Finish a quest to see it here.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                ...logs.map((log) {
                  final workout = workoutLookup[log.workoutPlanId];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout?.name ?? 'Workout #${log.workoutPlanId}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('Date: ${_formatDate(log.completedAt)}'),
                          Text('Completed Sets: ${log.completedSets}'),
                          Text('Total Reps: ${log.actualReps}'),
                          if (log.reflection.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text('Reflection: ${log.reflection}'),
                            ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton.icon(
                                onPressed: () => _editLog(log),
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                              ),
                              TextButton.icon(
                                onPressed: () => _deleteLog(log),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InsightCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF82B4FF)),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
