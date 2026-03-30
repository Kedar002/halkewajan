import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';

// ─── Data ─────────────────────────────────────────────────

class _Exercise {
  String name;
  int sets;
  int reps;
  int? weightKg;
  _Exercise(this.name, this.sets, this.reps, [this.weightKg]);

  String get detail {
    final base = '${sets}x$reps';
    return weightKg != null ? '$base · ${weightKg}kg' : base;
  }

  int get volume => sets * reps * (weightKg ?? 0);
}

class _WorkoutPlan {
  final String name;
  final String duration;
  final List<String> muscles;
  final List<_Exercise> exercises;
  _WorkoutPlan(this.name, this.duration, this.muscles, this.exercises);

  bool get isRest => exercises.isEmpty;
  int get totalVolume => exercises.fold(0, (s, e) => s + e.volume);
  int get totalSets => exercises.fold(0, (s, e) => s + e.sets);
}

class _ChangeEntry {
  final String date;
  final String change;
  final String reason;
  const _ChangeEntry(this.date, this.change, this.reason);
}

// ─── Screen ───────────────────────────────────────────────

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with TickerProviderStateMixin {
  late final AnimationController _anim;
  late final AnimationController _rowStagger;
  late final Animation<double> _headerFade;
  late final Animation<double> _selectorFade;
  late final Animation<Offset> _selectorSlide;
  late final Animation<double> _overviewFade;
  late final Animation<Offset> _overviewSlide;
  late final Animation<double> _exercisesFade;
  late final Animation<Offset> _exercisesSlide;
  late final Animation<double> _historyFade;
  late final Animation<Offset> _historySlide;

  int _selectedDay = DateTime.now().weekday - 1;
  int _previousDay = DateTime.now().weekday - 1;
  int? _expandedIndex;
  bool _historyExpanded = false;

  static const _dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  final int _today = DateTime.now().weekday - 1;

  // ── Workout plans ──────────────────────────────────────

  late final Map<int, _WorkoutPlan> _plans = {
    0: _WorkoutPlan('Push Day', '~45 min', ['Chest', 'Shoulders', 'Triceps'], [
      _Exercise('Bench Press', 4, 10, 60),
      _Exercise('Incline Dumbbell Press', 3, 12, 20),
      _Exercise('Cable Flyes', 3, 15),
      _Exercise('Overhead Press', 3, 10, 40),
      _Exercise('Tricep Pushdowns', 3, 12),
    ]),
    1: _WorkoutPlan('Pull Day', '~50 min', ['Back', 'Biceps', 'Rear Delts'], [
      _Exercise('Deadlift', 4, 8, 80),
      _Exercise('Barbell Rows', 4, 10, 50),
      _Exercise('Lat Pulldowns', 3, 12),
      _Exercise('Face Pulls', 3, 15),
      _Exercise('Barbell Curls', 3, 12, 20),
    ]),
    2: _WorkoutPlan('Leg Day', '~50 min', ['Quads', 'Hamstrings', 'Glutes'], [
      _Exercise('Barbell Squats', 4, 10, 70),
      _Exercise('Romanian Deadlift', 3, 12, 50),
      _Exercise('Leg Press', 3, 12, 100),
      _Exercise('Walking Lunges', 3, 12),
      _Exercise('Calf Raises', 4, 15),
    ]),
    3: _WorkoutPlan('Rest Day', '\u2014', [], []),
    4: _WorkoutPlan('Upper Body', '~45 min', ['Chest', 'Back', 'Shoulders'], [
      _Exercise('Bench Press', 4, 8, 65),
      _Exercise('Barbell Rows', 4, 10, 50),
      _Exercise('Overhead Press', 3, 10, 35),
      _Exercise('Dumbbell Flyes', 3, 12, 12),
      _Exercise('Lateral Raises', 3, 15),
    ]),
    5: _WorkoutPlan('Lower Body', '~45 min', ['Quads', 'Hamstrings', 'Calves'], [
      _Exercise('Front Squats', 4, 10, 50),
      _Exercise('Bulgarian Split Squats', 3, 12, 16),
      _Exercise('Leg Curls', 3, 12),
      _Exercise('Hip Thrusts', 3, 12, 60),
      _Exercise('Calf Raises', 4, 15),
    ]),
    6: _WorkoutPlan('Rest Day', '\u2014', [], []),
  };

  // ── Change history ─────────────────────────────────────

  static const _history = [
    _ChangeEntry(
      'Mar 28, 2026',
      'Bench Press: 50kg \u2192 60kg',
      'Progressive overload \u2014 hit 4\u00d710 clean for 2 weeks',
    ),
    _ChangeEntry(
      'Mar 15, 2026',
      'Added Cable Flyes to Push Day',
      'More chest isolation, weak point identified',
    ),
    _ChangeEntry(
      'Mar 8, 2026',
      'Deadlift: 70kg \u2192 80kg',
      'Form solid at 70kg, ready for next step',
    ),
    _ChangeEntry(
      'Mar 1, 2026',
      'Initial workout plan',
      'Starting Push/Pull/Legs split',
    ),
  ];

  // ── Animation helpers ──────────────────────────────────

  Animation<double> _fade(double s, double e) =>
      CurvedAnimation(
          parent: _anim, curve: Interval(s, e, curve: Curves.easeOut));

  Animation<Offset> _slide(double s, double e) =>
      Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _anim,
              curve: Interval(s, e, curve: Curves.easeOutCubic)));

  Animation<double> _rowFade(int index) {
    final start = (index * 0.14).clamp(0.0, 1.0);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return CurvedAnimation(
        parent: _rowStagger,
        curve: Interval(start, end, curve: Curves.easeOut));
  }

  Animation<Offset> _rowSlide(int index) {
    final start = (index * 0.14).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
    return Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _rowStagger,
            curve: Interval(start, end, curve: Curves.easeOutCubic)));
  }

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _rowStagger = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _headerFade = _fade(0.0, 0.25);
    _selectorFade = _fade(0.05, 0.30);
    _selectorSlide = _slide(0.05, 0.35);
    _overviewFade = _fade(0.12, 0.45);
    _overviewSlide = _slide(0.12, 0.50);
    _exercisesFade = _fade(0.25, 0.55);
    _exercisesSlide = _slide(0.25, 0.60);
    _historyFade = _fade(0.40, 0.70);
    _historySlide = _slide(0.40, 0.75);

    _anim.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _rowStagger.forward();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _rowStagger.dispose();
    super.dispose();
  }

  void _selectDay(int day) {
    if (day == _selectedDay) return;
    setState(() {
      _previousDay = _selectedDay;
      _selectedDay = day;
      _expandedIndex = null;
    });
    _rowStagger.reset();
    _rowStagger.forward();
  }

  /// Find the nearest workout name in the given direction (-1 or +1).
  String? _adjacentWorkout(int fromDay, int direction) {
    for (int step = 1; step < 7; step++) {
      final i = ((fromDay + direction * step) % 7 + 7) % 7;
      if (!_plans[i]!.isRest) {
        return '${_dayLabels[i]}: ${_plans[i]!.name}';
      }
    }
    return null;
  }

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final plan = _plans[_selectedDay]!;

    return AppBackground(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Spacing.xl),

              // Header
              FadeTransition(
                opacity: _headerFade,
                child: Text('Workout', style: tt.displayLarge),
              ),

              const SizedBox(height: Spacing.lg),

              // Day selector
              FadeTransition(
                opacity: _selectorFade,
                child: SlideTransition(
                  position: _selectorSlide,
                  child: _buildDaySelector(),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // Session overview (above exercises for orientation)
              if (!plan.isRest)
                FadeTransition(
                  opacity: _overviewFade,
                  child: SlideTransition(
                    position: _overviewSlide,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildSessionOverview(plan, tt),
                    ),
                  ),
                ),

              if (!plan.isRest) const SizedBox(height: Spacing.lg),

              // Exercise section (or rest day card)
              FadeTransition(
                opacity: _exercisesFade,
                child: SlideTransition(
                  position: _exercisesSlide,
                  child: _buildExerciseSection(plan, tt),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // Change history (collapsed by default)
              FadeTransition(
                opacity: _historyFade,
                child: SlideTransition(
                  position: _historySlide,
                  child: _buildHistory(tt),
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  // ── Day Selector ───────────────────────────────────────

  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = i == _selectedDay;
        final isToday = i == _today;
        final isRest = _plans[i]!.isRest;

        return GestureDetector(
          onTap: () => _selectDay(i),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 44,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? AppTheme.weight
                        : isRest
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.white.withValues(alpha: 0.06),
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color:
                                    AppTheme.weight.withValues(alpha: 0.35),
                                blurRadius: 12)
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _dayLabels[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? Colors.white
                            : isRest
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Today indicator dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isToday ? 4 : 0,
                  height: isToday ? 4 : 0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? Colors.white : AppTheme.weight,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Session Overview ──────────────────────────────────

  Widget _buildSessionOverview(_WorkoutPlan plan, TextTheme tt) {
    return GlassCard(
      key: ValueKey('overview_$_selectedDay'),
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SESSION OVERVIEW', style: tt.labelMedium),
          const SizedBox(height: Spacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatCol(
                  value: '${plan.exercises.length}',
                  unit: '',
                  label: 'Exercises',
                ),
              ),
              Container(
                width: 0.5,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              Expanded(
                child: _StatCol(
                  value: plan.duration.replaceAll('~', ''),
                  unit: '',
                  label: 'Duration',
                ),
              ),
              Container(
                width: 0.5,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              Expanded(
                child: _StatCol(
                  value: '${plan.totalSets}',
                  unit: 'total',
                  label: 'Sets',
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.xs,
            children: plan.muscles
                .map((m) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      child: Text(
                        m,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Exercise Section ───────────────────────────────────

  Widget _buildExerciseSection(_WorkoutPlan plan, TextTheme tt) {
    final goingForward = _selectedDay >= _previousDay;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final isIncoming =
            child.key == ValueKey('workout_$_selectedDay') ||
                child.key == ValueKey('rest_$_selectedDay');
        final beginX = isIncoming
            ? (goingForward ? 0.05 : -0.05)
            : (goingForward ? -0.05 : 0.05);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(beginX, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
      child:
          plan.isRest ? _buildRestDay(tt) : _buildExerciseList(plan, tt),
    );
  }

  Widget _buildRestDay(TextTheme tt) {
    final prev = _adjacentWorkout(_selectedDay, -1);
    final next = _adjacentWorkout(_selectedDay, 1);

    return GlassCard(
      key: ValueKey('rest_$_selectedDay'),
      padding: const EdgeInsets.symmetric(
          vertical: Spacing.xxl, horizontal: Spacing.lg),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.self_improvement_rounded,
                size: 32, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: Spacing.md),
            Text('Rest Day', style: tt.titleMedium),
            const SizedBox(height: Spacing.xs),
            Text('Recovery is progress too.', style: tt.bodySmall),
            if (prev != null || next != null) ...[
              const SizedBox(height: Spacing.lg),
              Container(
                height: 0.5,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prev != null)
                    _adjacentDayChip(prev, Icons.chevron_left_rounded),
                  if (prev != null && next != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm),
                      child: Text('\u00b7',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.2),
                              fontSize: 16)),
                    ),
                  if (next != null)
                    _adjacentDayChip(next, Icons.chevron_right_rounded),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _adjacentDayChip(String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 12, color: Colors.white.withValues(alpha: 0.3)),
        const SizedBox(width: Spacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseList(_WorkoutPlan plan, TextTheme tt) {
    return Column(
      key: ValueKey('workout_$_selectedDay'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('EXERCISES', style: tt.labelMedium),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.weight.withValues(alpha: 0.12),
                borderRadius: AppTheme.borderRadiusPill,
              ),
              child: Text(
                plan.name,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.weight),
              ),
            ),
          ],
        ),

        const SizedBox(height: Spacing.md),

        // Editable exercise list
        GlassCard(
          accentColor: AppTheme.weight,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Card header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.lg, Spacing.md, Spacing.lg, Spacing.sm),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(width: Spacing.xs),
                    Text(
                        '${plan.duration} \u00b7 ${plan.exercises.length} exercises',
                        style: tt.bodySmall),
                    const Spacer(),
                    Text(
                      'Tap to edit',
                      style: tt.bodySmall?.copyWith(
                          fontSize: 11,
                          color:
                              AppTheme.weight.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),

              // Exercise rows with per-row stagger
              for (var i = 0; i < plan.exercises.length; i++)
                FadeTransition(
                  opacity: _rowFade(i),
                  child: SlideTransition(
                    position: _rowSlide(i),
                    child: Column(
                      children: [
                        Container(
                          height: 0.5,
                          margin: const EdgeInsets.symmetric(
                              horizontal: Spacing.lg),
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        _EditableExerciseRow(
                          exercise: plan.exercises[i],
                          isExpanded: _expandedIndex == i,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _expandedIndex =
                                  _expandedIndex == i ? null : i;
                            });
                          },
                          onUpdate: () => setState(() {}),
                          onDelete: () => _deleteExercise(plan, i),
                        ),
                      ],
                    ),
                  ),
                ),

              // Add exercise button with stagger
              FadeTransition(
                opacity: _rowFade(plan.exercises.length),
                child: SlideTransition(
                  position: _rowSlide(plan.exercises.length),
                  child: Column(
                    children: [
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(
                            horizontal: Spacing.lg),
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              plan.exercises
                                  .add(_Exercise('New Exercise', 3, 10));
                              _expandedIndex =
                                  plan.exercises.length - 1;
                            });
                          },
                          splashColor:
                              AppTheme.weight.withValues(alpha: 0.05),
                          highlightColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.lg, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded,
                                    size: 18,
                                    color: AppTheme.weight
                                        .withValues(alpha: 0.7)),
                                const SizedBox(width: Spacing.sm),
                                Text(
                                  'Add Exercise',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.weight
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: Spacing.sm),
            ],
          ),
        ),
      ],
    );
  }

  // ── Delete with undo ──────────────────────────────────

  void _deleteExercise(_WorkoutPlan plan, int index) {
    final removed = plan.exercises[index];
    final removedIdx = index;

    setState(() {
      plan.exercises.removeAt(index);
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else if (_expandedIndex != null && _expandedIndex! > index) {
        _expandedIndex = _expandedIndex! - 1;
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${removed.name} removed',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(
            Spacing.lg, 0, Spacing.lg, Spacing.xxl + Spacing.xl),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppTheme.weight,
          onPressed: () {
            setState(() {
              plan.exercises.insert(
                removedIdx.clamp(0, plan.exercises.length),
                removed,
              );
            });
          },
        ),
      ),
    );
  }

  // ── Change History (collapsed by default) ──────────────

  Widget _buildHistory(TextTheme tt) {
    return GlassCard(
      accentColor: AppTheme.weight,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _historyExpanded = !_historyExpanded);
              },
              borderRadius: _historyExpanded
                  ? const BorderRadius.vertical(
                      top: Radius.circular(24))
                  : BorderRadius.circular(24),
              splashColor: AppTheme.weight.withValues(alpha: 0.05),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.lg, Spacing.lg, Spacing.lg, Spacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('CHANGE HISTORY', style: tt.labelMedium),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_history.length} entries',
                          style: tt.bodySmall?.copyWith(fontSize: 11),
                        ),
                        const SizedBox(width: Spacing.xs),
                        AnimatedRotation(
                          turns: _historyExpanded ? 0.5 : 0,
                          duration: AppTheme.animFast,
                          child: Icon(
                            Icons.expand_more_rounded,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Collapsible timeline
          AnimatedCrossFade(
            firstChild:
                const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: [
                for (var i = 0; i < _history.length; i++)
                  _TimelineEntry(
                    entry: _history[i],
                    isLast: i == _history.length - 1,
                  ),
                const SizedBox(height: Spacing.md),
              ],
            ),
            crossFadeState: _historyExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AppTheme.animMedium,
            sizeCurve: AppTheme.animCurve,
          ),
        ],
      ),
    );
  }
}

