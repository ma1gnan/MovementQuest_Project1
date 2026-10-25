import 'package:flutter/material.dart';

import 'screens/active_workout_screen.dart';
import 'database/database_helper.dart';
import 'models/workout_plan.dart';
import 'screens/workout_form_screen.dart';
import 'screens/training_history_screen.dart';

void main() {
  runApp(const MovementQuestApp());
}

// Main application shell

class MovementQuestApp extends StatelessWidget {
  const MovementQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF173B70);
    const darkGrey = Color(0xFF242424);

    return MaterialApp(
      title: 'Movement Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        colorScheme: const ColorScheme.dark(
          primary: darkBlue,
          onPrimary: Colors.white,
          secondary: Color(0xFF82B4FF),
          surface: Colors.black,
          onSurface: Colors.white,
        ),

        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
        cardColor: darkGrey,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

        cardTheme: CardThemeData(
          color: darkGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: darkBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF91BEFF)),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF5579AD)),
          ),
        ),

        inputDecorationTheme: InputDecorationThemeData(
          filled: true,
          fillColor: darkGrey,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),

        sliderTheme: const SliderThemeData(
          activeTrackColor: Color(0xFF82B4FF),
          thumbColor: Color(0xFF82B4FF),
          inactiveTrackColor: Color(0xFF555555),
        ),
      ),
      home: const WorkoutDashboard(),
    );
  }
}

// Dashboard with changing filter state
class WorkoutDashboard extends StatefulWidget {
  const WorkoutDashboard({super.key});

  @override
  State<WorkoutDashboard> createState() => _WorkoutDashboardState();
}

class _WorkoutDashboardState extends State<WorkoutDashboard> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  String selectedEquipment = 'All';
  List<WorkoutPlan> workouts = [];

  int completedSessions = 0;
  bool isLoading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  // Read saved workouts and completed-session count.
  Future<void> _loadWorkouts() async {
    try {
      final savedWorkouts = await _db.getAllWorkouts();
      final sessionCount = await _db.getCompletedSessionCount();

      if (!mounted) return;

      setState(() {
        workouts = savedWorkouts;
        completedSessions = sessionCount;
        isLoading = false;
        loadError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadError = 'Unable to load saved workouts.';
      });
    }
  }

  void showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature will be added next.')));
  }

  // CREATE and UPDATE
  Future<void> _openWorkoutForm({WorkoutPlan? existingPlan}) async {
    final result = await Navigator.push<WorkoutPlan>(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutFormScreen(existingPlan: existingPlan),
      ),
    );

    if (!mounted || result == null) return;

    try {
      if (existingPlan == null) {
        await _db.insertWorkout(result);
      } else {
        await _db.updateWorkout(result.copyWith(id: existingPlan.id));
      }

      await _loadWorkouts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingPlan == null
                ? 'Workout saved to SQLite!'
                : 'Workout updated successfully!',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save workout. Please try again.'),
        ),
      );
    }
  }

  Future<void> _startWorkout(WorkoutPlan workout) async {
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveWorkoutScreen(workout: workout),
      ),
    );

    if (!mounted) return;

    if (completed == true) {
      await _loadWorkouts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quest completed! Training log saved.')),
      );
    }
  }

  // DELETE with confirmation
  Future<void> _deleteWorkout(WorkoutPlan workout) async {
    if (workout.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Workout?'),
        content: Text(
          'Delete "${workout.name}" and all its training logs? '
          'This action cannot be undone.',
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

    if (confirmed != true || !mounted) return;

    try {
      await _db.deleteWorkout(workout.id!);
      await _loadWorkouts();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Workout deleted.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete workout.')),
      );
    }
  }

  Future<void> _openTrainingHistory() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const TrainingHistoryScreen()),
    );

    if (!mounted) return;

    await _loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    final filteredWorkouts = workouts.where((workout) {
      return selectedEquipment == 'All' ||
          workout.equipment == selectedEquipment;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movement Quest'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => showComingSoon('Settings'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(loadError!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      setState(() => isLoading = true);
                      _loadWorkouts();
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
                  'Welcome to Movement Quest!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Choose a workout and begin your next quest.'),
                const SizedBox(height: 20),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 40,
                          color: Color(0xFF82B4FF),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Completed Sessions'),
                            Text(
                              '$completedSessions',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  initialValue: selectedEquipment,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Equipment',
                    border: OutlineInputBorder(),
                  ),
                  items: ['All', 'None', 'Dumbbells', 'Resistance Bands'].map((
                    equipment,
                  ) {
                    return DropdownMenuItem(
                      value: equipment,
                      child: Text(equipment),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedEquipment = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Available Workout Quests',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                if (filteredWorkouts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No workouts found. Create your first quest!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                ...filteredWorkouts.map(
                  (workout) => WorkoutCard(
                    workout: workout,
                    onStart: () => _startWorkout(workout),
                    onEdit: () => _openWorkoutForm(existingPlan: workout),
                    onDelete: () => _deleteWorkout(workout),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () => _openWorkoutForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Workout'),
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _openTrainingHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('View Training History'),
                ),
              ],
            ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final WorkoutPlan workout;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onStart,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(workout.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Exercise: ${workout.exercise}'),
            Text('Equipment: ${workout.equipment}'),
            Text(
              'Target: ${workout.sets} sets × '
              '${workout.reps} reps',
            ),
            Text('Intensity: ${workout.intensity}/10'),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
                FilledButton(
                  onPressed: onStart,
                  child: const Text('Start Quest'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
