import 'dart:convert';

import 'package:universal_web/web.dart' as web;

import '../../server.dart';
import '../dom/validator.dart';
import 'child_nodes.dart';

abstract class MarkupRenderObject extends RenderObject implements RawableRenderObject {
  @override
  MarkupRenderObject? parent;
  @override
  web.Node? get node => null;

  late final ChildList children = ChildList(this);

  @override
  MarkupRenderElement createChildRenderElement(String tag) {
    return MarkupRenderElement(tag)..parent = this;
  }

  @override
  MarkupRenderText createChildRenderText(String text, [bool rawHtml = false]) {
    return MarkupRenderText(text, rawHtml)..parent = this;
  }

  @override
  MarkupRenderFragment createChildRenderFragment() {
    return MarkupRenderFragment()..parent = this;
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

  @visibleForTesting
  static int maxHtmlLineLength = 100;

  (String, bool, bool) _renderAndFormat([
    // Whether the current element requires strict formatting.
    // (no added whitespace or newlines)
    bool strictFormatting = false,
    // Whether the current element requires strict whitespace.
    // (only adds whitespace/newlines to existing leading or trailing whitespace, since longer whitespace blocks are collapsed)
    bool strictWhitespace = false,
    String indent = '',
  ]);

  (String, bool, bool) _renderChildren([
    bool strictWhitespace = false,
    bool childStrictFormatting = false,
    bool childStrictWhitespace = false,
    String indent = '',
  ]) {
    if (children.isEmpty) {
      return ('', false, false);
    }

    final output = StringBuffer();
    // Don't increase the indent for fragments.
    final childIndent = this is MarkupRenderFragment ? indent : '$indent  ';

    var leadingWhitespace = false;
    var trailingWhitespace = false;

    final childOutput = <({String html, bool leading, bool trailing, bool hasNewline})>[];
    var childOutputLength = 0;
    var childOutputLinebreak = false;

    // Special case: Detect parsed html by checking for initial whitespace-only text node containing a newline.
    final firstChild = children.first;
    childStrictFormatting |=
        firstChild is MarkupRenderText && firstChild.text.contains('\n') && firstChild.text.trim().isEmpty;

    for (final child in children) {
      final (html, leading, trailing) = child._renderAndFormat(
        childStrictFormatting,
        childStrictWhitespace,
        childIndent,
      );
      if (html.isEmpty) continue;

      final hasNewline = html.contains('\n');
      childOutput.add((html: html, leading: leading, trailing: trailing, hasNewline: hasNewline));
      childOutputLength += html.length;
      childOutputLinebreak |= hasNewline;
    }

    if (childOutput.isEmpty) {
      return ('', false, false);
    }

    // Iterate over the rendered children and adds newlines based on the following rules:
    //
    // a) When the element requires strict formatting (like <pre>) add no newlines.
    // b) When the combined child output is small enough to fit on one line and contains no newlines already, add no newlines.
    // c) When the element requires strict whitespace (like <p>, where multi-length whitespaces are collapsed into one), then:
    //    - only add newlines to existing leading or trailing whitespace and
    //    - try to keep children on the same line as much as possible.
    // d) When the element does not require strict whitespace (like <div>), add newlines before every child to improve readability.

    // Whether newlines are generally allowed (checks rule a and b).
    final allowNewlines = !childStrictFormatting && (childOutputLength > maxHtmlLineLength || childOutputLinebreak);

    // Whether to add a newline before the next child.
    var addNewline = allowNewlines && !strictWhitespace;

    // Keep track of the current line length to only break when necessary (for rule c).
    var currentLineLength = 0;

    for (final (index, child) in childOutput.indexed) {
      if (allowNewlines) {
        // Allow additional newlines if the child has leading whitespace and the line is too long.
        addNewline |= child.leading && currentLineLength > maxHtmlLineLength;
        // Skip newlines for the first child in a fragment to avoid excessive vertical space.
        addNewline &= index > 0 || this is! MarkupRenderFragment;
        if (addNewline) {
          output.write('\n$childIndent');
          currentLineLength = 0;
        }
      }

      if (index == 0) leadingWhitespace = child.leading || addNewline;
      output.write(child.html);

      if (allowNewlines) {
        // Update the current line length.
        currentLineLength = child.hasNewline
            ? child.html.length - child.html.lastIndexOf('\n')
            : currentLineLength + child.html.length;
        // When strict whitespace, only allow newlines if the child has trailing whitespace and the line is too long.
        addNewline = !childStrictWhitespace || (child.trailing && currentLineLength > maxHtmlLineLength);
      }
    }
    if (allowNewlines && this is! MarkupRenderFragment && (addNewline || !strictWhitespace)) {
      output.write('\n$indent');
      trailingWhitespace = true;
    } else {
      trailingWhitespace = childOutput.last.trailing;
    }

    return (output.toString(), leadingWhitespace, trailingWhitespace);
  }
}

class MarkupRenderElement extends MarkupRenderObject implements RenderElement {
  MarkupRenderElement(this.tag);

