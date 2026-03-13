import 'dart:async';

import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '../daemon/daemon.dart';
import '../daemon/domain.dart';
import '../html_spec.dart';
import '../logging.dart';

class HtmlDomain extends Domain {
  HtmlDomain(Daemon daemon, this.logger) : super(daemon, 'html') {
    registerHandler('convert', convertHtml);
    registerHandler('lookupTag', lookupTag);
  }

  final Logger logger;

  Future<String> convertHtml(Map<String, Object?> params) async {
    final html = params['html'] as String;
    final query = params['query'] as String?;
    final parsed = parse(html);

    List<Node> nodes = parsed.nodes;

    if (query != null) {
      nodes = parsed.querySelectorAll(query);
    }

    if (nodes.length == 1) {
      return _convertNode(nodes.first, '').trimLeft();
    }

    return '.fragment([\n${nodes.map((node) => _convertNode(node, '  ')).where((c) => c.trim().isNotEmpty).join(',\n')}\n])';
  }

  Future<String> lookupTag(Map<String, Object?> params) async {
    final tag = params['tag'] as String;
    final spec = elementSpecs[tag] as Map<String, Object?>?;
    if (spec == null) {
      return 'No component found for tag $tag.';
    }

    final attributes = spec['attributes'] as Map<String, Object?>? ?? {};
    final selfClosing = spec['self_closing'] == true;

    final description = spec['doc'] as String? ?? '';

    var signature = '';
    if (description.isNotEmpty) {
      signature += '/// ${description.split('\n').join('\n/// ')}\n';
    }
    signature += 'const $tag(';

    if (!selfClosing) {
      signature += '\n  List<Component> children, {\n';
    } else {
      signature += '{\n';
    }

    for (final attr in attributes.keys) {
      final attribute = attributes[attr] as Map<String, Object?>;
      final name = attribute['name'] as String? ?? attr;
      final type = attribute['type'];
      final required = attribute['required'] == true;
      final explicitBool = attribute['explicit'] == true;
      final docs = (attribute['doc'] as String).split('\n');

      signature += '  /// ${docs.join('\n  /// ')}\n';

      final isNullable = !required && (type != 'boolean' || explicitBool);
      final nullSuffix = isNullable ? '?' : '';

      String valuesHint = '';

      signature += '  ';

      if (required) {
        signature += 'required ';
      }
      if (type == 'string') {
        signature += 'String';
      } else if (type == 'boolean') {
        signature += 'bool';
      } else if (type == 'int') {
        signature += 'int';
      } else if (type == 'double') {
        signature += 'double';
      } else if (type is String && type.startsWith('enum:')) {
        final name = type.split(':')[1];
        signature += name;

        final enumSpec = htmlSpec['enums']![name] as Map<String, Object?>;
        final values = (enumSpec['values'] as Map<String, Object?>).keys;
        valuesHint = ' // One of ${values.map((v) => '`.$v`').join(', ')}';
      } else if (type is String && type.startsWith('event:')) {
        final [_, name, tt] = type.split(':');
        signature += tt;
      } else if (type is String && type.startsWith('css:')) {
        final [_, name] = type.split(':');
        signature += name;
      } else if (type == 'content') {
        signature += 'String';
      }

      signature += '$nullSuffix $name';

      if (type == 'boolean' && !required && !explicitBool) {
        signature += ' = false';
      }

      signature += ',$valuesHint\n';
    }

    signature += '  String? id,\n';
    signature += '  String? classes,\n';
    signature += '  Styles? styles,\n';
    signature += '  Map<String, String>? attributes,\n';
    signature += '  Map<String, void Function(Event)>? events,\n';
    signature += '  Key? key,\n';

    signature += '});';

    return signature;
  }

