import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/progress_calendar.dart';
import '../widgets/todays_calorie_card.dart';
import '../widgets/weight_goal_card.dart';
import '../widgets/diet_checklist.dart';
import '../widgets/todays_workout_card.dart';
import 'consistency_screen.dart';

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

  static const _userName = 'Kedar';

  // 5 sections — action-first hierarchy
  static const List<List<double>> _intervals = [
    [0.00, 0.25], // 0: greeting
    [0.08, 0.40], // 1: diet checklist
    [0.20, 0.52], // 2: workout
    [0.32, 0.62], // 3: calorie + weight
    [0.42, 0.72], // 4: calendar
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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                    Text(
                      '${_greeting()},',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userName,
                      style: textTheme.displayLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.xl),

              // 1: Diet Checklist — primary action
              _animated(1, const DietChecklist()),

              const SizedBox(height: Spacing.md),

              // 2: Today's Workout — secondary action
              _animated(2, const TodaysWorkoutCard()),

              const SizedBox(height: Spacing.md),

              // 3: Calorie + Weight cards — detailed stats
              _animated(
                3,
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

              const SizedBox(height: Spacing.md),

              // 4: Progress Calendar — reflection / history (tap to open)
              _animated(
                4,
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConsistencyScreen(),
                      ),
                    );
                  },
                  child: ProgressCalendar(
                    dayResults: ProgressCalendar.generateDemoData(),
                  ),
                ),
              ),

              // Breathing room for bottom nav
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
