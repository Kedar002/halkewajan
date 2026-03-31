import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import '../models/diet_models.dart';

// ─── Screen ───────────────────────────────────────────────

class DietPlanBuilderScreen extends StatefulWidget {
  final DietPlan plan;
  final bool isNew;

  const DietPlanBuilderScreen({
    super.key,
    required this.plan,
    required this.isNew,
  });

  @override
  State<DietPlanBuilderScreen> createState() =>
      _DietPlanBuilderScreenState();
}

class _DietPlanBuilderScreenState extends State<DietPlanBuilderScreen> {
  late final TextEditingController _nameCtrl;
  late final DietPlan _plan;
  final Set<int> _expandedMeals = {};

  static const _tagOptions = <(String, Color)>[
    ('Custom',       Color(0xFF00E676)),
    ('High Protein', Color(0xFFAF52DE)),
    ('Weight Loss',  Color(0xFFFF9500)),
    ('Vegetarian',   Color(0xFF34C759)),
    ('Vegan',        Color(0xFF30D158)),
    ('Liquid Diet',  Color(0xFF5AC8FA)),
    ('Fruits Only',  Color(0xFFFF6B6B)),
    ('Keto',         Color(0xFFFF9F0A)),
    ('Bulking',      Color(0xFFFF375F)),
    ('Balanced',     Color(0xFF64D2FF)),
  ];

