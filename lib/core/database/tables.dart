class Tables {
  static const String breathingSessions = 'breathing_sessions';
  static const String meals = 'meals';
  static const String weightEntries = 'weight_entries';
  static const String exerciseLogs = 'exercise_logs';
  static const String exercisePlan = 'exercise_plan';
  static const String exercisePlanProgress = 'exercise_plan_progress';

  static const String createBreathingSessions = '''
CREATE TABLE breathing_sessions (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  date              TEXT    NOT NULL,
  pattern_name      TEXT    NOT NULL,
  inhale_seconds    INTEGER NOT NULL,
  hold_seconds      INTEGER NOT NULL,
  exhale_seconds    INTEGER NOT NULL,
  cycles_completed  INTEGER NOT NULL
)
''';

  static const String createMeals = '''
CREATE TABLE meals (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  date         TEXT    NOT NULL,
  time_of_day  TEXT    NOT NULL CHECK(time_of_day IN ('breakfast','lunch','dinner','snack')),
  description  TEXT    NOT NULL,
  quantity     TEXT    NOT NULL DEFAULT '',
  notes        TEXT
)
''';

  static const String createWeightEntries = '''
CREATE TABLE weight_entries (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  date       TEXT    NOT NULL UNIQUE,
  weight_kg  REAL    NOT NULL
)
''';

  static const String createExerciseLogs = '''
CREATE TABLE exercise_logs (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  date        TEXT    NOT NULL,
  exercise_id TEXT    NOT NULL,
  completed   INTEGER NOT NULL DEFAULT 1
)
''';

  static const String createExercisePlan = '''
CREATE TABLE exercise_plan (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  exercise_id TEXT    NOT NULL UNIQUE,
  added_at    TEXT    NOT NULL
)
''';

  static const String createExercisePlanProgress = '''
CREATE TABLE exercise_plan_progress (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  date        TEXT    NOT NULL,
  exercise_id TEXT    NOT NULL,
  reps_done   INTEGER NOT NULL,
  UNIQUE(exercise_id, date)
)
''';
}
