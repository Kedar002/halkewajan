import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Day result for the progress calendar.
enum DayResult {
  /// Goal met / good day
  hit,

  /// Goal missed / bad day
  missed,

  /// No data logged
  noData,
}

/// Zerodha-style month-grouped progress calendar.
class ProgressCalendar extends StatelessWidget {
  final Map<DateTime, DayResult> dayResults;
  final int monthCount;
  final String? summaryText;

  const ProgressCalendar({
    super.key,
    this.dayResults = const {},
    this.monthCount = 12,
    this.summaryText,
  });

  static const double _cell = 14.0;
  static const double _gap = 3.0;
  static const double _step = _cell + _gap;
  static const double _monthGap = 12.0;

  /// Demo data for the past year.
  static Map<DateTime, DayResult> generateDemoData() {
    final rng = math.Random(42);
    final data = <DateTime, DayResult>{};
    final today = DateTime.now();

    for (var i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final key = DateTime(date.year, date.month, date.day);
      final roll = rng.nextDouble();

      if (roll < 0.20) {
        continue;
      } else if (roll < 0.40) {
        data[key] = DayResult.missed;
      } else {
        data[key] = DayResult.hit;
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final today = DateTime.now();

    final months = <_MonthData>[];
    for (var i = monthCount - 1; i >= 0; i--) {
      var year = today.year;
      var month = today.month - i;
      while (month <= 0) {
        month += 12;
        year--;
      }
      months.add(_buildMonth(year, month, today));
    }

    var totalWidth = 0.0;
    for (var i = 0; i < months.length; i++) {
      totalWidth += months[i].weekCount * _step;
      if (i < months.length - 1) totalWidth += _monthGap;
    }

    const gridHeight = 7 * _step - _gap;
    const labelHeight = 18.0;
    const totalHeight = gridHeight + 6 + labelHeight;

    final hitDays =
        dayResults.values.where((r) => r == DayResult.hit).length;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md, Spacing.md, Spacing.md, Spacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: totalHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              physics: const BouncingScrollPhysics(),
              child: CustomPaint(
                size: Size(totalWidth, totalHeight),
                painter: _CalendarPainter(
                  months: months,
                  cellSize: _cell,
                  gap: _gap,
                  monthGap: _monthGap,
                  gridHeight: gridHeight,
                  labelHeight: labelHeight,
                ),
              ),
            ),
          ),

          const SizedBox(height: Spacing.sm),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  summaryText ?? '$hitDays days on track this year',
                  style: textTheme.bodySmall?.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendItem(color: AppTheme.accent, label: 'Hit'),
                  const SizedBox(width: Spacing.sm),
                  _LegendItem(color: AppTheme.fat, label: 'Missed'),
                  const SizedBox(width: Spacing.sm),
                  _LegendItem(
                    color: Colors.white.withValues(alpha: 0.15),
                    label: 'No data',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _MonthData _buildMonth(int year, int month, DateTime today) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = (firstDay.weekday - 1) % 7;

    final totalSlots = firstWeekday + daysInMonth;
    final weekCount = (totalSlots / 7).ceil();

    final grid = List.generate(
      weekCount,
      (_) => List<_CellData?>.filled(7, null),
    );

    for (var d = 1; d <= daysInMonth; d++) {
      final slot = firstWeekday + d - 1;
      final col = slot ~/ 7;
      final row = slot % 7;

      final date = DateTime(year, month, d);
      final isFuture = date.isAfter(today);

      DayResult? result;
      if (isFuture) {
        result = null;
      } else {
        final key = DateTime(year, month, d);
        result = dayResults[key] ?? DayResult.noData;
      }

      grid[col][row] = _CellData(result: result, isFuture: isFuture);
    }

    const monthNames = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];

    return _MonthData(
      label: monthNames[month - 1],
      weekCount: weekCount,
      grid: grid,
    );
  }
}

class _MonthData {
  final String label;
  final int weekCount;
  final List<List<_CellData?>> grid;

  _MonthData({
    required this.label,
    required this.weekCount,
    required this.grid,
  });
}

class _CellData {
  final DayResult? result;
  final bool isFuture;

  _CellData({required this.result, required this.isFuture});
}

class _CalendarPainter extends CustomPainter {
  final List<_MonthData> months;
  final double cellSize;
  final double gap;
  final double monthGap;
  final double gridHeight;
  final double labelHeight;

  _CalendarPainter({
    required this.months,
    required this.cellSize,
    required this.gap,
    required this.monthGap,
    required this.gridHeight,
    required this.labelHeight,
  });

  Color _colorForResult(DayResult? result, bool isFuture) {
    if (isFuture || result == null) return Colors.transparent;
    switch (result) {
      case DayResult.hit:
        return AppTheme.accent;
      case DayResult.missed:
        return AppTheme.fat;
      case DayResult.noData:
        return Colors.white.withValues(alpha: 0.08);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final step = cellSize + gap;
    final cellRadius = Radius.circular(3);
    final paint = Paint()..style = PaintingStyle.fill;

    // Glow paint for hit/missed cells — light bleed on dark
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    var xOffset = 0.0;

    for (final month in months) {
      // Pass 1: glow behind colored cells
      for (var w = 0; w < month.weekCount; w++) {
        for (var d = 0; d < 7; d++) {
          final cell = month.grid[w][d];
          if (cell == null || cell.isFuture) continue;
          if (cell.result != DayResult.hit && cell.result != DayResult.missed) {
            continue;
          }

          final color = _colorForResult(cell.result, cell.isFuture);
          glowPaint.color = color.withValues(alpha: 0.25);
          final rect = RRect.fromLTRBR(
            xOffset + w * step,
            d * step,
            xOffset + w * step + cellSize,
            d * step + cellSize,
            cellRadius,
          );
          canvas.drawRRect(rect, glowPaint);
        }
      }

      // Pass 2: solid cells
      for (var w = 0; w < month.weekCount; w++) {
        for (var d = 0; d < 7; d++) {
          final cell = month.grid[w][d];
          if (cell == null) continue;

          final color = _colorForResult(cell.result, cell.isFuture);
          if (color == Colors.transparent) continue;

          paint.color = color;
          final rect = RRect.fromLTRBR(
            xOffset + w * step,
            d * step,
            xOffset + w * step + cellSize,
            d * step + cellSize,
            cellRadius,
          );
          canvas.drawRRect(rect, paint);
        }
      }

      // Month label
      final monthWidth = month.weekCount * step - gap;
      final tp = TextPainter(
        text: TextSpan(
          text: month.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelX = xOffset + (monthWidth - tp.width) / 2;
      tp.paint(canvas, Offset(labelX, gridHeight + 6));

      xOffset += monthWidth + gap + monthGap;
    }
  }

  @override
  bool shouldRepaint(_CalendarPainter oldDelegate) =>
      months.length != oldDelegate.months.length;
}

/// Legend item: small colored dot + label.
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
