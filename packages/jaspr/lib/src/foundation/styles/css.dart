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
///   css('.someclass').box(width: 100.px)
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
///   css('.someclass')
///     .box(width: 100.px)
///     .text(color: Colors.black)
///   ```
///
/// - Provide a second parameter to define nested rules. Use '&' to refer to the parent selector.
///   ```dart
///   css('.someclass', [
///     css('&').box(width: 100.px),
///     css('&:hover').background(color: Colors.blue),
///   ])
///   ```
///
/// - Use special rule variants:
///   ```dart
///   css.import('/some/external/styles.css');
///   css.fontFace(fontFamily: 'SomeFont', url: '/some/font.ttf');
///   css.media(MediaQuery.screen(minWidth: 800.px), [
///     css('.someclass').box(width: 200.px),
///   ]);
///   ```
const css = CssUtility._();

class CssUtility {
  const CssUtility._();

  NestedStyleRule call(String selector, [List<StyleRule> children = const []]) {
    return NestedStyleRule._(Selector(selector), Styles(), children);
  }

  ImportStyleRule import(String url) {
    return ImportStyleRule(url);
  }

  FontFaceStyleRule fontFace({required String fontFamily, FontStyle? fontStyle, required String url}) {
    return FontFaceStyleRule(fontFamily: fontFamily, fontStyle: fontStyle, url: url);
  }

  MediaStyleRule media(MediaQuery query, List<StyleRule> styles) {
    return MediaStyleRule(query: query, styles: styles);
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

    if (_self.styles.styles.isNotEmpty) {
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
