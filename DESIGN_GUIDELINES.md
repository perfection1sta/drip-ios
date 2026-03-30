# Drip — Design Guidelines

> Version 1.0 · iOS 17+ · SwiftUI · Dark-first

---

## 1. Design Philosophy

Drip is built on four core design principles:

1. **Motion as feedback, not decoration** — Every animation is triggered by a user action or a meaningful state change. Nothing moves unless it communicates something.
2. **Dark-first energy** — The default experience is a deep dark environment where vibrant energy colours cut through clearly, inspired by the gym environment where screens need to be readable under artificial light.
3. **Depth through layering** — Five visual layers: `Background → Surface → Glass → Content → Overlay`. Each layer has its own opacity and blur treatment.
4. **Physical feel** — Every interaction has a corresponding haptic. Users shouldn't just see the app respond — they should feel it.

---

## 2. Color System

### 2.1 Brand Palette

| Token | Dark Hex | Light Hex | Use |
|---|---|---|---|
| `energyOrange` | `#FF6B35` | `#E8521A` | Primary CTA, active state rings, completion badges |
| `energyRed` | `#FF3B30` | `#D63026` | Gradient partner, error states, urgency indicators |
| `wellnessTeal` | `#30D5C8` | `#0A9E93` | Rest timer, progress rings, recovery states |
| `achieveGold` | `#FFD60A` | `#CC9B00` | Streaks, personal records, medals, badges |
| `success` | `#32D74B` | `#248A35` | Completed workouts, positive feedback, beginner difficulty |
| `warning` | `#FF9F0A` | `#CC7200` | Intermediate difficulty, cautions |
| `error` | `#FF453A` | `#CC1F14` | Errors, destructive actions, advanced difficulty |

### 2.2 Surface Tokens

| Token | Dark | Light | Use |
|---|---|---|---|
| `surfacePrimary` | `#0D0D0F` | System Grouped BG | App root background |
| `surfaceSecondary` | `#1C1C1E` | System Secondary Grouped BG | Cards, list rows |
| `surfaceTertiary` | `#2C2C2E` | System Tertiary Grouped BG | Dividers, inactive states |
| `surfaceGlass` | White 8% opacity | Black 5% opacity | Floating tab bar, overlays |

### 2.3 Text Tokens

| Token | Use |
|---|---|
| `textPrimary` | Headlines, primary content (maps to `UIColor.label`) |
| `textSecondary` | Supporting text (maps to `UIColor.secondaryLabel`) |
| `textTertiary` | Metadata, timestamps (maps to `UIColor.tertiaryLabel`) |

### 2.4 Muscle Group Colors

Each muscle group has a unique hue to create an at-a-glance visual vocabulary for exercise categorisation.

| Muscle Group | Color | Hex |
|---|---|---|
| Chest | Coral Red | `#FF6666` |
| Back | Strong Blue | `#4285F5` |
| Legs (Quads/Hams/Glutes) | Purple | `#AF52DE` |
| Core | Amber | `#FF9500` |
| Arms (Biceps/Triceps) | Teal | `#30D5C8` |
| Shoulders | Indigo | `#6B8CF5` |
| Cardio/Full Body | Energy Orange | `#FF6B35` |

**Rule:** Never use muscle group colours as backgrounds — only use them as foreground text, icon tints, or at ≤ 20% opacity as fills.

### 2.5 Gradient Library

| Name | Colors | Direction | Use |
|---|---|---|---|
| `energyGradient` | `energyRed → energyOrange` | Top-leading → bottom-trailing | Primary CTA buttons, WOD hero card |
| `darkSurface` | `#0D0D0F → #1A1A2E` | Top → bottom | Full-screen view backgrounds |
| `tealWellness` | `wellnessTeal → #0A8A8A` | Top-leading → bottom-trailing | Rest timer, wellness states |
| `goldAchieve` | `achieveGold → #FF9500` | Top-leading → bottom-trailing | PR celebrations, streak milestones |

---

## 3. Typography Scale

Drip uses **SF Pro Display** (system font) exclusively. No custom fonts are loaded — this keeps the app lightweight and ensures Dynamic Type compatibility.

### 3.1 Type Ramp