  String _convertNode(Node? node, String indent) {
    if (node == null) {
      return '';
    }
    if (node is Text) {
      final text = node.text;
      if (text.trim().isEmpty) {
        return '';
      }
      return '$indent.text(${_escapeString(text)})';
    } else if (node is Element) {
      final tagName = node.localName;
      final attrs = node.attributes;
      final children = node.nodes;

      final spec = elementSpecs[tagName] as Map<String, Object?>?;

      if (spec == null) {
        final attrsString = attrs.isEmpty
            ? ''
            : ', attributes: {${attrs.entries.map((e) => "'${e.key}': ${_escapeString(e.value)}").join(', ')}}';

        final childrenString = children.isEmpty
            ? ''
            : ', children: [\n${children.map((c) => _convertNode(c, '$indent  ')).where((c) => c.trim().isNotEmpty).join(',\n')}\n$indent]';

        return '${indent}Component.element(tag: \'$tagName\'$attrsString$childrenString)';
      }

      final specAttributes = spec['attributes'] as Map<String, Object?>?;

      String? idString;
      String? classString;
      final paramStrings = <String>[];
      final attrStrings = <String>[];

      for (final MapEntry(:key, :value) in attrs.entries) {
        if (key == 'class') {
          classString = value;
        } else if (key == 'id') {
          idString = value;
        } else {
          if (specAttributes?[key] case final Map<String, Object?> attrSpec) {
            final attrName = (attrSpec['name'] ?? key) as String;
            final attrType = attrSpec['type'] as String;

            if (attrType == 'string') {
              paramStrings.add('$attrName: ${_escapeString(value)}');
              continue;
            }
            if (attrType == 'boolean') {
              paramStrings.add('$attrName: true');
              continue;
            }
            if (attrType.startsWith('enum:')) {
              final enumName = attrType.substring(5);
              final enumSpec = htmlSpec['enums']![enumName] as Map<String, Object?>;

              final enumValue = (enumSpec['values'] as Map<String, Object?>).entries
                  .where(
                    (e) => ((e.value as Map<String, Object?>?)?['value'] ?? e.key) == value,
                  )
                  .firstOrNull;
              if (enumValue != null) {
                paramStrings.add('$attrName: $enumName.${enumValue.key}');
                continue;
              }
            }
          }
          attrStrings.add("'$key': ${_escapeString(value)}");
        }
      }

      var result = '$indent${spec['name']}(';

      if (idString != null) {
        result += 'id: ${_escapeString(idString)}, ';
      }

      if (classString != null) {
        result += 'classes: ${_escapeString(classString)}, ';
      }

      if (paramStrings.isNotEmpty) {
        for (final param in paramStrings) {
          result += '$param, ';
        }
      }

      if (attrStrings.isNotEmpty) {
        result += 'attributes: {';
        var isFirst = true;
        for (final attrString in attrStrings) {
          if (!isFirst) {
            result += ', ';
          }
          isFirst = false;
          result += attrString;
        }
        result += '}, ';
      }

      final contentParam = specAttributes?.entries
          .map((e) => (key: e.key, value: e.value as Map<String, Object?>))
          .where((e) => e.value['type'] == 'content')
          .firstOrNull;

      if (contentParam != null && children.isNotEmpty) {
        final contentParamName = contentParam.value['name'] as String? ?? contentParam.key;
        result += '$contentParamName: ${_escapeString(node.innerHtml)}';
      }

      if (contentParam == null && spec['self_closing'] != true) {
        if (children.isEmpty) {
          result += '[]';
        } else {
          result += '[\n';
          for (final child in children) {
            final childHtml = _convertNode(child, '$indent  ');
            if (childHtml.trim().isEmpty) {
              continue;
            }
            result += '$childHtml,\n';
          }
          result += '$indent]';
        }
      } else {
        if (result.endsWith(', ')) {
          result = result.substring(0, result.length - 2);
        }
      }

      result += ')';

      return result;
    } else if (node is Comment) {
      final data = node.data?.trimLeft();
      if (data == null || data.isEmpty) {
        return '';
      }
      return '$indent// $data';
    } else {
      return '';
    }
  }

  String _escapeString(String input) {
    final isMultiLine = input.contains('\n');
    var escaped = input.replaceAll(r'\', r'\\').replaceAll(r'$', r'\$');
    if (isMultiLine) {
      escaped = escaped.replaceAll("'''", r"\'\'\'");
      return "'''$escaped'''";
    } else {
      escaped = escaped.replaceAll("'", r"\'");
      return "'$escaped'";
    }
  }
}

final elementSpecs = (() {
  final config = <String, Object?>{};
  for (final group in htmlSpec['tags']!.values) {
    for (final entry in group.entries) {
      final name = entry.key;
      final data = entry.value as Map<String, Object?>;
      final tag = data['tag'] as String? ?? name;
      config[tag] = {...data, 'name': name};
    }
  }
  return config;
})();
