import '../../../dom.dart';
import '../../../jaspr.dart';

class ElementPropertiesTooltip extends StatelessComponent {
  const ElementPropertiesTooltip(this.properties, {super.key});

  final List<DiagnosticsProperty> properties;

  @override
  Component build(BuildContext context) {
    return div(classes: 'jaspr-dev-properties-tooltip', [
      div(classes: 'jaspr-dev-properties-tooltip-content', [
        pre([
          code([
            _buildJsonValue(_propsToValue(properties)),
          ]),
        ]),
      ]),
    ]);
  }

  Object? _propsToValue(List<DiagnosticsProperty>? properties) {
    if (properties == null) return null;
    return {
      for (final p in properties) p.name: p.value ?? _propsToValue(p.properties),
    };
  }

  int _getJsonLength(Object? value) {
    if (value is String) return value.length + 2;
    if (value is num || value is bool || value == null) return value.toString().length;
    if (value is Map) {
      if (value.isEmpty) return 2;
      var len = 4; // "{  }"
      for (final e in value.entries) {
        len += e.key.toString().length + 4 + _getJsonLength(e.value);
      }
      len += (value.length - 1) * 2;
      return len;
    }
    if (value is Iterable) {
      if (value.isEmpty) return 2;
      var len = 4; // "[  ]"
      for (final e in value) {
        len += _getJsonLength(e);
      }
      len += (value.length - 1) * 2;
      return len;
    }
    return value.toString().length + 2;
  }

  Component _buildJsonValue(Object? value, [int indent = 0]) {
    final indentStr = '  ' * indent;
    if (value is String) {
      return span(classes: 'json-string', [Component.text('"$value"')]);
    } else if (value is num || value is bool || value == null) {
      return span(classes: 'json-literal', [Component.text(value.toString())]);
    } else if (value is Map) {
      if (value.isEmpty) return Component.text('{}');

      final isMultiline = _getJsonLength(value) > 20;
      final components = <Component>[];
      components.add(Component.text(isMultiline ? '{\n' : '{ '));

      var i = 0;
      for (final entry in value.entries) {
        if (isMultiline) components.add(Component.text('$indentStr  '));
        components.add(span(classes: 'json-key', [Component.text('"${entry.key}"')]));
        components.add(Component.text(': '));
        components.add(_buildJsonValue(entry.value, isMultiline ? indent + 1 : indent));
        if (i < value.length - 1) components.add(Component.text(isMultiline ? ',\n' : ', '));
        i++;
      }
      if (isMultiline) {
        components.add(Component.text('\n$indentStr}'));
      } else {
        components.add(Component.text(' }'));
      }
      return fragment(components);
    } else if (value is Iterable) {
      if (value.isEmpty) return Component.text('[]');

      final isMultiline = _getJsonLength(value) > 80;
      final components = <Component>[];
      components.add(Component.text(isMultiline ? '[\n' : '[ '));

      var i = 0;
      for (final item in value) {
        if (isMultiline) components.add(Component.text('$indentStr  '));
        components.add(_buildJsonValue(item, isMultiline ? indent + 1 : indent));
        if (i < value.length - 1) components.add(Component.text(isMultiline ? ',\n' : ', '));
        i++;
      }
      if (isMultiline) {
        components.add(Component.text('\n$indentStr]'));
      } else {
        components.add(Component.text(' ]'));
      }
      return fragment(components);
    }
    return span(classes: 'json-string', [Component.text('"${value.toString()}"')]);
  }

  static List<StyleRule> get styles => [
    css('.jaspr-dev-properties-tooltip', [
      css('&').styles(
        display: Display.flex,
        flexDirection: FlexDirection.column,
        padding: Padding.all(8.px),
        gap: Gap.all(8.px),
        fontSize: 14.px,
        color: Colors.white,
      ),
      css('.jaspr-dev-properties-tooltip-content', [
        css('&').styles(
          margin: Margin.zero,
          padding: Padding.all(8.px),
          backgroundColor: Color('rgba(0, 0, 0, 0.4)'),
          radius: BorderRadius.circular(4.px),
          overflow: Overflow.auto,
        ),
        css('& pre, & code').styles(
          all: All.unset,
          whiteSpace: WhiteSpace.pre,
          margin: Margin.zero,
          fontFamily: FontFamilies.monospace,
          fontSize: 12.px,
          lineHeight: 1.4.em,
        ),
        css('.json-key').styles(color: Color('#9cdcfe')),
        css('.json-string').styles(color: Color('#ce9178')),
        css('.json-literal').styles(color: Color('#b5cea8')),
      ]),
    ]),
  ];
}
