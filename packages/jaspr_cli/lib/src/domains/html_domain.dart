import 'dart:async';

import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '../helpers/daemon_helper.dart';
import '../html_spec.dart';
import '../logging.dart';

class HtmlDomain extends Domain {
  HtmlDomain(Daemon daemon, this.logger) : super(daemon, 'html') {
    registerHandler('convert', _convertHtml);
  }

  final Logger logger;

  Future<String> _convertHtml(Map<String, dynamic> params) async {
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

      var spec = elementSpecs[tagName];

      if (spec == null) {
        final attrsString = attrs.isEmpty
            ? ''
            : ', attributes: {${attrs.entries.map((e) => "'${e.key}': ${_escapeString(e.value)}").join(', ')}}';

        final childrenString = children.isEmpty
            ? ''
            : ', children: [\n${children.map((c) => _convertNode(c, '$indent  ')).where((c) => c.trim().isNotEmpty).join(',\n')}\n$indent]';

        return '${indent}Component.element(tag: \'$tagName\'$attrsString$childrenString)';
      }

      String? idString;
      String? classString;
      String? contentParam;
      var paramStrings = <String>[];
      var attrStrings = <String>[];

      for (final MapEntry(:key, :value) in attrs.entries) {
        if (key == 'class') {
          classString = value;
        } else if (key == 'id') {
          idString = value;
        } else {
          if (spec?['attributes']?[key] case final attrSpec?) {
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
            if (attrType == 'content') {
              contentParam = attrName;
              continue;
            }
            if (attrType is String && attrType.startsWith('enum:')) {
              final enumName = attrType.substring(5);
              attrType = enumSpecs[enumName];
            }
            if (attrType case {'name': String enumName, 'values': Map<String, dynamic> enumValues}) {
              final enumValue = enumValues.entries
                  .where(
                    (e) => (e.value['value'] ?? e.key) == value,
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

      if (contentParam != null && children.isNotEmpty) {
        result += '$contentParam: ${_escapeString(node.innerHtml)}';
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
  final config = <String, dynamic>{};
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
  final enums = <String, Map<String, dynamic>>{};
  for (final element in elementSpecs.values) {
    final attrs = element['attributes'] as Map<String, dynamic>?;
    if (attrs != null) {
      for (final attr in attrs.values) {
        final type = attr['type'];
        if (type case <String, dynamic>{'name': String _, 'values': Map<String, dynamic> _}) {
          enums[type['name'] as String] = type;
        }
      }
    }
  }
  return enums;
})();
