import 'package:flutter/material.dart';

import '../models/workout_plan.dart';

class WorkoutFormScreen extends StatefulWidget {
  final WorkoutPlan? existingPlan;

  const WorkoutFormScreen({super.key, this.existingPlan});

  @override
  State<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _exerciseController;
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;

  String _equipment = 'None';
  double _intensity = 5;

  @override
  void initState() {
    super.initState();

    final plan = widget.existingPlan;

    _nameController = TextEditingController(text: plan?.name ?? '');
    _exerciseController = TextEditingController(text: plan?.exercise ?? '');
    _setsController = TextEditingController(text: '${plan?.sets ?? 3}');
    _repsController = TextEditingController(text: '${plan?.reps ?? 12}');

    _equipment = plan?.equipment ?? 'None';
    _intensity = (plan?.intensity ?? 5).toDouble();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  String? _validateText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    final number = int.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return 'Enter a whole number greater than 0';
    }

    if (number > 1000) {
      return 'Enter a number no greater than 1000';
    }

    return null;
  }

  void _saveWorkout() {
    if (!_formKey.currentState!.validate()) return;

    final workout = WorkoutPlan(
      name: _nameController.text.trim(),
      exercise: _exerciseController.text.trim(),
      equipment: _equipment,
      sets: int.parse(_setsController.text.trim()),
      reps: int.parse(_repsController.text.trim()),
      intensity: _intensity.round(),
    );

    Navigator.pop(context, workout);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existingPlan != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Workout' : 'Create Workout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                border: OutlineInputBorder(),
              ),
              validator: _validateText,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _exerciseController,
              decoration: const InputDecoration(
                labelText: 'Exercise',
                border: OutlineInputBorder(),
              ),
              validator: _validateText,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Sets',
                border: OutlineInputBorder(),
              ),
              validator: _validateNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Repetitions',
                border: OutlineInputBorder(),
              ),
              validator: _validateNumber,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _equipment,
              decoration: const InputDecoration(
                labelText: 'Equipment',
                border: OutlineInputBorder(),
              ),
              items: ['None', 'Dumbbells', 'Resistance Bands']
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _equipment = value);
                }
              },
            ),
            const SizedBox(height: 20),
            Text('Intensity: ${_intensity.round()}/10'),
            Slider(
              value: _intensity,
              min: 1,
              max: 10,
              divisions: 9,
              label: '${_intensity.round()}',
              onChanged: (value) {
                setState(() => _intensity = value);
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saveWorkout,
              icon: const Icon(Icons.save),
              label: Text(editing ? 'Save Changes' : 'Save Workout'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