// ─── Editable Exercise Row ───────────────────────────────

class _EditableExerciseRow extends StatelessWidget {
  final _Exercise exercise;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const _EditableExerciseRow({
    required this.exercise,
    required this.isExpanded,
    required this.onTap,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          // Main row
          InkWell(
            onTap: onTap,
            splashColor: AppTheme.weight.withValues(alpha: 0.05),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg, vertical: 14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: AppTheme.animFast,
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? AppTheme.weight.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: isExpanded
                            ? AppTheme.weight
                            : Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.edit_rounded
                          : Icons.fitness_center_rounded,
                      size: 12,
                      color: isExpanded
                          ? AppTheme.weight
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                      child:
                          Text(exercise.name, style: tt.titleSmall)),
                  Text(
                    exercise.detail,
                    style: tt.bodySmall?.copyWith(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(width: Spacing.sm),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: AppTheme.animFast,
                    child: Icon(Icons.expand_more_rounded,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                ],
              ),
            ),
          ),

          // Expanded edit panel
          AnimatedCrossFade(
            firstChild:
                const SizedBox(width: double.infinity, height: 0),
            secondChild: _EditPanel(
              exercise: exercise,
              onUpdate: onUpdate,
              onDelete: onDelete,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AppTheme.animMedium,
            sizeCurve: AppTheme.animCurve,
          ),
        ],
      ),
    );
  }
}

