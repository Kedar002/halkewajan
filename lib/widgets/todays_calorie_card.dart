import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';
import 'stat_ring.dart';

/// Compact calorie summary card for the home dashboard.
/// Shows a small ring + consumed/remaining/goal + macro dots.
class TodaysCalorieCard extends StatelessWidget {
  final int consumed;
  final int goal;
  final int protein;
  final int carbs;
  final int fat;

  const TodaysCalorieCard({
    super.key,
    this.consumed = 1320,
    this.goal = 2000,
    this.protein = 85,
    this.carbs = 140,
    this.fat = 32,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final remaining = (goal - consumed).clamp(0, goal);
    final progress = (consumed / goal).clamp(0.0, 1.0);

    return GlassCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Row(
        children: [
          // Compact ring
          StatRing(
            progress: progress,
            color: AppTheme.calories,
            value: '$consumed',
            unit: 'kcal',
            size: 96,
            strokeWidth: 10,
          ),

          const SizedBox(width: Spacing.lg),

          // Right side: remaining + macros
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Remaining insight
                Text(
                  '$remaining kcal left',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'of $goal goal',
                  style: textTheme.bodySmall,
                ),

                const SizedBox(height: Spacing.md),

                // Macro dots row
                Row(
                  children: [
                    _MacroDot(
                      color: AppTheme.protein,
                      label: 'P',
                      value: '${protein}g',
                    ),
                    const SizedBox(width: Spacing.md),
                    _MacroDot(
                      color: AppTheme.carbs,
                      label: 'C',
                      value: '${carbs}g',
                    ),
                    const SizedBox(width: Spacing.md),
                    _MacroDot(
                      color: AppTheme.fat,
                      label: 'F',
                      value: '${fat}g',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiny colored dot + value label for a single macro.
class _MacroDot extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _MacroDot({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: Spacing.xs),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.ink,
          ),
        ),
      ],
    );
  }
}
