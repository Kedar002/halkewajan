import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  void _handleTap(int index) {
    HapticFeedback.lightImpact();
    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A12).withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(icon: Icons.cottage_rounded, label: 'Home', isActive: currentIndex == 0, onTap: () => _handleTap(0)),
                  _NavItem(icon: Icons.restaurant_menu_rounded, label: 'Diet', isActive: currentIndex == 1, onTap: () => _handleTap(1)),
                  _NavItem(icon: Icons.sports_gymnastics_rounded, label: 'Workout', isActive: currentIndex == 2, onTap: () => _handleTap(2)),
                  _NavItem(icon: Icons.insights_rounded, label: 'Progress', isActive: currentIndex == 3, onTap: () => _handleTap(3)),
                  _NavItem(icon: Icons.person_rounded, label: 'Profile', isActive: currentIndex == 4, onTap: () => _handleTap(4)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animated glow
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: AppTheme.animMedium,
                  curve: AppTheme.animCurve,
                  width: isActive ? 48 : 0,
                  height: isActive ? 48 : 0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isActive
                        ? RadialGradient(
                            colors: [
                              AppTheme.accent.withValues(alpha: 0.25),
                              Colors.transparent,
                            ],
                          )
                        : null,
                  ),
                ),
                Icon(
                  icon,
                  size: 24,
                  color: isActive
                      ? AppTheme.accent
                      : Colors.white.withValues(alpha: 0.4),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Active indicator dot
            AnimatedContainer(
              duration: AppTheme.animMedium,
              curve: AppTheme.animCurve,
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.accent.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: AppTheme.animFast,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppTheme.accent
                    : Colors.white.withValues(alpha: 0.4),
                letterSpacing: 0.1,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