// ─── Edit Panel (now stateful for name editing) ──────────

class _EditPanel extends StatefulWidget {
  final _Exercise exercise;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const _EditPanel({
    required this.exercise,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_EditPanel> createState() => _EditPanelState();
}

class _EditPanelState extends State<_EditPanel> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.exercise.name);
  }

  @override
  void didUpdateWidget(_EditPanel old) {
    super.didUpdateWidget(old);
    if (old.exercise != widget.exercise) {
      _nameCtrl.text = widget.exercise.name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          Spacing.lg, 0, Spacing.lg, Spacing.md),
      child: Column(
        children: [
          // Editable name field
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              hintText: 'Exercise name',
              hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: AppTheme.weight.withValues(alpha: 0.5),
                    width: 1),
              ),
            ),
            onChanged: (v) {
              widget.exercise.name = v;
              widget.onUpdate();
            },
          ),

          const SizedBox(height: Spacing.sm),

          // Stepper row
          Row(
            children: [
              Expanded(
                child: _StepperField(
                  label: 'Sets',
                  value: widget.exercise.sets,
                  onChanged: (v) {
                    widget.exercise.sets = v;
                    widget.onUpdate();
                  },
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _StepperField(
                  label: 'Reps',
                  value: widget.exercise.reps,
                  onChanged: (v) {
                    widget.exercise.reps = v;
                    widget.onUpdate();
                  },
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _StepperField(
                  label: 'Weight',
                  value: widget.exercise.weightKg ?? 0,
                  unit: 'kg',
                  step: 5,
                  onChanged: (v) {
                    widget.exercise.weightKg = v > 0 ? v : null;
                    widget.onUpdate();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: Spacing.sm),

          // Delete button
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppTheme.fat.withValues(alpha: 0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_rounded,
                        size: 14,
                        color: AppTheme.fat.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      'Remove',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.fat.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stepper Field (stateful for long-press auto-repeat) ─

class _StepperField extends StatefulWidget {
  final String label;
  final int value;
  final String? unit;
  final int step;
  final ValueChanged<int> onChanged;

  const _StepperField({
    required this.label,
    required this.value,
    this.unit,
    this.step = 1,
    required this.onChanged,
  });

  @override
  State<_StepperField> createState() => _StepperFieldState();
}

class _StepperFieldState extends State<_StepperField> {
  Timer? _holdTimer;
  int _holdTicks = 0;

  void _startHold(bool increment) {
    _holdTicks = 0;
    _doStep(increment);
    _scheduleNext(increment, 200);
  }

  void _scheduleNext(bool increment, int ms) {
    _holdTimer = Timer(Duration(milliseconds: ms), () {
      _doStep(increment);
      _holdTicks++;
      _scheduleNext(
          increment, _holdTicks > 5 ? 60 : (_holdTicks > 3 ? 100 : 200));
    });
  }

  void _doStep(bool increment) {
    HapticFeedback.selectionClick();
    if (increment) {
      widget.onChanged(widget.value + widget.step);
    } else {
      final next = widget.value - widget.step;
      if (next >= 0) widget.onChanged(next);
    }
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _holdTicks = 0;
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.06), width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stepButton(Icons.remove_rounded, false),
              Flexible(
                child: Text(
                  widget.unit != null
                      ? '${widget.value}${widget.unit}'
                      : '${widget.value}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _stepButton(Icons.add_rounded, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, bool increment) {
    return GestureDetector(
      onTap: () {
        if (increment || widget.value > 0) {
          _doStep(increment);
        }
      },
      onLongPressStart: (_) => _startHold(increment),
      onLongPressEnd: (_) => _stopHold(),
      onLongPressCancel: _stopHold,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.weight.withValues(alpha: 0.12),
        ),
        child: Icon(icon, size: 14, color: AppTheme.weight),
      ),
    );
  }
}

// ─── Stat Column ──────────────────────────────────────────

class _StatCol extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const _StatCol({
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: AppTheme.weightGradient,
          ).createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (unit.isNotEmpty)
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        const SizedBox(height: Spacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ─── Timeline Entry ───────────────────────────────────────

class _TimelineEntry extends StatelessWidget {
  final _ChangeEntry entry;
  final bool isLast;

  const _TimelineEntry({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.weight,
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.weight
                                .withValues(alpha: 0.3),
                            blurRadius: 6),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1,
                        margin: const EdgeInsets.only(top: 4),
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(bottom: isLast ? 0 : Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.date,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(entry.change, style: tt.titleSmall),
                    const SizedBox(height: Spacing.xs),
                    Text(entry.reason, style: tt.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
