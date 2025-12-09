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
    return NestedStyleRule._(Selector(selector), Styles(), children);
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

class NestedStyleRule with StylesMixin<NestedStyleRule> implements StyleRule {
  NestedStyleRule._(this._selector, this._styles, this._children);

  final Selector _selector;
  final Styles _styles;
  final List<StyleRule> _children;

  @override
  NestedStyleRule combine(Styles styles) {
    return NestedStyleRule._(_selector, _styles.combine(styles), _children);
  }

  @override
  String toCss([String indent = '']) {
    final rules = <String>[];

    for (final rule in resolve('')) {
      rules.add(rule.toCss(indent));
    }

    return rules.join(cssPropSpace);
  }
}

extension SelectorResolve on Selector {
  Selector resolve(String parent) {
    return Selector(
      selector.startsWith('&') || parent.isEmpty ? selector.replaceAll('&', parent) : '$parent $selector',
    );
  }
}

extension StyleRuleResolve on StyleRule {
  List<StyleRule> resolve(String parent) {
    final self = this;
    return switch (self) {
      NestedStyleRule() => self._resolve(parent),
      BlockStyleRule() => [self._resolve(parent)],
      MediaStyleRule() => [self._resolve(parent)],
      LayerStyleRule() => [self._resolve(parent)],
      SupportsStyleRule() => [self._resolve(parent)],
      _ => throw UnsupportedError('Cannot nest ${self.runtimeType} inside other StyleRule.'),
    };
  }
}

extension on NestedStyleRule {
  List<StyleRule> _resolve(String parent) {
    final rules = <StyleRule>[];

    final selector = _selector.resolve(parent);

    if (_styles.properties.isNotEmpty) {
      rules.add(StyleRule(selector: selector, styles: _styles));
    }

    for (final child in _children) {
      rules.addAll(child.resolve(selector.selector));
    }

    return rules;
  }
}

extension on BlockStyleRule {
  StyleRule _resolve(String parent) {
    return BlockStyleRule(selector: selector.resolve(parent), styles: styles);
  }
}

extension on MediaStyleRule {
  StyleRule _resolve(String parent) {
    return MediaStyleRule(query: query, styles: [for (final style in styles) ...style.resolve(parent)]);
  }
}

extension on LayerStyleRule {
  StyleRule _resolve(String parent) {
    return LayerStyleRule(name: name, styles: [for (final style in styles) ...style.resolve(parent)]);
  }
}

extension on SupportsStyleRule {
  StyleRule _resolve(String parent) {
    return SupportsStyleRule(condition: condition, styles: [for (final style in styles) ...style.resolve(parent)]);
  }
}
