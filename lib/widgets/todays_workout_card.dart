import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class _Exercise {
  final String name;
  final int sets;
  final int reps;
  final int? weightKg;
  bool completed = false;

  _Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weightKg,
  });

  String get detail {
    final base = '${sets}x$reps';
    return weightKg != null ? '$base · ${weightKg}kg' : base;
  }
}

class TodaysWorkoutCard extends StatefulWidget {
  const TodaysWorkoutCard({super.key});

  @override
  State<TodaysWorkoutCard> createState() => _TodaysWorkoutCardState();
}

class _TodaysWorkoutCardState extends State<TodaysWorkoutCard>
    with SingleTickerProviderStateMixin {
  static const _workoutType = 'Push Day';
  static const _duration = '~45 min';
  late final AnimationController _staggerController;

  final List<_Exercise> _exercises = [
    _Exercise(name: 'Bench Press', sets: 4, reps: 10, weightKg: 60),
    _Exercise(name: 'Incline Dumbbell Press', sets: 3, reps: 12, weightKg: 20),
    _Exercise(name: 'Cable Flyes', sets: 3, reps: 15),
    _Exercise(name: 'Tricep Pushdowns', sets: 3, reps: 12),
    _Exercise(name: 'Overhead Tricep Extension', sets: 3, reps: 10, weightKg: 15),
  ];

  int get _completedCount => _exercises.where((e) => e.completed).length;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Delay to sync with parent entrance animation
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _rowFade(int index) {
    final start = (index * 0.14).clamp(0.0, 1.0);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _rowSlide(int index) {
    final start = (index * 0.14).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
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
      accentColor: AppTheme.weight,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg, Spacing.lg, Spacing.lg, Spacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TODAY'S WORKOUT", style: textTheme.labelMedium),
                      const SizedBox(height: Spacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            '$_duration · $_completedCount of ${_exercises.length} done',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Workout type pill — blue accent
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.weight.withValues(alpha: 0.12),
                    borderRadius: AppTheme.borderRadiusPill,
                  ),
                  child: Text(
                    _workoutType,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppTheme.weight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Exercise list with stagger
          ...List.generate(_exercises.length, (index) {
            final exercise = _exercises[index];
            final isLast = index == _exercises.length - 1;

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
                    _ExerciseRow(
                      exercise: exercise,
                      onToggle: () {
                        setState(() =>
                            exercise.completed = !exercise.completed);
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

class _ExerciseRow extends StatelessWidget {
  final _Exercise exercise;
  final VoidCallback onToggle;

  const _ExerciseRow({required this.exercise, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        splashColor: AppTheme.weight.withValues(alpha: 0.05),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              // Blue checkbox
              AnimatedContainer(
                duration: AppTheme.animFast,
                curve: AppTheme.animCurve,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: exercise.completed
                      ? AppTheme.weight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: exercise.completed
                        ? AppTheme.weight
                        : Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: exercise.completed
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: Spacing.md),

              // Exercise name
              Expanded(
                child: Text(
                  exercise.name,
                  style: textTheme.titleSmall?.copyWith(
                    decoration: exercise.completed
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: Colors.white.withValues(alpha: 0.3),
                    color: exercise.completed
                        ? Colors.white.withValues(alpha: 0.4)
                        : null,
                  ),
                ),
              ),

              // Sets x reps · weight
              Text(
                exercise.detail,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: exercise.completed
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
