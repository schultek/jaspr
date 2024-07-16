import 'dart:convert';

import '../../server.dart';
import 'child_nodes.dart';

const formatOutput = kDebugMode || kGenerateMode;

class MarkupRenderObject extends RenderObject {
  String? tag;
  String? id;
  String? classes;
  Map<String, String>? styles;
  Map<String, String>? attributes;

  String? text;
  bool? rawHtml;

  @override
  MarkupRenderObject? parent;

  late final ChildList children = ChildList(this);

  @override
  MarkupRenderObject createChildRenderObject() {
    return MarkupRenderObject()..parent = this;
  }

  @override
  void updateElement(String tag, String? id, String? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    this.tag = tag;
    this.id = id;
    this.classes = classes;
    this.styles = styles;
    this.attributes = attributes;
  }

  @override
  void updateText(String text, [bool rawHtml = false]) {
    this.text = text;
    this.rawHtml = rawHtml;
  }

  @override
  void skipChildren() {
    // noop
  }

  @override
  void attach(MarkupRenderObject child, {MarkupRenderObject? after}) {
    child.parent = this;
    children.insertAfter(child, after: after);
  }

  @override
  void remove(MarkupRenderObject child) {
    children.remove(child);
    child.parent = null;
  }

  String renderToHtml() {
    final output = StringBuffer();
    if (text case final text?) {
      if (rawHtml == true) {
        output.write(text);
      } else {
        output.write(htmlEscape.convert(text));
      }
    } else if (tag case var tag?) {
      tag = tag.toLowerCase();
      _domValidator.validateElementName(tag);
      output.write('<$tag');
      if (id case final String id) {
        output.write(' id="${_attributeEscape.convert(id)}"');
      }
      if (classes case final String classes when classes.isNotEmpty) {
        output.write(' class="${_attributeEscape.convert(classes)}"');
      }
      if (styles case final styles? when styles.isNotEmpty) {
        final props = styles.entries.map((e) => '${e.key}: ${e.value}');
        output.write(' style="${_attributeEscape.convert(props.join('; '))}"');
      }
      if (attributes case final attrs? when attrs.isNotEmpty) {
        for (final attr in attrs.entries) {
          _domValidator.validateAttributeName(attr.key);
          if (attr.value.isNotEmpty) {
            output.write(' ${attr.key}="${_attributeEscape.convert(attr.value)}"');
          } else {
            output.write(' ${attr.key}');
          }
        }
      }
      final selfClosing = _domValidator.isSelfClosing(tag);
      if (selfClosing) {
        output.write('/>');
      } else {
        output.write('>');
        final childOutput = <String>[];
        for (final child in children) {
          childOutput.add(child.renderToHtml());
        }
        final fullChildOutput = childOutput.fold<String>('', (s, o) => s + o);
        if (formatOutput && (fullChildOutput.length > 80 || fullChildOutput.contains('\n'))) {
          output.write('\n');
          for (final child in childOutput) {
            output.writeln('  ${child.replaceAll('\n', '\n  ')}');
          }
        } else {
          output.write(fullChildOutput);
        }
        output.write('</$tag>');
      }
    } else {
      assert(parent == null);
      for (final child in children) {
        output.writeln(child.renderToHtml());
      }
    }
    return output.toString();
  }

  final _attributeEscape = const HtmlEscape(HtmlEscapeMode.attribute);
  final _domValidator = DomValidator();
}

/// DOM validator with sane defaults.
class DomValidator {
  static final _attributeRegExp = RegExp(r'^[a-z](?:[a-zA-Z0-9\-_:.]*[a-z0-9]+)?$');
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
