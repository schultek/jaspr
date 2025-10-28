import 'dart:io';

void main() async {
  await generate('scaffold');
  await generate('templates/docs');

  Process.runSync('dart', 'format lib/src/bundles/ --line-length=120'.split(' '));
}

Future<void> generate(String name) async {
  var scaffoldDir = Directory('tool/$name');

  var result = await Process.run('mason', 'bundle -t dart -o lib/src/bundles/$name ${scaffoldDir.path}'.split(' '));
  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    exit(result.exitCode);
  }
}
