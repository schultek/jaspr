import 'dart:convert';

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
    if (text case var text?) {
      var html = rawHtml == true ? text : htmlEscape.convert(text);
      if (strictFormatting) {
        output.write(html);
      } else {
        output.write(html.replaceAll('\n', '\n$indent'));
      }
      leadingWhitespace = html.startsWith(DomValidator._whitespace);
      trailingWhitespace = html.substring(html.length - 1).startsWith(DomValidator._whitespace);
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
    } else {
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

  final _attributeEscape = HtmlEscape(HtmlEscapeMode.attribute);
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
  static const _strictWhitespace = <String>{
    'p',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'label',
  };
  static const _strictFormatting = <String>{
    'span',
    'pre',
  };
  static final _whitespace = RegExp(r'\s');
  static final _tags = <String>{};
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

  bool hasStrictWhitespace(String tag) {
    return _strictWhitespace.contains(tag);
  }

  bool hasStrictFormatting(String tag) {
    return _strictFormatting.contains(tag);
  }
}
