import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import '../models/diet_models.dart';
import 'diet_plan_builder_screen.dart';

class DietPlansScreen extends StatefulWidget {
  /// When set, screen works in "select for day" mode.
  final int? selectForDay;
  final String? selectForDayName;

  const DietPlansScreen({
    super.key,
    this.selectForDay,
    this.selectForDayName,
  });

  @override
  State<DietPlansScreen> createState() => _DietPlansScreenState();
}

class _DietPlansScreenState extends State<DietPlansScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final _store = DietPlansStore.instance;

  bool get _isSelectMode => widget.selectForDay != null;

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.md, Spacing.lg, Spacing.md, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 15, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isSelectMode ? 'Select Plan' : 'My Diet Plans',
                            style: tt.displaySmall,
                          ),
                          if (_isSelectMode &&
                              widget.selectForDayName != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'for ${widget.selectForDayName}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.calories
                                      .withValues(alpha: 0.8)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _createNewPlan,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                              colors: AppTheme.caloriesGradient),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded,
                                size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Create',
                                style: tt.labelLarge
                                    ?.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // ── Content ──────────────────────────────────
              Expanded(
                child: _store.plans.isEmpty
                    ? _buildEmpty(tt)
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                            Spacing.lg, 0, Spacing.lg, 120),
                        itemCount: _store.plans.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: Spacing.md),
                        itemBuilder: (_, i) {
                          final plan = _store.plans[i];
                          final assignedDays =
                              _store.getDaysForPlan(plan.id);
                          final isSelected = _isSelectMode &&
                              _store
                                      .getPlanForDay(widget.selectForDay!)
                                      ?.id ==
                                  plan.id;
                          return FadeTransition(
                            opacity: _anim,
                            child: _PlanCard(
                              plan: plan,
                              isSelectMode: _isSelectMode,
                              assignedDays: assignedDays,
                              isCurrentlySelected: isSelected,
                              dayLetters: _dayLetters,
                              onTap: () => _isSelectMode
                                  ? _selectPlan(plan)
                                  : _editPlan(plan),
                              onDelete: () => _confirmDelete(plan),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────

  Widget _buildEmpty(TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.calories.withValues(alpha: 0.08),
              ),
              child: Icon(Icons.restaurant_menu_rounded,
                  size: 36,
                  color: AppTheme.calories.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: Spacing.lg),
            Text('No diet plans yet', style: tt.titleMedium),
            const SizedBox(height: Spacing.sm),
            Text(
              _isSelectMode
                  ? 'Create a plan first, then assign it to this day.'
                  : 'Create custom diet plans like\n"Fruits Only" or "Liquid Diet".',
              style: tt.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),
            GestureDetector(
              onTap: _createNewPlan,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xl, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                      colors: AppTheme.caloriesGradient),
                ),
                child: const Text(
                  'Create First Plan',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────

  Future<void> _createNewPlan() async {
    HapticFeedback.lightImpact();
    final plan = DietPlan(
      id: _store.generateId(),
      name: 'New Plan',
    );
    final result = await Navigator.push<DietPlan>(
      context,
      MaterialPageRoute(
        builder: (_) => DietPlanBuilderScreen(plan: plan, isNew: true),
      ),
    );
    if (result != null && mounted) {
      setState(() => _store.plans.add(result));
    }
  }

  Future<void> _editPlan(DietPlan plan) async {
    HapticFeedback.lightImpact();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DietPlanBuilderScreen(plan: plan, isNew: false),
      ),
    );
    if (mounted) setState(() {});
  }

  void _selectPlan(DietPlan plan) {
    HapticFeedback.lightImpact();
    _store.assignPlanToDay(widget.selectForDay!, plan.id);
    Navigator.pop(context);
  }

  void _confirmDelete(DietPlan plan) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(Spacing.md),
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(999)),
            ),
            const SizedBox(height: Spacing.lg),
            Text('Delete "${plan.name}"?',
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: Spacing.sm),
            Text(
              'This will also remove it from any assigned days.',
              style: Theme.of(ctx).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withValues(alpha: 0.06),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: const Center(
                        child: Text('Cancel',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _store.deletePlan(plan.id));
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: AppTheme.fat.withValues(alpha: 0.12),
                        border: Border.all(
                            color: AppTheme.fat.withValues(alpha: 0.2)),
                      ),
                      child: Center(
                        child: Text('Delete',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.fat)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );
  }
}

// ─── Plan Card ────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final DietPlan plan;
  final bool isSelectMode;
  final List<int> assignedDays;
  final bool isCurrentlySelected;
  final List<String> dayLetters;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PlanCard({
    required this.plan,
    required this.isSelectMode,
    required this.assignedDays,
    required this.isCurrentlySelected,
    required this.dayLetters,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final hasFood = plan.totalCalories > 0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: isSelectMode ? null : onDelete,
      child: GlassCard(
        accentColor:
            isCurrentlySelected ? AppTheme.calories : plan.tagColor,
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(plan.name,
                                style: tt.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: plan.tagColor.withValues(alpha: 0.15),
                            ),
                            child: Text(plan.tag,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: plan.tagColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.meals.length} meal${plan.meals.length == 1 ? '' : 's'}'
                        '${hasFood ? ' · ${plan.totalCalories} kcal' : ''}',
                        style: tt.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isCurrentlySelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: AppTheme.calories),
                    child: const Icon(Icons.check_rounded,
                        size: 16, color: Colors.black),
                  )
                else if (isSelectMode)
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.3))
                else
                  Icon(Icons.edit_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.25)),
              ],
            ),

            // ── Macro chips ───────────────────────────
            if (hasFood) ...[
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  _macroChip('P ${plan.totalProtein}g', AppTheme.protein),
                  const SizedBox(width: Spacing.sm),
                  _macroChip('C ${plan.totalCarbs}g', AppTheme.carbs),
                  const SizedBox(width: Spacing.sm),
                  _macroChip('F ${plan.totalFat}g', AppTheme.fat),
                ],
              ),
            ],

            // ── Assigned days ─────────────────────────
            if (!isSelectMode && assignedDays.isNotEmpty) ...[
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Text('Active: ',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.35))),
                  for (final d in assignedDays)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.calories.withValues(alpha: 0.15),
                      ),
                      child: Center(
                        child: Text(
                          dayLetters[d],
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.calories),
                        ),
                      ),
                    ),
                ],
              ),
            ],

            // ── Long press hint ───────────────────────
            if (!isSelectMode) ...[
              const SizedBox(height: Spacing.xs),
              Text('Hold to delete',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.18))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _macroChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withValues(alpha: 0.10),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.8))),
      );
}
