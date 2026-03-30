import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_ring.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_calendar.dart';
import '../widgets/todays_calorie_card.dart';
import '../widgets/weight_goal_card.dart';
import '../widgets/diet_checklist.dart';
import '../widgets/todays_workout_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0);

  // 6 sections — action-first hierarchy, no insight banner
  static const List<List<double>> _intervals = [
    [0.00, 0.25], // 0: greeting
    [0.08, 0.38], // 1: macro dashboard
    [0.18, 0.48], // 2: diet checklist
    [0.28, 0.55], // 3: workout
    [0.36, 0.62], // 4: calorie + weight
    [0.44, 0.70], // 5: calendar
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fades = _intervals
        .map((i) => CurvedAnimation(
              parent: _controller,
              curve: Interval(i[0], i[1], curve: Curves.easeOut),
            ))
        .toList();

    _slides = _intervals
        .map((i) => Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _controller,
              curve: Interval(
                i[0],
                (i[1] + 0.05).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic,
              ),
            )))
        .toList();

    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  Widget _animated(int index, Widget child) {
    return FadeTransition(
      opacity: _fades[index],
      child: SlideTransition(
        position: _slides[index],
        child: child,
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
      'Saturday', 'Sunday',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
        ),

        // Parallax ambient orbs
        ValueListenableBuilder<double>(
          valueListenable: _scrollOffset,
          builder: (context, offset, child) => Positioned(
            top: -80 - (offset * 0.12),
            right: -60 + (offset * 0.03),
            child: child!,
          ),
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accent.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        ValueListenableBuilder<double>(
          valueListenable: _scrollOffset,
          builder: (context, offset, child) => Positioned(
            bottom: 100 + (offset * 0.08),
            left: -100 - (offset * 0.03),
            child: child!,
          ),
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.calories.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        ValueListenableBuilder<double>(
          valueListenable: _scrollOffset,
          builder: (context, offset, child) => Positioned(
            top: 300 - (offset * 0.06),
            left: -80,
            child: child!,
          ),
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.weight.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Content
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Spacing.xl),

                // 0: Greeting
                _animated(
                  0,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formattedDate().toUpperCase(),
                        style: textTheme.labelMedium,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(_greeting(), style: textTheme.displayLarge),
                    ],
                  ),
                ),

                const SizedBox(height: Spacing.xl),

                // 1: Compact Macro Dashboard
                _animated(1, _buildMacroDashboard()),

                const SizedBox(height: Spacing.xl),

                // 2: Diet Checklist — primary action
                _animated(2, const DietChecklist()),

                const SizedBox(height: Spacing.xl),

                // 3: Today's Workout — secondary action
                _animated(3, const TodaysWorkoutCard()),

                const SizedBox(height: Spacing.xl),

                // 4: Calorie + Weight cards — detailed stats
                _animated(
                  4,
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        Expanded(child: TodaysCalorieCard()),
                        SizedBox(width: Spacing.md),
                        Expanded(child: WeightGoalCard()),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: Spacing.xl),

                // 5: Progress Calendar — reflection / history
                _animated(
                  5,
                  ProgressCalendar(
                    dayResults: ProgressCalendar.generateDemoData(),
                  ),
                ),

                // Breathing room for bottom nav
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Compact Macro Dashboard ────────────────────────────

  double _cellAnim(double value, int index) {
    final delay = index * 0.05;
    return Curves.easeOutCubic
        .transform(((value - delay) / 0.7).clamp(0.0, 1.0));
  }

  String _fmtCount(int value) {
    if (value >= 1000) {
      return '${value ~/ 1000},${(value % 1000).toString().padLeft(3, '0')}';
    }
    return value.toString();
  }

  Widget _buildMacroDashboard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.linear,
      builder: (context, value, _) {
        return GlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: _macroCell(
                  rawValue: 1460,
                  suffix: '',
                  label: 'CALORIES',
                  color: AppTheme.calories,
                  gradient: AppTheme.caloriesGradient,
                  progress: 0.74,
                  animValue: _cellAnim(value, 0),
                ),
              ),
              Expanded(
                child: _macroCell(
                  rawValue: 92,
                  suffix: 'g',
                  label: 'PROTEIN',
                  color: AppTheme.protein,
                  gradient: AppTheme.proteinGradient,
                  progress: 0.61,
                  animValue: _cellAnim(value, 1),
                ),
              ),
              Expanded(
                child: _macroCell(
                  rawValue: 145,
                  suffix: 'g',
                  label: 'CARBS',
                  color: AppTheme.carbs,
                  gradient: AppTheme.carbsGradient,
                  progress: 0.72,
                  animValue: _cellAnim(value, 2),
                ),
              ),
              Expanded(
                child: _macroCell(
                  rawValue: 52,
                  suffix: 'g',
                  label: 'FAT',
                  color: AppTheme.fat,
                  gradient: AppTheme.fatGradient,
                  progress: 0.69,
                  animValue: _cellAnim(value, 3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _macroCell({
    required int rawValue,
    required String suffix,
    required String label,
    required Color color,
    required List<Color> gradient,
    required double progress,
    required double animValue,
  }) {
    final animated = (rawValue * animValue).round();
    final display = '${_fmtCount(animated)}$suffix';

    return Opacity(
      opacity: animValue.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 8 * (1 - animValue.clamp(0.0, 1.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini ring — no center text
            StatRing(
              progress: progress * animValue.clamp(0.0, 1.0),
              color: color,
              value: '',
              size: 52,
              strokeWidth: 5,
            ),
            const SizedBox(height: Spacing.sm),
            // Gradient value text with count-up
            ShaderMask(
              shaderCallback: (b) => LinearGradient(colors: gradient)
                  .createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
              child: Text(
                display,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
