import 'dart:convert';

import 'package:universal_web/web.dart' as web;

import '../../server.dart';
import 'child_nodes.dart';

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
  @override
  web.Node? get node => null;

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
    return _renderAndFormat().$1;
  }

  (String, bool, bool) _renderAndFormat(
      [bool strictFormatting = false, bool strictWhitespace = false, String indent = '']) {
    var output = StringBuffer();
    var leadingWhitespace = false;
    var trailingWhitespace = false;
    if (text case var text? when text.isNotEmpty) {
      var html = rawHtml == true ? text : _elementEscape.convert(text);
      if (strictFormatting) {
        output.write(html);
      } else {
        output.write(html.replaceAll('\n', '\n$indent'));
      }
      leadingWhitespace = html.startsWith(DomValidator.whitespace);
      trailingWhitespace = html.substring(html.length - 1).startsWith(DomValidator.whitespace);
    } else if (tag case var tag?) {
      tag = tag.toLowerCase();
      _domValidator.validateElementName(tag);
      output.write('<$tag');
      if (id case String id) {
        output.write(' id="${_attributeEscape.convert(id)}"');
      }
      if (classes case String classes when classes.isNotEmpty) {
        output.write(' class="${_attributeEscape.convert(classes)}"');
      }
      if (styles case var styles? when styles.isNotEmpty) {
        var props = styles.entries.map((e) => '${e.key}: ${e.value}');
        output.write(' style="${_attributeEscape.convert(props.join('; '))}"');
      }
      if (attributes case var attrs? when attrs.isNotEmpty) {
        for (var attr in attrs.entries) {
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
        if (children.isNotEmpty) {
          final childStrictFormatting = strictFormatting || _domValidator.hasStrictFormatting(tag);
          final childStrictWhitespace = strictWhitespace || _domValidator.hasStrictWhitespace(tag);

          final childOutput = <(String, bool, bool)>[];
          var childOutputLength = 0;
          var childOutputLinebreak = false;

          for (var child in children) {
            final (html, leading, trailing) =
                child._renderAndFormat(childStrictFormatting, childStrictWhitespace, '$indent  ');
            childOutput.add((html, leading, trailing));
            childOutputLength += html.length;
            childOutputLinebreak |= html.contains('\n');
          }

          if (childStrictFormatting || (childOutputLength < 100 && !childOutputLinebreak)) {
            for (var child in childOutput) {
              output.write(child.$1);
              if (child == childOutput.first) leadingWhitespace = child.$2;
              trailingWhitespace = child.$3;
            }
          } else {
            var allowNewline = strictWhitespace ? false : true;
            for (var child in childOutput) {
              if (allowNewline || child.$2) {
                output.write('\n$indent  ');
                if (child == childOutput.first) leadingWhitespace = true;
              }
              output.write(child.$1);
              allowNewline = childStrictWhitespace //
                  ? child.$3
                  : true;
            }
            if (allowNewline || !strictWhitespace) {
              output.write('\n$indent');
              trailingWhitespace = true;
            }
          }
        }
        output.write('</$tag>');
      }
    } else if (children.isNotEmpty) {
      assert(parent == null);
      for (var child in children) {
        final (html, leading, trailing) = child._renderAndFormat(strictFormatting, strictWhitespace, indent);
        output.writeln(html);
        if (child == children.first) leadingWhitespace = leading;
        trailingWhitespace = trailing;
      }
    }
    return (output.toString(), leadingWhitespace, trailingWhitespace);
  }

  final _elementEscape = HtmlEscape(HtmlEscapeMode.element);
  final _attributeEscape = HtmlEscape(HtmlEscapeMode.attribute);
  final _domValidator = DomValidator();
}