| Token | Size | Weight | Use |
|---|---|---|---|
| `displayLarge` | 40pt | Bold | Hero streak count, major stats |
| `displayMedium` | 32pt | Bold | Section hero numbers |
| `displaySmall` | 28pt | Bold | Workout names, exercise names |
| `titleLarge` | 24pt | Semibold | Screen titles, card headers |
| `titleMedium` | 20pt | Semibold | Section headers |
| `titleSmall` | 17pt | Semibold | List headers, button labels |
| `bodyLarge` | 17pt | Regular | Primary reading copy |
| `bodyMedium` | 15pt | Regular | Instructions, descriptions |
| `bodySmall` | 13pt | Regular | Secondary descriptions |
| `labelLarge` | 13pt | Medium | Chips, tags, metadata |
| `labelSmall` | 11pt | Medium | Compact chips, captions |
| `caption` | 11pt | Regular | Timestamps, footnotes |
| `timerDisplay` | 64pt | Thin, Monospaced | Rest timer countdown |
| `timerMedium` | 40pt | Light, Monospaced | Active workout elapsed time |
| `statNumber` | 36pt | Bold, Monospaced | Dashboard stats, weights |
| `statSmall` | 24pt | Semibold, Monospaced | Inline stat values |

### 3.2 Typography Rules

- **Never use italic** — italic implies weakness/hesitation; use weight variation for emphasis instead.
- **Monospace for numbers** — all counters, weights, timers, and reps use `.monospacedDigit()` to prevent layout shift when digits change.
- **Uppercase only for labels** — use `.tracking(4)` uppercase for short system labels like "REST", "SETS". Not for body copy.
- **Line height** — use default system line height. Do not override unless text is multiline display size.

---

## 4. Spacing System

Drip uses a **4-point grid**. All padding, margins, and spacing values are multiples of 4.

| Token | Value | Use |
|---|---|---|
| `Spacing.xxs` | 4pt | Icon padding, tight gaps |
| `Spacing.xs` | 8pt | Chip internal padding |
| `Spacing.sm` | 12pt | List row internal spacing |
| `Spacing.md` | 16pt | Standard edge padding, card content |
| `Spacing.lg` | 20pt | Card padding (default) |
| `Spacing.xl` | 24pt | Section spacing |
| `Spacing.xxl` | 32pt | Large section breaks |
| `Spacing.xxxl` | 48pt | Full-screen section spacing |
| `Spacing.huge` | 64pt | Bottom scroll clearance, hero spacing |

### Corner Radii

| Token | Value | Use |
|---|---|---|
| `Spacing.Radius.sm` | 8pt | Small buttons, inline tags |
| `Spacing.Radius.md` | 12pt | List rows, compact cards |
| `Spacing.Radius.lg` | 16pt | Standard cards |
| `Spacing.Radius.xl` | 20pt | Hero cards, large buttons |
| `Spacing.Radius.xxl` | 28pt | WOD hero card, full-width cards |
| `Spacing.Radius.pill` | 999pt | Capsule/pill shapes |

---

## 5. Animation System

### 5.1 Spring Presets

All animations use SwiftUI springs. Never use linear or ease-in-out for interactive UI — springs feel physical.

| Token | Response | Damping | Use |
|---|---|---|---|
| `.snappy` | 0.3 | 0.7 | Buttons, navigation, tab switching |
| `.bouncy` | 0.5 | 0.6 | Set completion, PR badges, celebrations |
| `.smooth` | 0.6 | 0.8 | Progress bars, chart data updates |
| `.gentle` | — | — | easeInOut(0.4) — background colour shifts, non-interactive |
| `.staggered(n)` | — | — | Delays base animation by n × 50ms for list entrances |

### 5.2 Transition Catalogue

| Transition | Use |
|---|---|
| `.move(edge:) + .opacity` | Sheet presentations, overlay appearances |
| `.scale(0.6) + .opacity` | Set completion overlay burst |
| `.asymmetric(insertion: .trailing, removal: .leading)` | Exercise advance in active workout |
| `.numericText()` | Timer digit changes (`contentTransition`) |

### 5.3 Animation Performance Rules