  final String tag;

  String? id;
  String? classes;
  Map<String, String>? styles;
  Map<String, String>? attributes;

  @override
  void update(
    String? id,
    String? classes,
    Map<String, String>? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
  ) {
    this.id = id;
    this.classes = classes;
    this.styles = styles;
    this.attributes = attributes;
  }

  @override
  (String, bool, bool) _renderAndFormat([
    bool strictFormatting = false,
    bool strictWhitespace = false,
    String indent = '',
  ]) {
    final output = StringBuffer();
    var leadingWhitespace = false;
    var trailingWhitespace = false;

    final tag = this.tag.toLowerCase();
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
      if (children.isNotEmpty) {
        final childStrictFormatting = strictFormatting || _domValidator.hasStrictFormatting(tag);
        final childStrictWhitespace = strictWhitespace || _domValidator.hasStrictWhitespace(tag);

        final result = _renderChildren(strictWhitespace, childStrictFormatting, childStrictWhitespace, indent);

        output.write(result.$1);
        leadingWhitespace = result.$2;
        trailingWhitespace = result.$3;
      }
      output.write('</$tag>');
    }

    return (output.toString(), leadingWhitespace, trailingWhitespace);
  }
}

class MarkupRenderText extends MarkupRenderObject implements RawableRenderText {
  MarkupRenderText(this.text, this.rawHtml);

  String text;
  bool rawHtml;

  @override
  void update(String text, [bool rawHtml = false]) {
    this.text = text;
    this.rawHtml = rawHtml;
  }

  @override
  (String, bool, bool) _renderAndFormat([
    bool strictFormatting = false,
    bool strictWhitespace = false,
    String indent = '',
  ]) {
    final output = StringBuffer();
    var leadingWhitespace = false;
    var trailingWhitespace = false;

    if (text.isNotEmpty) {
      final html = rawHtml == true ? text : _elementEscape.convert(text);
      if (strictFormatting) {
        output.write(html);
      } else {
        output.write(html.replaceAll('\n', '\n$indent'));
      }
      leadingWhitespace = html.startsWith(DomValidator.whitespace);
      trailingWhitespace = html.substring(html.length - 1).startsWith(DomValidator.whitespace);
    }
    return (output.toString(), leadingWhitespace, trailingWhitespace);
  }
}

class MarkupRenderFragment extends MarkupRenderObject implements RenderFragment {
  @override
  (String, bool, bool) _renderAndFormat([
    bool strictFormatting = false,
    bool strictWhitespace = false,
    String indent = '',
  ]) {
    final result = _renderChildren(strictWhitespace, strictFormatting, strictWhitespace, indent);
    return result;
  }
}

class RootMarkupRenderObject extends MarkupRenderObject {
  @override
  (String, bool, bool) _renderAndFormat([
    bool strictFormatting = false,
    bool strictWhitespace = false,
    String indent = '',
  ]) {
    final output = StringBuffer();
    var leadingWhitespace = false;
    var trailingWhitespace = false;

    for (final child in children) {
      final (html, leading, trailing) = child._renderAndFormat(strictFormatting, strictWhitespace, indent);
      output.writeln(html);
      if (child == children.first) leadingWhitespace = leading;
      trailingWhitespace = trailing;
    }

    return (output.toString(), leadingWhitespace, trailingWhitespace);
  }
}

const HtmlEscape _elementEscape = HtmlEscape(HtmlEscapeMode.element);
const HtmlEscape _attributeEscape = HtmlEscape(HtmlEscapeMode.attribute);
const DomValidator _domValidator = DomValidator();
