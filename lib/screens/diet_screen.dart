import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

// ─── Data ─────────────────────────────────────────────────

class _Meal {
  final String type;
  final List<String> items;
  final int calories;
  const _Meal(this.type, this.items, this.calories);
}

class _Recipe {
  final String name;
  final int calories;
  final String tag;
  const _Recipe(this.name, this.calories, this.tag);
}

class _Supplement {
  final String name;
  final String dosage;
  final IconData icon;
  const _Supplement(this.name, this.dosage, this.icon);
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
  late final Animation<double> _mealsFade;
  late final Animation<Offset> _mealsSlide;
  late final Animation<double> _macrosFade;
  late final Animation<Offset> _macrosSlide;
  late final Animation<double> _recipesFade;
  late final Animation<Offset> _recipesSlide;
  late final Animation<double> _suppFade;
  late final Animation<Offset> _suppSlide;
  late final Animation<double> _historyFade;
  late final Animation<Offset> _historySlide;

  int _selectedDay = DateTime.now().weekday - 1;
  final Set<int> _takenSupps = {};

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // ── Meal plans per day ─────────────────────────────────

  static const _plans = <int, List<_Meal>>{
    0: [
      _Meal('Breakfast', ['Egg white omelette', 'Whole wheat toast', 'Green tea'], 350),
      _Meal('Lunch', ['Chicken breast & brown rice', 'Dal tadka'], 580),
      _Meal('Dinner', ['Grilled fish', 'Sautéed veggies', 'Roti'], 520),
      _Meal('Snack', ['Protein shake', 'Banana'], 280),
    ],
    1: [
      _Meal('Breakfast', ['Overnight oats & nuts'], 320),
      _Meal('Lunch', ['Paneer tikka wrap', 'Raita'], 490),
      _Meal('Dinner', ['Moong dal khichdi', 'Papad'], 420),
      _Meal('Snack', ['Greek yogurt', 'Almonds'], 180),
    ],
    2: [
      _Meal('Breakfast', ['Egg white omelette', 'Whole wheat toast', 'Green tea'], 350),
      _Meal('Lunch', ['Chicken breast & brown rice', 'Dal tadka'], 580),
      _Meal('Dinner', ['Grilled fish', 'Sautéed veggies', 'Roti'], 520),
      _Meal('Snack', ['Protein shake', 'Banana'], 280),
    ],
    3: [
      _Meal('Breakfast', ['Overnight oats & nuts'], 320),
      _Meal('Lunch', ['Paneer tikka wrap', 'Raita'], 490),
      _Meal('Dinner', ['Moong dal khichdi', 'Papad'], 420),
      _Meal('Snack', ['Greek yogurt', 'Almonds'], 180),
    ],
    4: [
      _Meal('Breakfast', ['Poha with peanuts', 'Chai'], 300),
      _Meal('Lunch', ['Rajma chawal', 'Green salad'], 520),
      _Meal('Dinner', ['Tandoori chicken', 'Mint chutney', 'Roti'], 560),
      _Meal('Snack', ['Whey protein', 'Apple'], 250),
    ],
    5: [
      _Meal('Breakfast', ['Idli sambar'], 280),
      _Meal('Lunch', ['Chole with rice', 'Pickle'], 540),
      _Meal('Dinner', ['Grilled paneer', 'Quinoa salad'], 480),
      _Meal('Snack', ['Mixed nuts', 'Seasonal fruit'], 220),
    ],
    6: [
      _Meal('Breakfast', ['Dosa', 'Coconut chutney'], 350),
      _Meal('Lunch', ['Chicken biryani', 'Raita'], 620),
      _Meal('Dinner', ['Tomato soup', 'Multigrain bread'], 320),
      _Meal('Snack', ['Protein bar', 'Green tea'], 200),
    ],
  };

  static const _recipes = [
    _Recipe('Chicken Tikka', 380, 'High Protein'),
    _Recipe('Overnight Oats', 290, 'High Fiber'),
    _Recipe('Protein Smoothie', 220, 'Post Workout'),
    _Recipe('Paneer Bhurji', 340, 'Vegetarian'),
    _Recipe('Quinoa Bowl', 310, 'Balanced'),
  ];

