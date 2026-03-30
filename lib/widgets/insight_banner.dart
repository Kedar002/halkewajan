import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InsightBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? accentColor;

  const InsightBanner({
    super.key,
    required this.message,
    this.icon = Icons.auto_awesome_rounded,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.accent;
    return ClipRRect(
      borderRadius: AppTheme.borderRadiusCard,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md + Spacing.xs),
          decoration: BoxDecoration(
            borderRadius: AppTheme.borderRadiusCard,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.08),
                color.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppTheme.ink,
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
