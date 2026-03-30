import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MacroBar extends StatelessWidget {
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;

  const MacroBar({
    super.key,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.proteinGoal = 150,
    this.carbsGoal = 250,
    this.fatGoal = 65,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MacroTile(
          color: AppTheme.protein,
          label: 'Protein',
          grams: proteinGrams,
          goal: proteinGoal,
        ),
        const SizedBox(width: Spacing.sm),
        _MacroTile(
          color: AppTheme.carbs,
          label: 'Carbs',
          grams: carbsGrams,
          goal: carbsGoal,
        ),
        const SizedBox(width: Spacing.sm),
        _MacroTile(
          color: AppTheme.fat,
          label: 'Fat',
          grams: fatGrams,
          goal: fatGoal,
        ),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  final Color color;
  final String label;
  final int grams;
  final int goal;

  const _MacroTile({
    required this.color,
    required this.label,
    required this.grams,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (grams / goal).clamp(0.0, 1.0);

    return Expanded(
      child: Column(
        children: [
          // Mini progress bar
          ClipRRect(
            borderRadius: AppTheme.borderRadiusPill,
            child: SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            '${grams}g',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            '/ ${goal}g',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
