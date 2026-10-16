import 'rules.dart';
import 'selector.dart';
import 'styles.dart';

/// Styling utility to create nested style definitions.
///
/// ### 1. **Annotation**
/// Use as `@css` annotation to create a global styles definition:
///
/// ```dart
/// @css
/// final styles = [
///   css('.someclass').styles(width: 100.px)
/// ];
/// ```
///
/// Only allowed on global variables, global getters, static fields and static getters.
/// Must be of type `List<StyleRule>`.
///
/// ### 2. **Styling**
/// Use as `css()` method to define style rules:
///
/// - Provide any valid css selector and chain a set of styles:
///   ```dart
///   css('.someclass').styles(
///     width: 100.px,
///     color: Colors.black,
///   )
///   ```
///
/// - Provide a second parameter to define nested rules. Use '&' to refer to the parent selector.
///   ```dart
///   css('.someclass', [
///     css('&').styles(width: 100.px),
///     css('&:hover').styles(backgroundColor: Colors.blue),
///   ])
///   ```
///
///   Nested rules are rendered as [nested css](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_nesting),
///   which is what the definition already looks like:
///
///   ```css
///   .someclass {
///     width: 100px;
///     &:hover {
///       background-color: blue;
///     }
///   }
///   ```
///
/// - Use special rule variants:
///   ```dart
///   css.import('/some/external/styles.css');
///   css.fontFace(fontFamily: 'SomeFont', url: '/some/font.ttf');
///   css.media(MediaQuery.screen(minWidth: 800.px), [
///     css('.someclass').styles(width: 200.px),
///   ]);
///   ```
const css = CssUtility._();

class CssUtility {
  const CssUtility._();

  /// Renders a css rule with the given selector.
  ///
  /// Use chained calls to [Styles] groups to define the styles for the rule.
  ///
  /// Rules can be nested using the optional second list parameter. Nested rules
  /// can use the `&` symbol in their selector to refer to the parent selector.
  NestedStyleRule call(String selector, [List<StyleRule> children = const []]) {
    return NestedStyleRule(Selector(selector), Styles(), children);
  }

  /// Renders a `@import url(...)` css rule.
  ///
  /// The `@import` CSS at-rule is used to import style rules from other valid stylesheets.
  ImportStyleRule import(String url) {
    return ImportStyleRule(url);
  }

  /// Renders a `@font-face` css rule.
  ///
  /// The `@font-face` CSS at-rule specifies a custom font with which to display text; the font can be loaded from
  /// either a remote server or a locally-installed font on the user's own computer.
  FontFaceStyleRule fontFace({required String family, FontStyle? style, required String url}) {
    return FontFaceStyleRule(family: family, style: style, url: url);
  }

  /// Renders a `@media` css rule.
  ///
  /// The `@media` CSS at-rule can be used to apply part of a style sheet based on the result of one or more media
  /// queries. With it, you specify a media query and a block of CSS to apply to the document if and only if the media
  /// query matches the device on which the content is being used.
  MediaStyleRule media(MediaQuery query, List<StyleRule> styles) {
    return MediaStyleRule(query: query, styles: styles);
  }

  /// Renders a `@layer` css rule.
  ///
  /// The `@layer` CSS at-rule is used to declare a cascade layer and can also be used to define the order of
  /// precedence in case of multiple cascade layers.
  LayerStyleRule layer(List<StyleRule> styles, {String? name}) {
    return LayerStyleRule(name: name, styles: styles);
  }

  /// Renders a `@supports` css rule.
  ///
  /// The `@supports` CSS at-rule lets you specify CSS declarations that depend on a browser's support for CSS
  /// features. Using this at-rule is commonly called a feature query. The rule must be placed at the top level of
  /// your code or nested inside any other conditional group at-rule.
  SupportsStyleRule supports(String condition, List<StyleRule> styles) {
    return SupportsStyleRule(condition: condition, styles: styles);
  }