  static const _mealPresets = <(String, IconData)>[
    ('Early Morning',  Icons.wb_twilight_rounded),
    ('Breakfast',      Icons.light_mode_rounded),
    ('Mid-Morning',    Icons.coffee_rounded),
    ('Lunch',          Icons.wb_sunny_rounded),
    ('Evening Snack',  Icons.emoji_food_beverage_rounded),
    ('Dinner',         Icons.dark_mode_rounded),
    ('Post-Workout',   Icons.sports_bar_rounded),
    ('Custom',         Icons.add_circle_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
    _nameCtrl = TextEditingController(text: _plan.name);
    // Auto-expand all meals so user sees them immediately.
    for (var i = 0; i < _plan.meals.length; i++) {
      _expandedMeals.add(i);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Computed totals ────────────────────────────────────

  int get _totalCal => _plan.totalCalories;
  int get _totalP   => _plan.totalProtein;
  int get _totalC   => _plan.totalCarbs;
  int get _totalF   => _plan.totalFat;

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── App bar ───────────────────────────────
              _buildAppBar(tt),

              // ── Tag chips ─────────────────────────────
              _buildTagChips(),

              Container(
                height: 0.5,
                color: Colors.white.withValues(alpha: 0.06),
              ),

              // ── Meals list / empty state ───────────────
              Expanded(
                child: _plan.meals.isEmpty
                    ? _buildEmptyState(tt)
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                            Spacing.lg, Spacing.lg, Spacing.lg, 220),
                        itemCount: _plan.meals.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: Spacing.md),
                        itemBuilder: (_, i) => _MealSectionCard(
                          meal: _plan.meals[i],
                          isExpanded: _expandedMeals.contains(i),
                          onToggle: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              if (_expandedMeals.contains(i)) {
                                _expandedMeals.remove(i);
                              } else {
                                _expandedMeals.add(i);
                              }
                            });
                          },
                          onAddFood: () => _showAddFoodSheet(i),
                          onDeleteMeal: () => _deleteMeal(i),
                          onEditFood: (fi) =>
                              _showAddFoodSheet(i, foodIndex: fi),
                          onDeleteFood: (fi) {
                            HapticFeedback.mediumImpact();
                            setState(
                                () => _plan.meals[i].foods.removeAt(fi));
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
        // ── Sticky bottom bar ──────────────────────────
        bottomNavigationBar: _buildBottomBar(tt),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────

  Widget _buildAppBar(TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Spacing.md, Spacing.md, Spacing.md, Spacing.sm),
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
            child: TextField(
              controller: _nameCtrl,
              style: tt.displaySmall,
              decoration: InputDecoration(
                hintText: 'Plan name',
                hintStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.2)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (v) =>
                  _plan.name = v.trim().isEmpty ? 'My Plan' : v.trim(),
            ),
          ),
          GestureDetector(
            onTap: _addMeal,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: AppTheme.calories.withValues(alpha: 0.12),
                border: Border.all(
                    color: AppTheme.calories.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded,
                      size: 15, color: AppTheme.calories),
                  const SizedBox(width: 4),
                  Text('Add Meal',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.calories)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tag Chips ─────────────────────────────────────────

  Widget _buildTagChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(Spacing.lg, 6, Spacing.lg, 6),
        itemCount: _tagOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: Spacing.sm),
        itemBuilder: (_, i) {
          final (label, color) = _tagOptions[i];
          final selected = _plan.tag == label;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _plan.tag = label;
                _plan.tagColor = color;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: selected
                    ? color.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: selected
                      ? color.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? color
                      : Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────

  Widget _buildEmptyState(TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.calories.withValues(alpha: 0.08),
              ),
              child: Icon(Icons.restaurant_menu_outlined,
                  size: 32,
                  color: AppTheme.calories.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: Spacing.lg),
            Text('No meals added', style: tt.titleMedium),
            const SizedBox(height: Spacing.sm),
            Text(
              'Tap "Add Meal" above to create\nyour first meal section.',
              style: tt.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────

  Widget _buildBottomBar(TextTheme tt) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        Spacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
            top: BorderSide(
                color: Colors.white.withValues(alpha: 0.06), width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Macro totals ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _totalTile('$_totalCal', 'kcal', AppTheme.calories,
                  AppTheme.caloriesGradient),
              _vDivider(),
              _totalTile('${_totalP}g', 'Protein', AppTheme.protein,
                  AppTheme.proteinGradient),
              _vDivider(),
              _totalTile('${_totalC}g', 'Carbs', AppTheme.carbs,
                  AppTheme.carbsGradient),
              _vDivider(),
              _totalTile(
                  '${_totalF}g', 'Fat', AppTheme.fat, AppTheme.fatGradient),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // ── Save button ────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient:
                    const LinearGradient(colors: AppTheme.caloriesGradient),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _savePlan,
                  splashColor: Colors.white.withValues(alpha: 0.08),
                  child: const Center(
                    child: Text(
                      'Save Plan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalTile(
      String value, String label, Color color, List<Color> gradient) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (b) => LinearGradient(colors: gradient)
              .createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
          child: Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5)),
        ),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.35))),
      ],
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 28,
        color: Colors.white.withValues(alpha: 0.07),
      );

  // ── Add Meal ──────────────────────────────────────────

  void _addMeal() {
    HapticFeedback.lightImpact();
    final existing = _plan.meals.map((m) => m.name).toSet();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMealSheet(
        existingNames: existing,
        presets: _mealPresets,
        onSelect: (name, icon) {
          setState(() {
            _plan.meals.add(DietMeal(name: name, icon: icon));
            _expandedMeals.add(_plan.meals.length - 1);
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _deleteMeal(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _plan.meals.removeAt(index);
      _expandedMeals.remove(index);
      // Shift indices of meals after removed one.
      final shifted = <int>{};
      for (final idx in _expandedMeals) {
        shifted.add(idx > index ? idx - 1 : idx);
      }
      _expandedMeals
        ..clear()
        ..addAll(shifted);
    });
  }

  void _showAddFoodSheet(int mealIndex, {int? foodIndex}) {
    final existing =
        foodIndex != null ? _plan.meals[mealIndex].foods[foodIndex] : null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddFoodSheet(
        existing: existing,
        mealName: _plan.meals[mealIndex].name,
        onSave: (item) {
          setState(() {
            if (foodIndex != null) {
              _plan.meals[mealIndex].foods[foodIndex] = item;
            } else {
              _plan.meals[mealIndex].foods.add(item);
            }
          });
        },
      ),
    );
  }

  void _savePlan() {
    HapticFeedback.mediumImpact();
    _plan.name = _nameCtrl.text.trim().isEmpty
        ? 'My Plan'
        : _nameCtrl.text.trim();
    Navigator.pop(context, _plan);
  }
}

// ─── Meal Section Card ────────────────────────────────────

class _MealSectionCard extends StatelessWidget {
  final DietMeal meal;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onAddFood;
  final VoidCallback onDeleteMeal;
  final ValueChanged<int> onEditFood;
  final ValueChanged<int> onDeleteFood;

  const _MealSectionCard({
    required this.meal,
    required this.isExpanded,
    required this.onToggle,
    required this.onAddFood,
    required this.onDeleteMeal,
    required this.onEditFood,
    required this.onDeleteFood,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final hasFood = meal.foods.isNotEmpty;

    return GlassCard(
      accentColor: AppTheme.calories,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Meal header ──────────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                  bottom: Radius.circular(24)),
              splashColor: AppTheme.calories.withValues(alpha: 0.05),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.calories.withValues(alpha: 0.12),
                      ),
                      child: Icon(meal.icon,
                          size: 18,
                          color: AppTheme.calories.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meal.name, style: tt.titleSmall),
                          if (hasFood) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${meal.foods.length} item${meal.foods.length == 1 ? '' : 's'}',
                              style: tt.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (hasFood) ...[
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: AppTheme.caloriesGradient,
                        ).createShader(
                            Rect.fromLTWH(0, 0, b.width, b.height)),
                        child: Text(
                          '${meal.totalCalories}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3),
                        ),
                      ),
                      Text(' kcal',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.3))),
                      const SizedBox(width: Spacing.sm),
                    ],
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: AppTheme.animFast,
                      child: Icon(Icons.expand_more_rounded,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Expanded body ─────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: [
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  color: Colors.white.withValues(alpha: 0.06),
                ),

                // Food items
                if (meal.foods.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.lg, vertical: Spacing.md),
                    child: Text(
                      'No food items yet.',
                      style: tt.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  for (var i = 0; i < meal.foods.length; i++) ...[
                    _FoodItemRow(
                      food: meal.foods[i],
                      onEdit: () => onEditFood(i),
                      onDelete: () => onDeleteFood(i),
                    ),
                    if (i < meal.foods.length - 1)
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(
                            horizontal: Spacing.lg),
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                  ],

                // Macro summary for this meal
                if (hasFood) ...[
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Spacing.lg, Spacing.sm, Spacing.lg, 0),
                    child: Row(
                      children: [
                        _macroChip(
                            'P ${meal.totalProtein}g', AppTheme.protein),
                        const SizedBox(width: Spacing.sm),
                        _macroChip('C ${meal.totalCarbs}g', AppTheme.carbs),
                        const SizedBox(width: Spacing.sm),
                        _macroChip('F ${meal.totalFat}g', AppTheme.fat),
                      ],
                    ),
                  ),
                ],

                // Footer: add food + delete meal
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.lg, Spacing.md, Spacing.lg, Spacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onAddFood,
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppTheme.calories.withValues(alpha: 0.10),
                              border: Border.all(
                                  color:
                                      AppTheme.calories.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded,
                                    size: 16, color: AppTheme.calories),
                                const SizedBox(width: 5),
                                Text('Add Food',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.calories)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      GestureDetector(
                        onTap: onDeleteMeal,
                        child: Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.fat.withValues(alpha: 0.08),
                            border: Border.all(
                                color:
                                    AppTheme.fat.withValues(alpha: 0.15)),
                          ),
                          child: Icon(Icons.delete_outline_rounded,
                              size: 16,
                              color: AppTheme.fat.withValues(alpha: 0.7)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AppTheme.animMedium,
            sizeCurve: AppTheme.animCurve,
          ),
        ],
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

