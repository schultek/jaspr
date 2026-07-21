import 'dart:io';

void main() {
  // Clean up backslashes in JS templates to make them valid JS first
  final standardFile = File('tool/loaders/standard_loader.js');
  final standardJs = standardFile.readAsStringSync().replaceAll(r'\${m}', r'${m}');
  standardFile.writeAsStringSync(standardJs);

  final flutterFile = File('tool/loaders/flutter_loader.js');
  final flutterJs = flutterFile.readAsStringSync().replaceAll(r'\${m}', r'${m}');
  flutterFile.writeAsStringSync(flutterJs);

  final standardDartStr = _escapeAndInterpolate(standardJs);

  final sb = StringBuffer();
  sb.write("""
// GENERATED FILE. DO NOT EDIT.
// ignore_for_file: unnecessary_brace_in_string_interps

String getStandardWasmLoaderScript(String cleanBasename) {
  return '''
$standardDartStr''';
}

String getFlutterWasmLoaderScript({
  required String cleanBasename,
  required String modulesNeedingSkwasmJson,
  required bool needsSkwasmImmediately,
  required bool isServe,
}) {
  final sb = StringBuffer();
""");

  final flutterLines = flutterJs.split('\n');
  var indent = '  ';
  final stack = <_Cond>[];
  final buffer = <String>[];

  void flushBuffer() {
    if (buffer.isNotEmpty) {
      final joined = buffer.join('\n');
      sb.writeln("${indent}sb.writeln('''$joined''');");
      buffer.clear();
    }
  }

  for (final line in flutterLines) {
    final ifMatch = RegExp(r'^\s*//\s*#if\s+(.+)$').firstMatch(line);
    final elseMatch = RegExp(r'^\s*//\s*#else\s*$').firstMatch(line);
    final endifMatch = RegExp(r'^\s*//\s*#endif\s*$').firstMatch(line);

    if (ifMatch != null) {
      flushBuffer();
      final cond = ifMatch.group(1)!.trim();
      sb.writeln('${indent}if ($cond) {');
      stack.add(_Cond(cond, hasElse: false));
      indent += '  ';
    } else if (elseMatch != null) {
      flushBuffer();
      indent = indent.substring(0, indent.length - 2);
      sb.writeln('$indent} else {');
      stack.last.hasElse = true;
      indent += '  ';
    } else if (endifMatch != null) {
      flushBuffer();
      indent = indent.substring(0, indent.length - 2);
      sb.writeln('$indent}');
      stack.removeLast();
    } else {
      final escaped = _escapeAndInterpolate(line);
      buffer.add(escaped);
    }
  }
  flushBuffer();

  sb.writeln('  return sb.toString();');
  sb.writeln('}');

  File('lib/src/helpers/wasm_loader_script.dart').writeAsStringSync(sb.toString());
  print('Generated lib/src/helpers/wasm_loader_script.dart successfully!');
}

class _Cond {
  final String condition;
  bool hasElse;
  _Cond(this.condition, {required this.hasElse});
}

String _escapeAndInterpolate(String text) {
  var escaped = text.replaceAll(r'$', r'\$');
  escaped = escaped.replaceAll('{{cleanBasename}}', r'${cleanBasename}');
  escaped = escaped.replaceAll('"{{modulesNeedingSkwasmJson}}"', r'${modulesNeedingSkwasmJson}');
  return escaped;
}