  /// Renders a `@keyframes` css rule.
  ///
  /// The `@keyframes` CSS at-rule controls the intermediate steps in a CSS animation sequence by defining styles for
  /// keyframes (or waypoints) along the animation sequence. This gives more control over the intermediate steps of
  /// the animation sequence than transitions.
  KeyframesStyleRule keyframes(String name, Map<String, Styles> styles) {
    return KeyframesStyleRule(name: name, styles: styles);
  }
}

/// A style rule with a [selector], its [ownStyles] and the rules nested under
/// it, rendered as [nested css](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_nesting).
class NestedStyleRule with StylesMixin<NestedStyleRule> implements StyleRule {
  const NestedStyleRule(this.selector, this.ownStyles, [this.children = const []]);

  final Selector selector;

  /// The styles of this rule itself, as opposed to its [children].
  ///
  /// Not `styles`, which is the [StylesMixin] builder that `css()` chains.
  final Styles ownStyles;
  final List<StyleRule> children;

  @override
  NestedStyleRule combine(Styles styles) {
    return NestedStyleRule(selector, ownStyles.combine(styles), children);
  }

  @override
  String toCss([String indent = '']) {
    final contents = _contentsCss(indent + cssBlockInset);

    // A rule that says nothing about itself and has nothing nested under it
    // renders as nothing, rather than as an empty block.
    if (contents.isEmpty) return '';

    return '$indent${selector.selector} {$cssPropSpace$contents$indent}';
  }

  /// The properties and nested rules of this rule, rendered at [indent].
  String _contentsCss(String indent) {
    final contents = StringBuffer();

    for (final entry in ownStyles.properties.entries) {
      contents.write('$indent${entry.key}: ${entry.value};$cssPropSpace');
    }

    for (final child in children) {
      // A child whose selector is just `&` is the parent, so what it holds
      // belongs in the parent's block rather than in one of its own.
      if (child._isBareParent) {
        contents.write((child as NestedStyleRule)._contentsCss(indent));
        continue;
      }
      final css = _withinStyleRule(child).toCss(indent);
      if (css.isNotEmpty) contents.write(css + cssPropSpace);
    }

    return contents.toString();
  }
}

extension on StyleRule {
  /// Whether this is a nested rule whose selector is just `&`.
  bool get _isBareParent => this is NestedStyleRule && (this as NestedStyleRule).selector.selector == '&';
}

/// [rule] as it renders inside a style rule.
///
/// A grouping at-rule nested in a style rule keeps that rule as its context,
/// so a bare `&` inside it writes its declarations straight into the at-rule's
/// block, which the browser applies to the enclosing rule. Wrapping them in
/// `& {}` instead would not reach a pseudo-element: `&` matches like `:is()`,
/// which cannot hold one.
StyleRule _withinStyleRule(StyleRule rule) {
  return switch (rule) {
    MediaStyleRule(:final query, :final styles) => MediaStyleRule(
      query: query,
      styles: styles.map(_withinGroupingRule).toList(),
    ),
    SupportsStyleRule(:final condition, :final styles) => SupportsStyleRule(
      condition: condition,
      styles: styles.map(_withinGroupingRule).toList(),
    ),
    LayerStyleRule(:final name, :final styles) => LayerStyleRule(
      name: name,
      styles: styles.map(_withinGroupingRule).toList(),
    ),
    _ => rule,
  };
}

/// [rule] as it renders inside a grouping at-rule that is nested in a style
/// rule.
StyleRule _withinGroupingRule(StyleRule rule) {
  if (rule._isBareParent) return _NestedDeclarations(rule as NestedStyleRule);
  return _withinStyleRule(rule);
}

/// The contents of a bare `&` rule, rendered without a block of their own.
class _NestedDeclarations implements StyleRule {
  const _NestedDeclarations(this.rule);

  final NestedStyleRule rule;

  @override
  String toCss([String indent = '']) {
    final contents = rule._contentsCss(indent);
    // The grouping rule ends every child it renders with its own separator.
    return contents.endsWith(cssPropSpace) ? contents.substring(0, contents.length - cssPropSpace.length) : contents;
  }
}