// ─── Food Item Row ────────────────────────────────────────

class _FoodItemRow extends StatelessWidget {
  final DietFoodItem food;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FoodItemRow({
    required this.food,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name,
                    style: tt.titleSmall?.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _miniChip('P ${food.protein}g', AppTheme.protein),
                    const SizedBox(width: 4),
                    _miniChip('C ${food.carbs}g', AppTheme.carbs),
                    const SizedBox(width: 4),
                    _miniChip('F ${food.fat}g', AppTheme.fat),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppTheme.calories.withValues(alpha: 0.10),
            ),
            child: Text(
              '${food.calories} kcal',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.calories),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06)),
              child: Icon(Icons.edit_rounded,
                  size: 13, color: Colors.white.withValues(alpha: 0.45)),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.fat.withValues(alpha: 0.08)),
              child: Icon(Icons.close_rounded,
                  size: 13, color: AppTheme.fat.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withValues(alpha: 0.10),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.7))),
      );
}

// ─── Add Meal Sheet ───────────────────────────────────────

class _AddMealSheet extends StatefulWidget {
  final Set<String> existingNames;
  final List<(String, IconData)> presets;
  final void Function(String, IconData) onSelect;

  const _AddMealSheet({
    required this.existingNames,
    required this.presets,
    required this.onSelect,
  });

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final _customCtrl = TextEditingController();
  bool _showCustomInput = false;

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text('Add Meal', style: tt.titleLarge),
            const SizedBox(height: Spacing.md),

