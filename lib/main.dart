import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/diet_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/progress_screen.dart';
import 'widgets/app_background.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/glass_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlay);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const HalkeWajanApp());
}

class HalkeWajanApp extends StatelessWidget {
  const HalkeWajanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halke Wajan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: _buildBody(),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: const [
        HomeScreen(),
        DietScreen(),
        WorkoutScreen(),
        ProgressScreen(),
        _PlaceholderScreen(title: 'Profile'),
      ],
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(title, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 32),
              // Tall card
              const GlassCard(
                child: SizedBox(height: 180, width: double.infinity),
              ),
              const SizedBox(height: 16),
              // Two side-by-side cards
              const IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        child: SizedBox(height: 120),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GlassCard(
                        child: SizedBox(height: 120),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Medium card
              const GlassCard(
                child: SizedBox(height: 140, width: double.infinity),
              ),
              const SizedBox(height: 16),
              // Small card
              const GlassCard(
                child: SizedBox(height: 80, width: double.infinity),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
