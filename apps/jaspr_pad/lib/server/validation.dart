import 'package:path/path.dart' as path;

final _sourceFileNamePattern = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*\.dart$');

String validateSourceFileName(String name) {
  if (path.isAbsolute(name) || !_sourceFileNamePattern.hasMatch(name)) {
    throw FormatException('Invalid source file name: $name');
  }
  return name;
}
