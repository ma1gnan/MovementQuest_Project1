# Movement Quest — Next Quest Recommendation Helper

## 1. Feature Overview

Movement Quest includes a rule-based Next Quest Recommendation Helper that suggests a workout based on the user's preferences and training history.

The helper considers four factors:

- Preferred equipment
- Preferred workout intensity
- How recently each workout was completed
- How frequently each workout has been completed

The purpose is to help users choose their next workout without requiring them to manually compare every available workout plan.

**AI approach:** This is an introductory, AI-inspired decision-support feature implemented using deterministic Dart rules. It is not a trained machine-learning model or a generative AI system.

## 2. Inputs and Outputs

**Inputs:**

- Workout plans stored in SQLite
- Training logs stored in SQLite
- Preferred equipment stored using SharedPreferences
- Preferred intensity stored using SharedPreferences
- Current date and time for recency calculations

**Outputs:**

- Recommended workout plan
- Numerical recommendation score
- Human-readable explanation
- Option to start the recommended workout
- Option to choose a different workout

## 3. Recommendation Algorithm

The algorithm is implemented in `lib/services/next_quest_recommender.dart`.

Each available workout receives a score using four rules.

| Factor | Scoring |
|---|---|
| Equipment compatibility | +40 for compatible equipment; −40 otherwise |
| Intensity similarity | Up to +30, decreasing by 5 points per intensity level of difference |
| Training recency | +20 if never completed or last completed at least 7 days ago; +10 if last completed 3–6 days ago |
| Training frequency | +10 if never completed; +7 for 1–2 sessions; +3 for 3–5 sessions; +0 for more than 5 sessions |

The workout with the highest score is recommended. Ties retain the original workout-list order.

Workouts requiring no equipment are treated as compatible with any equipment preference.

## 4. Baseline Comparison

The baseline method recommends the first workout in the available workout list, regardless of the user's preferences or training history.

The enhanced helper instead calculates a score for each workout and selects the highest-scoring plan.

**Baseline limitations:** The first workout might require unavailable equipment, differ substantially from the user's preferred intensity, or have been completed recently.

**Enhanced approach:** The recommendation responds to saved preferences and recorded activity, and provides an explanation.

The enhanced approach is more personalized by design, but it does not guarantee a better fitness outcome.

## 5. Explainability and User Control

The recommendation screen displays the suggested workout's name, exercise, equipment, intensity, score, and reasons.

Users can select **Start Recommended Quest** to begin the suggested workout.

Users can select **Choose Another** to override the recommendation and start a different workout.

The helper does not automatically begin a workout, modify workout plans, or delete training records.

## 6. Test Cases

The following cases define expected algorithm behavior. They should be verified using automated unit tests.

| Case | Input situation | Expected behavior |
|---|---|---|
| 1. Empty catalog | No workout plans | Return no recommendation |
| 2. Exact match | Compatible equipment, matching intensity, no prior logs | Recommend the exact-match workout when competing plans score lower |
| 3. Equipment mismatch | One compatible and one incompatible plan with otherwise equal scores | Prefer the compatible plan |
| 4. Recency | Two otherwise equal plans, one completed today and one at least 7 days ago | Prefer the less-recently completed plan |
| 5. Frequency | Two otherwise equal plans, one completed once and one completed more than five times | Prefer the less-frequently completed plan |

Additional interface checks were performed on the Pixel emulator, including recommendation display, explanation visibility, starting a quest, manual override, session completion, and restart behavior.

## 7. Limitations and Responsible Use

The helper is a workout-planning aid, not a medical or professional fitness recommendation.

Its scoring weights are developer-defined and have not been clinically validated.

The current equipment rule penalizes incompatible workouts but does not exclude them completely. The app displays equipment requirements so users can make their own decisions.

Training frequency uses the total number of saved sessions rather than a rolling time window.

Recency depends on valid timestamps in the training logs.

The helper does not evaluate injury risk, medical conditions, recovery needs, exercise technique, or whether a workout is safe for a particular person.

## 8. Privacy and Offline Operation

Workout plans and training logs are stored locally using SQLite.

Equipment and intensity preferences are stored locally using SharedPreferences.

The recommendation algorithm runs in Dart without requiring an internet connection or sending workout information to an external AI service.

## 9. Implementation Files

- `lib/services/next_quest_recommender.dart` — recommendation scoring and explanations
- `lib/screens/recommendation_screen.dart` — recommendation display and manual override
- `lib/models/workout_plan.dart` — workout plan data
- `lib/models/training_log.dart` — completed-session data
- `lib/database/database_helper.dart` — local SQLite persistence
- `lib/screens/settings_screen.dart` — saved user preferences

## 10. Future Improvements

Possible improvements include stricter equipment filtering, user-adjustable scoring weights, a configurable recent-history window, richer exercise tracking, and additional evaluation against a baseline.

These are future enhancements and are not claimed as implemented features.