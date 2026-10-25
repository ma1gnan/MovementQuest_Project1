import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String equipmentKey = 'preferred_equipment';
  static const String intensityKey = 'preferred_intensity';

  final List<String> equipmentOptions = [
    'None',
    'Dumbbells',
    'Resistance Bands',
  ];

  String preferredEquipment = 'None';
  double preferredIntensity = 5;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedEquipment = prefs.getString(equipmentKey) ?? 'None';

      final savedIntensity = prefs.getInt(intensityKey) ?? 5;

      if (!mounted) return;

      setState(() {
        preferredEquipment = equipmentOptions.contains(savedEquipment)
            ? savedEquipment
            : 'None';

        preferredIntensity = savedIntensity.clamp(1, 10).toDouble();

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load preferences.')),
      );
    }
  }

  Future<void> _savePreferences() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final equipmentSaved = await prefs.setString(
        equipmentKey,
        preferredEquipment,
      );

      final intensitySaved = await prefs.setInt(
        intensityKey,
        preferredIntensity.round(),
      );

      if (!equipmentSaved || !intensitySaved) {
        throw StateError('Could not save preferences');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved successfully!')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save preferences.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Workout Preferences',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Customize your preferred equipment and '
                  'workout intensity.',
                ),
                const SizedBox(height: 24),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferred Equipment',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          initialValue: preferredEquipment,
                          decoration: const InputDecoration(
                            labelText: 'Equipment',
                            border: OutlineInputBorder(),
                          ),
                          items: equipmentOptions.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() {
                                      preferredEquipment = value;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferred Intensity',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          '${preferredIntensity.round()} / 10',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),

                        Slider(
                          value: preferredIntensity,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: preferredIntensity.round().toString(),
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    preferredIntensity = value;
                                  });
                                },
                        ),

                        const Text(
                          '1 = Low intensity\n'
                          '10 = High intensity',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: isSaving ? null : _savePreferences,
                  icon: const Icon(Icons.save),
                  label: Text(isSaving ? 'Saving...' : 'Save Preferences'),
                ),
              ],
            ),
    );
  }
}
