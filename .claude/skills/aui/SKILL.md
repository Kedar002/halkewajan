---
name: flutter-ui
description: Build and style Flutter UI for the fitness app with an Apple Health-inspired liquid glass aesthetic — soft gradients, translucent cards, generous whitespace, rounded surfaces, and obsessive typographic hierarchy. Use this skill whenever the user asks to create pages, screens, widgets, layouts, navigation, forms, charts, dashboards, or any visual component for the fitness Flutter project. Also trigger when the user mentions UI, design, styling, theme, responsive layout, glass effect, or wants to add/modify any screen in the fitness app.
---

# Flutter Fitness App UI Builder

**Design philosophy: "Design is how it works, not how it looks." Every screen answers ONE question only.**

You are building UI for a Flutter fitness application. The app should feel like **Apple Health + Notion + Calm** — minimal, calm, premium. No clutter, no loud colors. A health dashboard, not social media. Remove anything that doesn't improve user health tracking.

## The Design System

### Color Palette — Calm, Purposeful, Health-First

The app uses a restrained palette: a soft neutral base with ONE health-green accent, plus semantic colors reserved strictly for data categories.

| Role | Color | Hex | Usage |
|---|---|---|---|
| **Ink** | Near-black | `#1D1D1F` | Primary text, icons, active states |
| **Canvas** | Off-white | `#F8F8FA` | Primary background |
| **Surface** | White | `#FFFFFF` | Card surfaces, elevated content |
| **Accent** | Health Green | `#34C759` | Primary action, positive progress, main CTA |

Semantic data colors — used ONLY inside charts, macro breakdowns, and data badges:

| Data Type | Color | Hex | Usage |
|---|---|---|---|
| **Calories** | Warm Orange | `#FF9500` | Calorie rings, calorie data only |
| **Protein** | Soft Purple | `#AF52DE` | Protein macro data only |
| **Weight / Water** | Calm Blue | `#007AFF` | Weight graphs, hydration data only |
| **Fat** | Soft Pink | `#FF2D55` | Fat macro data only |
| **Carbs** | Teal | `#5AC8FA` | Carb macro data only |

Plus grays derived from Ink:

| Role | Color | Usage |
|---|---|---|
| **Secondary** | `Ink` at 50% opacity | Secondary text, labels, inactive icons |
| **Divider** | `Ink` at 10% opacity | Borders, dividers, subtle separators |
| **Whisper** | `Ink` at 5% opacity | Hover states, subtle backgrounds |

**Rules:**
- Semantic data colors appear ONLY in charts, rings, and macro badges. Never on buttons, backgrounds, or navigation.
- Accent green is for ONE primary action per screen — the main CTA. Not decorative.
- No neon colors. No saturated backgrounds on containers.
- Borders are `Ink` at 10% opacity, always. Never darker, never colored.
- No heavy shadows. Use `elevation: 0` with border, or `elevation: 0.5` maximum.

### Liquid Glass Effect — The Signature

The app's defining visual treatment: translucent, frosted-glass cards that feel like they float above a soft gradient background.