  static const _supplements = [
    _Supplement('Whey Protein', '30g', Icons.fitness_center_rounded),
    _Supplement('Creatine', '5g', Icons.bolt_rounded),
    _Supplement('Multivitamin', '1 tab', Icons.medication_rounded),
    _Supplement('Fish Oil', '1000mg', Icons.water_drop_rounded),
    _Supplement('Vitamin D3', '2000 IU', Icons.wb_sunny_rounded),
  ];

  static const _dietHistory = [
    _DietChange(
      'Mar 25, 2026',
      'Added Quinoa Bowl to Friday lunch',
      'Better post-workout recovery meal with balanced macros',
    ),
    _DietChange(
      'Mar 18, 2026',
      'Reduced carbs: 250g → 200g target',
      'Plateau at current weight — adjusting macros for deficit',
    ),
    _DietChange(
      'Mar 10, 2026',
      'Swapped white rice for brown rice',
      'More fiber, slower digestion — keeps fullness longer',
    ),
    _DietChange(
      'Mar 3, 2026',
      'Added Fish Oil & Vitamin D3',
      'Blood work showed low Vitamin D, doctor recommended',
    ),
    _DietChange(
      'Feb 25, 2026',
      'Initial diet plan',
      'Starting 1,700 kcal deficit plan with high protein',
    ),
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

    _headerFade    = _fade(0.0, 0.25);
    _selectorFade  = _fade(0.05, 0.30);
    _selectorSlide = _slide(0.05, 0.35);
    _mealsFade     = _fade(0.12, 0.40);
    _mealsSlide    = _slide(0.12, 0.50);
    _macrosFade    = _fade(0.25, 0.55);
    _macrosSlide   = _slide(0.25, 0.60);
    _recipesFade   = _fade(0.35, 0.65);
    _recipesSlide  = _slide(0.35, 0.70);
    _suppFade      = _fade(0.45, 0.75);
    _suppSlide     = _slide(0.45, 0.80);
    _historyFade   = _fade(0.55, 0.85);
    _historySlide  = _slide(0.55, 0.90);

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final meals = _plans[_selectedDay] ?? [];
    final dayTotal = meals.fold(0, (s, m) => s + m.calories);

    return Stack(
      children: [
        Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),

        // Ambient glow orbs
        Positioned(
          top: -60, left: -80,
          child: _glowOrb(280, AppTheme.protein, 0.06),
        ),
        Positioned(
          bottom: 150, right: -80,
          child: _glowOrb(300, AppTheme.accent, 0.05),
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

                // Header
                FadeTransition(
                  opacity: _headerFade,
                  child: Text('Diet', style: tt.displayLarge),
                ),

                const SizedBox(height: Spacing.lg),

                // Weekday selector
                FadeTransition(
                  opacity: _selectorFade,
                  child: SlideTransition(
                    position: _selectorSlide,
                    child: _buildDaySelector(),
                  ),
                ),

                const SizedBox(height: Spacing.lg),

                // Meal plan
                FadeTransition(
                  opacity: _mealsFade,
                  child: SlideTransition(
                    position: _mealsSlide,
                    child: _buildMealSection(meals, dayTotal, tt),
                  ),
                ),

                const SizedBox(height: Spacing.lg),

                // Macros
                FadeTransition(
                  opacity: _macrosFade,
                  child: SlideTransition(
                    position: _macrosSlide,
                    child: _buildMacros(tt),
                  ),
                ),

                const SizedBox(height: Spacing.lg),

                // Recipes
                FadeTransition(
                  opacity: _recipesFade,
                  child: SlideTransition(
                    position: _recipesSlide,
                    child: _buildRecipes(tt),
                  ),
                ),

                const SizedBox(height: Spacing.lg),

                // Supplements
                FadeTransition(
                  opacity: _suppFade,
                  child: SlideTransition(
                    position: _suppSlide,
                    child: _buildSupplements(tt),
                  ),
                ),

                const SizedBox(height: Spacing.lg),

                // Change history
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
      ],
    );
  }

