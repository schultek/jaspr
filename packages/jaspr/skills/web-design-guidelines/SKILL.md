---
name: web-design-guidelines
description: Review UI code and build modern web interfaces complying with Web Interface Guidelines. Use when asked to "review my UI", "audit design", "check accessibility", "review UX", or when creating/styling accessible, polished Jaspr web components.
---

# Web Design & Interface Guidelines for Jaspr

This skill provides an actionable standard for building and auditing high-quality, polished, and accessible web interfaces in Jaspr. Derived from modern Web Interface Guidelines, it applies framework-agnostic interaction standards directly to Jaspr's `package:jaspr/dom.dart` and CSS-in-Dart APIs.

---

## 1. Accessibility & Semantic HTML

Always prefer native HTML elements over ARIA attributes or custom div click handlers.

### Core Rules
- **Rule 1 (Links vs Buttons):** Use `a(href: ...)` for navigation and `button(type: ButtonType.button, ...)` for actions. NEVER use `div(onClick: ...)` or `span(onClick: ...)` as interactive elements.
- **Rule 2 (Icon Buttons):** Icon-only buttons MUST have an `ariaLabel:` or visually hidden text for screen readers.
- **Rule 3 (Decorative Media):** Decorative icons and SVG illustrations MUST set `ariaHidden: 'true'`.
- **Rule 4 (Images):** Every `img()` MUST provide an `alt` attribute (use `alt: ''` if purely decorative).
- **Rule 5 (Headings):** Maintain logical heading hierarchy (`h1` through `h6`). Headings with anchor links MUST include `scroll-margin-top` to avoid being obscured by sticky headers.
- **Rule 6 (Async Announcements):** Dynamic alerts, toasts, or inline validation updates MUST use `ariaLive: 'polite'`.

### Good vs Bad Example

```dart
// ❌ BAD: Non-semantic, inaccessible div-button
div(classes: 'btn', onClick: () => doAction(), [
  img(src: '/icons/trash.svg'), // Missing alt / ariaHidden
])

// ✅ GOOD: Semantic, fully accessible Jaspr button
button(
  type: ButtonType.button,
  classes: 'btn-icon',
  ariaLabel: 'Delete item',
  onClick: () => doAction(),
  [
    img(src: '/icons/trash.svg', alt: '', ariaHidden: 'true'),
  ],
)
```

---

## 2. Focus States & Keyboard Navigation

Every interactive element must provide clear, accessible focus states for keyboard users without creating visual noise for mouse/pointer users.

### Core Rules
- **Rule 1 (Use `:focus-visible`):** Apply focus styles to `:focus-visible` rather than `:focus` so click/tap users don't see distracting rings.
- **Rule 2 (Never Bare `outline: none`):** NEVER remove the outline (`outline: none` or `outline: Outline.none`) without immediately replacing it with an accessible focus indicator (e.g. outline ring or box-shadow).
- **Rule 3 (Group Focus):** Use `:focus-within` on compound controls (e.g. an input with an embedded clear button or action dropdown).
- **Rule 4 (No Obscuring):** Sticky headers, floating banners, and drawers must never overlap or cover the actively focused element.

### Good vs Bad Example

```dart
// ❌ BAD: Removing focus ring completely
@css
static List<StyleRule> get styles => [
  css('button:focus').styles(outline: Outline.none),
];

// ✅ GOOD: Accessible focus ring with :focus-visible
@css
static List<StyleRule> get styles => [
  css('button:focus').styles(outline: Outline.none),
  css('button:focus-visible').styles(
    outline: Outline(width: 2.px, style: OutlineStyle.solid, color: Colors.blue),
    outlineOffset: 2.px,
  ),
  css('.input-group:focus-within').styles(
    border: .all(color: Colors.blue),
  ),
];
```

---

## 3. Forms & Interactive Controls

Form controls must be resilient, convenient, and mobile-friendly.

### Core Rules
- **Rule 1 (Clickable Labels):** Form controls MUST be associated with a `<label>` using `label(htmlFor: 'field-id', ...)` or by wrapping the input inside the label.
- **Rule 2 (Appropriate Input Types):** Use semantic `InputType` (`.email`, `.tel`, `.url`, `.number`, `.search`, `.password`).
- **Rule 3 (Mobile Font Size):** On mobile, inputs MUST have a `font-size` of at least `16px` (or `1.rem`) to prevent iOS Safari from automatically zooming and shifting the layout on focus.
- **Rule 4 (Hit Target Sizes):** Interactive targets must be at least `24px` on desktop and at least `44px` on mobile/touch interfaces.
- **Rule 5 (Never Block Paste):** NEVER disable paste events (`onPaste`) on password or code inputs.
- **Rule 6 (Loading State):** When submitting forms, keep the submit button visible and disabled, show a loading spinner, and preserve the original label or use an ellipsis: `"Saving…"`.
- **Rule 7 (Spellcheck):** Set `spellCheck: false` on emails, usernames, API keys, and verification codes.

### Good vs Bad Example

```dart
// ✅ GOOD: Accessible Jaspr form input
div(classes: 'field', [
  label(htmlFor: 'email-input', [.text('Email Address')]),
  input(
    id: 'email-input',
    type: InputType.email,
    name: 'email',
    autoComplete: 'email',
    spellCheck: false,
    placeholder: 'name@example.com',
  ),
])
```

---

## 4. Animations & Transitions

Animations should clarify cause-and-effect or add deliberate delight without causing layout shifts, jank, or motion sickness.