```dart
// widgets/glass_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double blur;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.blur = 20.0,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

**When to use GlassCard vs solid Card:**
- GlassCard: Home dashboard summary cards, floating action panels, overlay content
- Solid Card: Lists (meal cards, exercise cards), forms, tables — anywhere legibility is critical

### Theme Setup

```dart
// theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // The palette
  static const Color ink = Color(0xFF1D1D1F);
  static const Color canvas = Color(0xFFF8F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF34C759);
  static const Color secondary = Color(0x801D1D1F);    // 50%
  static const Color divider = Color(0x1A1D1D1F);      // 10%
  static const Color whisper = Color(0x0D1D1D1F);      // 5%

  // Semantic data colors — charts and data badges ONLY
  static const Color calories = Color(0xFFFF9500);
  static const Color protein = Color(0xFFAF52DE);
  static const Color weight = Color(0xFF007AFF);
  static const Color fat = Color(0xFFFF2D55);
  static const Color carbs = Color(0xFF5AC8FA);

  // The radii — cards round to 20, controls round to 12
  static const double radiusCard = 20.0;
  static const double radiusControl = 12.0;
  static const BorderRadius borderRadiusCard = BorderRadius.all(Radius.circular(20));
  static const BorderRadius borderRadiusControl = BorderRadius.all(Radius.circular(12));
  static const BorderRadius borderRadiusPill = BorderRadius.all(Radius.circular(999));

  // Gradient background — the canvas behind glass cards
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF5F5F7),   // off-white
      Color(0xFFEEEEF0),   // light grey
    ],
  );

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: canvas,
    colorScheme: const ColorScheme.light(
      primary: accent,
      onPrimary: surface,
      secondary: secondary,
      surface: surface,
      onSurface: ink,
      error: fat,
      onError: surface,
    ),
    fontFamily: 'Inter', // Clean sans-serif, SF Pro fallback on Apple devices
    textTheme: const TextTheme(
      // Large titles — lightweight, airy, let the numbers breathe
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: ink, letterSpacing: -0.5, height: 1.2),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: ink, letterSpacing: -0.3, height: 1.2),
      displaySmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: ink, letterSpacing: -0.2, height: 1.25),
      // Section headers — medium weight, never bold
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: ink, height: 1.3),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: ink, height: 1.3),
      titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: ink, height: 1.3),
      // Body — regular weight, generous line height
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: ink, height: 1.5),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: ink, height: 1.5),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: secondary, height: 1.4),
      // Labels — slightly tracked out, secondary color
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: secondary, letterSpacing: 0.5),
      labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: secondary, letterSpacing: 0.6),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadiusCard,
        side: BorderSide(color: divider, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: borderRadiusControl,
        borderSide: BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadiusControl,
        borderSide: BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadiusControl,
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: surface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: borderRadiusPill),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        side: BorderSide(color: divider),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: borderRadiusPill),
      ),
    ),
    dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),
    iconTheme: const IconThemeData(color: ink, size: 22),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: ink),
    ),
  );
}
```

### Typography — The Silent Architecture

Type does the heavy lifting. Follow these rules absolutely:

1. **Weight creates hierarchy, not size.** A 17px semibold title above 15px regular body is enough. Don't jump to 28px unless it's a page title.
2. **Negative letter-spacing on large text.** Anything above 22px gets `-0.2` to `-0.5` tracking. Tighter feels more intentional.
3. **Generous line height on body text.** `1.5` minimum. Cramped text feels cheap.
4. **Secondary text uses the `secondary` color**, never a separate gray. One gray, derived from one black.
5. **Data numbers are slightly larger than their labels.** Calories "1,800" at 22px bold, "kcal consumed" at 13px secondary below it.
6. **ALL-CAPS only for tiny section labels** (11-13px), tracked out at `letterSpacing: 0.6`. Sparingly. One per card max.

### Spacing — Whitespace Is a Feature

Spacing is not empty — it's structure. Use a **base unit of 8px**:

| Token | Value | Usage |
|---|---|---|
| `xs` | 4px | Inline gaps (icon to label, unit after number) |
| `sm` | 8px | Tight grouping (related items within a card) |
| `md` | 16px | Standard padding inside cards |
| `lg` | 24px | Between card sections, card internal padding |
| `xl` | 32px | Between major content blocks |
| `xxl` | 48px | Page margins, section spacing |

```dart
class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
```

**The rule:** When in doubt, add more space. A component that feels "too far apart" in development will feel "just right" to users. Crowded layouts feel anxious. Breathing layouts feel confident. "If it feels tight → increase spacing."

### Rounded Borders — Soft, Always

Every surface follows these radius rules:

- Cards / containers: **20px** — the signature rounded feel
- Buttons: **pill (999px)** — primary and secondary both pill-shaped
- Inputs / controls: **12px**
- Chips / tags / badges: **pill (999px)**
- Modals / dialogs / bottom sheets: **24px** top corners
- Charts containers: **20px** (same as cards)

No sharp corners anywhere. Sharp corners signal "unfinished."

## Project Structure

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart              # Palette, type scale, spacing — single source of truth
├── router/
│   └── app_router.dart
├── screens/
│   ├── home_screen.dart            # Today dashboard
│   ├── diet_screen.dart            # Meal logging & macros
│   ├── workout_screen.dart         # Workout tracking
│   ├── progress_screen.dart        # Weight graphs, measurements
│   └── profile_screen.dart         # Goals, settings, preferences
├── widgets/
│   ├── glass_card.dart             # Frosted glass container
│   ├── stat_ring.dart              # Circular progress for calories/macros
│   ├── meal_card.dart              # Breakfast/lunch/dinner card
│   ├── exercise_card.dart          # Single exercise row
│   ├── progress_chart.dart         # Weight/trend line chart
│   ├── macro_bar.dart              # Horizontal macro breakdown bar
│   ├── quick_action_button.dart    # Floating quick actions
│   ├── insight_banner.dart         # Smart insight messages
│   └── bottom_nav.dart             # Bottom navigation bar
└── models/
    ├── meal.dart
    ├── exercise.dart
    ├── daily_log.dart
    └── body_stats.dart
```

