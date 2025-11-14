// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';

void main() {
  final specFile = File('tool/data/html.json');
  final specJson = jsonDecode(specFile.readAsStringSync()) as Map<String, dynamic>;

  final cliSpecFile = File('../jaspr_cli/lib/src/html_spec.dart');

  cliSpecFile.writeAsString('''
// GENERATED FILE - DO NOT EDIT
// Generated from packages/jaspr/tool/generate_html.dart

const htmlSpec = ${const JsonEncoder.withIndent('  ').convert(specJson)};
''');

  final allTags = <String>{};

  for (final key in specJson.keys) {
    final group = specJson[key] as Map<String, dynamic>;
    final file = File('lib/src/components/html/$key.dart');
    final content = StringBuffer("part of 'html.dart';\n");

    final schemas = <String, Map<String, dynamic>>{};

    for (final tag in group.keys) {
      final data = group[tag] as Map<String, dynamic>;
      if (tag.startsWith(':')) {
        schemas[tag.substring(1)] = data;
        continue;
      }

      allTags.add(tag);

      final doc = data['doc'] as String;
      content.write('\n${doc.split('\n').map((t) => '/// $t\n').join()}');

      var attrs = data['attributes'] as Map<String, dynamic>?;

      final inherit = data['inherit'];

      if (inherit != null) {
        (attrs ??= {}).addAll(schemas[inherit]!);
      }

      if (attrs != null) {
        content.writeln('///');
        for (final attr in attrs.keys) {
          final name = attrs[attr]['name'] ?? attr;
          content.writeln('/// - [$name]: ${attrs[attr]['doc'].split('\n').join('\n///   ')}');
        }
      }
      content.write('Component $tag(');

      final selfClosing = data['self_closing'] == true;

      if (!selfClosing) {
        content.write('List<Component> children, ');
      }
      content.write('{');

      final events = <String>{};
      String? contentParam;

      if (attrs != null) {
        for (final attr in attrs.keys) {
          final name = attrs[attr]['name'] ?? attr;
          final type = attrs[attr]['type'];

          if (type == null) {
            throw ArgumentError('Attribute type is required for attribute $key.$tag.$attr');
          }
          final required = attrs[attr]['required'] == true;

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
            final name = type.split(':')[1];
            content.write(name);
          } else if (type is String && type.startsWith('event:')) {
            final [_, name, t] = type.split(':');
            events.add(name);
            content.write(t);
          } else if (type is String && type.startsWith('css:')) {
            final [_, name] = type.split(':');
            content.write(name);
          } else if (type is Map<String, dynamic>) {
            final name = type['name'];
            content.write(name);
          } else if (type == 'content') {
            content.write('String');
            contentParam = name as String;
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
        '  return Component.element(\n'
        '    tag: \'$tagValue\',\n'
        '    key: key,\n'
        '    id: id,\n'
        '    classes: classes,\n'
        '    styles: styles,\n'
        '    attributes: ',
      );

      if (attrs != null) {
        content.write(
          '{\n'
          '      ...?attributes,\n',
        );

        for (final attr in attrs.keys) {
          final name = attrs[attr]['name'] ?? attr;
          final type = attrs[attr]['type'];

          if (type is String && (type.startsWith('event:') || type == 'content')) continue;

          content.write('      ');

          final required = attrs[attr]['required'] == true;
          final explicitBool = attrs[attr]['explicit'] == true;

          if (type == 'boolean' && !explicitBool) {
            content.write('if ($name == true) ');
          }

          content.write("'$attr': ");

          final nullCheck = !required ? '?' : '';

          if (type == 'string') {
            content.write('$nullCheck$name');
          } else if (type == 'boolean') {
            if (!explicitBool) {
              content.write('\'\'');
            } else {
              content.write('?_explicitBool($name)');
            }
          } else if (type == 'int' || type == 'double') {
            content.write("$nullCheck$name$nullCheck.toString()");
          } else if (type is String && type.startsWith('enum:')) {
            content.write('$nullCheck$name$nullCheck.value');
          } else if (type is String && type.startsWith('css:')) {
            content.write('$nullCheck$name$nullCheck.value');
          } else if (type is Map<String, dynamic>) {
            content.write('$nullCheck$name$nullCheck.value');
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
        content.write(
          '{\n'
          '      ...?events,\n'
          '      ..._events(${events.map((e) => '$e: $e').join(', ')}),\n'
          '    },\n',
        );
      } else {
        content.write('events,\n');
      }

      if (!selfClosing) {
        content.write('    children: children,\n');
      } else if (contentParam != null) {
        content.write('    children: [if ($contentParam != null) raw($contentParam)],\n');
      }

      content.writeln(
        '  );\n'
        '}',
      );

      if (attrs != null) {
        for (final attr in attrs.keys) {
          final type = attrs[attr]['type'];

          if (type is Map<String, dynamic>) {
            if (type['values'] != null) {
              final name = type['name'] as String;
              final values = type['values'] as Map<String, dynamic>;
              final doc = type['doc'] as String;

              content.write('\n${doc.split('\n').map((t) => '/// $t\n').join()}');

              content.write('enum $name {\n');

              for (final name in values.keys) {
                final value = values[name]['value'] ?? name;
                content.write('  /// ${values[name]['doc'].split('\n').join('\n  /// ')}\n');
                content.write('  $name(\'$value\')');
                if (values.keys.last != name) {
                  content.write(',\n');
                } else {
                  content.write(';\n');
                }
              }

              content.writeln(
                '\n'
                '  final String value;\n'
                '  const $name(this.value);\n'
                '}',
              );
            }
          }
        }
      }
    }

    file.writeAsStringSync(content.toString());
  }

  final lintFile = File('../jaspr_lints/lib/src/all_html_tags.dart');
  lintFile.writeAsStringSync('const allHtmlTags = {${allTags.map((t) => "'$t'").join(', ')}};\n');
}
