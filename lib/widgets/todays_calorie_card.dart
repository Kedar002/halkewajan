import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';
import 'stat_ring.dart';

class TodaysCalorieCard extends StatelessWidget {
  final int consumed;
  final int burned;
  final int deficit;

  const TodaysCalorieCard({
    super.key,
    this.consumed = 1320,
    this.burned = 2280,
    this.deficit = 500,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final targetIntake = burned - deficit;
    final remaining = targetIntake - consumed;
    final progress = (consumed / targetIntake).clamp(0.0, 1.0);
    final isOver = remaining < 0;

    final String goalText;
    if (deficit > 0) {
      goalText = '$deficit cal deficit';
    } else if (deficit < 0) {
      goalText = '${-deficit} cal surplus';
    } else {
      goalText = 'Maintenance';
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.lg,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: progress),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, _) {
          final animatedConsumed = progress > 0
              ? (consumed * (animatedProgress / progress)).round()
              : 0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ambient glow behind ring
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (isOver ? AppTheme.fat : AppTheme.calories)
                              .withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  StatRing(
                    progress: animatedProgress,
                    color: isOver ? AppTheme.fat : AppTheme.calories,
                    value: '$animatedConsumed',
                    unit: 'of $targetIntake',
                    size: 85,
                    strokeWidth: 9,
                    valueGradient: LinearGradient(
                      colors: isOver
                          ? const [AppTheme.fat, Color(0xFFFF6B6B)]
                          : AppTheme.caloriesGradient,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Spacing.md),

              Text(
                isOver
                    ? '${-remaining} over'
                    : '$remaining kcal left',
                style: textTheme.titleSmall?.copyWith(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: Spacing.xs),

              Text(goalText, style: textTheme.bodySmall),
            ],
          );
        },
      ),
    );
  }
}
