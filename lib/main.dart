import 'package:flutter/material.dart';

import 'models/workout_plan.dart';
import 'screens/workout_form_screen.dart';

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
  String selectedEquipment = 'All';

  final List<WorkoutPlan> workouts = [
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

  Future<void> _openWorkoutForm({WorkoutPlan? existingPlan}) async {
    final result = await Navigator.push<WorkoutPlan>(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutFormScreen(existingPlan: existingPlan),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      if (existingPlan == null) {
        workouts.add(result);
      } else {
        final index = workouts.indexOf(existingPlan);

        if (index != -1) {
          workouts[index] = result;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existingPlan == null
              ? 'Workout created successfully!'
              : 'Workout updated successfully!',
        ),
      ),
    );
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
              onEdit: () => _openWorkoutForm(existingPlan: workout),
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
            onPressed: () => showComingSoon('Training History'),
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

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onStart,
    required this.onEdit,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Workout'),
                ),
              ],
            ),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onStart,
                child: const Text('Start Quest'),
              ), //Filled Button
            ), //Align
          ],
        ), //Column
      ), //Padding
    ); // Card
  }
}