            // Preset grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: Spacing.sm,
              crossAxisSpacing: Spacing.sm,
              childAspectRatio: 3.4,
              physics: const NeverScrollableScrollPhysics(),
              children: widget.presets.map((preset) {
                final (name, icon) = preset;
                final isCustomOption = name == 'Custom';
                final alreadyAdded =
                    !isCustomOption && widget.existingNames.contains(name);
                return GestureDetector(
                  onTap: alreadyAdded
                      ? null
                      : () {
                          if (isCustomOption) {
                            setState(() => _showCustomInput = true);
                          } else {
                            HapticFeedback.lightImpact();
                            widget.onSelect(name, icon);
                          }
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: alreadyAdded
                          ? Colors.white.withValues(alpha: 0.02)
                          : isCustomOption
                              ? AppTheme.calories.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                        color: alreadyAdded
                            ? Colors.white.withValues(alpha: 0.04)
                            : isCustomOption
                                ? AppTheme.calories.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: alreadyAdded
                              ? Colors.white.withValues(alpha: 0.2)
                              : isCustomOption
                                  ? AppTheme.calories
                                  : Colors.white.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: alreadyAdded
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : isCustomOption
                                      ? AppTheme.calories
                                      : Colors.white
                                          .withValues(alpha: 0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (alreadyAdded) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.check_rounded,
                              size: 12,
                              color: AppTheme.accent.withValues(alpha: 0.5)),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Custom name input
            if (_showCustomInput) ...[
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _customCtrl,
                autofocus: true,
                style: const TextStyle(color: AppTheme.ink),
                decoration: const InputDecoration(
                  labelText: 'Meal name',
                  hintText: 'e.g. Pre-Workout, Night Snack',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: Spacing.md),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.calories,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final name = _customCtrl.text.trim();
                    if (name.isEmpty) return;
                    HapticFeedback.lightImpact();
                    widget.onSelect(name, Icons.restaurant_menu_rounded);
                  },
                  child: const Text('Add Meal',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],

            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }
}

// ─── Add / Edit Food Sheet ────────────────────────────────

class _AddFoodSheet extends StatefulWidget {
  final DietFoodItem? existing;
  final String mealName;
  final void Function(DietFoodItem) onSave;

  const _AddFoodSheet({
    this.existing,
    required this.mealName,
    required this.onSave,
  });

  @override
  State<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<_AddFoodSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _calCtrl;
  late final TextEditingController _protCtrl;
  late final TextEditingController _carbCtrl;
  late final TextEditingController _fatCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _calCtrl  = TextEditingController(
        text: e != null && e.calories > 0 ? '${e.calories}' : '');
    _protCtrl = TextEditingController(
        text: e != null && e.protein > 0 ? '${e.protein}' : '');
    _carbCtrl = TextEditingController(
        text: e != null && e.carbs > 0 ? '${e.carbs}' : '');
    _fatCtrl  = TextEditingController(
        text: e != null && e.fat > 0 ? '${e.fat}' : '');
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _calCtrl, _protCtrl, _carbCtrl, _fatCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isEdit = widget.existing != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(999)),
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // Title
              Text(isEdit ? 'Edit Food' : 'Add Food', style: tt.titleLarge),
              const SizedBox(height: 2),
              Text('to ${widget.mealName}',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.calories.withValues(alpha: 0.7))),
              const SizedBox(height: Spacing.lg),

              // Food name field
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppTheme.ink),
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  hintText: 'e.g. Boiled Eggs, Protein Shake',
                ),
                autofocus: !isEdit,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: Spacing.lg),

              // ── Calories (large, Healthify Me style) ──
              Container(
                padding: const EdgeInsets.all(Spacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.calories.withValues(alpha: 0.06),
                  border: Border.all(
                      color: AppTheme.calories.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Text('CALORIES',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: AppTheme.calories.withValues(alpha: 0.7))),
                    const SizedBox(height: Spacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Minus button
                        _stepBtn(
                          Icons.remove_rounded,
                          () {
                            final v = int.tryParse(_calCtrl.text) ?? 0;
                            if (v >= 10) {
                              setState(
                                  () => _calCtrl.text = '${v - 10}');
                            }
                          },
                        ),
                        // Calorie number input
                        Expanded(
                          child: TextField(
                            controller: _calCtrl,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.ink,
                                letterSpacing: -1.5),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.15),
                                  letterSpacing: -1.5),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        // Plus button
                        _stepBtn(
                          Icons.add_rounded,
                          () {
                            final v = int.tryParse(_calCtrl.text) ?? 0;
                            setState(
                                () => _calCtrl.text = '${(v + 10).clamp(0, 9999)}');
                          },
                        ),
                      ],
                    ),
                    Text('kcal',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.calories.withValues(alpha: 0.4))),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.md),

              // ── P / C / F inputs ───────────────────────
              Row(
                children: [
                  Expanded(
                    child: _MacroInput(
                        label: 'Protein',
                        unit: 'g',
                        color: AppTheme.protein,
                        controller: _protCtrl),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: _MacroInput(
                        label: 'Carbs',
                        unit: 'g',
                        color: AppTheme.carbs,
                        controller: _carbCtrl),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: _MacroInput(
                        label: 'Fat',
                        unit: 'g',
                        color: AppTheme.fat,
                        controller: _fatCtrl),
                  ),
                ],
              ),

              const SizedBox(height: Spacing.xl),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _save,
                  child: Text(
                    isEdit ? 'Save Changes' : 'Add to Meal',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.calories.withValues(alpha: 0.10),
          ),
          child: Icon(icon, size: 18, color: AppTheme.calories),
        ),
      );

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    HapticFeedback.mediumImpact();
    widget.onSave(DietFoodItem(
      name: name,
      calories: int.tryParse(_calCtrl.text) ?? 0,
      protein: int.tryParse(_protCtrl.text) ?? 0,
      carbs: int.tryParse(_carbCtrl.text) ?? 0,
      fat: int.tryParse(_fatCtrl.text) ?? 0,
    ));
    Navigator.pop(context);
  }
}

// ─── Macro Number Input ───────────────────────────────────

class _MacroInput extends StatelessWidget {
  final String label;
  final String unit;
  final Color color;
  final TextEditingController controller;

  const _MacroInput({
    required this.label,
    required this.unit,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm, vertical: Spacing.sm + 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: color.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
                letterSpacing: -0.3),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.18),
                  letterSpacing: -0.3),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              suffixText: unit,
              suffixStyle: TextStyle(
                  fontSize: 11, color: color.withValues(alpha: 0.45)),
            ),
          ),
        ],
      ),
    );
  }
}
