import 'dart:io';

void main() async {
  var service = 'jasprpad';

  await run('docker build --platform linux/amd64 -t $service -f apps/jaspr_pad/Dockerfile apps/jaspr_pad/');
  await run('docker tag $service gcr.io/jaspr-demo/$service');
  await run('docker push gcr.io/jaspr-demo/$service');
  await run(
    'gcloud run deploy $service --image=gcr.io/jaspr-demo/$service '
    '--region=europe-west1 --allow-unauthenticated --project=jaspr-demo',
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