- Never animate layout outside of `withAnimation {}` blocks.
- Use `Canvas` + `TimelineView` for particle effects — never individual animated `View`s.
- Particle systems must stay under 30 views. For more particles, use `Canvas`.
- Disable all decorative animations when `accessibilityReduceMotion` is true.
- Background animations (gradient breathing, etc.) use `repeatForever(autoreverses: true)` on phase offsets — not `Timer`.

### 5.4 Stagger Pattern

When lists or grids appear, stagger child animations by index:

```swift
.opacity(appeared ? 1 : 0)
.offset(y: appeared ? 0 : 20)
.animation(.staggered(index), value: appeared)
```

Cap the stagger at index 10 — items beyond that should appear instantly to avoid feeling sluggish.

---

## 6. Components

### 6.1 DripCard

The primary container for grouped content.

| Property | Value |
|---|---|
| Background | `surfaceSecondary` (default) or `ultraThinMaterial` (glass) |
| Corner radius | `Spacing.Radius.xl` (20pt) |
| Default padding | `Spacing.lg` (20pt) |
| Shadow | `black 35% / 24pt radius / y+8` |

**Do:** Use `glassEffect: true` for floating elements like banners and overlays.
**Don't:** Nest DripCards inside DripCards.

### 6.2 DripButton

| Variant | Height | Background | Text |
|---|---|---|---|
| `.primary` | 56pt | `energyGradient` | White |
| `.secondary` | 48pt | Glass (`ultraThinMaterial`) | `textPrimary` |
| `.ghost` | 44pt | Clear | `energyOrange`, outline border |
| `.destructive` | 44pt | `error` | White |

**Always** pair a `.primary` button with a `.ghost` cancel/skip as a secondary action.

### 6.3 DripBadge

Pill-shaped label for categorisation tags.

```
Background: [color] at 18% opacity
Border: [color] at 35% opacity, 1pt
Text: labelSmall, medium weight, [color]
Height: 26pt (pill)
```

**Never** use more than 4 badges in a horizontal row without a `ScrollView(.horizontal)`.

### 6.4 ProgressRing

Animatable circular arc shape.

| Size | Ring Width | Use |
|---|---|---|
| 28pt | 3pt | Mini (tab bar active indicator, list rows) |
| 80pt | 6pt | Card summary completion |
| 200pt | 10pt | Rest timer full-screen |

Ring colours follow state:
- `wellnessTeal` → resting, normal progress
- `energyOrange` → active, < 10s remaining
- `energyRed` → urgent, < 5s remaining

### 6.5 StatPill

Three-line metric display (label / number / unit). Use in `HStack` rows of 3.

```
minWidth: 80pt
Background: surfaceGlass (ultraThinMaterial)
Corner radius: Radius.lg
Number: statSmall, monospacedDigit
```

### 6.6 HapticManager

Centralised — never call `UIImpactFeedbackGenerator` directly. Always use `HapticManager.shared.*`.

| Action | Method |
|---|---|
| Button tap | `.light()` |
| Selection change | `.selection()` |
| Set complete | `.setComplete()` (medium + 2× light) |
| Rest timer tick | `.timerPulse(secondsRemaining:)` |
| Workout complete | `.success()` |
| Personal record | `.personalRecord()` (3× ascending) |
| Error | `.error()` |

---

## 7. Screen-by-Screen Guidelines

### Home
- **Background:** `LinearGradient.darkSurface` full-screen
- **WOD Hero Card:** Full-width, 220pt height, `energyGradient` background, `Radius.xxl`, 4pt drop shadow
- **Stagger:** 6 sections enter with `.staggered(0-5)` delays
- **Streak fire:** Always show at top-right if streak > 0

### Workout Detail
- **Exercise list:** Expandable rows with `chevron.down` rotate animation
- **CTA:** Single `.primary` "Start Workout" button, sticky at bottom
- **Completed state:** Workout header shows `checkmark.seal.fill` in `.success`, button opacity 0.5, disabled