## Component Patterns

### Navigation — Bottom Tab Bar

Clean bottom navigation with 5 tabs max. No labels until active. Accent-colored active icon.

```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: AppTheme.surface,
  selectedItemColor: AppTheme.accent,
  unselectedItemColor: AppTheme.secondary,
  selectedFontSize: 11,
  unselectedFontSize: 11,
  showUnselectedLabels: false,
  elevation: 0,
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.restaurant_rounded), label: 'Diet'),
    BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: 'Workout'),
    BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded), label: 'Progress'),
    BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
  ],
)
```

A thin 1px divider line (at `Ink` 10% opacity) separates the nav from content. No shadows on the nav bar.

### Cards — Containers With Purpose

Every solid card: white background, 1px border at 10% ink, 20px radius, 0 elevation. Floating feel.

```dart
Container(
  padding: const EdgeInsets.all(Spacing.lg),
  decoration: BoxDecoration(
    color: AppTheme.surface,
    borderRadius: AppTheme.borderRadiusCard,
    border: Border.all(color: AppTheme.divider),
  ),
  child: child,
)
```

### Stat Rings — Circular Progress for Calories & Macros

The home dashboard uses circular progress indicators for today's calories and macro targets. The ring color matches the semantic data color.

```dart
class StatRing extends StatelessWidget {
  final String label;
  final double progress;      // 0.0 to 1.0
  final Color color;          // e.g., AppTheme.calories
  final String value;         // e.g., "1,200"
  final String unit;          // e.g., "kcal"
  final double size;

  const StatRing({
    super.key,
    required this.label,
    required this.progress,
    required this.color,
    required this.value,
    this.unit = '',
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              color: color.withOpacity(0.15),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 8,
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                )),
              if (unit.isNotEmpty)
                Text(unit,
                  style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Meal Cards — Breakfast, Lunch, Dinner

Each meal gets its own card with time, items logged, and calorie total. Tap to expand details.

```dart
class MealCard extends StatelessWidget {
  final String mealType;        // "Breakfast", "Lunch", "Dinner", "Snack"
  final String time;            // "8:30 AM"
  final int totalCalories;
  final List<String> items;     // ["Oatmeal", "Banana", "Black Coffee"]
  final VoidCallback onTap;
  final VoidCallback onAdd;

  // ...

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.borderRadiusCard,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mealType,
                    style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: Spacing.xs),
                  Text(time,
                    style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              Text('$totalCalories kcal',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppTheme.calories,
                )),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Text(item, style: Theme.of(context).textTheme.bodyMedium),
            )),
          ],
          const SizedBox(height: Spacing.md),
          // Add food button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Food'),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Insight Banners — Show Insight, Not Raw Data

This is critical to the Apple-level experience. **Show what the data means, not just the data.**

❌ "Calories: 1800"
✅ "You are 200 kcal below your goal"

❌ "Protein: 45g"
✅ "You need 75g more protein today"

```dart
class InsightBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? accentColor;

  const InsightBanner({
    super.key,
    required this.message,
    this.icon = Icons.lightbulb_outline_rounded,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.accent;
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: AppTheme.borderRadiusCard,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(message,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppTheme.ink,
              )),
          ),
        ],
      ),
    );
  }
}
```

### Macro Breakdown Bar — Horizontal Stacked Bar

A horizontal bar showing protein/carbs/fat proportions. Clean, no labels inside the bar.

```dart
class MacroBar extends StatelessWidget {
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;
  final double height;

  const MacroBar({
    super.key,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppTheme.borderRadiusPill,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(flex: (proteinPercent * 100).round(),
              child: Container(color: AppTheme.protein)),
            Expanded(flex: (carbsPercent * 100).round(),
              child: Container(color: AppTheme.carbs)),
            Expanded(flex: (fatPercent * 100).round(),
              child: Container(color: AppTheme.fat)),
          ],
        ),
      ),
    );
  }
}
```

