import 'dart:io';

void main() async {
  var scaffoldDir = Directory('tool/scaffold');

  var result = await Process.run('mason', 'bundle -t dart -o lib/src/scaffold ${scaffoldDir.path}'.split(' '));
  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    exit(result.exitCode);
  }
}

String toCamelCase(String s) {
  var c = s.split('_');
  return [c.first, ...c.skip(1).map((c) => c[0].toUpperCase() + c.substring(1))].join();
}
