# Movement Quest

**Project 1 — Mobile Application Development**

**Developer:** Deborah Maignan  
**Pathway:** Undergraduate  
**Framework:** Flutter / Dart  
**Platform:** Android  
**Development Tools:** Visual Studio Code and Android Studio  

## Project Overview

Movement Quest is a personal workout companion application designed to help GSU students create workout plans, track exercise progress, and review their training activities.

This application uses a quest theme to make workout planning more engaging. Its goal is to provide a simple, organized workout.

## Implementation

### 1. Workout Dashboard

The Workout Dashboard is the application's main screen.

Current features include:

- Displays some sample workout plans: Full Body Basics, Upper Body Quest, etc.
- Displaying workoutnames, exercises, equipment, target sets, repetitions, and intensity.
- Students can to filter workouts by equipment.
- Displays an empty-state message when no workouts match.
- Provides buttons to create workouts, edit existing workouts, and start a workout.

### 2. Create/Edit Workout Screen

The Create/Edit Workout screen gives students the option to enter and modify workout info.

Implemented features include:

- Workout name
- Exercise name
- Target sets and repetitions
- Equipment selection
- Intensity slider ranging from 1 to 10.
- Save Workout, Save Changes, and Cancel buttons
- Form validation for required fields and invalid numeric values

New workouts are added to the dashboard, and existing workouts can be edited.


### 3. Dark Theme

Movement Quest uses a dark theme:

| Interface Element | Color |
|---|---|
| Background | Black |
| Workout | Dark Grey |
| Primary buttons | Dark Blue |
| Main text | White |
| Other color | Light Blue |


**File Responsibilities**

- `main.dart`: Application entry point, theme, dashboard, workouts, and navigation.
- `workout_plan.dart`: WorkoutPlan data model.
- `workout_form_screen.dart`: Workout creation and editing.
- `widget_test.dart`: Automated dashboard widget test.
