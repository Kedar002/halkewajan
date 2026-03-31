import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Day Log ─────────────────────────────────────────────

/// All data logged for a single day.
class DayLog {
  final DateTime date;
  final DayStatus status;

  // Diet
  final String? dietPlanName;
  final Color? dietPlanColor;
  final List<MealLog> meals;
  final int calorieGoal;

  // Workout
  final String? workoutName;
  final String? workoutDuration;
  final List<String> musclesWorked;
  final List<ExerciseLog> exercises;

  // Body
  final double? weight;
  final Map<String, MeasurementLog> measurements;

  // Hydration
  final double? waterLitres;

  const DayLog({
    required this.date,
    required this.status,
    this.dietPlanName,
    this.dietPlanColor,
    this.meals = const [],
    this.calorieGoal = 2000,
    this.workoutName,
    this.workoutDuration,
    this.musclesWorked = const [],
    this.exercises = const [],
    this.weight,
    this.measurements = const {},
    this.waterLitres,
  });

  int get totalCalories => meals.fold(0, (s, m) => s + m.totalCalories);
  int get totalProtein => meals.fold(0, (s, m) => s + m.totalProtein);
  int get totalCarbs => meals.fold(0, (s, m) => s + m.totalCarbs);
  int get totalFat => meals.fold(0, (s, m) => s + m.totalFat);

  int get totalVolume => exercises.fold(0, (s, e) => s + e.volume);
  int get totalSets => exercises.fold(0, (s, e) => s + e.sets);

  bool get hasDiet => meals.isNotEmpty;
  bool get hasWorkout => exercises.isNotEmpty;
  bool get hasWeight => weight != null;
  bool get hasMeasurements => measurements.isNotEmpty;
}

enum DayStatus { hit, missed, rest, noData }

// ─── Meal Log ────────────────────────────────────────────

class MealLog {
  final String name;
  final IconData icon;
  final List<FoodLog> foods;

  const MealLog({
    required this.name,
    required this.icon,
    this.foods = const [],
  });

  int get totalCalories => foods.fold(0, (s, f) => s + f.calories);
  int get totalProtein => foods.fold(0, (s, f) => s + f.protein);
  int get totalCarbs => foods.fold(0, (s, f) => s + f.carbs);
  int get totalFat => foods.fold(0, (s, f) => s + f.fat);
}

class FoodLog {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const FoodLog({
    required this.name,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });
}

// ─── Exercise Log ────────────────────────────────────────

class ExerciseLog {
  final String name;
  final int sets;
  final int reps;
  final int? weightKg;

  const ExerciseLog({
    required this.name,
    required this.sets,
    required this.reps,
    this.weightKg,
  });

  String get detail {
    final base = '${sets}x$reps';
    return weightKg != null ? '$base · ${weightKg}kg' : base;
  }

  int get volume => sets * reps * (weightKg ?? 0);
}

// ─── Measurement Log ─────────────────────────────────────

class MeasurementLog {
  final double value;
  final String unit;

  const MeasurementLog({required this.value, this.unit = 'in'});
}

// ─── Consistency Store (singleton) ───────────────────────

class ConsistencyStore {
  static final ConsistencyStore instance = ConsistencyStore._();
  ConsistencyStore._() {
    _generateDemoData();
  }

  final Map<DateTime, DayLog> _logs = {};

  /// Normalise date to midnight for consistent lookups.
  static DateTime _normalise(DateTime d) => DateTime(d.year, d.month, d.day);

  DayLog? getLog(DateTime date) => _logs[_normalise(date)];

  Map<DateTime, DayStatus> get allStatuses =>
      _logs.map((k, v) => MapEntry(k, v.status));

  // ── Streak helpers ──────────────────────────────────────

