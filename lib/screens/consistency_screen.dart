import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import '../models/consistency_models.dart';

// ─── Consistency Screen ───────────────────────────────────

class ConsistencyScreen extends StatefulWidget {
  const ConsistencyScreen({super.key});

  @override
  State<ConsistencyScreen> createState() => _ConsistencyScreenState();
}

class _ConsistencyScreenState extends State<ConsistencyScreen>
    with SingleTickerProviderStateMixin {
  // ── Staggered entrance animation ──────────────────────────
  late final AnimationController _entranceCtrl;

  // 6 sections: header, stats row, calendar header, calendar grid,
  // day detail label, day detail content
  static const List<List<double>> _intervals = [
    [0.00, 0.30], // 0: header
    [0.10, 0.40], // 1: stats row
    [0.22, 0.52], // 2: calendar card header
    [0.30, 0.62], // 3: calendar grid
    [0.42, 0.70], // 4: day detail label
    [0.50, 0.80], // 5: day detail content
  ];

  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  // ── Calendar state ────────────────────────────────────────
  late DateTime _displayMonth; // first day of visible month
  late DateTime _selectedDate;
  final DateTime _today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  // ── Month slide direction (for AnimatedSwitcher key trick) ─
  int _monthSlideDirection = 1; // +1 forward, -1 backward

  @override
  void initState() {
    super.initState();

    _displayMonth = DateTime(_today.year, _today.month, 1);
    _selectedDate = _today;

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fades = _intervals
        .map((i) => CurvedAnimation(
              parent: _entranceCtrl,
              curve: Interval(i[0], i[1], curve: Curves.easeOut),
            ))
        .toList();

    _slides = _intervals
        .map((i) => Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _entranceCtrl,
              curve: Interval(
                i[0],
                (i[1] + 0.04).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic,
              ),
            )))
        .toList();

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _animated(int index, Widget child) => FadeTransition(
        opacity: _fades[index],
        child: SlideTransition(position: _slides[index], child: child),
      );

  // ── Navigation helpers ────────────────────────────────────
  void _prevMonth() {
    setState(() {
      _monthSlideDirection = -1;
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    final nextFirst = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    // Don't advance past the current month
    if (nextFirst.isAfter(DateTime(_today.year, _today.month, 1))) return;
    setState(() {
      _monthSlideDirection = 1;
      _displayMonth = nextFirst;
    });
  }

  bool get _canGoForward {
    final nextFirst = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    return !nextFirst.isAfter(DateTime(_today.year, _today.month, 1));
  }

  // ── Month label ───────────────────────────────────────────
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String get _monthLabel =>
      '${_months[_displayMonth.month - 1]} ${_displayMonth.year}';

  // ── Calendar grid helpers ─────────────────────────────────
  // Returns the list of DateTime? for the grid (null = padding cells)
  List<DateTime?> _calendarCells() {
    final firstWeekday = _displayMonth.weekday; // 1=Mon … 7=Sun
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;

    final cells = <DateTime?>[];

    // Leading empty cells so Mon is column 0
    for (var i = 1; i < firstWeekday; i++) {
      cells.add(null);
    }

    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_displayMonth.year, _displayMonth.month, d));
    }

    // Pad to complete the last row
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  // ── Day status helpers ────────────────────────────────────
  DayStatus? _statusFor(DateTime date) {
    return ConsistencyStore.instance.getLog(date)?.status;
  }

  bool _isFuture(DateTime date) => date.isAfter(_today);
  bool _isToday(DateTime date) => date == _today;
  bool _isSelected(DateTime date) => date == _selectedDate;

  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final store = ConsistencyStore.instance;
    final currentStreak = store.currentStreak;
    final longestStreak = store.longestStreak;
    final monthPct = store.monthConsistency(_today.year, _today.month);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: Spacing.md),

                    // ── 1. Header ──────────────────────────
                    _animated(
                      0,
                      _buildHeader(currentStreak),
                    ),

                    const SizedBox(height: Spacing.lg),

                    // ── 2. Stats row ───────────────────────
                    _animated(
                      1,
                      _buildStatsRow(
                          currentStreak, longestStreak, monthPct),
                    ),

                    const SizedBox(height: Spacing.md),

                    // ── 3 + 4. Calendar ─────────────────────
                    _animated(
                      2,
                      _buildCalendarCard(),
                    ),

                    const SizedBox(height: Spacing.md),

                    // ── 5 + 6. Day detail ──────────────────
                    _animated(
                      4,
                      _buildDayDetailSection(),
                    ),

                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildHeader(int currentStreak) {
    return Row(
      children: [
        // Back button — 38px circle
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppTheme.ink,
            ),
          ),
        ),

        const SizedBox(width: Spacing.md),

        // Title
        Expanded(
          child: Text(
            'Consistency',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),

        // Streak badge — gradient pill
        _buildStreakBadge(currentStreak),
      ],
    );
  }

  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs + 2,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppTheme.accentGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTheme.borderRadiusPill,
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.canvas,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            'days',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.canvas.withValues(alpha: 0.70),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STATS ROW
  // ══════════════════════════════════════════════════════════
  Widget _buildStatsRow(
      int currentStreak, int longestStreak, double monthPct) {
    final pctString =
        '${(monthPct * 100).round()}%';

    return Stack(
      children: [
        // Ambient green glow behind the card
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppTheme.borderRadiusCard,
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.2,
                colors: [
                  AppTheme.accent.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        GlassCard(
          accentColor: AppTheme.accent,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.lg,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Current streak
                Expanded(
                  child: _buildStatCell(
                    value: '$currentStreak',
                    label: 'days',
                    sublabel: 'Current Streak',
                    isAccent: true,
                  ),
                ),

                // Divider
                _buildVertDivider(),

                // Longest streak
                Expanded(
                  child: _buildStatCell(
                    value: '$longestStreak',
                    label: 'days',
                    sublabel: 'Longest Streak',
                    isAccent: false,
                  ),
                ),

                // Divider
                _buildVertDivider(),

                // This month
                Expanded(
                  child: _buildStatCell(
                    value: pctString,
                    label: '',
                    sublabel: 'This Month',
                    isAccent: false,
                    isMedium: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCell({
    required String value,
    required String label,
    required String sublabel,
    bool isAccent = false,
    bool isMedium = false,
  }) {
    final valueWidget = Text(
      value,
      style: TextStyle(
        fontSize: isMedium ? 28 : 32,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -1.0,
        height: 1.0,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        isAccent
            ? ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: AppTheme.accentGradient,
                ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: valueWidget,
              )
            : valueWidget,
        if (label.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: 0.3,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          sublabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.40),
            letterSpacing: 0.8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVertDivider() => Container(
        width: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: Colors.white.withValues(alpha: 0.08),
      );

  // ══════════════════════════════════════════════════════════
  // CALENDAR
  // ══════════════════════════════════════════════════════════
  Widget _buildCalendarCard() {
    return GlassCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        children: [
          // Month nav
          _buildMonthNav(),
          const SizedBox(height: Spacing.md),
          // Weekday headers
          _buildWeekdayHeaders(),
          const SizedBox(height: Spacing.sm),
          // Day grid — animate on month change
          AnimatedSwitcher(
            duration: AppTheme.animMedium,
            transitionBuilder: (child, animation) {
              // Slide direction based on navigation
              final offset = _monthSlideDirection > 0
                  ? const Offset(0.15, 0)
                  : const Offset(-0.15, 0);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: offset,
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: AppTheme.animCurve,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey('${_displayMonth.year}-${_displayMonth.month}'),
              child: _animated(3, _buildDayGrid()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNav() {
    final canForward = _canGoForward;
    return Row(
      children: [
        // Left arrow
        _buildNavArrow(
          icon: Icons.chevron_left_rounded,
          onTap: _prevMonth,
          enabled: true,
        ),

        // Month label
        Expanded(
          child: AnimatedSwitcher(
            duration: AppTheme.animFast,
            child: Text(
              _monthLabel,
              key: ValueKey(_monthLabel),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Right arrow
        _buildNavArrow(
          icon: Icons.chevron_right_rounded,
          onTap: canForward ? _nextMonth : null,
          enabled: canForward,
        ),
      ],
    );
  }

  Widget _buildNavArrow({
    required IconData icon,
    required VoidCallback? onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: enabled ? 0.06 : 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: enabled ? 0.08 : 0.04),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.white.withValues(alpha: enabled ? 0.80 : 0.25),
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: labels
          .map(
            (l) => Expanded(
              child: Text(
                l,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.30),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDayGrid() {
    final cells = _calendarCells();
    final rows = <Widget>[];

    for (var r = 0; r < cells.length ~/ 7; r++) {
      final rowCells = cells.sublist(r * 7, r * 7 + 7);
      rows.add(
        Row(
          children: rowCells
              .map((date) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: date == null
                          ? const SizedBox(height: 40)
                          : _DayCell(
                              date: date,
                              status: _statusFor(date),
                              isFuture: _isFuture(date),
                              isToday: _isToday(date),
                              isSelected: _isSelected(date),
                              onTap: () {
                                if (!_isFuture(date)) {
                                  setState(() => _selectedDate = date);
                                }
                              },
                            ),
                    ),
                  ))
              .toList(),
        ),
      );
    }

    return Column(children: rows);
  }

  // ══════════════════════════════════════════════════════════
  // DAY DETAIL
  // ══════════════════════════════════════════════════════════
  Widget _buildDayDetailSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: AppTheme.animCurve,
            )),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(_selectedDate),
        child: _buildDayDetail(_selectedDate),
      ),
    );
  }

  Widget _buildDayDetail(DateTime date) {
    final log = ConsistencyStore.instance.getLog(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header row
        _buildDetailHeader(date, log),
        const SizedBox(height: Spacing.md),

        // Diet section
        if (log != null && log.hasDiet) ...[
          _animated(5, _buildDietCard(log)),
          const SizedBox(height: Spacing.md),
        ],

        // Workout section
        if (log != null) ...[
          _animated(5, _buildWorkoutCard(log)),
          const SizedBox(height: Spacing.md),
        ],

        // Body stats section
        if (log != null && (log.hasWeight || log.hasMeasurements)) ...[
          _animated(5, _buildBodyCard(log)),
        ],

        // Empty state when no log at all
        if (log == null) _buildNoDataPlaceholder(date),
      ],
    );
  }

  Widget _buildDetailHeader(DateTime date, DayLog? log) {
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    final dayName = weekdays[date.weekday - 1];
    final monthName = _months[date.month - 1];
    final dateLabel = '$dayName, $monthName ${date.day}';

    final status = log?.status ?? DayStatus.noData;

    return Row(
      children: [
        Expanded(
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        _buildStatusPill(status),
      ],
    );
  }

  Widget _buildStatusPill(DayStatus status) {
    IconData icon;
    String label;
    Color color;

    switch (status) {
      case DayStatus.hit:
        icon = Icons.check_circle_rounded;
        label = 'Goal Met';
        color = AppTheme.accent;
        break;
      case DayStatus.missed:
        icon = Icons.cancel_rounded;
        label = 'Missed';
        color = AppTheme.fat;
        break;
      case DayStatus.rest:
        icon = Icons.bedtime_rounded;
        label = 'Rest Day';
        color = AppTheme.weight;
        break;
      case DayStatus.noData:
        icon = Icons.remove_circle_outline_rounded;
        label = 'No Data';
        color = Colors.white.withValues(alpha: 0.40);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm + 4,
        vertical: Spacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppTheme.borderRadiusPill,
        border: Border.all(
          color: color.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Diet Card ─────────────────────────────────────────────
  Widget _buildDietCard(DayLog log) {
    final progress =
        (log.calorieGoal > 0 ? log.totalCalories / log.calorieGoal : 0.0)
            .clamp(0.0, 1.0);

    return GlassCard(
      accentColor: AppTheme.calories,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _iconBadge(Icons.restaurant_rounded, AppTheme.caloriesGradient),
              const SizedBox(width: Spacing.sm),
              Text(
                'Diet',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              if (log.dietPlanName != null)
                _planPill(log.dietPlanName!, log.dietPlanColor ?? AppTheme.accent),
            ],
          ),

          const SizedBox(height: Spacing.md),

          // Calorie progress bar
          _buildCalorieBar(log.totalCalories, log.calorieGoal, progress),

          const SizedBox(height: Spacing.md),

          // Macro row
          Row(
            children: [
              Expanded(
                child: _buildMacroBlock(
                  label: 'Protein',
                  value: '${log.totalProtein}g',
                  gradient: AppTheme.proteinGradient,
                  color: AppTheme.protein,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _buildMacroBlock(
                  label: 'Carbs',
                  value: '${log.totalCarbs}g',
                  gradient: AppTheme.carbsGradient,
                  color: AppTheme.carbs,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _buildMacroBlock(
                  label: 'Fat',
                  value: '${log.totalFat}g',
                  gradient: AppTheme.fatGradient,
                  color: AppTheme.fat,
                ),
              ),
            ],
          ),

          if (log.meals.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            // Subtle divider
            Container(height: 0.5, color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: Spacing.sm),

            // Meal list
            ...List.generate(log.meals.length, (i) {
              final meal = log.meals[i];
              final foods = meal.foods.map((f) => f.name).join(', ');
              return _buildMealRow(
                icon: meal.icon,
                name: meal.name,
                foods: foods,
                calories: meal.totalCalories,
                isAlt: i.isOdd,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildCalorieBar(int consumed, int goal, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Consumed — gradient text
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: AppTheme.caloriesGradient,
              ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                '$consumed',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
            Text(
              '/ $goal kcal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Stack(
          children: [
            // Track
            Container(
              height: 7,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            // Fill
            LayoutBuilder(builder: (ctx, constraints) {
              return Stack(
                children: [
                  // Glow layer
                  Container(
                    height: 7,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppTheme.caloriesGradient,
                      ),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.calories.withValues(alpha: 0.45),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroBlock({
    required String label,
    required String value,
    required List<Color> gradient,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: color.withValues(alpha: 0.12), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: gradient,
            ).createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.40),
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealRow({
    required IconData icon,
    required String name,
    required String foods,
    required int calories,
    bool isAlt = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.xs + 2,
        horizontal: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: isAlt
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 16, color: Colors.white.withValues(alpha: 0.60)),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
                if (foods.isNotEmpty)
                  Text(
                    foods,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.40),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: AppTheme.caloriesGradient,
            ).createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: Text(
              '$calories',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            ' kcal',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  // ── Workout Card ──────────────────────────────────────────
  Widget _buildWorkoutCard(DayLog log) {
    final hasWorkout = log.hasWorkout;
    final isRest = log.status == DayStatus.rest;

    return GlassCard(
      accentColor: AppTheme.accent,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _iconBadge(Icons.fitness_center_rounded, AppTheme.accentGradient),
              const SizedBox(width: Spacing.sm),
              Text(
                hasWorkout
                    ? (log.workoutName ?? 'Workout')
                    : 'Workout',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              if (hasWorkout && log.workoutDuration != null)
                _durationPill(log.workoutDuration!),
            ],
          ),

          if (!hasWorkout) ...[
            const SizedBox(height: Spacing.md),
            _buildWorkoutEmpty(isRest),
          ] else ...[
            // Muscle tags
            if (log.musclesWorked.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: log.musclesWorked
                    .map((m) => _musclePill(m))
                    .toList(),
              ),
            ],

            const SizedBox(height: Spacing.md),

            // Stats row
            Row(
              children: [
                _buildMiniStat(
                  label: 'Volume',
                  value: '${log.totalVolume}',
                  unit: 'kg',
                  gradient: AppTheme.accentGradient,
                ),
                const SizedBox(width: Spacing.lg),
                _buildMiniStat(
                  label: 'Sets',
                  value: '${log.totalSets}',
                  unit: '',
                  gradient: AppTheme.weightGradient,
                ),
              ],
            ),

            const SizedBox(height: Spacing.md),
            Container(
                height: 0.5,
                color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: Spacing.sm),

            // Exercise list
            ...List.generate(log.exercises.length, (i) {
              final ex = log.exercises[i];
              return _buildExerciseRow(
                name: ex.name,
                detail: ex.detail,
                isAlt: i.isOdd,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkoutEmpty(bool isRest) {
    return Row(
      children: [
        Icon(
          isRest ? Icons.bedtime_rounded : Icons.fitness_center_outlined,
          size: 28,
          color: Colors.white.withValues(alpha: 0.20),
        ),
        const SizedBox(width: Spacing.sm),
        Text(
          isRest ? 'Rest Day — recovery counts.' : 'No workout logged.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.35),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required String unit,
    required List<Color> gradient,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: gradient,
              ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 3),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.40),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseRow({
    required String name,
    required String detail,
    bool isAlt = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.xs + 2,
        horizontal: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: isAlt
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.ink,
              ),
            ),
          ),
          Text(
            detail,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.50),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Body Stats Card ───────────────────────────────────────
  Widget _buildBodyCard(DayLog log) {
    return GlassCard(
      accentColor: AppTheme.weight,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _iconBadge(
                  Icons.monitor_weight_rounded, AppTheme.weightGradient),
              const SizedBox(width: Spacing.sm),
              Text('Body Stats',
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),

          const SizedBox(height: Spacing.md),

          // Weight + Water row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (log.hasWeight) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.40),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(
                            colors: AppTheme.weightGradient,
                          ).createShader(Rect.fromLTWH(
                              0, 0, bounds.width, bounds.height)),
                          child: Text(
                            log.weight!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1.5,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'kg',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              const Spacer(),
              if (log.waterLitres != null)
                _buildWaterDisplay(log.waterLitres!),
            ],
          ),

          if (log.hasMeasurements) ...[
            const SizedBox(height: Spacing.md),
            Container(
                height: 0.5,
                color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: Spacing.md),
            _buildMeasurementsGrid(log.measurements),
          ],
        ],
      ),
    );
  }

  Widget _buildWaterDisplay(double litres) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Hydration',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.40),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.water_drop_rounded,
                size: 16, color: AppTheme.carbs.withValues(alpha: 0.80)),
            const SizedBox(width: 4),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: AppTheme.carbsGradient,
              ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                '${litres.toStringAsFixed(1)}L',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementsGrid(Map<String, MeasurementLog> measurements) {
    final entries = measurements.entries.toList();
    final rows = <Widget>[];

    for (var i = 0; i < entries.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(
              child: _buildMeasurementCell(
                  entries[i].key, entries[i].value),
            ),
            if (i + 1 < entries.length) ...[
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _buildMeasurementCell(
                    entries[i + 1].key, entries[i + 1].value),
              ),
            ] else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < entries.length) {
        rows.add(const SizedBox(height: Spacing.sm));
      }
    }

    return Column(children: rows);
  }

  Widget _buildMeasurementCell(String name, MeasurementLog log) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.weight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.weight.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.50),
            ),
          ),
          Text(
            '${log.value.toStringAsFixed(1)} ${log.unit}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }

  // ── No data placeholder ────────────────────────────────────
  Widget _buildNoDataPlaceholder(DateTime date) {
    final isFuture = _isFuture(date);
    return GlassCard(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              isFuture
                  ? Icons.lock_clock_rounded
                  : Icons.edit_calendar_rounded,
              size: 40,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              isFuture ? 'Future date' : 'Nothing logged',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.30),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              isFuture
                  ? 'Log data once the day arrives.'
                  : 'No entries found for this day.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.20),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared sub-widgets ────────────────────────────────────

  Widget _iconBadge(IconData icon, List<Color> gradient) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.30),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 17, color: Colors.white),
    );
  }

  Widget _planPill(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppTheme.borderRadiusPill,
        border:
            Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _durationPill(String duration) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.10),
        borderRadius: AppTheme.borderRadiusPill,
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Text(
        duration,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.accent.withValues(alpha: 0.90),
        ),
      ),
    );
  }

  Widget _musclePill(String muscle) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: AppTheme.borderRadiusPill,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Text(
        muscle,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.60),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// DAY CELL WIDGET
// A stateful widget so AnimatedContainer is self-contained
// ══════════════════════════════════════════════════════════
class _DayCell extends StatefulWidget {
  final DateTime date;
  final DayStatus? status;
  final bool isFuture;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.status,
    required this.isFuture,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  // ── Color helpers ──────────────────────────────────────────
  Color _statusColor() {
    switch (widget.status) {
      case DayStatus.hit:
        return AppTheme.accent;
      case DayStatus.missed:
        return AppTheme.fat;
      case DayStatus.rest:
        return AppTheme.weight;
      case DayStatus.noData:
      case null:
        return Colors.white;
    }
  }

  Color _textColor() {
    if (widget.isFuture) return Colors.white.withValues(alpha: 0.18);
    switch (widget.status) {
      case DayStatus.hit:
      case DayStatus.missed:
        return Colors.white;
      case DayStatus.rest:
        return Colors.white.withValues(alpha: 0.70);
      case DayStatus.noData:
      case null:
        return Colors.white.withValues(alpha: 0.30);
    }
  }

  Color _bgColor() {
    if (widget.isFuture) return Colors.transparent;
    switch (widget.status) {
      case DayStatus.hit:
        return AppTheme.accent.withValues(alpha: 0.15);
      case DayStatus.missed:
        return AppTheme.fat.withValues(alpha: 0.15);
      case DayStatus.rest:
        return Colors.white.withValues(alpha: 0.08);
      case DayStatus.noData:
      case null:
        return Colors.white.withValues(alpha: 0.05);
    }
  }

  Color _borderColor() {
    if (widget.isSelected) {
      return _statusColor().withValues(alpha: 0.60);
    }
    if (widget.isFuture) return Colors.transparent;
    switch (widget.status) {
      case DayStatus.hit:
        return AppTheme.accent.withValues(alpha: 0.40);
      case DayStatus.missed:
        return AppTheme.fat.withValues(alpha: 0.35);
      case DayStatus.rest:
        return Colors.white.withValues(alpha: 0.10);
      case DayStatus.noData:
      case null:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final isInteractive = !widget.isFuture;

    return GestureDetector(
      onTapDown: isInteractive
          ? (_) => _pressCtrl.forward()
          : null,
      onTapUp: isInteractive
          ? (_) {
              _pressCtrl.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: isInteractive ? () => _pressCtrl.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Center(
          child: AnimatedContainer(
            duration: AppTheme.animFast,
            curve: AppTheme.animCurve,
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isSelected
                  ? statusColor.withValues(alpha: 0.20)
                  : _bgColor(),
              border: Border.all(
                color: _borderColor(),
                width: widget.isSelected ? 1.5 : 1.0,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.30),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.12),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Day number
                Text(
                  '${widget.date.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isSelected || widget.isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? Colors.white
                        : _textColor(),
                    height: 1.0,
                  ),
                ),

                // Today dot indicator
                if (widget.isToday)
                  Positioned(
                    bottom: 5,
                    child: AnimatedContainer(
                      duration: AppTheme.animFast,
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isSelected
                            ? Colors.white.withValues(alpha: 0.70)
                            : AppTheme.accent,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.60),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
