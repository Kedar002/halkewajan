import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import 'tracking_screen.dart';

// ─── Data models ──────────────────────────────────────────

class _WeightEntry {
  final DateTime date;
  final double weight;
  const _WeightEntry(this.date, this.weight);
}

class _PR {
  final String exercise;
  final double weightKg;
  final String date;
  final bool isRecent;
  const _PR(this.exercise, this.weightKg, this.date, {this.isRecent = false});
}

class _Measurement {
  final String name;
  final double value;
  final String unit;
  final double change;
  const _Measurement(this.name, this.value, this.unit, this.change);
}

class _PRChange {
  final String date;
  final String change;
  final String detail;
  const _PRChange(this.date, this.change, this.detail);
}

// ─── Screen ───────────────────────────────────────────────

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  late final Animation<double> _headerFade;
  late final Animation<double> _rangeFade;
  late final Animation<Offset> _rangeSlide;
  late final Animation<double> _chartFade;
  late final Animation<Offset> _chartSlide;
  late final Animation<double> _bmiFade;
  late final Animation<Offset> _bmiSlide;
  late final Animation<double> _prFade;
  late final Animation<Offset> _prSlide;
  late final Animation<double> _measureFade;
  late final Animation<Offset> _measureSlide;
  late final Animation<double> _historyFade;
  late final Animation<Offset> _historySlide;

  int _rangeIndex = 2;

  static const _rangeLabels = ['1W', '1M', '3M', '6M', '1Y'];

  // ── Demo data ──────────────────────────────────────────

  static final _weightData = List.generate(13, (i) {
    final date = DateTime(2026, 1, 1).add(Duration(days: i * 7));
    final w = 85.0 - (i * 0.5) + (math.sin(i * 0.8) * 0.4);
    return _WeightEntry(date, double.parse(w.toStringAsFixed(1)));
  });

  static const _goalWeight = 72.0;
  static const _currentWeight = 78.5;
  static const _startWeight = 85.0;

  static const _prs = [
    _PR('Bench Press', 65, 'Mar 28', isRecent: true),
    _PR('Barbell Squat', 80, 'Mar 25', isRecent: true),
    _PR('Deadlift', 90, 'Mar 20'),
    _PR('Overhead Press', 42.5, 'Mar 15'),
    _PR('Barbell Row', 55, 'Mar 10'),
  ];

  static const _measurements = [
    _Measurement('Chest', 40, 'in', 0.5),
    _Measurement('Waist', 32, 'in', -1.5),
    _Measurement('Arms', 14, 'in', 0.3),
    _Measurement('Thighs', 22, 'in', 0.2),
  ];

  static const _prHistory = [
    _PRChange('Mar 28, 2026', 'Bench Press: 60kg → 65kg',
        'Hit 4×10 clean — moved up 5kg'),
    _PRChange('Mar 25, 2026', 'Squat: 75kg → 80kg',
        'Depth improved, confident at heavier load'),
    _PRChange('Mar 20, 2026', 'Deadlift: 85kg → 90kg',
        'Grip held, back neutral through all reps'),
    _PRChange('Mar 10, 2026', 'Barbell Row: 50kg → 55kg',
        'Controlled eccentrics finally paid off'),
  ];

  // ── Animation helpers ──────────────────────────────────

  Animation<double> _fade(double s, double e) => CurvedAnimation(
      parent: _anim, curve: Interval(s, e, curve: Curves.easeOut));

  Animation<Offset> _slide(double s, double e) =>
      Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _anim,
              curve: Interval(s, e, curve: Curves.easeOutCubic)));

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _headerFade   = _fade(0.00, 0.25);
    _rangeFade    = _fade(0.05, 0.30);
    _rangeSlide   = _slide(0.05, 0.35);
    _chartFade    = _fade(0.10, 0.40);
    _chartSlide   = _slide(0.10, 0.45);
    _bmiFade      = _fade(0.20, 0.50);
    _bmiSlide     = _slide(0.20, 0.55);
    _prFade       = _fade(0.30, 0.60);
    _prSlide      = _slide(0.30, 0.65);
    _measureFade  = _fade(0.40, 0.70);
    _measureSlide = _slide(0.40, 0.75);
    _historyFade  = _fade(0.50, 0.80);
    _historySlide = _slide(0.50, 0.85);

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _openTracking() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const TrackingScreen(),
        transitionsBuilder: (context, anim, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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

              // Header with + button
              FadeTransition(
                opacity: _headerFade,
                child: Row(
                  children: [
                    Text('Progress', style: tt.displayLarge),
                    const Spacer(),
                    GestureDetector(
                      onTap: _openTracking,
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accent.withValues(alpha: 0.12),
                        ),
                        child: const Icon(Icons.add_rounded,
                            size: 22, color: AppTheme.accent),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.lg),

              FadeTransition(
                opacity: _rangeFade,
                child: SlideTransition(
                  position: _rangeSlide,
                  child: _buildRangeSelector(),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              FadeTransition(
                opacity: _chartFade,
                child: SlideTransition(
                  position: _chartSlide,
                  child: _buildWeightChart(tt),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              FadeTransition(
                opacity: _bmiFade,
                child: SlideTransition(
                  position: _bmiSlide,
                  child: _buildBMI(tt),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              FadeTransition(
                opacity: _prFade,
                child: SlideTransition(
                  position: _prSlide,
                  child: _buildPRs(tt),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              FadeTransition(
                opacity: _measureFade,
                child: SlideTransition(
                  position: _measureSlide,
                  child: _buildMeasurements(tt),
                ),
              ),

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
    );
  }

  // ── Range Selector ─────────────────────────────────────

  Widget _buildRangeSelector() {
    return Row(
      children: List.generate(_rangeLabels.length, (i) {
        final active = i == _rangeIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _rangeIndex = i);
            },
            child: AnimatedContainer(
              duration: AppTheme.animFast,
              margin: EdgeInsets.only(right: i < 4 ? Spacing.sm : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: active
                    ? AppTheme.accent
                    : Colors.white.withValues(alpha: 0.06),
                boxShadow: active
                    ? [BoxShadow(
                        color: AppTheme.accent.withValues(alpha: 0.3),
                        blurRadius: 12)]
                    : null,
              ),
              child: Center(
                child: Text(
                  _rangeLabels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? Colors.black
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Weight Chart ───────────────────────────────────────

  Widget _buildWeightChart(TextTheme tt) {
    return GlassCard(
      accentColor: AppTheme.weight,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.lg, Spacing.lg, Spacing.lg, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WEIGHT TREND', style: tt.labelMedium),
                const SizedBox(height: Spacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                              colors: AppTheme.weightGradient)
                          .createShader(
                              Rect.fromLTWH(0, 0, b.width, b.height)),
                      child: Text(_currentWeight.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -1.0,
                              height: 1.1)),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('kg',
                          style: tt.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppTheme.accent.withValues(alpha: 0.12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.trending_down_rounded,
                              size: 12, color: AppTheme.accent),
                          const SizedBox(width: 2),
                          Text(
                              '${(_startWeight - _currentWeight).toStringAsFixed(1)} kg',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            height: 180,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _WeightChartPainter(
                    data: _weightData,
                    goalWeight: _goalWeight,
                    animProgress: value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.lg, 0, Spacing.lg, Spacing.lg),
            child: Row(
              children: [
                _miniStat('Start', '${_startWeight.toStringAsFixed(0)}kg'),
                _dividerVert(),
                _miniStat('Current', '${_currentWeight.toStringAsFixed(1)}kg'),
                _dividerVert(),
                _miniStat('Goal', '${_goalWeight.toStringAsFixed(0)}kg'),
                _dividerVert(),
                _miniStat('Left',
                    '${(_currentWeight - _goalWeight).toStringAsFixed(1)}kg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) => Expanded(
        child: Column(children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 0.5)),
        ]),
      );

  Widget _dividerVert() => Container(
      width: 0.5, height: 28, color: Colors.white.withValues(alpha: 0.08));

  // ── BMI Records ────────────────────────────────────────

  Widget _buildBMI(TextTheme tt) {
    return GlassCard(
      accentColor: AppTheme.accent,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.lg, Spacing.lg, Spacing.lg, Spacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('BMI RECORDS', style: tt.labelMedium),
                GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: AppTheme.accent.withValues(alpha: 0.12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file_rounded,
                            size: 14, color: AppTheme.accent),
                        const SizedBox(width: 4),
                        Text('Upload',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accent)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Record entries
          _bmiRecordRow(
            date: 'Mar 25, 2026',
            bmi: '24.2',
            category: 'Normal',
            fileType: 'PDF',
            icon: Icons.picture_as_pdf_rounded,
          ),
          _bmiRecordRow(
            date: 'Feb 20, 2026',
            bmi: '25.1',
            category: 'Overweight',
            fileType: 'Photo',
            icon: Icons.image_rounded,
          ),
          _bmiRecordRow(
            date: 'Jan 15, 2026',
            bmi: '26.3',
            category: 'Overweight',
            fileType: 'PDF',
            icon: Icons.picture_as_pdf_rounded,
            isLast: true,
          ),
          const SizedBox(height: Spacing.sm),
        ],
      ),
    );
  }

  Widget _bmiRecordRow({
    required String date,
    required String bmi,
    required String category,
    required String fileType,
    required IconData icon,
    bool isLast = false,
  }) {
    final isNormal = category == 'Normal';

    return Column(
      children: [
        Container(
          height: 0.5,
          margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          color: Colors.white.withValues(alpha: 0.06),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => HapticFeedback.lightImpact(),
            splashColor: AppTheme.accent.withValues(alpha: 0.05),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg, vertical: 14),
              child: Row(
                children: [
                  // File type icon
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    child: Icon(icon,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(width: Spacing.md),
                  // Date and file type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(date,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                        Text(fileType,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.white
                                    .withValues(alpha: 0.4))),
                      ],
                    ),
                  ),
                  // BMI value
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                            colors: AppTheme.accentGradient)
                        .createShader(
                            Rect.fromLTWH(0, 0, b.width, b.height)),
                    child: Text(bmi,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3)),
                  ),
                  const SizedBox(width: Spacing.sm),
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: (isNormal ? AppTheme.accent : AppTheme.calories)
                          .withValues(alpha: 0.12),
                    ),
                    child: Text(category,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isNormal
                                ? AppTheme.accent
                                : AppTheme.calories)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Strength PRs ───────────────────────────────────────

  Widget _buildPRs(TextTheme tt) {
    return GlassCard(
      accentColor: AppTheme.protein,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.lg, Spacing.lg, Spacing.lg, Spacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PERSONAL RECORDS', style: tt.labelMedium),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: AppTheme.protein.withValues(alpha: 0.12),
                  ),
                  child: Text('${_prs.length} lifts',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.protein)),
                ),
              ],
            ),
          ),
          for (var i = 0; i < _prs.length; i++) ...[
            Container(
              height: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              color: Colors.white.withValues(alpha: 0.06),
            ),
            _PRRow(pr: _prs[i]),
          ],
          const SizedBox(height: Spacing.sm),
        ],
      ),
    );
  }

  // ── Body Measurements ──────────────────────────────────

  Widget _buildMeasurements(TextTheme tt) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.lg, Spacing.lg, Spacing.lg, Spacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('MEASUREMENTS', style: tt.labelMedium),
                Text('Last updated: Mar 28',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.3))),
              ],
            ),
          ),
          for (var i = 0; i < _measurements.length; i++) ...[
            Container(
              height: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              color: Colors.white.withValues(alpha: 0.06),
            ),
            _MeasurementRow(measurement: _measurements[i]),
          ],
          const SizedBox(height: Spacing.sm),
        ],
      ),
    );
  }

  // ── PR History ─────────────────────────────────────────

  Widget _buildHistory(TextTheme tt) {
    return GlassCard(
      accentColor: AppTheme.protein,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.lg, Spacing.lg, Spacing.lg, Spacing.md),
            child: Text('PR HISTORY', style: tt.labelMedium),
          ),
          for (var i = 0; i < _prHistory.length; i++)
            _TimelineEntry(
              entry: _prHistory[i],
              isLast: i == _prHistory.length - 1,
            ),
          const SizedBox(height: Spacing.md),
        ],
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────

