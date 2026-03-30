import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_ring.dart';
import '../widgets/insight_banner.dart';
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

  // 7 sections — reordered for action-first hierarchy
  static const List<List<double>> _intervals = [
    [0.00, 0.22], // 0: greeting
    [0.06, 0.32], // 1: insight banner
    [0.12, 0.40], // 2: hero rings
    [0.22, 0.50], // 3: diet checklist
    [0.30, 0.58], // 4: workout
    [0.38, 0.65], // 5: calorie + weight
    [0.46, 0.72], // 6: calendar
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

                const SizedBox(height: Spacing.lg),

                // 1: Insight Banner — context before data
                _animated(
                  1,
                  const InsightBanner(
                    message:
                        "You're 460 kcal below your target — on track for your deficit goal today.",
                  ),
                ),

                const SizedBox(height: Spacing.xl),

                // 2: Hero Activity Rings — the visual centerpiece
                _animated(2, Center(child: _buildHeroRings(context))),

                const SizedBox(height: Spacing.xl),

                // 3: Diet Checklist — primary action
                _animated(3, const DietChecklist()),

                const SizedBox(height: Spacing.xl),

                // 4: Today's Workout — secondary action
                _animated(4, const TodaysWorkoutCard()),

                const SizedBox(height: Spacing.xl),

                // 5: Calorie + Weight cards — detailed stats
                _animated(
                  5,
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

                // 6: Progress Calendar — reflection / history
                _animated(
                  6,
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

  Widget _buildHeroRings(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Ambient glow behind rings
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withValues(alpha: 0.08 * value),
                    AppTheme.calories.withValues(alpha: 0.04 * value),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Activity rings
            ActivityRings(
              calorieProgress: 0.74 * value,
              proteinProgress: 0.61 * value,
              carbsProgress: 0.72 * value,
              fatProgress: 0.69 * value,
              size: 190,
            ),
            // Center content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: AppTheme.accentGradient,
                  ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: Text(
                    '${(74 * value).round()}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1.0,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daily Goal',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
