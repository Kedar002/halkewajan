import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  late final Animation<double> _headerFade;
  late final Animation<double> _weightFade;
  late final Animation<Offset> _weightSlide;
  late final Animation<double> _prFade;
  late final Animation<Offset> _prSlide;
  late final Animation<double> _measureFade;
  late final Animation<Offset> _measureSlide;
  late final Animation<double> _bmiFade;
  late final Animation<Offset> _bmiSlide;
  late final Animation<double> _saveFade;

  // ── State ─────────────────────────────────────────────

  double _weight = 78.5;
  double _prWeight = 70;
  int _prIndex = 0;
  double _heightCm = 180;
  double _chest = 40;
  double _waist = 32;
  double _arms = 14;
  double _thighs = 22;

  static const _exercises = [
    'Bench Press', 'Barbell Squat', 'Deadlift',
    'Overhead Press', 'Barbell Row', 'Pull-ups',
  ];

  double get _bmi => _weight / ((_heightCm / 100) * (_heightCm / 100));
  String get _bmiCategory {
    if (_bmi < 18.5) return 'Underweight';
    if (_bmi < 25) return 'Normal';
    if (_bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // ── Animations ────────────────────────────────────────

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
        vsync: this, duration: const Duration(milliseconds: 1200));

    _headerFade   = _fade(0.00, 0.30);
    _weightFade   = _fade(0.05, 0.40);
    _weightSlide  = _slide(0.05, 0.45);
    _prFade       = _fade(0.15, 0.50);
    _prSlide      = _slide(0.15, 0.55);
    _measureFade  = _fade(0.25, 0.60);
    _measureSlide = _slide(0.25, 0.65);
    _bmiFade      = _fade(0.35, 0.70);
    _bmiSlide     = _slide(0.35, 0.75);
    _saveFade     = _fade(0.50, 0.80);

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _glowOrb(double size, Color color, double alpha) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withValues(alpha: alpha), Colors.transparent]),
        ),
      );

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
              decoration:
                  const BoxDecoration(gradient: AppTheme.backgroundGradient)),

          // Nebula orbs
          Positioned(
              top: -60,
              right: -80,
              child: _glowOrb(350, AppTheme.weight, 0.18)),
          Positioned(
              bottom: 200,
              left: -80,
              child: _glowOrb(380, AppTheme.accent, 0.14)),
          Positioned(
              top: 400,
              left: -60,
              child: _glowOrb(280, AppTheme.protein, 0.10)),

          SafeArea(
            child: Column(
              children: [
                // Header bar
                FadeTransition(
                  opacity: _headerFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md, vertical: Spacing.sm),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                            child: Icon(Icons.arrow_back_rounded,
                                size: 20,
                                color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Text('Log Progress', style: tt.titleLarge),
                        const Spacer(),
                        Text(_todayFormatted(),
                            style: tt.bodySmall?.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                    child: Column(
                      children: [
                        const SizedBox(height: Spacing.md),

                        // Weight section
                        FadeTransition(
                          opacity: _weightFade,
                          child: SlideTransition(
                            position: _weightSlide,
                            child: _buildWeightSection(tt),
                          ),
                        ),

                        const SizedBox(height: Spacing.lg),

                        // PR section
                        FadeTransition(
                          opacity: _prFade,
                          child: SlideTransition(
                            position: _prSlide,
                            child: _buildPRSection(tt),
                          ),
                        ),

                        const SizedBox(height: Spacing.lg),

                        // Measurements section
                        FadeTransition(
                          opacity: _measureFade,
                          child: SlideTransition(
                            position: _measureSlide,
                            child: _buildMeasurementsSection(tt),
                          ),
                        ),

                        const SizedBox(height: Spacing.lg),

                        // BMI section
                        FadeTransition(
                          opacity: _bmiFade,
                          child: SlideTransition(
                            position: _bmiSlide,
                            child: _buildBMISection(tt),
                          ),
                        ),

                        const SizedBox(height: Spacing.xl),

                        // Save button
                        FadeTransition(
                          opacity: _saveFade,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: AppTheme.accent,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accent
                                        .withValues(alpha: 0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_rounded,
                                      size: 20, color: Colors.black),
                                  SizedBox(width: Spacing.sm),
                                  Text('Save All',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          letterSpacing: 0.2)),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: Spacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _todayFormatted() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  // ── Weight ────────────────────────────────────────────

  Widget _buildWeightSection(TextTheme tt) {
    return GlassCard(
      accentColor: AppTheme.weight,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_weight_rounded,
                  size: 18,
                  color: AppTheme.weight.withValues(alpha: 0.7)),
              const SizedBox(width: Spacing.sm),
              Text('WEIGHT', style: tt.labelMedium),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          Center(
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                          colors: AppTheme.weightGradient)
                      .createShader(
                          Rect.fromLTWH(0, 0, b.width, b.height)),
                  child: Text(
                    _weight.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        height: 1.0),
                  ),
                ),
                const SizedBox(height: 4),
                Text('kg',
                    style: tt.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          _Stepper(
            value: _weight,
            unit: 'kg',
            step: 0.1,
            decimals: 1,
            color: AppTheme.weight,
            onChanged: (v) => setState(() => _weight = v.clamp(30, 300)),
          ),
        ],
      ),
    );
  }

  // ── PR ────────────────────────────────────────────────

  Widget _buildPRSection(TextTheme tt) {
    return GlassCard(
      accentColor: AppTheme.protein,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded,
                  size: 18,
                  color: AppTheme.protein.withValues(alpha: 0.7)),
              const SizedBox(width: Spacing.sm),
              Text('NEW PR', style: tt.labelMedium),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          // Exercise selector
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _exercises.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: Spacing.sm),
              itemBuilder: (_, i) {
                final active = i == _prIndex;
                return GestureDetector(
                  onTap: () => setState(() => _prIndex = i),
                  child: AnimatedContainer(
                    duration: AppTheme.animFast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: active
                          ? AppTheme.protein.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: active
                            ? AppTheme.protein.withValues(alpha: 0.3)
                            : Colors.transparent,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      _exercises[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w500,
                        color: active
                            ? AppTheme.protein
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Center(
            child: ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                      colors: AppTheme.proteinGradient)
                  .createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
              child: Text(
                '${_prWeight.toStringAsFixed(1)} kg',
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -1.0,
                    height: 1.1),
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          _Stepper(
            value: _prWeight,
            unit: 'kg',
            step: 2.5,
            decimals: 1,
            color: AppTheme.protein,
            onChanged: (v) => setState(() => _prWeight = v.clamp(0, 500)),
          ),
        ],
      ),
    );
  }

  // ── Measurements ──────────────────────────────────────

  Widget _buildMeasurementsSection(TextTheme tt) {
    return GlassCard(
      accentColor: AppTheme.accent,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.straighten_rounded,
                  size: 18,
                  color: AppTheme.accent.withValues(alpha: 0.7)),
              const SizedBox(width: Spacing.sm),
              Text('MEASUREMENTS', style: tt.labelMedium),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          _measureRow('Chest', _chest, (v) => setState(() => _chest = v)),
          const SizedBox(height: Spacing.md),
          _measureRow('Waist', _waist, (v) => setState(() => _waist = v)),
          const SizedBox(height: Spacing.md),
          _measureRow('Arms', _arms, (v) => setState(() => _arms = v)),
          const SizedBox(height: Spacing.md),
          _measureRow('Thighs', _thighs, (v) => setState(() => _thighs = v)),
        ],
      ),
    );
  }

  Widget _measureRow(
      String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.6))),
        ),
        Expanded(
          child: _Stepper(
            value: value,
            unit: 'in',
            step: 0.5,
            decimals: 1,
            color: AppTheme.accent,
            onChanged: (v) => onChanged(v.clamp(0, 100)),
          ),
        ),
      ],
    );
  }

  // ── BMI ───────────────────────────────────────────────

  Widget _buildBMISection(TextTheme tt) {
    return GlassCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.height_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(width: Spacing.sm),
              Text('HEIGHT & BMI', style: tt.labelMedium),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          _Stepper(
            value: _heightCm,
            unit: 'cm',
            step: 1,
            decimals: 0,
            color: AppTheme.carbs,
            onChanged: (v) =>
                setState(() => _heightCm = v.clamp(100, 250)),
          ),
          const SizedBox(height: Spacing.lg),
          // Auto-calculated BMI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('BMI: ',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.5))),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                          colors: AppTheme.accentGradient)
                      .createShader(
                          Rect.fromLTWH(0, 0, b.width, b.height)),
                  child: Text(
                    _bmi.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: AppTheme.accent.withValues(alpha: 0.12),
                  ),
                  child: Text(_bmiCategory,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stepper Widget ───────────────────────────────────────

class _Stepper extends StatelessWidget {
  final double value;
  final String unit;
  final double step;
  final int decimals;
  final Color color;
  final ValueChanged<double> onChanged;

  const _Stepper({
    required this.value,
    required this.unit,
    required this.step,
    required this.decimals,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepBtn(Icons.remove_rounded, () {
            HapticFeedback.selectionClick();
            onChanged(value - step);
          }),
          Text(
            '${value.toStringAsFixed(decimals)} $unit',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3),
          ),
          _stepBtn(Icons.add_rounded, () {
            HapticFeedback.selectionClick();
            onChanged(value + step);
          }),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
