---
title: Use ContentTheme and Tokenized CSS Variables for Universal Theming
impact: MEDIUM
impactDescription: Guarantees consistent dark/light mode adaptation across built-in and custom components
tags: content, theming, colors, jaspr_content
---

## Use ContentTheme and Tokenized CSS Variables for Universal Theming

**Impact: MEDIUM (Guarantees consistent dark/light mode adaptation across built-in and custom components)**

`jaspr_content` includes a built-in theming system (`ContentTheme`) that automatically handles light and dark mode through CSS custom properties (variables like `--content-primary`, `--content-background`, `--content-font`).

Every `ColorToken` (such as `ContentColors.background` or `ContentColors.text`) implements `Color` directly and resolves to `var(--name)` in CSS.

When styling custom components or creating layouts:
- Use `ContentColors.<token>` directly anywhere a `Color` is expected.
- Add custom color tokens with light and dark variants using `ColorToken('token-name', lightColor, dark: darkColor)` and provide them to `ContentTheme(colors: [...])`.
- In component styles, reference theme variables via `ContentColors` tokens, custom `ColorToken`s, or `ContentTheme.currentFont` instead of hardcoded hex values, ensuring seamless dark mode switching.

**Incorrect (hardcoding fixed color values that break in dark mode):**

```dart
@css
static List<StyleRule> get styles => [
  css('.custom-card').styles(
    backgroundColor: Colors.white, // Breaks in dark mode!
    color: Colors.black,
  ),
];
```

**Correct (leveraging ContentTheme tokens and custom ColorToken):**

```dart
// 1. Defining a custom color token with light and dark variants:
final customAccent = ColorToken(
  'custom-accent',
  Colors.blue,
  dark: Colors.lightBlue,
);

// 2. Setting the theme and registering custom tokens in ContentApp:
ContentApp(
  theme: ContentTheme(
    primary: Colors.indigo,
    colors: [customAccent],
  ),
  ...
)

// 3. Using tokens directly as Colors in component styles:
@css
static List<StyleRule> get styles => [
  css('.custom-card').styles(
    backgroundColor: ContentColors.background, // ColorToken implements Color directly
    color: ContentColors.text,
    border: .all(color: customAccent),
    fontFamily: ContentTheme.currentFont,
  ),
];
```
