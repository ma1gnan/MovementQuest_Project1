import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/workout_plan.dart';
import '../services/next_quest_recommender.dart';
import 'active_workout_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<WorkoutPlan> workouts = [];
  QuestRecommendation? recommendation;

  String preferredEquipment = 'None';
  int preferredIntensity = 5;

  bool isLoading = true;
  bool isStarting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecommendation();
  }

  Future<void> _loadRecommendation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWorkouts = await _db.getAllWorkouts();
      final savedLogs = await _db.getAllTrainingLogs();

      final equipment = prefs.getString('preferred_equipment') ?? 'None';
      final intensity = (prefs.getInt('preferred_intensity') ?? 5).clamp(1, 10);

      final result = NextQuestRecommender.recommend(
        workouts: savedWorkouts,
        logs: savedLogs,
        preferredEquipment: equipment,
        preferredIntensity: intensity,
      );

      if (!mounted) return;

      setState(() {
        workouts = savedWorkouts;
        preferredEquipment = equipment;
        preferredIntensity = intensity;
        recommendation = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load recommendation.';
      });
    }
  }

  Future<void> _startQuest(WorkoutPlan workout) async {
    if (isStarting) return;

    setState(() {
      isStarting = true;
    });

    try {
      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveWorkoutScreen(workout: workout),
        ),
      );

      if (!mounted) return;

      if (completed == true) {
        // Refresh recommendation after a new training log.
        await _loadRecommendation();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quest completed! Your recommendation was updated.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isStarting = false;
        });
      }
    }
  }

  Future<void> _chooseAnotherWorkout() async {
    if (workouts.isEmpty) return;

    final selected = await showModalBottomSheet<WorkoutPlan>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text('Choose Another Workout'),
                subtitle: Text(
                  'You can override the recommendation at any time.',
                ),
              ),
              ...workouts.map(
                (workout) => ListTile(
                  title: Text(workout.name),
                  subtitle: Text(
                    '${workout.equipment} • '
                    'Intensity ${workout.intensity}/10',
                  ),
                  onTap: () => Navigator.pop(sheetContext, workout),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    await _startQuest(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Next Quest Helper'), centerTitle: true),
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
                      _loadRecommendation();
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
                  'Your Next Workout Recommendation',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Saved Preferences',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Equipment: $preferredEquipment'),
                        Text('Intensity: $preferredIntensity/10'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (recommendation == null)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No workouts available. '
                        'Create a workout to get a recommendation.',
                      ),
                    ),
                  )
                else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF82B4FF),
                              ),
                              SizedBox(width: 8),
                              Text('Recommended Quest'),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Text(
                            recommendation!.workout.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Exercise: '
                            '${recommendation!.workout.exercise}',
                          ),
                          Text(
                            'Equipment: '
                            '${recommendation!.workout.equipment}',
                          ),
                          Text(
                            'Intensity: '
                            '${recommendation!.workout.intensity}/10',
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Recommendation Score: '
                            '${recommendation!.score}',
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Why this workout?',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),

                          ...recommendation!.reasons.map(
                            (reason) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('• $reason'),
                            ),
                          ),

                          const SizedBox(height: 20),

                          FilledButton.icon(
                            onPressed: isStarting
                                ? null
                                : () => _startQuest(recommendation!.workout),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Recommended Quest'),
                          ),

                          const SizedBox(height: 8),

                          OutlinedButton.icon(
                            onPressed: isStarting
                                ? null
                                : _chooseAnotherWorkout,
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Choose Another'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                const Text(
                  'This recommendation uses transparent '
                  'rules based on equipment, intensity, '
                  'recency, and workout frequency. '
                  'It is not a medical recommendation '
                  'or a trained machine-learning model.',
                ),
              ],
            ),
    );
  }
}
