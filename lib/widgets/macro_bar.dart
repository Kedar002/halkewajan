import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class MacroBar extends StatelessWidget {
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;

  const MacroBar({
    super.key,
    this.proteinGrams = 92,
    this.carbsGrams = 180,
    this.fatGrams = 45,
    this.proteinGoal = 150,
    this.carbsGoal = 250,
    this.fatGoal = 65,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MACROS', style: textTheme.labelMedium),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              _MacroTile(
                color: AppTheme.protein,
                gradient: AppTheme.proteinGradient,
                label: 'Protein',
                grams: proteinGrams,
                goal: proteinGoal,
              ),
              const SizedBox(width: Spacing.md),
              _MacroTile(
                color: AppTheme.carbs,
                gradient: AppTheme.carbsGradient,
                label: 'Carbs',
                grams: carbsGrams,
                goal: carbsGoal,
              ),
              const SizedBox(width: Spacing.md),
              _MacroTile(
                color: AppTheme.fat,
                gradient: AppTheme.fatGradient,
                label: 'Fat',
                grams: fatGrams,
                goal: fatGoal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  final Color color;
  final List<Color> gradient;
  final String label;
  final int grams;
  final int goal;

  const _MacroTile({
    required this.color,
    required this.gradient,
    required this.label,
    required this.grams,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = (grams / goal).clamp(0.0, 1.0);

    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, _) {
          return Column(
            children: [
              // Gradient bar with glow
              Stack(
                children: [
                  // Track
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: color.withValues(alpha: 0.1),
                    ),
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: animValue,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(colors: gradient),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              // Gram number with gradient
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: gradient,
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Text(
                  '${grams}g',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '/ ${goal}g',
                style: textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          );
        },
      ),
    );
  }
}
