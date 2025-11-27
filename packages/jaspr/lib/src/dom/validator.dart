import 'dart:convert';

/// DOM validator with sane defaults.
class DomValidator {
  const DomValidator();

  static final _attributeRegExp = RegExp(r'^[@a-z:](?:[a-zA-Z0-9\-_:.]*[a-z0-9]+)?$');
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
    'source',
    'track',
    'wbr',
  };
  static const _strictWhitespace = <String>{'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'label', 'li'};
  static const _strictFormatting = <String>{'span', 'pre'};
  static final whitespace = RegExp(r'\s');
  static final _tags = <String>{};
  static final _attrs = <String>{};

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

  static const clientMarkerPrefix = '@';
  static const clientMarkerPrefixRegex = '@';

  static const syncMarkerPrefix = r'$';
  static const syncMarkerPrefixRegex = r'\$';

  static final _escapeRegex = RegExp(r'&(amp|lt|gt);');

  String unescapeMarkerText(String text) {
    return text.replaceAllMapped(_escapeRegex, (match) {
      return switch (match.group(1)) {
        'amp' => '&',
        'lt' => '<',
        'gt' => '>',
        _ => match.group(0)!,
      };
    });
  }

  String escapeMarkerText(String text) {
    return const HtmlEscape(HtmlEscapeMode(escapeLtGt: true)).convert(text);
  }
}
