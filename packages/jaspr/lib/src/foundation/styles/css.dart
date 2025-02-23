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
  ImportStyleRule import(String url) {
    return ImportStyleRule(url);
  }

  /// Renders a `@font-face` css rule.
  FontFaceStyleRule fontFace({required String family, FontStyle? style, required String url}) {
    return FontFaceStyleRule(family: family, style: style, url: url);
  }

  /// Renders a `@media` css rule.
  MediaStyleRule media(MediaQuery query, List<StyleRule> styles) {
    return MediaStyleRule(query: query, styles: styles);
  }

  /// Renders a `@layer` css rule.
  LayerStyleRule layer(List<StyleRule> styles, {String? name}) {
    return LayerStyleRule(name: name, styles: styles);
  }

  /// Renders a `@supports` css rule.
  SupportsStyleRule supports(String condition, List<StyleRule> styles) {
    return SupportsStyleRule(condition: condition, styles: styles);
  }

  /// Renders a `@keyframes` css rule.
  KeyframesStyleRule keyframes(String name, Map<String, Styles> styles) {
    return KeyframesStyleRule(name: name, styles: styles);
  }
}

class NestedStyleRule with StylesMixin<NestedStyleRule> implements StyleRule {
  NestedStyleRule._(Selector selector, Styles styles, this._children)
      : _self = BlockStyleRule(selector: selector, styles: styles);

  final BlockStyleRule _self;
  final List<StyleRule> _children;

  @override
  NestedStyleRule combine(Styles styles) {
    return NestedStyleRule._(_self.selector, _self.styles.combine(styles), _children);
  }

  @override
  String toCss([String indent = '', String parent = '']) {
    var rules = <String>[];

    var self = _self;
    var curr = self.selector.selector.startsWith('&') || parent.isEmpty
        ? self.selector.selector.replaceAll('&', parent)
        : '$parent ${self.selector.selector}';

    if (_self.styles.properties.isNotEmpty) {
      rules.add(_self._toCssWithParent(indent, parent));
    }

    for (var child in _children) {
      if (child is NestedStyleRule) {
        rules.add(child.toCss(indent, curr));
      } else if (child is BlockStyleRule) {
        rules.add(child._toCssWithParent(indent, curr));
      } else {
        throw UnsupportedError('Cannot nest ${child.runtimeType} inside other StyleRule.');
      }
    }

    return rules.join(cssPropSpace);
  }
}

extension on BlockStyleRule {
  String _toCssWithParent(String indent, String parent) {
    var child = BlockStyleRule(
      selector: Selector(selector.selector.startsWith('&') || parent.isEmpty
          ? selector.selector.replaceAll('&', parent)
          : '$parent ${selector.selector}'),
      styles: styles,
    );
    return child.toCss(indent);
  }
}
