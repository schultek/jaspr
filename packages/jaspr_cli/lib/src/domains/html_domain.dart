import 'dart:async';

import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '../helpers/daemon_helper.dart';
import '../html_spec.dart';
import '../logging.dart';

class HtmlDomain extends Domain {
  HtmlDomain(Daemon daemon, this.logger) : super(daemon, 'html') {
    registerHandler('convert', convertHtml);
  }

  final Logger logger;

  Future<String> convertHtml(Map<String, Object?> params) async {
    final html = params['html'] as String;
    final parsed = parseFragment(html);

    return _convertNode(parsed.firstChild, '').trimLeft();
  }

  String _convertNode(Node? node, String indent) {
    if (node == null) {
      return '';
    }
    if (node is Text) {
      var text = node.text;
      if (text.trim().isEmpty) {
        return '';
      }
      return "${indent}text(${_escapeString(text)})";
    } else if (node is Element) {
      var tagName = node.localName;
      var attrs = node.attributes;
      var children = node.nodes;

      var spec = elementSpecs[tagName] as Map<String, Object?>?;

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
      var paramStrings = <String>[];
      var attrStrings = <String>[];

      for (final MapEntry(:key, :value) in attrs.entries) {
        if (key == 'class') {
          classString = value;
        } else if (key == 'id') {
          idString = value;
        } else {
          if (specAttributes?[key] case final Map<String, Object?> attrSpec) {
            final attrName = (attrSpec['name'] ?? key) as String;
            var attrType = attrSpec['type'];

            if (attrType == 'string') {
              paramStrings.add("$attrName: ${_escapeString(value)}");
              continue;
            }
            if (attrType == 'boolean') {
              paramStrings.add('$attrName: true');
              continue;
            }
            if (attrType is String && attrType.startsWith('enum:')) {
              final enumName = attrType.substring(5);
              attrType = enumSpecs[enumName];
            }
            if (attrType case {'name': String enumName, 'values': Map<String, Object?> enumValues}) {
              final enumValue = enumValues.entries
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
        result += "id: ${_escapeString(idString)}, ";
      }

      if (classString != null) {
        result += "classes: ${_escapeString(classString)}, ";
      }

      if (paramStrings.isNotEmpty) {
        for (var param in paramStrings) {
          result += '$param, ';
        }
      }

      if (attrStrings.isNotEmpty) {
        result += 'attributes: {';
        var isFirst = true;
        for (var attrString in attrStrings) {
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
          for (var child in children) {
            var childHtml = _convertNode(child, '$indent  ');
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
  for (final group in htmlSpec.values) {
    for (final entry in group.entries) {
      final name = entry.key;
      final data = entry.value;
      final tag = data['tag'] as String? ?? name;
      config[tag] = {...data, 'name': name};
    }
  }
  return config;
})();

final enumSpecs = (() {
  final enums = <String, Map<String, Object?>>{};
  for (final element in elementSpecs.values.cast<Map<String, Object?>>()) {
    if (element['attributes'] case final Map<String, Object?> attrs) {
      for (final attr in attrs.values.cast<Map<String, Object?>>()) {
        if (attr['type'] case <String, Object?>{'name': String _, 'values': Map<String, Object?> type}) {
          enums[type['name'] as String] = type;
        }
      }
    }
  }
  return enums;
})();
