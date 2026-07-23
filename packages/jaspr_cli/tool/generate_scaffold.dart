import 'dart:io';

void main() async {
  await generate('scaffold');
  await generate('templates/docs');
  await generate('new_component_bricks/new_stateless_component');
  await generate('new_component_bricks/new_stateful_component');
  await generate('new_component_bricks/new_async_component');
  await generate('new_component_bricks/new_component_test');
  await generate('new_component_bricks/new_async_component_test');

  Process.runSync('dart', 'format lib/src/bundles/ --line-length=120'.split(' '));
}

Future<void> generate(String name) async {
  final scaffoldDir = Directory('tool/$name');

  final result = await Process.run('mason', 'bundle -t dart -o lib/src/bundles/$name ${scaffoldDir.path}'.split(' '));
  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    exit(result.exitCode);
  }
}
