import 'dart:convert';
import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

void main() {
  final specFile = File('tool/data/html.json');
  final specJson = jsonDecode(specFile.readAsStringSync()) as Map<String, dynamic>;

  final cliSpecFile = File('../jaspr_cli/lib/src/html_spec.dart');

  cliSpecFile.writeAsString('''
// GENERATED FILE - DO NOT EDIT
// Generated from packages/jaspr/tool/generate_html.dart
//
// dart format off

const htmlSpec = ${const JsonEncoder.withIndent('  ').convert(specJson)};
''');

  final allTags = <String>{};

  for (final key in specJson.keys) {
    final group = specJson[key] as Map<String, dynamic>;
    final file = File('lib/src/components/html/$key.dart');

    final library = Library((l) {
      l.directives.add(Directive.partOf('html.dart'));

      final schemas = <String, Map<String, dynamic>>{};

      for (final tag in group.keys) {
        final data = group[tag] as Map<String, dynamic>;
        if (tag.startsWith(':')) {
          schemas[tag.substring(1)] = data;
          continue;
        }

        allTags.add(tag);

        final attrs = data['attributes'] as Map<String, dynamic>? ?? {};

        final inherit = data['inherit'];
        if (inherit != null) {
          attrs.addAll(schemas[inherit]!);
        }

        l.body.add(
          Class((c) {
            c.name = tag;
            c.extend = refer('StatelessComponent');

            final docs = (data['doc'] as String).split('\n').map((d) => '/// $d');
            c.docs.addAll([
              '/// {@template jaspr.html.$tag}',
              ...docs,
              '/// {@endtemplate}',
            ]);

            final selfClosing = data['self_closing'] == true;

            final events = <String>{};
            String? contentParam;

            c.constructors.add(
              Constructor((ctor) {
                ctor.constant = true;
                ctor.docs.addAll([
                  '/// {@macro jaspr.html.$tag}',
                ]);

                if (!selfClosing) {
                  ctor.requiredParameters.add(
                    Parameter((p) {
                      p.name = 'children';
                      p.toThis = true;
                    }),
                  );
                }

                for (final attr in attrs.keys) {
                  final name = attrs[attr]['name'] ?? attr;
                  final type = attrs[attr]['type'];

                  if (type == null) {
                    throw ArgumentError('Attribute type is required for attribute $key.$tag.$attr');
                  }
                  final required = attrs[attr]['required'] == true;

                  final parameter = Parameter((p) {
                    p.name = name;
                    p.named = true;
                    p.toThis = true;
                    p.required = required;
                  });

                  ctor.optionalParameters.add(parameter);
                }

                ctor.optionalParameters.addAll([
                  Parameter((p) {
                    p.name = 'id';
                    p.named = true;
                    p.toThis = true;
                  }),
                  Parameter((p) {
                    p.name = 'classes';
                    p.named = true;
                    p.toThis = true;
                  }),
                  Parameter((p) {
                    p.name = 'styles';
                    p.named = true;
                    p.toThis = true;
                  }),
                  Parameter((p) {
                    p.name = 'attributes';
                    p.named = true;
                    p.toThis = true;
                  }),
                  Parameter((p) {
                    p.name = 'events';
                    p.named = true;
                    p.toThis = true;
                  }),
                  Parameter((p) {
                    p.name = 'key';
                    p.named = true;
                    p.toSuper = true;
                  }),
                ]);
              }),
            );

            for (final attr in attrs.keys) {
              final name = attrs[attr]['name'] ?? attr;
              final type = attrs[attr]['type'];

              if (type == null) {
                throw ArgumentError('Attribute type is required for attribute $key.$tag.$attr');
              }

              final required = attrs[attr]['required'] == true;
              final docs = (attrs[attr]['doc'] as String).split('\n');

              c.fields.add(
                Field((f) {
                  f.name = name;
                  f.modifier = FieldModifier.final$;

                  f.docs.addAll(docs.map((d) => '/// $d'));

                  f.type = TypeReference((t) {
                    if (type == 'string') {
                      t.symbol = 'String';
                    } else if (type == 'boolean') {
                      t.symbol = 'bool';
                    } else if (type == 'int') {
                      t.symbol = 'int';
                    } else if (type == 'double') {
                      t.symbol = 'double';
                    } else if (type is String && type.startsWith('enum:')) {
                      var name = type.split(':')[1];
                      t.symbol = name;
                    } else if (type is String && type.startsWith('event:')) {
                      var [_, name, tt] = type.split(':');
                      events.add(name);
                      t.symbol = tt;
                    } else if (type is String && type.startsWith('css:')) {
                      var [_, name] = type.split(':');
                      t.symbol = name;
                    } else if (type is Map<String, dynamic>) {
                      var name = type['name'];
                      t.symbol = name;
                    } else if (type == 'content') {
                      t.symbol = 'String';
                      contentParam = name;
                    } else {
                      throw ArgumentError('Attribute type is unknown ($type) for attribute $key.$tag.$attr');
                    }

                    t.isNullable = !required;
                  });
                }),
              );
            }

            c.fields.addAll([
              Field((f) {
                f.name = 'id';
                f.modifier = FieldModifier.final$;
                f.type = refer('String?');
                f.docs.add('/// The id of the HTML element. Must be unique within the document.');
              }),
              Field((f) {
                f.name = 'classes';
                f.modifier = FieldModifier.final$;
                f.type = refer('String?');
                f.docs.add('/// The CSS classes to apply to the HTML element, separated by whitespace.');
              }),
              Field((f) {
                f.name = 'styles';
                f.modifier = FieldModifier.final$;
                f.type = refer('Styles?');
                f.docs.add('/// The inline styles to apply to the HTML element.');
              }),
              Field((f) {
                f.name = 'attributes';
                f.modifier = FieldModifier.final$;
                f.type = refer('Map<String, String>?');
                f.docs.add('/// Additional attributes to apply to the HTML element.');
              }),
              Field((f) {
                f.name = 'events';
                f.modifier = FieldModifier.final$;
                f.type = refer('Map<String, EventCallback>?');
                f.docs.add('/// Event listeners to attach to the HTML element.');
              }),
            ]);

            if (!selfClosing) {
              c.fields.add(
                Field((f) {
                  f.name = 'children';
                  f.type = refer('List<Component>');
                  f.modifier = FieldModifier.final$;
                  f.docs.add('/// The children of this component.');
                }),
              );
            }

            c.methods.add(
              Method((m) {
                m.name = 'build';
                m.annotations.add(refer('override'));
                m.returns = refer('Component');
                m.requiredParameters.add(
                  Parameter((p) {
                    p.name = 'context';
                    p.type = refer('BuildContext');
                  }),
                );

                // Forced tag name
                final tagValue = data["tag"] ?? tag;

                final content = StringBuffer();

                content.write(
                  'return Component.element(\n'
                  '    tag: \'$tagValue\',\n'
                  '    id: id,\n'
                  '    classes: classes,\n'
                  '    styles: styles,\n'
                  '    attributes: ',
                );

                if (attrs.isNotEmpty) {
                  content.write(
                    '{\n'
                    '      ...?attributes,\n',
                  );

                  for (var attr in attrs.keys) {
                    var name = attrs[attr]['name'] ?? attr;
                    var type = attrs[attr]['type'];

                    if (type is String && (type.startsWith('event:') || type == 'content')) continue;

                    content.write('      ');

                    var required = attrs[attr]['required'] == true;

                    if (type == 'boolean') {
                      if (attrs[attr]['explicit'] == true) {
                        content.write('if ($name case final $name?) ');
                      } else {
                        content.write('if ($name == true) ');
                      }
                    }

                    content.write("'$attr': ");

                    var nullCheck = !required && type != 'boolean' ? '?' : '';

                    if (type == 'string') {
                      content.write('$nullCheck$name');
                    } else if (type == 'boolean') {
                      if (attrs[attr]['explicit'] == true) {
                        content.write("$name ? 'true' : 'false'");
                      } else {
                        content.write("''");
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
                  content.write('    children: [if ($contentParam case final $contentParam?) raw($contentParam)],\n');
                }

                content.writeln('  );');

                m.body = Code(content.toString());
              }),
            );
          }),
        );

        for (var attr in attrs.keys) {
          var type = attrs[attr]['type'];

          if (type is Map<String, dynamic>) {
            if (type['values'] != null) {
              var name = type['name'] as String;
              var values = type['values'] as Map<String, dynamic>;

              l.body.add(
                Enum((e) {
                  e.name = name;
                  e.docs.addAll((type['doc'] as String).split('\n').map((d) => '/// $d'));

                  for (var name in values.keys) {
                    var value = values[name]['value'] ?? name;

                    e.values.add(
                      EnumValue((ev) {
                        ev.name = name;
                        ev.docs.addAll((values[name]['doc'] as String).split('\n').map((d) => '/// $d'));
                        ev.arguments.add(literalString(value));
                      }),
                    );
                  }

                  e.constructors.add(
                    Constructor((c) {
                      c.constant = true;
                      c.requiredParameters.add(
                        Parameter((p) {
                          p.name = 'value';
                          p.toThis = true;
                        }),
                      );
                    }),
                  );

                  e.fields.add(
                    Field((f) {
                      f.name = 'value';
                      f.modifier = FieldModifier.final$;
                      f.type = refer('String');
                    }),
                  );
                }),
              );
            }
          }
        }
      }
    });

    final formatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);
    final header =
        '// GENERATED FILE - DO NOT EDIT\n'
        '// Generated from packages/jaspr/tool/generate_html.dart\n'
        '//\n'
        '// dart format off\n'
        '// ignore_for_file: camel_case_types\n';

    file.writeAsStringSync(
      '$header\n${formatter.format(library.accept(DartEmitter(useNullSafetySyntax: true)).toString())}',
    );
  }

  var lintFile = File('../jaspr_lints/lib/src/all_html_tags.dart');
  lintFile.writeAsStringSync(
    '// GENERATED FILE - DO NOT EDIT\n'
    '// Generated from packages/jaspr/tool/generate_html.dart\n'
    '//\n'
    '// dart format off\n\n'
    'const allHtmlTags = {${allTags.map((t) => "'$t'").join(', ')}};\n',
  );
}
