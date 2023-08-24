import 'dart:convert';
import 'dart:io';

void main() {
  var specFile = File('tool/data/html.json');
  var specJson = jsonDecode(specFile.readAsStringSync()) as Map<String, dynamic>;

  for (var key in specJson.keys) {
    var group = specJson[key] as Map<String, dynamic>;
    var file = File('lib/src/ui/html/$key.dart');
    var content = StringBuffer("part of jaspr_html;\n");

    for (var tag in group.keys) {
      var data = group[tag] as Map<String, dynamic>;
      var attrs = data['attributes'] as Map<String, dynamic>?;

      content.write('\n${data['doc'].split('\n').map((t) => '/// $t\n').join()}');

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

      content.write(
          'Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {\n'
          '  return DomComponent(\n'
          '    tag: \'$tag\',\n'
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

      content.write(''
          '    events: events,\n');

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
}
