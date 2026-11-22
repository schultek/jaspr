import 'package:meta/meta.dart';

/// DOM values contributed by apply wrappers.
/// Styles and attributes are tracked by name,
/// which is all the client needs to remove them during hydration.
@internal
final class AppliedDomValues {
  String? id;
  List<String>? classes;
  List<String>? styles;
  List<String>? attributes;

  AppliedDomValues();

  bool get isEmpty => id == null && classes == null && styles == null && attributes == null;

  void add(AppliedDomValues other) {
    id ??= other.id;
    if (other.classes case final names?) (classes ??= []).addAll(names);
    if (other.styles case final names?) (styles ??= []).addAll(names);
    if (other.attributes case final names?) (attributes ??= []).addAll(names);
  }

  String encode() => [
    if (id case final value?) 'i:${_escapeApplyValue(value)}',
    if (classes case final names? when names.isNotEmpty) 'c:${names.map(_escapeApplyValue).join(',')}',
    if (styles case final names? when names.isNotEmpty) 's:${names.map(_escapeApplyValue).join(',')}',
    if (attributes case final names? when names.isNotEmpty) 'a:${names.map(_escapeApplyValue).join(',')}',
  ].join(';');

  factory AppliedDomValues.decode(String marker) {
    final values = AppliedDomValues();
    for (final section in marker.split(';')) {
      final colon = section.indexOf(':');
      if (colon < 0) continue;
      final value = section.substring(colon + 1);
      switch (section.substring(0, colon)) {
        case 'i':
          values.id = _unescapeApplyValue(value);
        case 'c':
          values.classes = value.split(',').map(_unescapeApplyValue).toList();
        case 's':
          values.styles = value.split(',').map(_unescapeApplyValue).toList();
        case 'a':
          values.attributes = value.split(',').map(_unescapeApplyValue).toList();
      }
    }
    return values;
  }
}

String _escapeApplyValue(String val) => (val.contains(';') || val.contains(',') || val.contains('%'))
    ? val.replaceAll('%', '%25').replaceAll(';', '%3B').replaceAll(',', '%2C')
    : val;

String _unescapeApplyValue(String val) =>
    val.contains('%') ? val.replaceAll('%2C', ',').replaceAll('%3B', ';').replaceAll('%25', '%') : val;
