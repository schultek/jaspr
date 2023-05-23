import 'dart:convert';

import '../foundation/constants.dart';
import '../framework/framework.dart';

class DomNodeData {
  String? tag;
  String? id;
  List<String>? classes;
  Map<String, String>? styles;
  Map<String, String>? attributes;
  String? text;
  bool? rawHtml;
  List<RenderElement> children = [];
}

extension DomNodeDataExt on RenderElement {
  DomNodeData get data => getData() ?? setData(DomNodeData());
}

class MarkupDomRenderer extends Renderer {
  RenderElement? root;

  @override
  void renderNode(RenderElement element, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    element.data
      ..tag = tag
      ..id = id
      ..classes = classes
      ..styles = styles
      ..attributes = attributes;
  }

  @override
  void renderTextNode(RenderElement element, String text, [bool rawHtml = false]) {
    element.data
      ..text = text
      ..rawHtml = rawHtml;
  }

  @override
  void skipContent(RenderElement element) {
    // noop
  }

  @override
  void attachNode(RenderElement? parent, RenderElement child, RenderElement? after) {
    if (parent == null) {
      root = child;
      return;
    }

    var children = parent.data.children;
    children.remove(child);
    if (after == null) {
      children.insert(0, child);
    } else {
      var index = children.indexOf(after);
      children.insert(index + 1, child);
    }
  }

  @override
  void finalizeNode(RenderElement element) {}

  @override
  void removeChild(RenderElement parent, RenderElement child) {
    parent.data.children.remove(child);
  }

  String renderHtml() {
    return root != null ? renderNodeHtml(root!) : '';
  }

  String renderNodeHtml(RenderElement element) {
    var data = element.data;
    if (data.text != null) {
      if (data.rawHtml == true) {
        return data.text!;
      } else {
        return htmlEscape.convert(data.text!);
      }
    } else if (data.tag != null) {
      var output = StringBuffer();
      var tag = data.tag!.toLowerCase();
      _domValidator.validateElementName(tag);
      output.write('<$tag');
      if (data.id != null) {
        output.write(' id="${_attributeEscape.convert(data.id!)}"');
      }
      if (data.classes != null && data.classes!.isNotEmpty) {
        output.write(' class="${_attributeEscape.convert(data.classes!.join(' '))}"');
      }
      if (data.styles != null && data.styles!.isNotEmpty) {
        output.write(
            ' style="${_attributeEscape.convert(data.styles!.entries.map((e) => '${e.key}: ${e.value}').join('; '))}"');
      }
      if (data.attributes != null && data.attributes!.isNotEmpty) {
        for (var attr in data.attributes!.entries) {
          _domValidator.validateAttributeName(attr.key);
          if (attr.value.isNotEmpty) {
            output.write(' ${attr.key}="${_attributeEscape.convert(attr.value)}"');
          } else {
            output.write(' ${attr.key}');
          }
        }
      }
      var selfClosing = _domValidator.isSelfClosing(tag);
      if (selfClosing) {
        output.write('/>');
      } else {
        output.write('>');
        var childOutput = <String>[];
        for (var child in data.children) {
          childOutput.add(renderNodeHtml(child));
        }
        var fullChildOutput = childOutput.fold<String>('', (s, o) => s + o);
        if (kDebugMode && (fullChildOutput.length > 80 || fullChildOutput.contains('\n'))) {
          output.write('\n');
          for (var child in childOutput) {
            output.writeln('  ${child.replaceAll('\n', '\n  ')}');
          }
        } else {
          output.write(fullChildOutput);
        }
        output.write('</$tag>');
      }
      return output.toString();
    } else {
      assert(element == root);
      var output = StringBuffer();
      for (var child in data.children) {
        output.writeln(renderNodeHtml(child));
      }
      return output.toString();
    }
  }

  final _attributeEscape = HtmlEscape(HtmlEscapeMode.attribute);
  final _domValidator = DomValidator();
}

/// DOM validator with sane defaults.
class DomValidator {
  static final _attributeRegExp = RegExp(r'^[a-z](?:[a-z0-9\-\_]*[a-z0-9]+)?$');
  static final _elementRegExp = _attributeRegExp;
  static const _selfClosing = <String>{
    'area',
    'base',
    'br',
    'col',
    'embed',
    'hr',
    'img',
    'input',
    'link',
    'meta',
    'param',
    'path',
    'source',
    'track',
    'wbr',
  };
  final _tags = <String>{};
  final _attrs = <String>{};

  void validateElementName(String tag) {
    if (_tags.contains(tag)) return;
    if (_elementRegExp.matchAsPrefix(tag) != null) {
      _tags.add(tag);
    } else {
      throw ArgumentError('"$tag" is not a valid element name.');
    }
  }

  void validateAttributeName(String name) {
    if (_attrs.contains(name)) return;
    if (_attributeRegExp.matchAsPrefix(name) != null) {
      _attrs.add(name);
    } else {
      throw ArgumentError('"$name" is not a valid attribute name.');
    }
  }

  bool isSelfClosing(String tag) {
    return _selfClosing.contains(tag);
  }
}
