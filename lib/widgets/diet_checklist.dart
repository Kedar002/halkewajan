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

class _DietChecklistState extends State<DietChecklist>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  final List<_Meal> _meals = [
    _Meal(name: 'Breakfast', description: 'Oats & Banana', calories: 320),
    _Meal(name: 'Lunch', description: 'Grilled Chicken Salad', calories: 450),
    _Meal(name: 'Snack', description: 'Almonds & Green Tea', calories: 150),
    _Meal(name: 'Dinner', description: 'Dal Rice & Sabzi', calories: 520),
  ];

  int get _completedCount => _meals.where((m) => m.completed).length;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Delay to sync with parent entrance animation
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _rowFade(int index) {
    final start = (index * 0.18).clamp(0.0, 1.0);
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _rowSlide(int index) {
    final start = (index * 0.18).clamp(0.0, 1.0);
    final end = (start + 0.55).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      accentColor: AppTheme.calories,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.calories.withValues(alpha: 0.12),
                    borderRadius: AppTheme.borderRadiusPill,
                  ),
                  child: Text(
                    '${(_completedCount * 100 / _meals.length).round()}%',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppTheme.calories,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Meal list with staggered animation
          ...List.generate(_meals.length, (index) {
            final meal = _meals[index];
            final isLast = index == _meals.length - 1;

            return FadeTransition(
              opacity: _rowFade(index),
              child: SlideTransition(
                position: _rowSlide(index),
                child: Column(
                  children: [
                    Container(
                      height: 0.5,
                      margin:
                          const EdgeInsets.symmetric(horizontal: Spacing.lg),
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
                ),
              ),
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
        splashColor: AppTheme.calories.withValues(alpha: 0.05),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: AppTheme.animFast,
                curve: AppTheme.animCurve,
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

              // Calories with gradient when active
              if (!meal.completed)
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: AppTheme.caloriesGradient,
                  ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: Text(
                    '${meal.calories}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Text(
                  '${meal.calories}',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.3),
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