### Active Workout
- **Background:** `AnimatedGradientBackground` — living, breathing colour based on exercise category
- **Exercise transition:** `.asymmetric` slide — new exercise slides in from trailing, old slides out to leading
- **Progress bar:** 4pt thin bar at very top of screen, continuously animated
- **Rest timer:** Full-screen `ultraThinMaterial` blur, 200pt ring, monospace 64pt countdown
- **Set bubbles:** Pending = ghost, Active = teal pulse, Complete = orange fill with spring checkmark

### Exercise Library
- **Grid:** 2-column `LazyVGrid`, cards enter with stagger
- **Search:** Instant filter, no search button needed
- **Filters:** Bottom sheet (`.medium` + `.large` detents)

### Progress
- **Charts:** Bars grow from 0 on appear, `.smooth` animation
- **Calendar:** Today has orange outline, completed days have filled orange circles
- **PR rows:** Ranked with emoji medals (🥇🥈🥉🏅)

### Settings
- **List style:** Native `List` with `scrollContentBackground(.hidden)` + `Color.surfacePrimary` background
- **Toggle accent:** `.energyOrange`
- **Pickers:** `.menu` style for compact options

---

## 8. Accessibility

### 8.1 Reduce Motion
Every decorative animation must check `@Environment(\.accessibilityReduceMotion)`:

```swift
.animation(reduceMotion ? nil : .bouncy, value: state)
```

For navigation transitions, use `.opacity` instead of `.move` when reduce motion is enabled.

### 8.2 Dynamic Type
- All fonts use `Font` tokens defined in `TypographyTokens.swift` — never hardcode `CGFloat` for text sizes.
- Cards expand vertically — never set fixed heights on text containers.
- Test at Accessibility Extra Extra Large (AXXL) before shipping.

### 8.3 Colour Contrast
- All text on `surfacePrimary` dark background: minimum 4.5:1 WCAG AA.
- Badge text on badge background: minimum 3:1 (large text exemption applies).
- Never convey information by colour alone — always pair with icon or label text.

### 8.4 VoiceOver
- Every interactive element has `.accessibilityLabel`.
- Timer announces remaining time via `.accessibilityValue(vm.timerVM.displayTime)`.
- Set completion announces result via `.accessibilityAnnouncement`.
- Tab bar items use the `tab.label` string for `.accessibilityLabel`.

---

## 9. Do's and Don'ts

### Do
✅ Use the design token system for all colours, spacing, and animations
✅ Apply `HapticManager` on every interactive action
✅ Check `accessibilityReduceMotion` before any decorative animation
✅ Use `.monospacedDigit()` on any Text that displays numbers
✅ Keep particle effects in `Canvas` / `TimelineView`, not individual Views
✅ Use `DripCard` as the default content container
✅ Stagger list/grid entrances for a polished feel

### Don't
❌ Use hex colours directly — always use token extensions
❌ Add animations that serve no informational purpose
❌ Use `.linear` or `.easeInOut` for interactive animations (use springs)
❌ Nest `DripCard` inside `DripCard`
❌ Use more than 4 `DripBadge` chips in a row without a horizontal scroll
❌ Hardcode `UIColor` — use the semantic `Color` extensions
❌ Add decorative animations that play continuously on the home screen without user interaction

---

## 10. File Structure Reference

```
Drip/
├── DesignSystem/         ← All tokens and base components live here
│   ├── Colors/           ← ColorTokens.swift, GradientTokens.swift
│   ├── Typography/       ← TypographyTokens.swift
│   ├── Spacing/          ← SpacingTokens.swift
│   ├── Animations/       ← AnimationTokens.swift
│   └── Components/       ← DripButton, DripCard, DripBadge, StatPill,
│                           ProgressRing, HapticManager
├── Models/               ← SwiftData @Model classes
│   └── Enums/            ← MuscleGroup, ExerciseCategory, etc.
├── ViewModels/           ← @Observable classes, one per screen
├── Views/                ← SwiftUI views, organised by screen
│   ├── MainTab/
│   ├── Home/
│   ├── WorkoutDetail/
│   ├── ActiveWorkout/
│   ├── ExerciseLibrary/
│   ├── Progress/
│   └── Settings/
├── Services/             ← Business logic, data seeding, notifications
└── Utilities/            ← Extensions on Date, View, Color
```

---

*Drip Design Guidelines v1.0 — Keep it consistent, keep it physical, keep it dripping.*
