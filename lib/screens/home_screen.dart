import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_calendar.dart';
import '../widgets/todays_calorie_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    final screenHeight = MediaQuery.of(context).size.height;
    final widgetZoneHeight = screenHeight * 0.40;

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
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

                // Greeting
                Text(
                  _formattedDate().toUpperCase(),
                  style: textTheme.labelMedium,
                ),
                const SizedBox(height: Spacing.sm),
                Text(_greeting(), style: textTheme.displayLarge),

                const SizedBox(height: Spacing.xl),

                // --- Widget zone: 40% of screen height ---
                SizedBox(
                  height: widgetZoneHeight,
                  child: Column(
                    children: [
                      // 1. Progress calendar
                      ProgressCalendar(
                        dayResults: ProgressCalendar.generateDemoData(),
                      ),

                      const SizedBox(height: Spacing.md),

                      // 2. Today's calorie calculator
                      const TodaysCalorieCard(),
                    ],
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
}
