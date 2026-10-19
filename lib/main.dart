import 'package:flutter/material.dart';

void main() {
  runApp(const MovementQuestApp());
}

// Main application shell
class MovementQuestApp extends StatelessWidget {
  const MovementQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movement Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WorkoutDashboard(),
    );
  }
}

// Sample workout data
class WorkoutPlan {
  final String name;
  final String exercise;
  final String equipment;
  final int sets;
  final int reps;
  final int intensity;

  const WorkoutPlan({
    required this.name,
    required this.exercise,
    required this.equipment,
    required this.sets,
    required this.reps,
    required this.intensity,
  });
}

// Dashboard with changing filter state
class WorkoutDashboard extends StatefulWidget {
  const WorkoutDashboard({super.key});

  @override
  State<WorkoutDashboard> createState() => _WorkoutDashboardState();
}

class _WorkoutDashboardState extends State<WorkoutDashboard> {
  String selectedEquipment = 'All';

  final List<WorkoutPlan> workouts = const [
    WorkoutPlan(
      name: 'Full Body Basics',
      exercise: 'Squats',
      equipment: 'None',
      sets: 3,
      reps: 12,
      intensity: 5,
    ),
    WorkoutPlan(
      name: 'Upper Body Quest',
      exercise: 'Dumbbell Curls',
      equipment: 'Dumbbells',
      sets: 4,
      reps: 10,
      intensity: 6,
    ),
    WorkoutPlan(
      name: 'Core Challenge',
      exercise: 'Crunches',
      equipment: 'None',
      sets: 3,
      reps: 15,
      intensity: 4,
    ),
  ];

  // Placeholder until SQLite training logs are implemented.
  final int completedSessions = 0;

  void showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature will be added next.')));
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome to Movement Quest!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Choose a workout and begin your next quest.'),
          const SizedBox(height: 20),

          // Completed session summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 40,
                    color: Colors.deepPurple,
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

          // Equipment filter
          DropdownButtonFormField<String>(
            initialValue: selectedEquipment,
            decoration: const InputDecoration(
              labelText: 'Filter by Equipment',
              border: OutlineInputBorder(),
            ),
            items: ['All', 'None', 'Dumbbells', 'Resistance Bands']
                .map(
                  (equipment) => DropdownMenuItem(
                    value: equipment,
                    child: Text(equipment),
                  ),
                )
                .toList(),
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
                  'No workouts match this equipment filter.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Reusable stateless workout cards
          ...filteredWorkouts.map(
            (workout) => WorkoutCard(
              workout: workout,
              onStart: () => showComingSoon('${workout.name} workout tracking'),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () => showComingSoon('Create Workout'),
            icon: const Icon(Icons.add),
            label: const Text('Create New Workout'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => showComingSoon('Training History'),
            icon: const Icon(Icons.history),
            label: const Text('View Training History'),
          ),
        ],
      ),
    );
  }
}

// Reusable stateless display widget
class WorkoutCard extends StatelessWidget {
  final WorkoutPlan workout;
  final VoidCallback onStart;

  const WorkoutCard({super.key, required this.workout, required this.onStart});

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
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onStart,
                child: const Text('Start Quest'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
