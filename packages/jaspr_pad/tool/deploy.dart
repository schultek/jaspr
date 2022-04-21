import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

void main() async {
  await buildPackage();
  await run('dart pub get');
  await run('dart run build_runner build');

  var service = 'jasprpad';

  await run('docker build -t $service .');
  await run('docker tag $service gcr.io/jaspr-demo/$service');
  await run('docker push gcr.io/jaspr-demo/$service');
  await run('gcloud run deploy $service --image=gcr.io/jaspr-demo/$service '
      '--region=europe-west1 --allow-unauthenticated');
}

Future<void> run(String command, {bool shell = false, bool output = true}) async {
  print('RUNNING $command IN $_workingDir');
  var args = command.split(' ');
  var process = await Process.start(
    args[0],
    args.skip(1).toList(),
    workingDirectory: _workingDir,
    runInShell: shell,
  );

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

Future<void> buildPackage() async {
  var pubspecLock = File('pubspec.lock');

  if (!pubspecLock.existsSync()) {
    stdout.write('Cannot find pubspec.lock file in current directory.');
    exit(1);
  }

  var pubspecContent = loadYamlDocument(await pubspecLock.readAsString()).contents;
  var pubspecMap = {
    ...pubspecContent as Map,
    'packages': {...(pubspecContent as Map)['packages'] as Map}
  };

  var buildDir = Directory('build');
  if (await buildDir.exists()) {
    await buildDir.delete(recursive: true);
  }

  await copy('.', 'build/', exclude: ['./build', './.packages', './tool', './bin']);

  bool hasChangedPackages = false;

  var packages = pubspecMap['packages'];
  for (var key in packages.keys) {
    var package = packages[key];
    if (package is YamlMap && package['source'] == 'path') {
      print('Found path package: $package');

      var path = package['description']['path'] as String;
      await copy(path, 'build/packages/');

      packages[key] = {
        ...package,
        'description': {...package['description'], 'path': 'packages/$key'}
      };
      hasChangedPackages = true;
    }
  }

  if (hasChangedPackages) {
    var yamlStr = YAMLWriter().write(pubspecMap);
    await File('build/pubspec.lock').writeAsString(yamlStr);
  }

  changeWorkingDir('build/');
}

Future<void> copy(String from, String to, {List<String>? exclude}) async {
  var fromDir = Directory(from);
  var toDir = Directory(to);

  if (!(await toDir.exists())) {
    await toDir.create(recursive: true);
  }

  if (exclude != null) {
    var files = await fromDir.list().toList();
    var filesList = files.map((f) => f.path).where((p) => !exclude.contains(p)).join(' ');

    await run('cp -r $filesList ${toDir.path}');
  } else {
    await run('cp -r ${fromDir.path} ${toDir.path}');
  }
}