  Widget _glowOrb(double size, Color color, double alpha) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: alpha), Colors.transparent],
          ),
        ),
      );

  // ── Weekday pills ──────────────────────────────────────

  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = i == _selectedDay;
        return GestureDetector(
          onTap: () => setState(() => _selectedDay = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? AppTheme.accent
                  : Colors.white.withValues(alpha: 0.06),
              boxShadow: active
                  ? [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.35), blurRadius: 12)]
                  : null,
            ),
            child: Center(
              child: Text(
                _dayLetters[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? AppTheme.canvas
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Meal plan ──────────────────────────────────────────

  Widget _buildMealSection(List<_Meal> meals, int total, TextTheme tt) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey(_selectedDay),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MEAL PLAN', style: tt.labelMedium),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: AppTheme.caloriesGradient,
                ).createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
                child: Text(
                  '$total kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          for (var i = 0; i < meals.length; i++) ...[
            if (i > 0) const SizedBox(height: Spacing.sm),
            _MealCard(meal: meals[i]),
          ],
        ],
      ),
    );
  }

  // ── Macros ─────────────────────────────────────────────

  Widget _buildMacros(TextTheme tt) {
    return GlassCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TODAY'S MACROS", style: tt.labelMedium),
          const SizedBox(height: Spacing.lg),
          _macroRow('Protein', 85, 150, AppTheme.protein),
          const SizedBox(height: Spacing.md),
          _macroRow('Carbs', 120, 200, AppTheme.carbs),
          const SizedBox(height: Spacing.md),
          _macroRow('Fat', 35, 60, AppTheme.fat),
        ],
      ),
    );
  }

  Widget _macroRow(String label, int consumed, int target, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: (consumed / target).clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: v,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.7), color],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            '$consumed/${target}g',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
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
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppTheme.accent.withValues(alpha: 0.12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: AppTheme.accent),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
                      ),
                    ),
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

  // ── Change History ──────────────────────────────────────

  Widget _buildHistory(TextTheme tt) {
    return GlassCard(
      accentColor: AppTheme.calories,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg, Spacing.lg, Spacing.lg, Spacing.md,
            ),
            child: Text('CHANGE HISTORY', style: tt.labelMedium),
          ),
          for (var i = 0; i < _dietHistory.length; i++)
            _DietTimelineEntry(
              entry: _dietHistory[i],
              isLast: i == _dietHistory.length - 1,
            ),
          const SizedBox(height: Spacing.md),
        ],
      ),
    );
  }

  // ── Supplements ────────────────────────────────────────

  Widget _buildSupplements(TextTheme tt) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg, Spacing.lg, Spacing.lg, Spacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SUPPLEMENTS', style: tt.labelMedium),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.12),
                    borderRadius: AppTheme.borderRadiusPill,
                  ),
                  child: Text(
                    '${_takenSupps.length}/${_supplements.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < _supplements.length; i++) ...[
            Container(
              height: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              color: Colors.white.withValues(alpha: 0.06),
            ),
            _SupplementRow(
              supplement: _supplements[i],
              taken: _takenSupps.contains(i),
              onTap: () => setState(() {
                _takenSupps.contains(i)
                    ? _takenSupps.remove(i)
                    : _takenSupps.add(i);
              }),
            ),
          ],
          const SizedBox(height: Spacing.sm),
        ],
      ),
    );
  }
}

// ─── Meal Card ────────────────────────────────────────────

class _MealCard extends StatelessWidget {
  final _Meal meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meal.type.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 1.2,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: AppTheme.caloriesGradient,
                    ).createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
                    child: Text(
                      '${meal.calories}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    ' kcal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          for (final item in meal.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4, height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recipe Card ──────────────────────────────────────────

class _RecipeCard extends StatelessWidget {
  final _Recipe recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.accent.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: AppTheme.caloriesGradient,
              ).createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
              child: Text(
                '${recipe.calories} kcal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Supplement Row ───────────────────────────────────────

class _SupplementRow extends StatelessWidget {
  final _Supplement supplement;
  final bool taken;
  final VoidCallback onTap;

  const _SupplementRow({
    required this.supplement,
    required this.taken,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.accent.withValues(alpha: 0.05),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              // Animated checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: taken ? AppTheme.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: taken
                        ? AppTheme.accent
                        : Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: taken
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
                    : null,
              ),
              const SizedBox(width: Spacing.md),
              Icon(
                supplement.icon,
                size: 18,
                color: Colors.white.withValues(alpha: taken ? 0.7 : 0.4),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  supplement.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: taken ? 0.8 : 0.6),
                  ),
                ),
              ),
              Text(
                supplement.dosage,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: taken ? 0.3 : 0.5),
                ),
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
            // Timeline — dot + line
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
                          blurRadius: 6,
                        ),
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
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.date,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 0.5,
                      ),
                    ),
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
