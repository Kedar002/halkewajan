import 'package:flutter/material.dart';

// ─── Food Item ────────────────────────────────────────────

class DietFoodItem {
  String name;
  int calories;
  int protein;
  int carbs;
  int fat;

  DietFoodItem({
    required this.name,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });
}

// ─── Meal ─────────────────────────────────────────────────

class DietMeal {
  String name;
  IconData icon;
  List<DietFoodItem> foods;

  DietMeal({
    required this.name,
    required this.icon,
    List<DietFoodItem>? foods,
  }) : foods = foods ?? [];

  int get totalCalories => foods.fold(0, (s, f) => s + f.calories);
  int get totalProtein  => foods.fold(0, (s, f) => s + f.protein);
  int get totalCarbs    => foods.fold(0, (s, f) => s + f.carbs);
  int get totalFat      => foods.fold(0, (s, f) => s + f.fat);
}

// ─── Diet Plan ────────────────────────────────────────────

class DietPlan {
  final String id;
  String name;
  String tag;
  Color tagColor;
  List<DietMeal> meals;

  DietPlan({
    required this.id,
    required this.name,
    this.tag = 'Custom',
    this.tagColor = const Color(0xFF00E676),
    List<DietMeal>? meals,
  }) : meals = meals ?? [];

  int get totalCalories => meals.fold(0, (s, m) => s + m.totalCalories);
  int get totalProtein  => meals.fold(0, (s, m) => s + m.totalProtein);
  int get totalCarbs    => meals.fold(0, (s, m) => s + m.totalCarbs);
  int get totalFat      => meals.fold(0, (s, m) => s + m.totalFat);
}

// ─── In-Memory Store (singleton) ──────────────────────────

class DietPlansStore {
  static final DietPlansStore instance = DietPlansStore._();
  DietPlansStore._();

  final List<DietPlan> plans = [];
  final Map<int, String> _dayAssignments = {}; // 0=Mon … 6=Sun → planId

  DietPlan? getPlanForDay(int day) {
    final id = _dayAssignments[day];
    if (id == null) return null;
    try {
      return plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void assignPlanToDay(int day, String planId) =>
      _dayAssignments[day] = planId;

  void removePlanFromDay(int day) => _dayAssignments.remove(day);

  bool isDayAssigned(int day) => _dayAssignments.containsKey(day);

  List<int> getDaysForPlan(String planId) =>
      _dayAssignments.entries
          .where((e) => e.value == planId)
          .map((e) => e.key)
          .toList();

  void deletePlan(String planId) {
    plans.removeWhere((p) => p.id == planId);
    _dayAssignments.removeWhere((_, v) => v == planId);
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
