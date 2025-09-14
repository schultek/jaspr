import 'dart:io';

void main() async {
  await run('docker build --platform linux/amd64 -t dart_quotes .');
  await run('docker tag dart_quotes gcr.io/dart-quotes/dart_quotes');
  await run('docker push gcr.io/dart-quotes/dart_quotes');
  await run(
    'gcloud run deploy dart-quotes --image=gcr.io/dart-quotes/dart_quotes '
    '--region=europe-west1 --allow-unauthenticated --project=dart-quotes',
  );
}

Future<void> run(String command, {bool shell = false, bool output = true}) async {
  print('RUNNING $command IN $_workingDir');
  var args = command.split(' ');
  var process = await Process.start(args[0], args.skip(1).toList(), workingDirectory: _workingDir, runInShell: shell);

  if (output) {
    process.stdout.listen((event) => stdout.add(event));
  }
  process.stderr.listen((event) => stderr.add(event));

  var exitCode = await process.exitCode;

  if (exitCode != 0) {
    exit(exitCode);
  }
}

String? _workingDir;

void changeWorkingDir(String dir) {
  _workingDir = dir;
}
