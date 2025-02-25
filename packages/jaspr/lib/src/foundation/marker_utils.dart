import 'dart:convert';

const componentMarkerPrefix = '@';
const componentMarkerPrefixRegex = '@';

const syncMarkerPrefix = r'$';
const syncMarkerPrefixRegex = r'\$';

final _escapeRegex = RegExp(r'&(amp|lt|gt);');

String unescapeMarkerText(String text) {
  return text.replaceAllMapped(_escapeRegex, (match) {
    return switch (match.group(1)) { 'amp' => '&', 'lt' => '<', 'gt' => '>', _ => match.group(0)! };
  });
}

String escapeMarkerText(String text) {
  return HtmlEscape(HtmlEscapeMode(escapeLtGt: true)).convert(text);
}
