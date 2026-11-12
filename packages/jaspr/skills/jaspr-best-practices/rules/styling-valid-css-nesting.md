---
title: Follow Native CSS Nesting Rules in css()
impact: HIGH
impactDescription: Prevents silent CSS styling bugs caused by invalid selector concatenation
tags: styling, css, nesting, selectors
---

## Follow Native CSS Nesting Rules in css()

**Impact: HIGH (Prevents silent CSS styling bugs caused by invalid selector concatenation)**

Jaspr's `css()` function compiles nested rules directly into standard [Native CSS Nesting](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_nesting).

In native CSS nesting:
- The `&` symbol represents the parent selector (e.g., `css('&:hover')`, `css('&.active')`, `css('& > span')`).
- Concatenating suffixes onto `&` (such as `css('&-item')` inside `css('.list')` to mean `.list-item`) **is not supported in native CSS nesting**. It will not produce `.list-item`.

Always write suffix variant classes as separate rules.

**Incorrect (attempting selector name concatenation):**

```dart
css('.button', [
  // INVALID in native CSS nesting: Does NOT produce .button-primary!
  css('&-primary').styles(
    backgroundColor: Colors.blue,
  ),
])
```

**Correct (separate rules for suffix variants, '&' reserved for pseudo-classes and compound selectors):**

```dart
// Parent rule
css('.button', [
  css('&').styles(padding: .all(8.px)),
  // Pseudo-classes are completely valid:
  css('&:hover').styles(opacity: 0.9),
  // Child element selectors are valid:
  css('& > svg').styles(width: 16.px),
]),

// Modifier variant written as its own rule:
css('.button-primary', [
  css('&').styles(backgroundColor: Colors.blue, color: Colors.white),
])
```