### Core Rules
- **Rule 1 (Compositor-Friendly Properties):** Animate ONLY GPU-accelerated properties (`transform` and `opacity`). NEVER animate layout-triggering properties (`width`, `height`, `top`, `left`, `margin`, `padding`).
- **Rule 2 (Never `transition: all`):** Explicitly declare only the properties being animated (e.g. `transition: 'transform 0.2s ease, opacity 0.2s ease'`).
- **Rule 3 (Respect Reduced Motion):** ALWAYS provide a `@media (prefers-reduced-motion: reduce)` override that removes or simplifies motion.
- **Rule 4 (Interruptible):** Animations must be cancelable and immediately respond to user input mid-flight.
- **Rule 5 (Autoplay Controls):** Any automatically looping animation lasting longer than 5 seconds must provide controls to pause, stop, or hide it.

### Good vs Bad Example

```dart
// ❌ BAD: Animating height/width, transition: all, no reduced-motion
@css
static List<StyleRule> get styles => [
  css('.panel').styles(
    transition: Transition('all', duration: 300),
  ),
  css('.panel.open').styles(
    height: 300.px, // Triggers layout thrashing / jank
  ),
];

// ✅ GOOD: GPU-accelerated transform & opacity with prefers-reduced-motion
@css
static List<StyleRule> get styles => [
  css('.panel').styles(
    opacity: 0,
    transform: Transform.translate(y: 8.px),
    transition: Transition('opacity 0.2s ease, transform 0.2s ease'),
  ),
  css('.panel.open').styles(
    opacity: 1,
    transform: Transform.translate(y: Unit.zero),
  ),
  css('@media (prefers-reduced-motion: reduce)', [
    css('.panel').styles(
      transition: Transition.none,
      transform: Transform.none,
    ),
  ]),
];
```

---

## 5. Typography & Micro-Copy Polish

Small typographic details distinguish high-end products from amateur designs.

### Core Rules
- **Rule 1 (Ellipsis):** Use the actual ellipsis character `…` (`&hellip;`), not three periods `...`.
- **Rule 2 (Loading & Menu Actions):** Menu items that open a dialog end with an ellipsis (e.g. `"Rename…"`, `"Export…"`). Active processing states end with an ellipsis (e.g. `"Loading…"`, `"Saving…"`, `"Deploying…"`).
- **Rule 3 (Curly Quotes):** Use typographic curly quotes `“` `”` / `‘` `’` rather than straight quotes `"`, `'` in marketing and editorial text.
- **Rule 4 (Tabular Figures for Numbers):** Use `font-variant-numeric: tabular-nums` (or monospace) when displaying columns of numbers, timers, or metric counters to prevent horizontal jitter as digits change.
- **Rule 5 (Preventing Widows):** Apply `text-wrap: balance` on headings and `text-wrap: pretty` on paragraphs to avoid lone dangling words on the final line.
- **Rule 6 (Non-Breaking Spaces):** Use non-breaking spaces (`\u00A0` or `&nbsp;`) between numbers and units (e.g. `10\u00A0MB`, `⌘\u00A0K`).

### Good vs Bad Example

```dart
// ❌ BAD: Straight quotes, three dots, jittery numbers
p([.text('Loading... "Project Alpha" (10 MB)')])

// ✅ GOOD: Typographic polish
p([.text('Loading… “Project Alpha” (10\u00A0MB)')])

@css
static List<StyleRule> get styles => [
  css('h1, h2, h3').styles(
    textWrap: TextWrap.balance,
  ),
  css('.metric-counter, .table-numbers').styles(
    fontVariantNumeric: FontVariantNumeric.tabularNums,
  ),
];
```

---

## 6. Layout, Content & Overflow

Designs must gracefully handle varying content sizes without breaking layouts.

### Core Rules
- **Rule 1 (Flex Truncation with `min-w-0`):** Flex child containers that truncate text MUST set `min-width: 0` (`minWidth: Unit.zero`), otherwise CSS flex minimum size rules prevent text truncation (`text-overflow: ellipsis`) from working.
- **Rule 2 (No Cumulative Layout Shift - CLS):** Every `img()` MUST specify explicit `width` and `height` attributes (or an `aspect-ratio` style) so the browser reserves space before the image loads.
- **Rule 3 (Lazy Loading):** Images below the fold MUST use `loading: 'lazy'`. Images critical to the initial viewport (LCP) should use `loading: 'eager'`.
- **Rule 4 (Handle All States):** Design for all 4 states: Empty, Sparse, Dense, and Error. Never render broken UI or blank containers for empty arrays/strings.

### Good vs Bad Example

```dart
// ❌ BAD: Flex child text truncation fails without min-width: 0
div(styles: Styles(display: Display.flex), [
  div(classes: 'title-column', [
    p(styles: Styles(textOverflow: TextOverflow.ellipsis, whiteSpace: WhiteSpace.noWrap), [
      .text(longUserText),
    ]),
  ]),
])

// ✅ GOOD: Resilient flex truncation and responsive layout
div(styles: Styles(display: Display.flex), [
  div(
    styles: Styles(
      minWidth: Unit.zero, // Allows text-overflow to truncate properly
      flex: Flex(grow: 1),
    ),
    [
      p(styles: Styles(textOverflow: TextOverflow.ellipsis, overflow: Overflow.hidden, whiteSpace: WhiteSpace.noWrap), [
        .text(longUserText),
      ]),
    ],
  ),
])
```

---

## 7. Performance & Rendering Cleanliness

- **Rule 1 (Let CSS Layout):** Avoid measuring DOM dimensions (`getBoundingClientRect`, `offsetHeight`) inside build/render loops. Let CSS Grid and Flexbox handle intrinsic sizing.
- **Rule 2 (Preconnect CDN Assets):** Add `<link rel="preconnect" href="...">` in document head for external asset origins (Google Fonts, CDNs).
- **Rule 3 (Virtualize Massive Lists):** For lists with $> 100$ items, use virtualization or CSS `content-visibility: auto`.
