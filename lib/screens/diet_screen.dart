import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';

// ─── Data ─────────────────────────────────────────────────

class _Meal {
  final String type;
  final IconData icon;
  final List<String> items;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  const _Meal(this.type, this.icon, this.items, this.calories,
      {this.protein = 0, this.carbs = 0, this.fat = 0});
}

class _Recipe {
  final String name;
  final int calories;
  final String tag;
  final Color tagColor;
  const _Recipe(this.name, this.calories, this.tag, this.tagColor);
}

class _DietChange {
  final String date;
  final String change;
  final String reason;
  const _DietChange(this.date, this.change, this.reason);
}

// ─── Screen ───────────────────────────────────────────────

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _headerFade;
  late final Animation<double> _selectorFade;
  late final Animation<Offset> _selectorSlide;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _mealsFade;
  late final Animation<Offset> _mealsSlide;
  late final Animation<double> _recipesFade;
  late final Animation<Offset> _recipesSlide;
  late final Animation<double> _historyFade;
  late final Animation<Offset> _historySlide;

  int _selectedDay = DateTime.now().weekday - 1;
  bool _historyExpanded = false;
  int? _expandedMeal;

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // ── Meal plans per day (with macros) ───────────────────

  static const _plans = <int, List<_Meal>>{
    0: [
      _Meal('Breakfast', Icons.wb_twilight_rounded,
          ['Egg white omelette', 'Whole wheat toast', 'Green tea'], 350,
          protein: 28, carbs: 35, fat: 10),
      _Meal('Lunch', Icons.wb_sunny_rounded,
          ['Chicken breast & brown rice', 'Dal tadka'], 580,
          protein: 42, carbs: 55, fat: 18),
      _Meal('Dinner', Icons.nightlight_round,
          ['Grilled fish', 'Sautéed veggies', 'Roti'], 520,
          protein: 38, carbs: 40, fat: 20),
      _Meal('Snack', Icons.local_cafe_rounded,
          ['Protein shake', 'Banana'], 280,
          protein: 25, carbs: 30, fat: 6),
    ],
    1: [
      _Meal('Breakfast', Icons.wb_twilight_rounded,
          ['Overnight oats & nuts'], 320,
          protein: 12, carbs: 45, fat: 12),
      _Meal('Lunch', Icons.wb_sunny_rounded,
          ['Paneer tikka wrap', 'Raita'], 490,
          protein: 28, carbs: 50, fat: 16),
      _Meal('Dinner', Icons.nightlight_round,
          ['Moong dal khichdi', 'Papad'], 420,
          protein: 18, carbs: 60, fat: 10),
      _Meal('Snack', Icons.local_cafe_rounded,
          ['Greek yogurt', 'Almonds'], 180,
          protein: 14, carbs: 12, fat: 10),
    ],
    2: [
      _Meal('Breakfast', Icons.wb_twilight_rounded,
          ['Egg white omelette', 'Whole wheat toast', 'Green tea'], 350,
          protein: 28, carbs: 35, fat: 10),
      _Meal('Lunch', Icons.wb_sunny_rounded,
          ['Chicken breast & brown rice', 'Dal tadka'], 580,
          protein: 42, carbs: 55, fat: 18),
      _Meal('Dinner', Icons.nightlight_round,
          ['Grilled fish', 'Sautéed veggies', 'Roti'], 520,
          protein: 38, carbs: 40, fat: 20),
      _Meal('Snack', Icons.local_cafe_rounded,
          ['Protein shake', 'Banana'], 280,
          protein: 25, carbs: 30, fat: 6),
    ],
    3: [
      _Meal('Breakfast', Icons.wb_twilight_rounded,
          ['Overnight oats & nuts'], 320,
          protein: 12, carbs: 45, fat: 12),
      _Meal('Lunch', Icons.wb_sunny_rounded,
          ['Paneer tikka wrap', 'Raita'], 490,
          protein: 28, carbs: 50, fat: 16),
      _Meal('Dinner', Icons.nightlight_round,
          ['Moong dal khichdi', 'Papad'], 420,
          protein: 18, carbs: 60, fat: 10),
      _Meal('Snack', Icons.local_cafe_rounded,
          ['Greek yogurt', 'Almonds'], 180,
          protein: 14, carbs: 12, fat: 10),
    ],
    4: [
      _Meal('Breakfast', Icons.wb_twilight_rounded,
          ['Poha with peanuts', 'Chai'], 300,
          protein: 10, carbs: 42, fat: 10),
      _Meal('Lunch', Icons.wb_sunny_rounded,
          ['Rajma chawal', 'Green salad'], 520,
          protein: 22, carbs: 65, fat: 14),
      _Meal('Dinner', Icons.nightlight_round,
          ['Tandoori chicken', 'Mint chutney', 'Roti'], 560,
          protein: 40, carbs: 38, fat: 22),
      _Meal('Snack', Icons.local_cafe_rounded,
          ['Whey protein', 'Apple'], 250,
          protein: 28, carbs: 25, fat: 4),
    ],
    5: [
      _Meal('Breakfast', Icons.wb_twilight_rounded,
          ['Idli sambar'], 280,
          protein: 8, carbs: 48, fat: 6),
      _Meal('Lunch', Icons.wb_sunny_rounded,
          ['Chole with rice', 'Pickle'], 540,
          protein: 20, carbs: 70, fat: 16),
      _Meal('Dinner', Icons.nightlight_round,
          ['Grilled paneer', 'Quinoa salad'], 480,
          protein: 32, carbs: 40, fat: 18),
      _Meal('Snack', Icons.local_cafe_rounded,
          ['Mixed nuts', 'Seasonal fruit'], 220,
          protein: 8, carbs: 22, fat: 12),
    ],
    6: [
      _Meal('Breakfast', Icons.wb_twilight_rounded,
          ['Dosa', 'Coconut chutney'], 350,
          protein: 8, carbs: 50, fat: 14),
      _Meal('Lunch', Icons.wb_sunny_rounded,
          ['Chicken biryani', 'Raita'], 620,
          protein: 35, carbs: 65, fat: 22),
      _Meal('Dinner', Icons.nightlight_round,
          ['Tomato soup', 'Multigrain bread'], 320,
          protein: 12, carbs: 40, fat: 10),
      _Meal('Snack', Icons.local_cafe_rounded,
          ['Protein bar', 'Green tea'], 200,
          protein: 20, carbs: 18, fat: 8),
    ],
  };

  static const _recipes = [
    _Recipe('Chicken Tikka', 380, 'High Protein', AppTheme.protein),
    _Recipe('Overnight Oats', 290, 'High Fiber', AppTheme.accent),
    _Recipe('Protein Smoothie', 220, 'Post Workout', AppTheme.weight),
    _Recipe('Paneer Bhurji', 340, 'Vegetarian', AppTheme.accent),
    _Recipe('Quinoa Bowl', 310, 'Balanced', AppTheme.carbs),
  ];

  static const _dietHistory = [
    _DietChange('Mar 25, 2026', 'Added Quinoa Bowl to Friday lunch',
        'Better post-workout recovery meal with balanced macros'),
    _DietChange('Mar 18, 2026', 'Reduced carbs: 250g → 200g target',
        'Plateau at current weight — adjusting macros for deficit'),
    _DietChange('Mar 10, 2026', 'Swapped white rice for brown rice',
        'More fiber, slower digestion — keeps fullness longer'),
    _DietChange('Mar 3, 2026', 'Added Fish Oil & Vitamin D3',
        'Blood work showed low Vitamin D, doctor recommended'),
    _DietChange('Feb 25, 2026', 'Initial diet plan',
        'Starting 1,700 kcal deficit plan with high protein'),
  ];

  // ── Animation helpers ──────────────────────────────────

  Animation<double> _fade(double s, double e) =>
      CurvedAnimation(parent: _anim, curve: Interval(s, e, curve: Curves.easeOut));

  Animation<Offset> _slide(double s, double e) =>
      Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
          .animate(CurvedAnimation(parent: _anim, curve: Interval(s, e, curve: Curves.easeOutCubic)));

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

    _headerFade    = _fade(0.00, 0.25);
    _selectorFade  = _fade(0.05, 0.30);
    _selectorSlide = _slide(0.05, 0.35);
    _heroFade      = _fade(0.10, 0.38);
    _heroSlide     = _slide(0.10, 0.43);
    _mealsFade     = _fade(0.18, 0.48);
    _mealsSlide    = _slide(0.18, 0.53);
    _recipesFade   = _fade(0.30, 0.60);
    _recipesSlide  = _slide(0.30, 0.65);
    _historyFade   = _fade(0.40, 0.70);
    _historySlide  = _slide(0.40, 0.75);

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // ── Computed macros for selected day ───────────────────

  List<_Meal> get _meals => _plans[_selectedDay] ?? [];
  int get _dayTotal => _meals.fold(0, (s, m) => s + m.calories);
  int get _dayProtein => _meals.fold(0, (s, m) => s + m.protein);
  int get _dayCarbs => _meals.fold(0, (s, m) => s + m.carbs);
  int get _dayFat => _meals.fold(0, (s, m) => s + m.fat);

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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

              FadeTransition(
                opacity: _headerFade,
                child: Text('Diet', style: tt.displayLarge),
              ),

              const SizedBox(height: Spacing.lg),

              FadeTransition(
                opacity: _selectorFade,
                child: SlideTransition(
                  position: _selectorSlide,
                  child: _buildDaySelector(),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // Hero summary card
              FadeTransition(
                opacity: _heroFade,
                child: SlideTransition(
                  position: _heroSlide,
                  child: _buildHeroSummary(tt),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // Consolidated meal plan
              FadeTransition(
                opacity: _mealsFade,
                child: SlideTransition(
                  position: _mealsSlide,
                  child: _buildMealPlan(tt),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              FadeTransition(
                opacity: _recipesFade,
                child: SlideTransition(
                  position: _recipesSlide,
                  child: _buildRecipes(tt),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              FadeTransition(
                opacity: _historyFade,
                child: SlideTransition(
                  position: _historySlide,
                  child: _buildHistory(tt),
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  // ── Day Selector (orange accent) ───────────────────────

  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = i == _selectedDay;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedDay = i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? AppTheme.calories
                  : Colors.white.withValues(alpha: 0.06),
              boxShadow: active
                  ? [BoxShadow(color: AppTheme.calories.withValues(alpha: 0.35), blurRadius: 12)]
                  : null,
            ),
            child: Center(
              child: Text(
                _dayLetters[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Hero Summary Card ──────────────────────────────────

  Widget _buildHeroSummary(TextTheme tt) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GlassCard(
        key: ValueKey('hero_$_selectedDay'),
        accentColor: AppTheme.calories,
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          children: [
            // Large calorie number
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: AppTheme.caloriesGradient,
              ).createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
              child: Text(
                '$_dayTotal',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('kcal planned', style: tt.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: Spacing.lg),
            // Macro split row
            Row(
              children: [
                _miniMacro('P', _dayProtein, 150, AppTheme.protein, AppTheme.proteinGradient),
                const SizedBox(width: Spacing.md),
                _miniMacro('C', _dayCarbs, 200, AppTheme.carbs, AppTheme.carbsGradient),
                const SizedBox(width: Spacing.md),
                _miniMacro('F', _dayFat, 65, AppTheme.fat, AppTheme.fatGradient),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniMacro(String label, int grams, int goal, Color color, List<Color> gradient) {
    final progress = (grams / goal).clamp(0.0, 1.0);
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (b) => LinearGradient(colors: gradient)
                    .createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
                child: Text('${grams}g',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3)),
              ),
              Text(' / ${goal}g',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.3))),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: color.withValues(alpha: 0.1),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(colors: gradient),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  // ── Consolidated Meal Plan ─────────────────────────────

  Widget _buildMealPlan(TextTheme tt) {
    final meals = _meals;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey('meals_$_selectedDay'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MEAL PLAN', style: tt.labelMedium),
          const SizedBox(height: Spacing.md),
          GlassCard(
            accentColor: AppTheme.calories,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.lg, Spacing.md, Spacing.lg, Spacing.sm),
                  child: Row(
                    children: [
                      Text('${meals.length} meals', style: tt.bodySmall),
                      const Spacer(),
                      Text('Tap to edit',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.calories.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
                for (var i = 0; i < meals.length; i++) ...[
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  _MealRow(
                    meal: meals[i],
                    isExpanded: _expandedMeal == i,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _expandedMeal = _expandedMeal == i ? null : i;
                      });
                    },
                  ),
                ],
                const SizedBox(height: Spacing.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Recipes ────────────────────────────────────────────

  Widget _buildRecipes(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RECIPES', style: tt.labelMedium),
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppTheme.calories.withValues(alpha: 0.12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: AppTheme.calories),
                    const SizedBox(width: 4),
                    Text('Add',
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
        const SizedBox(height: Spacing.md),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _recipes.length,
            separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
            itemBuilder: (_, i) => _RecipeCard(recipe: _recipes[i]),
          ),
        ),
      ],
    );
  }

  // ── Change History (collapsible) ───────────────────────

  Widget _buildHistory(TextTheme tt) {
    final visibleCount = _historyExpanded ? _dietHistory.length : 2;
    return GlassCard(
      accentColor: AppTheme.calories,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.lg, Spacing.lg, Spacing.lg, Spacing.md),
            child: Text('CHANGE HISTORY', style: tt.labelMedium),
          ),
          for (var i = 0; i < visibleCount; i++)
            _DietTimelineEntry(
              entry: _dietHistory[i],
              isLast: i == visibleCount - 1 && !_historyExpanded,
            ),
          if (!_historyExpanded && _dietHistory.length > 2)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _historyExpanded = true);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.lg, Spacing.sm, Spacing.lg, Spacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Show all',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.calories.withValues(alpha: 0.7))),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppTheme.calories.withValues(alpha: 0.7)),
                  ],
                ),
              ),
            )
          else
            const SizedBox(height: Spacing.md),
        ],
      ),
    );
  }
}

// ─── Meal Row (consolidated) ─────────────────────────────

class _MealRow extends StatelessWidget {
  final _Meal meal;
  final bool isExpanded;
  final VoidCallback onTap;

  const _MealRow({
    required this.meal,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final preview = meal.items.length <= 2
        ? meal.items.join(', ')
        : '${meal.items.take(2).join(', ')} +${meal.items.length - 2}';

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            splashColor: AppTheme.calories.withValues(alpha: 0.05),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isExpanded
                          ? AppTheme.calories.withValues(alpha: 0.15)
                          : AppTheme.calories.withValues(alpha: 0.10),
                    ),
                    child: Icon(meal.icon, size: 16,
                        color: AppTheme.calories.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meal.type, style: tt.titleSmall),
                        if (!isExpanded) ...[
                          const SizedBox(height: 2),
                          Text(preview,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.4)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: AppTheme.caloriesGradient,
                    ).createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
                    child: Text('${meal.calories}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3)),
                  ),
                  Text(' kcal',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.3))),
                  const SizedBox(width: Spacing.sm),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: AppTheme.animFast,
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                ],
              ),
            ),
          ),
          // Expanded: show all food items with edit hint
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.lg + 32 + Spacing.md, 0, Spacing.lg, Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in meal.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 4, height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.calories.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Text(item,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.6))),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: Spacing.sm),
                  // Macro breakdown for this meal
                  Row(
                    children: [
                      _macroChip('P', '${meal.protein}g', AppTheme.protein),
                      const SizedBox(width: Spacing.sm),
                      _macroChip('C', '${meal.carbs}g', AppTheme.carbs),
                      const SizedBox(width: Spacing.sm),
                      _macroChip('F', '${meal.fat}g', AppTheme.fat),
                    ],
                  ),
                ],
              ),
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

  Widget _macroChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.10),
      ),
      child: Text('$label $value',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8))),
    );
  }
}

// ─── Recipe Card (with gradient tint + tap) ──────────────

class _RecipeCard extends StatelessWidget {
  final _Recipe recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: GlassCard(
        accentColor: recipe.tagColor,
        padding: const EdgeInsets.all(Spacing.md),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(recipe.tag,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: recipe.tagColor.withValues(alpha: 0.8))),
                ],
              ),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: AppTheme.caloriesGradient,
                ).createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
                child: Text('${recipe.calories} kcal',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Diet Timeline Entry ─────────────────────────────────

class _DietTimelineEntry extends StatelessWidget {
  final _DietChange entry;
  final bool isLast;

  const _DietTimelineEntry({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.calories,
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.calories.withValues(alpha: 0.3),
                            blurRadius: 6),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1,
                        margin: const EdgeInsets.only(top: 4),
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.date,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.4),
                            letterSpacing: 0.5)),
                    const SizedBox(height: Spacing.xs),
                    Text(entry.change, style: tt.titleSmall),
                    const SizedBox(height: Spacing.xs),
                    Text(entry.reason, style: tt.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
