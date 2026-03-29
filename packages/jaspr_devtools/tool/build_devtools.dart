import 'dart:io';

import 'package:io/io.dart';

void main() async {
  // Build the app using jaspr_cli
  final buildResult = await Process.start(
    'dart',
    ['run', 'jaspr_cli:jaspr', 'build', '-O0'],
    mode: ProcessStartMode.inheritStdio,
  );

  final exitCode = await buildResult.exitCode;
  if (exitCode != 0) {
    print('Build failed.');
    return;
  }

  print('Build successful.');

  // The output is in build/jaspr/
  // Depending on whether we use web or just build/jaspr, let's copy build/jaspr
  final targetDir = Directory('../jaspr_cli/lib/src/devtools/web');
  if (targetDir.existsSync()) {
    targetDir.deleteSync(recursive: true);
  }
  targetDir.createSync(recursive: true);

  // Copy all files from buildDir to targetDir
  copyPath('build/jaspr/', '../jaspr_cli/lib/src/devtools/web');

  print('Copied DevTools build output to jaspr_cli/lib/src/devtools/web.');
}
