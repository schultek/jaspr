---
name: jaspr-styling
description: Write type-safe CSS-in-Dart to style Jaspr components. Use this skill when styling components, implementing themes, or using CSS properties.
metadata:
  jaspr_version: 0.22.4
---

## Rules for Styling

Jaspr provides a native, type-safe **CSS-in-Dart** styling API via the `Styles` class.

### 1. Component-Level Styles (`@css` annotation)

The recommended approach for defining styles in Jaspr is inside your components to ensure better code locality.

- **Rule 1:** You MUST use the `@css` annotation on a static getter returning `List<StyleRule>` to scope styles to a component.
- **Rule 2:** You MUST use specific CSS selectors (like `.main` classes or `#id` ids) within `css()` to prevent your styles from bleeding into other components, as `@css` styles are globalized during rendering.

```dart
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'main', [
      p([.text('Hello World')]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.main', [
      // Use css('&') to refer to the parent selector (.main)
      css('&').styles(
        width: 100.px, // Note: Use `.px`, `.rem`, `.percent` extensions on numbers.
        padding: .all(10.rem),
        display: .flex,
      ),
      css('&:hover').styles(
        backgroundColor: Colors.blue,
      ),
      css('p').styles(
        color: Colors.blue,
      ),
    ]),
    // Responsive queries
    css.media(MediaQuery.screen(maxWidth: 600.px), [
      css('.main').styles(flexDirection: .column),
    ])
  ];
}
```

### 2. Inline Styles

You can pass `Styles` instances directly to native HTML components. This renders as the `style="..."` HTML attribute.

- **Rule 1:** You MUST ONLY use inline styles for **dynamic styles** (e.g., styles that change based on state or parameters).
- **Rule 2:** For static styles, you MUST use the component-level `@css` annotation.
- **Rule 3:** You MUST NOT use inline styles for complex rules like media queries, hover states, or animations.

```dart
// Example of dynamic inline styling driven by state
class ColorBox extends StatelessComponent {
  final Color boxColor;

  const ColorBox({required this.boxColor, super.key});

  @override
  Component build(BuildContext context) {
    return div(styles: Styles(backgroundColor: boxColor), []);
  }
}
```

### 3. Global `@css` Styles

You can define a global set of styles directly from Dart using the `@css` annotation on a global variable or getter.

- **Rule 1:** Just like component-level `@css`, global `@css` is ONLY supported in **server** and **static** modes.
- **Rule 2:** You MUST place global `@css` annotations on top-level getters or static getters returning `List<StyleRule>`.

```dart
@css
List<StyleRule> get globalStyles => [
  css('body').styles(
    margin: .zero,
    fontFamily: .list([FontFamily('Roboto'), FontFamilies.sansSerif]),
    backgroundColor: Colors.white,
  ),
  css('a').styles(
    textDecoration: TextDecoration(line: .none),
    color: Colors.blue,
  ),
];
```

### 4. Global External Stylesheets

- **Rule:** If you are using raw `.css` files (or other css frameworks like sass/scss, tailwind, etc.), you MUST include them using a `<link rel="stylesheet">` element inside the `Document(head: [...])` component (for server/static mode) or in `web/index.html` (for client mode).

---

## Jaspr Styles Properties

To avoid guessing CSS properties and overwhelming context, Jaspr maps CSS properties to strongly-typed Dart classes.

Here is the full list of properties both the `Styles()` class and `.styles()` method support:

```dart
Styles({ // or .styles({
  All? all,
  // Box Styles
  String? content,
  Display? display,
  Position? position,
  ZIndex? zIndex,
  Unit? width,
  Unit? height,
  Unit? minWidth,
  Unit? minHeight,
  Unit? maxWidth,
  Unit? maxHeight,
  AspectRatio? aspectRatio,
  Padding? padding,
  Margin? margin,
  BoxSizing? boxSizing,
  Border? border,
  BorderRadius? radius,
  Outline? outline,
  double? opacity,
  Visibility? visibility,
  Overflow? overflow,
  Appearance? appearance,
  BoxShadow? shadow,
  Filter? filter,
  Filter? backdropFilter,
  Cursor? cursor,
  UserSelect? userSelect,
  PointerEvents? pointerEvents,
  Animation? animation,
  Transition? transition,
  Transform? transform,
  // Flexbox Styles
  FlexDirection? flexDirection,
  FlexWrap? flexWrap,
  JustifyContent? justifyContent,
  AlignItems? alignItems,
  AlignContent? alignContent,
  // Grid Styles
  GridTemplate? gridTemplate,
  List<TrackSize>? autoRows,
  List<TrackSize>? autoColumns,
  JustifyItems? justifyItems,
  Gap? gap,
  // Item Styles
  Flex? flex,
  int? order,
  AlignSelf? alignSelf,
  JustifySelf? justifySelf,
  GridPlacement? gridPlacement,
  // List Styles
  ListStyle? listStyle,
  ImageStyle? listImage,
  ListStylePosition? listPosition,
  // Text Styles
  Color? color,
  TextAlign? textAlign,
  FontFamily? fontFamily,
  Unit? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  TextDecoration? textDecoration,
  TextTransform? textTransform,
  Unit? textIndent,
  Unit? letterSpacing,
  Unit? wordSpacing,
  Unit? lineHeight,
  TextShadow? textShadow,
  TextOverflow? textOverflow,
  WhiteSpace? whiteSpace,
  Quotes? quotes,
  // Background Styles
  Color? backgroundColor,
  ImageStyle? backgroundImage,
  BackgroundOrigin? backgroundOrigin,
  BackgroundPosition? backgroundPosition,
  BackgroundAttachment? backgroundAttachment,
  BackgroundRepeat? backgroundRepeat,
  BackgroundSize? backgroundSize,
  BackgroundClip? backgroundClip,
  // Raw Styles
  Map<String, String>? raw,
})
```

- **Rule 1:** You MUST define all properties in the order they are defined in the `Styles` class.
- **Rule 2:** You MUST use dot-shorthands for all style properties and values where applicable (e.g., `padding: .all(10.px)` instead of `padding: Padding.all(Unit.pixels(10))`, or `justifyContent: .center` instead of `justifyContent: JustifyContent.center`).
- **Rule 3:** You MUST use `raw` for any properties that are not supported by the `Styles` class.

**IMPORTANT:** Before writing styles in one of the below areas, you **MUST** read the respective reference file provided alongside this skill:

- `references/sizing.md` (Units like `.px`, `.percent`, dimensions, margin, padding, borders, border-radius)
- `references/color.md` (Colors, HEX, RGB, HSL values)
- `references/box.md` (Position, overflow, transform, background, cursor, filters, z-index, visibility)
- `references/typography.md` (Text alignment, fonts, text decoration, letter spacing)
- `references/flexbox.md` (Flexbox container/item, flex layout, alignments)
- `references/grid.md` (Grid layout, track sizes, gaps, templates)
- `references/animation.md` (Transitions, Animations, keyframes, curves, durations)
