import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class _Meal {
  final String name;
  final String description;
  final int calories;
  bool completed = false;

  _Meal({
    required this.name,
    required this.description,
    required this.calories,
  });
}

class DietChecklist extends StatefulWidget {
  const DietChecklist({super.key});

  @override
  State<DietChecklist> createState() => _DietChecklistState();
}

class _DietChecklistState extends State<DietChecklist> {
  final List<_Meal> _meals = [
    _Meal(name: 'Breakfast', description: 'Oats & Banana', calories: 320),
    _Meal(name: 'Lunch', description: 'Grilled Chicken Salad', calories: 450),
    _Meal(name: 'Snack', description: 'Almonds & Green Tea', calories: 150),
    _Meal(name: 'Dinner', description: 'Dal Rice & Sabzi', calories: 520),
  ];

  int get _completedCount => _meals.where((m) => m.completed).length;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg, Spacing.lg, Spacing.lg, Spacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TODAY'S MEALS", style: textTheme.labelMedium),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      '$_completedCount of ${_meals.length} completed',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
                // Progress pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.12),
                    borderRadius: AppTheme.borderRadiusPill,
                  ),
                  child: Text(
                    '${(_completedCount * 100 / _meals.length).round()}%',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Meal list
          ...List.generate(_meals.length, (index) {
            final meal = _meals[index];
            final isLast = index == _meals.length - 1;

            return Column(
              children: [
                // Divider
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                _MealRow(
                  meal: meal,
                  onToggle: () {
                    setState(() => meal.completed = !meal.completed);
                  },
                ),
                if (isLast) const SizedBox(height: Spacing.sm),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final _Meal meal;
  final VoidCallback onToggle;

  const _MealRow({required this.meal, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        splashColor: AppTheme.accent.withValues(alpha: 0.05),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              // Custom checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: meal.completed
                      ? AppTheme.accent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: meal.completed
                        ? AppTheme.accent
                        : Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: meal.completed
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.black,
                      )
                    : null,
              ),

              const SizedBox(width: Spacing.md),

              // Meal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: textTheme.titleSmall?.copyWith(
                        decoration: meal.completed
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: Colors.white.withValues(alpha: 0.3),
                        color: meal.completed
                            ? Colors.white.withValues(alpha: 0.4)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: meal.completed
                            ? Colors.white.withValues(alpha: 0.2)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              // Calories
              Text(
                '${meal.calories}',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: meal.completed
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppTheme.calories,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                'cal',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: meal.completed
                      ? Colors.white.withValues(alpha: 0.2)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