Labels sit below the bar as a Row of small colored dots + text:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    _MacroLabel(color: AppTheme.protein, label: 'Protein', value: '${proteinGrams}g'),
    _MacroLabel(color: AppTheme.carbs, label: 'Carbs', value: '${carbGrams}g'),
    _MacroLabel(color: AppTheme.fat, label: 'Fat', value: '${fatGrams}g'),
  ],
)
```

### Charts — Clean, Smooth, No Grid Overload

For weight progress and calorie trends. Use `CustomPainter` or `fl_chart` package.

Rules:
- Smooth curved lines, not jagged point-to-point
- No heavy grid lines — one subtle horizontal reference line at the goal, if any
- Dots only at data points on hover/tap
- Y-axis labels in secondary color, minimal
- X-axis shows abbreviated dates (Mon, Tue, etc.)
- Chart background: transparent (sits inside a card)
- Line color: `AppTheme.weight` for weight charts, `AppTheme.calories` for calorie trends
- Area fill: the line color at 10% opacity below the curve

```dart
// Inside a card container
Container(
  height: 200,
  padding: const EdgeInsets.all(Spacing.md),
  decoration: BoxDecoration(
    color: AppTheme.surface,
    borderRadius: AppTheme.borderRadiusCard,
    border: Border.all(color: AppTheme.divider),
  ),
  child: CustomPaint(
    painter: TrendChartPainter(
      data: weightEntries,
      lineColor: AppTheme.weight,
      fillColor: AppTheme.weight.withOpacity(0.1),
      goalLine: targetWeight,       // subtle dashed horizontal line
    ),
    size: Size.infinite,
  ),
)
```

### Buttons — Two Kinds, Pill-Shaped

**Primary (filled):** Accent green background, white text, pill shape. Used for the single most important action per screen ("Log Meal", "Start Workout", "Save").

**Secondary (outlined):** 1px divider border, ink text, pill shape. Everything else ("Add Food", "Edit", "View All").

No flat text-only buttons (except in navigation). No gradient buttons. No red buttons — destructive actions use a dialog with red text, not a red button.

### Quick Action Buttons — Floating Entry Points

On the home screen, provide quick actions as subtle pill buttons:

```dart
Row(
  children: [
    _QuickAction(icon: Icons.restaurant_rounded, label: 'Add Meal', onTap: () {}),
    const SizedBox(width: Spacing.sm),
    _QuickAction(icon: Icons.fitness_center_rounded, label: 'Log Workout', onTap: () {}),
  ],
)

