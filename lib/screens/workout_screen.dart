import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _headerFade;
  late final Animation<double> _selectorFade;
  late final Animation<Offset> _selectorSlide;
  late final Animation<double> _exercisesFade;
  late final Animation<Offset> _exercisesSlide;
  late final Animation<double> _summaryFade;
  late final Animation<Offset> _summarySlide;
  late final Animation<double> _historyFade;
  late final Animation<Offset> _historySlide;

  int _selectedDay = DateTime.now().weekday - 1;
  int? _expandedIndex;

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

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
    3: _WorkoutPlan('Rest Day', '—', [], []),
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
    6: _WorkoutPlan('Rest Day', '—', [], []),
  };

  // ── Change history ─────────────────────────────────────

  static const _history = [
    _ChangeEntry(
      'Mar 28, 2026',
      'Bench Press: 50kg → 60kg',
      'Progressive overload — hit 4×10 clean for 2 weeks',
    ),
    _ChangeEntry(
      'Mar 15, 2026',
      'Added Cable Flyes to Push Day',
      'More chest isolation, weak point identified',
    ),
    _ChangeEntry(
      'Mar 8, 2026',
      'Deadlift: 70kg → 80kg',
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
      CurvedAnimation(parent: _anim, curve: Interval(s, e, curve: Curves.easeOut));

  Animation<Offset> _slide(double s, double e) =>
      Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
          .animate(CurvedAnimation(parent: _anim, curve: Interval(s, e, curve: Curves.easeOutCubic)));

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

    _headerFade     = _fade(0.0, 0.25);
    _selectorFade   = _fade(0.05, 0.30);
    _selectorSlide  = _slide(0.05, 0.35);
    _exercisesFade  = _fade(0.12, 0.45);
    _exercisesSlide = _slide(0.12, 0.50);
    _summaryFade    = _fade(0.30, 0.60);
    _summarySlide   = _slide(0.30, 0.65);
    _historyFade    = _fade(0.40, 0.70);
    _historySlide   = _slide(0.40, 0.75);

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────

  String _fmtVol(int v) {
    if (v < 1000) return v.toString();
    return '${v ~/ 1000},${(v % 1000).toString().padLeft(3, '0')}';
  }

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final plan = _plans[_selectedDay]!;

    return Stack(
      children: [
        Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),

        Positioned(
          top: -60, right: -60,
          child: _glowOrb(280, AppTheme.weight, 0.10),
        ),
        Positioned(
          bottom: 200, left: -100,
          child: _glowOrb(320, AppTheme.accent, 0.06),
        ),

        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Spacing.xl),

                FadeTransition(
                  opacity: _headerFade,
                  child: Text('Workout', style: tt.displayLarge),
                ),

                const SizedBox(height: Spacing.lg),

                FadeTransition(
                  opacity: _selectorFade,
                  child: SlideTransition(
                    position: _selectorSlide,
                    child: _buildDaySelector(),
                  ),
                ),

                const SizedBox(height: Spacing.lg),

                FadeTransition(
                  opacity: _exercisesFade,
                  child: SlideTransition(
                    position: _exercisesSlide,
                    child: _buildExerciseSection(plan, tt),
                  ),
                ),

                if (!plan.isRest) ...[
                  const SizedBox(height: Spacing.lg),
                  FadeTransition(
                    opacity: _summaryFade,
                    child: SlideTransition(
                      position: _summarySlide,
                      child: _buildSummary(plan, tt),
                    ),
                  ),
                ],

                const SizedBox(height: Spacing.lg),

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
      ],
    );
  }

  Widget _glowOrb(double size, Color color, double alpha) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: alpha), Colors.transparent],
          ),
        ),
      );

  // ── Day Selector ───────────────────────────────────────

  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = i == _selectedDay;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedDay = i;
            _expandedIndex = null;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? AppTheme.weight
                  : Colors.white.withValues(alpha: 0.06),
              boxShadow: active
                  ? [BoxShadow(color: AppTheme.weight.withValues(alpha: 0.35), blurRadius: 12)]
                  : null,
            ),
            child: Center(
              child: Text(
                _dayLetters[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Exercise Section ───────────────────────────────────

  Widget _buildExerciseSection(_WorkoutPlan plan, TextTheme tt) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: plan.isRest
          ? _buildRestDay(tt)
          : _buildExerciseList(plan, tt),
    );
  }

  Widget _buildRestDay(TextTheme tt) {
    return GlassCard(
      key: ValueKey('rest_$_selectedDay'),
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxl, horizontal: Spacing.lg),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.spa_rounded,
              size: 32,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: Spacing.md),
            Text('Rest Day', style: tt.titleMedium),
            const SizedBox(height: Spacing.xs),
            Text('Recovery is progress too.', style: tt.bodySmall),
          ],
        ),
      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.weight.withValues(alpha: 0.12),
                borderRadius: AppTheme.borderRadiusPill,
              ),
              child: Text(
                plan.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.weight,
                ),
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg, Spacing.md, Spacing.lg, Spacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      '${plan.duration} · ${plan.exercises.length} exercises',
                      style: tt.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      'Tap to edit',
                      style: tt.bodySmall?.copyWith(
                        fontSize: 11,
                        color: AppTheme.weight.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Exercise rows
              for (var i = 0; i < plan.exercises.length; i++) ...[
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                _EditableExerciseRow(
                  exercise: plan.exercises[i],
                  isExpanded: _expandedIndex == i,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _expandedIndex = _expandedIndex == i ? null : i;
                    });
                  },
                  onUpdate: () => setState(() {}),
                  onDelete: () {
                    setState(() {
                      plan.exercises.removeAt(i);
                      _expandedIndex = null;
                    });
                  },
                ),
              ],

              // Add exercise button
              Container(
                height: 0.5,
                margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                color: Colors.white.withValues(alpha: 0.06),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      plan.exercises.add(_Exercise('New Exercise', 3, 10));
                      _expandedIndex = plan.exercises.length - 1;
                    });
                  },
                  splashColor: AppTheme.weight.withValues(alpha: 0.05),
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: AppTheme.weight.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Text(
                          'Add Exercise',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.weight.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
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

  // ── Summary ────────────────────────────────────────────

  Widget _buildSummary(_WorkoutPlan plan, TextTheme tt) {
    return GlassCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUMMARY', style: tt.labelMedium),
          const SizedBox(height: Spacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatCol(
                  value: _fmtVol(plan.totalVolume),
                  unit: 'kg',
                  label: 'Volume',
                ),
              ),
              Container(
                width: 0.5, height: 40,
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
                width: 0.5, height: 40,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              Expanded(
                child: _StatCol(
                  value: '${plan.muscles.length}',
                  unit: 'groups',
                  label: 'Muscles',
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  // ── Change History ─────────────────────────────────────

  Widget _buildHistory(TextTheme tt) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg, Spacing.lg, Spacing.lg, Spacing.md,
            ),
            child: Text('CHANGE HISTORY', style: tt.labelMedium),
          ),
          for (var i = 0; i < _history.length; i++)
            _TimelineEntry(
              entry: _history[i],
              isLast: i == _history.length - 1,
            ),
          const SizedBox(height: Spacing.md),
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
          // Main row — tappable
          InkWell(
            onTap: onTap,
            splashColor: AppTheme.weight.withValues(alpha: 0.05),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: 14,
              ),
              child: Row(
                children: [
                  // Edit indicator
                  AnimatedContainer(
                    duration: AppTheme.animFast,
                    width: 22, height: 22,
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
                    child: Text(exercise.name, style: tt.titleSmall),
                  ),
                  Text(
                    exercise.detail,
                    style: tt.bodySmall?.copyWith(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: AppTheme.animFast,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded edit panel
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
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

// ─── Edit Panel ──────────────────────────────────────────

class _EditPanel extends StatelessWidget {
  final _Exercise exercise;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const _EditPanel({
    required this.exercise,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg, 0, Spacing.lg, Spacing.md,
      ),
      child: Column(
        children: [
          // Stepper row
          Row(
            children: [
              Expanded(
                child: _StepperField(
                  label: 'Sets',
                  value: exercise.sets,
                  onChanged: (v) {
                    exercise.sets = v;
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _StepperField(
                  label: 'Reps',
                  value: exercise.reps,
                  onChanged: (v) {
                    exercise.reps = v;
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _StepperField(
                  label: 'Weight',
                  value: exercise.weightKg ?? 0,
                  unit: 'kg',
                  step: 5,
                  onChanged: (v) {
                    exercise.weightKg = v > 0 ? v : null;
                    onUpdate();
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
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppTheme.fat.withValues(alpha: 0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 14, color: AppTheme.fat.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.fat.withValues(alpha: 0.7),
                      ),
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

// ─── Stepper Field ───────────────────────────────────────

class _StepperField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
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
              _stepButton(Icons.remove_rounded, () {
                if (value > 0) {
                  HapticFeedback.selectionClick();
                  onChanged(value - step);
                }
              }),
              Text(
                unit != null ? '$value$unit' : '$value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              _stepButton(Icons.add_rounded, () {
                HapticFeedback.selectionClick();
                onChanged(value + step);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
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
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.weight,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.weight.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
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
                padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.lg),
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
