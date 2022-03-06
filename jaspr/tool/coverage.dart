import 'dart:io';

void main() async {
  await Future.wait([
    run('dart run test --coverage=coverage'),
    run('dart run test --preset=browser --coverage=coverage'),
  ]);

  await run(
      'dart pub global run coverage:format_coverage --check-ignore --packages=.packages --report-on=lib --lcov -o ./coverage/lcov.info -i ./coverage');

  await run('genhtml -o ./coverage/report ./coverage/lcov.info');

  await run('open ./coverage/report/index.html');
}

Future<void> run(String command) async {
  var parts = command.split(' ');
  var process = await Process.start(parts[0], parts.skip(1).toList());

  process.stdout.listen((_) => stdout.add(_));
  process.stderr.listen((_) => stderr.add(_));

  var code = await process.exitCode;
  if (code != 0) {
    exit(code);
  }
}