// Where _QuickAction is:
Container(
  padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
  decoration: BoxDecoration(
    color: AppTheme.accent.withOpacity(0.1),
    borderRadius: AppTheme.borderRadiusPill,
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: AppTheme.accent),
      const SizedBox(width: Spacing.xs),
      Text(label, style: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.accent,
      )),
    ],
  ),
)
```

### Empty States — Minimal But Warm

When no data exists yet:

```dart
Center(
  child: Padding(
    padding: const EdgeInsets.all(Spacing.xxl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.restaurant_rounded, size: 48, color: AppTheme.secondary),
        const SizedBox(height: Spacing.md),
        Text('No meals logged today',
          style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Spacing.sm),
        Text('Track your first meal to see your macro breakdown.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center),
        const SizedBox(height: Spacing.lg),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Log Meal'),
        ),
      ],
    ),
  ),
)
```

## Screen Layouts

### 🏠 Home Dashboard

The home screen answers: **"How am I doing today?"**

Layout (top to bottom):
1. Greeting + date ("Good morning" / today's date)
2. Calorie ring (large, centered) with remaining kcal insight
3. Macro breakdown bar + labels
4. Quick actions row (Add Meal, Log Workout)
5. Today's workout status card (if scheduled)
6. Insight banner (one smart message)

### 🍽 Diet Screen

Answers: **"What did I eat today?"**

Layout:
1. Date selector (horizontal scrollable pills)
2. Daily calorie summary (consumed / goal)
3. Meal cards stacked vertically — Breakfast, Lunch, Dinner, Snack
4. Each card: expandable, shows food items and per-item calories
5. Floating "+" button to add a meal

### 🏋️ Workout Screen

Answers: **"What should I do today?"**

Layout:
1. Today's workout title + estimated duration
2. Exercise list — each row: exercise name, sets × reps, optional weight
3. Timer / rest timer (simple, clean)
4. "Complete Workout" button at bottom

### 📈 Progress Screen

Answers: **"Am I improving?"**

Layout:
1. Time range selector (1W, 1M, 3M, 6M, 1Y)
2. Weight trend chart (the hero element)
3. Body measurements cards (waist, chest, arms — simple list)
4. Progress photos grid (if available)

### 👤 Profile Screen

Answers: **"What are my goals and settings?"**

Layout:
1. User info (name, avatar)
2. Goals section (calorie target, weight goal, workout frequency)
3. Preferences (units, notifications)
4. Settings list

## Motion & Interaction

### Animations — Fast, Smooth, Subtle

- Duration: **200–300ms** maximum
- Curve: `Curves.easeInOut` for most, `Curves.easeOutCubic` for entries
- Use `AnimatedContainer` for state changes (card expand, progress updates)
- Use `AnimatedSwitcher` for content transitions
- Tab transitions: simple crossfade, no slide
- Progress ring fill: animate on screen load with a 500ms fill

**No flashy animations.** No bounces, no spring physics, no particle effects. If the animation draws attention to itself, remove it.

### Gestures

- Swipe left on meal/exercise item → delete with confirmation
- Swipe right on meal/exercise item → edit
- Tap card → expand details (animated)
- Long press → quick action menu (contextual)
- Pull to refresh on list screens

### Hover & Interaction States (for web/tablet)

Subtle. No color shifts. Just opacity changes:

```dart
MouseRegion(
  cursor: SystemMouseCursors.click,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    decoration: BoxDecoration(
      color: isHovered ? AppTheme.whisper : Colors.transparent,
      borderRadius: AppTheme.borderRadiusCard,
    ),
    child: child,
  ),
)
```

## Gradient Background Setup

The scaffold body uses a gradient behind all content so glass cards have something to blur against:

```dart
Scaffold(
  extendBodyBehindAppBar: true,
  body: Container(
    decoration: const BoxDecoration(
      gradient: AppTheme.backgroundGradient,
    ),
    child: SafeArea(
      child: screenContent,
    ),
  ),
  bottomNavigationBar: const BottomNav(),
)
```

## Design Audit Checklist

Before finishing any screen, run through this:

- [ ] **Palette respected?** Only ink, canvas, surface, accent green, and semantic data colors. No random colors.
- [ ] **Semantic colors in data only?** Orange, purple, blue, pink, teal appear exclusively in charts, rings, and data badges — never on buttons, backgrounds, or nav.
- [ ] **One primary CTA per screen?** Only one green pill button visible at a time.
- [ ] **All card corners 20px?** All button corners pill? All input corners 12px?
- [ ] **Enough whitespace?** If anything feels tight, it is. Add more spacing.
- [ ] **Type hierarchy clear?** Can you tell title vs label vs body at a glance?
- [ ] **Zero decoration?** No icons without function. No borders without separation. No shadows without lift.
- [ ] **Insight over data?** Are you showing what the number means, not just the number?
- [ ] **Glass effect appropriate?** Used on dashboard summary cards and overlays, not on dense list content?
- [ ] **Animations under 300ms?** No flashy transitions?

## What NOT to Do ❌

- No clutter dashboards — each screen answers ONE question
- No social media style UI — no likes, shares, streaks with fire emojis
- No neon or saturated background colors
- No tiny text below 11px
- No laggy or springy animations
- No more than 5 nav tabs
- No deep nesting — 2 levels maximum from any tab
- No heavy shadows (max elevation 0.5)
- No sharp corners anywhere

## Workflow

When building UI:

1. Read existing files in `lib/` first — match what's there
2. Ensure `theme/app_theme.dart` exists with the full theme. Create it first if missing
3. Ensure `widgets/glass_card.dart` exists. Create it first if missing
4. Build the screen or widget using **only** theme tokens — never hard-code a color, font size, or radius
5. Run the audit checklist above before finishing
6. Update routing in `app_router.dart` if adding a new screen
7. Run `flutter analyze` on substantial changes

**The ultimate test:** Does the screen feel like Apple Health meets Notion meets Calm? If it feels like Instagram, a gaming app, or a bodybuilding flashy app — redesign it.

**Steve Jobs rule:** After designing, remove 30% of the UI elements. If the user has to think, redesign.