  int get currentStreak {
    var streak = 0;
    var day = _normalise(DateTime.now());
    // If today has no data yet, start from yesterday
    if (!_logs.containsKey(day) ||
        _logs[day]!.status == DayStatus.noData) {
      day = day.subtract(const Duration(days: 1));
    }
    while (true) {
      final log = _logs[day];
      if (log == null) break;
      if (log.status == DayStatus.hit || log.status == DayStatus.rest) {
        streak++;
      } else {
        break;
      }
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get longestStreak {
    var longest = 0;
    var current = 0;
    final sorted = _logs.keys.toList()..sort();
    for (final date in sorted) {
      final s = _logs[date]!.status;
      if (s == DayStatus.hit || s == DayStatus.rest) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
    }
    return longest;
  }

  double monthConsistency(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final today = _normalise(DateTime.now());
    var total = 0;
    var hits = 0;
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      if (date.isAfter(today)) break;
      total++;
      final log = _logs[date];
      if (log != null &&
          (log.status == DayStatus.hit || log.status == DayStatus.rest)) {
        hits++;
      }
    }
    return total > 0 ? hits / total : 0;
  }

  // ── Demo data generation ──────────────────────────────

  static const _pushExercises = [
    ExerciseLog(name: 'Bench Press', sets: 4, reps: 10, weightKg: 60),
    ExerciseLog(name: 'Incline Dumbbell Press', sets: 3, reps: 12, weightKg: 20),
    ExerciseLog(name: 'Cable Flyes', sets: 3, reps: 15),
    ExerciseLog(name: 'Overhead Press', sets: 3, reps: 10, weightKg: 40),
    ExerciseLog(name: 'Tricep Pushdowns', sets: 3, reps: 12),
  ];

  static const _pullExercises = [
    ExerciseLog(name: 'Deadlift', sets: 4, reps: 8, weightKg: 80),
    ExerciseLog(name: 'Barbell Rows', sets: 4, reps: 10, weightKg: 50),
    ExerciseLog(name: 'Lat Pulldowns', sets: 3, reps: 12),
    ExerciseLog(name: 'Face Pulls', sets: 3, reps: 15),
    ExerciseLog(name: 'Barbell Curls', sets: 3, reps: 12, weightKg: 20),
  ];

  static const _legExercises = [
    ExerciseLog(name: 'Barbell Squats', sets: 4, reps: 10, weightKg: 70),
    ExerciseLog(name: 'Romanian Deadlift', sets: 3, reps: 12, weightKg: 50),
    ExerciseLog(name: 'Leg Press', sets: 3, reps: 12, weightKg: 100),
    ExerciseLog(name: 'Walking Lunges', sets: 3, reps: 12),
    ExerciseLog(name: 'Calf Raises', sets: 4, reps: 15),
  ];

  static const _breakfastFoods = [
    FoodLog(name: 'Oats & Banana', calories: 320, protein: 12, carbs: 55, fat: 6),
    FoodLog(name: 'Egg White Omelette', calories: 180, protein: 26, carbs: 2, fat: 5),
    FoodLog(name: 'Greek Yogurt Bowl', calories: 250, protein: 18, carbs: 30, fat: 8),
  ];

  static const _lunchFoods = [
    FoodLog(name: 'Grilled Chicken Salad', calories: 450, protein: 42, carbs: 15, fat: 22),
    FoodLog(name: 'Dal Rice & Sabzi', calories: 520, protein: 18, carbs: 75, fat: 12),
    FoodLog(name: 'Paneer Tikka Wrap', calories: 480, protein: 28, carbs: 42, fat: 20),
  ];

  static const _snackFoods = [
    FoodLog(name: 'Almonds & Green Tea', calories: 150, protein: 5, carbs: 6, fat: 12),
    FoodLog(name: 'Protein Bar', calories: 200, protein: 20, carbs: 22, fat: 8),
    FoodLog(name: 'Fruit Bowl', calories: 120, protein: 2, carbs: 28, fat: 1),
  ];

  static const _dinnerFoods = [
    FoodLog(name: 'Grilled Fish & Veggies', calories: 380, protein: 38, carbs: 12, fat: 18),
    FoodLog(name: 'Chicken Curry & Roti', calories: 550, protein: 35, carbs: 48, fat: 22),
    FoodLog(name: 'Tofu Stir Fry & Rice', calories: 420, protein: 22, carbs: 55, fat: 14),
  ];

  void _generateDemoData() {
    final rng = math.Random(42);
    final today = _normalise(DateTime.now());

    for (var i = 0; i < 120; i++) {
      final date = today.subtract(Duration(days: i));
      final weekday = date.weekday; // 1=Mon … 7=Sun

      // Rest days: Thursday (4) and Sunday (7)
      final isRestDay = weekday == 4 || weekday == 7;

      // ~15% chance of a missed day, ~8% no data
      final roll = rng.nextDouble();
      DayStatus status;
      if (roll < 0.08) {
        // No data — user didn't log anything
        _logs[date] = DayLog(date: date, status: DayStatus.noData);
        continue;
      } else if (roll < 0.20) {
        status = DayStatus.missed;
      } else if (isRestDay) {
        status = DayStatus.rest;
      } else {
        status = DayStatus.hit;
      }

      // ── Diet ──
      final bf = _breakfastFoods[rng.nextInt(_breakfastFoods.length)];
      final lunch = _lunchFoods[rng.nextInt(_lunchFoods.length)];
      final snack = _snackFoods[rng.nextInt(_snackFoods.length)];
      final dinner = _dinnerFoods[rng.nextInt(_dinnerFoods.length)];

      final meals = [
        MealLog(name: 'Breakfast', icon: Icons.wb_sunny_rounded, foods: [bf]),
        MealLog(name: 'Lunch', icon: Icons.restaurant_rounded, foods: [lunch]),
        MealLog(name: 'Snack', icon: Icons.local_cafe_rounded, foods: [snack]),
        MealLog(name: 'Dinner', icon: Icons.nightlight_round, foods: [dinner]),
      ];

      // If missed, randomly remove 1-2 meals to simulate incomplete logging
      final mealList = List<MealLog>.from(meals);
      if (status == DayStatus.missed) {
        final removals = 1 + rng.nextInt(2);
        for (var r = 0; r < removals && mealList.length > 1; r++) {
          mealList.removeAt(rng.nextInt(mealList.length));
        }
      }

      // ── Workout ──
      String? workoutName;
      String? workoutDuration;
      List<String> muscles = [];
      List<ExerciseLog> exercises = [];

      if (!isRestDay) {
        // PPL rotation: Mon=Push, Tue=Pull, Wed=Legs, Fri=Push, Sat=Pull
        final dayMod = weekday % 3;
        if (dayMod == 1) {
          workoutName = 'Push Day';
          workoutDuration = '~45 min';
          muscles = ['Chest', 'Shoulders', 'Triceps'];
          exercises = _pushExercises;
        } else if (dayMod == 2) {
          workoutName = 'Pull Day';
          workoutDuration = '~50 min';
          muscles = ['Back', 'Biceps', 'Rear Delts'];
          exercises = _pullExercises;
        } else {
          workoutName = 'Leg Day';
          workoutDuration = '~50 min';
          muscles = ['Quads', 'Hamstrings', 'Glutes'];
          exercises = _legExercises;
        }

        // If missed, maybe skip workout
        if (status == DayStatus.missed && rng.nextBool()) {
          workoutName = null;
          workoutDuration = null;
          muscles = [];
          exercises = [];
        }
      }

      // ── Weight ── (logged ~3 times per week)
      double? weight;
      if (rng.nextDouble() < 0.45) {
        // Gradual decline from 85 to ~78.5 over 120 days
        final progress = i / 120.0;
        weight = 85.0 - (progress * 6.5) + (rng.nextDouble() * 0.8 - 0.4);
        weight = double.parse(weight.toStringAsFixed(1));
      }

      // ── Measurements ── (logged ~once per week)
      Map<String, MeasurementLog> measurements = {};
      if (weekday == 1 && rng.nextDouble() < 0.7) {
        final weekNum = i ~/ 7;
        measurements = {
          'Chest': MeasurementLog(value: 40.0 + weekNum * 0.04),
          'Waist': MeasurementLog(value: 34.0 - weekNum * 0.1),
          'Arms': MeasurementLog(value: 13.5 + weekNum * 0.03),
          'Thighs': MeasurementLog(value: 21.5 + weekNum * 0.02),
        };
      }

      // ── Water ──
      final water = 1.5 + rng.nextDouble() * 2.5;

      _logs[date] = DayLog(
        date: date,
        status: status,
        dietPlanName: isRestDay ? 'Light Diet' : 'Balanced Diet',
        dietPlanColor: isRestDay
            ? const Color(0xFF5AC8FA)
            : const Color(0xFF00E676),
        meals: mealList,
        calorieGoal: 2000,
        workoutName: workoutName,
        workoutDuration: workoutDuration,
        musclesWorked: muscles,
        exercises: exercises,
        weight: weight,
        measurements: measurements,
        waterLitres: double.parse(water.toStringAsFixed(1)),
      );
    }
  }
}
