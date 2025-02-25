import 'dart:convert';
import 'dart:io';

void main() {
  var specFile = File('tool/data/html.json');
  var specJson = jsonDecode(specFile.readAsStringSync()) as Map<String, dynamic>;

  var allTags = <String>{};

  for (var key in specJson.keys) {
    var group = specJson[key] as Map<String, dynamic>;
    var file = File('lib/src/components/html/$key.dart');
    var content = StringBuffer("part of 'html.dart';\n");

    var schemas = <String, Map<String, dynamic>>{};

    for (var tag in group.keys) {
      var data = group[tag] as Map<String, dynamic>;
      if (tag.startsWith(':')) {
        schemas[tag.substring(1)] = data;
        continue;
      }

      allTags.add(tag);
      content.write('\n${data['doc'].split('\n').map((t) => '/// $t\n').join()}');

      var attrs = data['attributes'] as Map<String, dynamic>?;

      var inherit = data['inherit'];

      if (inherit != null) {
        (attrs ??= {}).addAll(schemas[inherit]!);
      }

      if (attrs != null) {
        content.writeln('///');
        for (var attr in attrs.keys) {
          var name = attrs[attr]['name'] ?? attr;
          content.writeln('/// - [$name]: ${attrs[attr]['doc'].split('\n').join('\n///   ')}');
        }
      }
      content.write('Component $tag(');

      var selfClosing = data['self_closing'] == true;

      if (!selfClosing) {
        content.write('List<Component> children, ');
      }
      content.write('{');

      var events = <String>{};

      if (attrs != null) {
        for (var attr in attrs.keys) {
          var name = attrs[attr]['name'] ?? attr;
          var type = attrs[attr]['type'];

          if (type == null) {
            throw ArgumentError('Attribute type is required for attribute $key.$tag.$attr');
          }
          var required = attrs[attr]['required'] == true;

          if (required) {
            content.write('required ');
          }

          if (type == 'string') {
            content.write('String');
          } else if (type == 'boolean') {
            content.write('bool');
          } else if (type == 'int') {
            content.write('int');
          } else if (type == 'double') {
            content.write('double');
          } else if (type is String && type.startsWith('enum:')) {
            var name = type.split(':')[1];
            content.write(name);
          } else if (type is String && type.startsWith('event:')) {
            var [_, name, t] = type.split(':');
            events.add(name);
            content.write(t);
          } else if (type is String && type.startsWith('css:')) {
            var [_, name] = type.split(':');
            content.write(name);
          } else if (type is Map<String, dynamic>) {
            var name = type['name'];
            content.write(name);
          } else {
            throw ArgumentError('Attribute type is unknown ($type) for attribute $key.$tag.$attr');
          }

          if (!required) {
            content.write('?');
          }
          content.write(' $name, ');
        }
      }

      // Forced tag name
      final tagValue = data["tag"] ?? tag;

      content.write(
          'Key? key, String? id, String? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {\n'
          '  return DomComponent(\n'
          '    tag: \'$tagValue\',\n'
          '    key: key,\n'
          '    id: id,\n'
          '    classes: classes,\n'
          '    styles: styles,\n'
          '    attributes: ');

      if (attrs != null) {
        content.write('{\n'
            '      ...attributes ?? {},\n');

        for (var attr in attrs.keys) {
          var name = attrs[attr]['name'] ?? attr;
          var type = attrs[attr]['type'];

          if (type is String && type.startsWith('event:')) continue;

          content.write('      ');

          var required = attrs[attr]['required'] == true;

          if (type == 'boolean') {
            content.write('if ($name == true) ');
          } else if (!required) {
            content.write('if ($name != null) ');
          }

          content.write("'$attr': ");

          if (type == 'string') {
            content.write('$name');
          } else if (type == 'boolean') {
            content.write("''");
          } else if (type == 'int' || type == 'double') {
            content.write("'\$$name'");
          } else if (type is String && type.startsWith('enum:')) {
            content.write('$name.value');
          } else if (type is String && type.startsWith('css:')) {
            content.write('$name.value');
          } else if (type is Map<String, dynamic>) {
            content.write('$name.value');
          } else {
            throw ArgumentError('Attribute type is unknown ($type) for attribute $key.$tag.$attr');
          }

          content.write(',\n');
        }

        content.write('    },\n');
      } else {
        content.write('attributes,\n');
      }

      content.write('    events: ');

      if (events.isNotEmpty) {
        content.write('{\n'
            '      ...?events,\n'
            '      ..._events(${events.map((e) => '$e: $e').join(', ')}),\n'
            '    },\n');
      } else {
        content.write('events,\n');
      }

      if (!selfClosing) {
        content.write('    children: children,\n');
      }

      content.writeln('  );\n'
          '}');

      if (attrs != null) {
        for (var attr in attrs.keys) {
          var type = attrs[attr]['type'];

          if (type is Map<String, dynamic>) {
            if (type['values'] != null) {
              var name = type['name'] as String;
              var values = type['values'] as Map<String, dynamic>;

              content.write('\n${type['doc'].split('\n').map((t) => '/// $t\n').join()}');

              content.write('enum $name {\n');

              for (var name in values.keys) {
                var value = values[name]['value'] ?? name;
                content.write('  /// ${values[name]['doc'].split('\n').join('\n  /// ')}\n');
                content.write('  $name(\'$value\')');
                if (values.keys.last != name) {
                  content.write(',\n');
                } else {
                  content.write(';\n');
                }
              }

              content.writeln('\n'
                  '  final String value;\n'
                  '  const $name(this.value);\n'
                  '}');
            }
          }
        }
      }
    }

    file.writeAsStringSync(content.toString());
  }

  var lintFile = File('../jaspr_lints/lib/src/all_html_tags.dart');
  lintFile.writeAsStringSync('const allHtmlTags = {${allTags.map((t) => "'$t'").join(', ')}};\n');
}
