import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class WeightGoalCard extends StatelessWidget {
  final double currentWeight;
  final double goalWeight;
  final double startWeight;

  const WeightGoalCard({
    super.key,
    this.currentWeight = 82.5,
    this.goalWeight = 72.0,
    this.startWeight = 90.0,
  });

  String _fmt(double w) =>
      w == w.roundToDouble() ? w.toInt().toString() : w.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final totalChange = (startWeight - goalWeight).abs();
    final progress = totalChange > 0
        ? ((startWeight - currentWeight).abs() / totalChange).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (currentWeight - goalWeight).abs();
    final isGaining = goalWeight > startWeight;

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.lg,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: progress),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              Text(
                'WEIGHT GOAL',
                style: textTheme.labelMedium,
              ),

              const SizedBox(height: Spacing.md),

              // Current weight — gradient number with ambient glow
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(30),
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.weight.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: AppTheme.weightGradient,
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: Text(
                          _fmt(currentWeight),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -1.0,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'kg',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: Spacing.md),

              // Animated progress bar with glow
              Stack(
                children: [
                  // Track
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: animatedProgress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          colors: AppTheme.weightGradient,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.weight.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Spacing.md),

              // Goal row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isGaining ? 'Target' : 'Goal',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  Text(
                    '${_fmt(goalWeight)} kg',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Spacing.sm),

              // Remaining
              Text(
                '${_fmt(remaining)} kg to go',
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}