class _PRRow extends StatelessWidget {
  final _PR pr;
  const _PRRow({required this.pr});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pr.isRecent
                  ? AppTheme.protein.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.04),
            ),
            child: Icon(
              pr.isRecent
                  ? Icons.emoji_events_rounded
                  : Icons.fitness_center_rounded,
              size: 14,
              color: pr.isRecent
                  ? AppTheme.protein
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pr.exercise, style: tt.titleSmall),
                Text(pr.date,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          ),
          ShaderMask(
            shaderCallback: (b) =>
                const LinearGradient(colors: AppTheme.proteinGradient)
                    .createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
            child: Text(
              '${pr.weightKg % 1 == 0 ? pr.weightKg.toInt() : pr.weightKg}kg',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementRow extends StatelessWidget {
  final _Measurement measurement;
  const _MeasurementRow({required this.measurement});

  @override
  Widget build(BuildContext context) {
    final isPositive = measurement.change > 0;
    final isNegative = measurement.change < 0;
    final isGood = measurement.name == 'Waist' ? isNegative : isPositive;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 14),
      child: Row(
        children: [
          Expanded(
              child: Text(measurement.name,
                  style: Theme.of(context).textTheme.titleSmall)),
          Text(
            '${measurement.value}${measurement.unit}',
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3),
          ),
          const SizedBox(width: Spacing.sm),
          if (measurement.change != 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: (isGood ? AppTheme.accent : AppTheme.fat)
                    .withValues(alpha: 0.12),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${measurement.change}',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isGood ? AppTheme.accent : AppTheme.fat),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final _PRChange entry;
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
                      color: AppTheme.protein,
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.protein.withValues(alpha: 0.3),
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
                padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.date,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.4),
                            letterSpacing: 0.5)),
                    const SizedBox(height: Spacing.xs),
                    Text(entry.change, style: tt.titleSmall),
                    const SizedBox(height: Spacing.xs),
                    Text(entry.detail, style: tt.bodySmall),
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

// ─── Weight Chart Painter ─────────────────────────────────

class _WeightChartPainter extends CustomPainter {
  final List<_WeightEntry> data;
  final double goalWeight;
  final double animProgress;

  _WeightChartPainter({
    required this.data,
    required this.goalWeight,
    required this.animProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    const padL = 0.0, padR = 16.0, padT = 12.0, padB = 24.0;
    final chartW = size.width - padL - padR;
    final chartH = size.height - padT - padB;
    final weights = data.map((d) => d.weight).toList();
    final minW = (weights.reduce(math.min) - 2).floorToDouble();
    final maxW = (weights.reduce(math.max) + 2).ceilToDouble();
    final range = maxW - minW;
    double toX(int i) => padL + (i / (data.length - 1)) * chartW;
    double toY(double w) => padT + (1 - (w - minW) / range) * chartH;

    // Goal line
    final goalY = toY(goalWeight);
    final dashPaint = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (double x = padL; x < size.width - padR; x += 8) {
      canvas.drawLine(Offset(x, goalY), Offset(x + 4, goalY), dashPaint);
    }
    final goalTp = TextPainter(
      text: TextSpan(
          text: 'Goal ${goalWeight.toStringAsFixed(0)}kg',
          style: TextStyle(
              fontSize: 9,
              color: AppTheme.accent.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500)),
      textDirection: TextDirection.ltr,
    )..layout();
    goalTp.paint(
        canvas, Offset(size.width - padR - goalTp.width, goalY - 14));

    // Bezier path
    final visibleCount =
        (data.length * animProgress).ceil().clamp(1, data.length);
    final points = <Offset>[];
    for (var i = 0; i < visibleCount; i++) {
      points.add(Offset(toX(i), toY(data[i].weight)));
    }
    if (points.length < 2) return;

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i], p1 = points[i + 1];
      final cpx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cpx, p0.dy, cpx, p1.dy, p1.dx, p1.dy);
    }

    // Fill
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, padT + chartH)
      ..lineTo(points.first.dx, padT + chartH)
      ..close();
    canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.weight.withValues(alpha: 0.15),
              AppTheme.weight.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, padT, chartW, chartH)));

    // Line
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..shader = const LinearGradient(colors: AppTheme.weightGradient)
              .createShader(Rect.fromLTWH(padL, 0, chartW, 1)));

    // Glow
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(colors: [
            AppTheme.weight.withValues(alpha: 0.15),
            AppTheme.weight.withValues(alpha: 0.08),
          ]).createShader(Rect.fromLTWH(padL, 0, chartW, 1))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Data points
    for (final p in points) {
      canvas.drawCircle(
          p,
          4,
          Paint()
            ..color = AppTheme.weight.withValues(alpha: 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawCircle(p, 2.5, Paint()..color = AppTheme.weight);
      canvas.drawCircle(p, 1.2, Paint()..color = Colors.white);
    }

    // X labels
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    for (var i = 0; i < visibleCount; i += 3) {
      final d = data[i].date;
      final tp = TextPainter(
        text: TextSpan(
            text: '${months[d.month - 1]} ${d.day}',
            style: TextStyle(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.3))),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(toX(i) - tp.width / 2, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) =>
      animProgress != old.animProgress;
}
