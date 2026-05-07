import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

import '../commands/base_command.dart';
import '../dev/client_workflow.dart';
import '../dev/dev_proxy.dart';
import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';

extension CssHelper on BaseCommand {
  void runCssGeneration(ClientWorkflow workflow) async {
    final generatedDir = Directory('.dart_tool/jaspr/generated');
    if (generatedDir.existsSync()) {
      generatedDir.deleteSync(recursive: true);
    }
    generatedDir.createSync(recursive: true);

    Process? process;

    VmService? vmService;
    String? isolateId;

    Future<void> runGeneration() async {
      final (runnerFile, cssFiles) = await _generateRunner(watch: true);
      if (runnerFile == null) return;

      if (process == null) {
        process = await Process.start(
          dartExecutable,
          ['run', '--enable-vm-service=0', runnerFile.path],
          workingDirectory: Directory.current.path,
        );

        process!.stdout.transform(utf8.decoder).transform(LineSplitter()).listen((line) async {
          if (vmService == null) {
            final RegExp vmServiceRegex = RegExp(r'The Dart VM service is listening on (http://[a-zA-Z0-9:/_\-\.=]+)');
            final match = vmServiceRegex.firstMatch(line);
            if (match != null) {
              final uri = match.group(1)!;
              final wsUri = uri.replaceFirst('http', 'ws') + (uri.endsWith('/') ? 'ws' : '/ws');
              try {
                vmService = await vmServiceConnectUri(wsUri);
                final vm = await vmService!.getVM();
                isolateId = vm.isolates!.first.id;
              } catch (e) {
                logger.write('Failed to connect to CSS VM service: $e', tag: Tag.cli, level: Level.warning);
              }
              return;
            }
          }

          _processCssOutput(
            line,
            onDone: () {
              for (final connection in workflow.devProxy.getClientConnections()) {
                _reloadStylesheets(connection, cssFiles);
              }
            },
          );
        });

        process!.stderr.transform(utf8.decoder).transform(LineSplitter()).listen((line) async {
          logger.write('[CSS Runner] $line', tag: Tag.cli, level: Level.error);
        });

        process!.exitCode.then((value) {
          if (value != 0) {
            logger.write('CSS runner exited with code $value', tag: Tag.cli, level: Level.error);
          }
          process = null;
          vmService = null;
          isolateId = null;
        });
      } else {
        if (vmService != null && isolateId != null) {
          try {
            await vmService!.reloadSources(isolateId!);
          } catch (e) {
            logger.write('Failed to hot-reload CSS runner: $e', tag: Tag.cli, level: Level.warning);
          }
        }
        process!.stdin.writeln(jsonEncode({'command': 'run'}));
      }
    }

    workflow.devProxy.registerPostReloadCallback(runGeneration);

    runGeneration();

    guardResource(() {
      workflow.devProxy.unregisterPostReloadCallback(runGeneration);
      process?.kill();
    });
  }

  Future<void> _reloadStylesheets(ClientConnection connection, List<String> cssFiles) async {
    if (connection.vmService == null) {
      return;
    }
    try {
      await connection.vmService!.callServiceExtension('ext.jaspr.reload_stylesheets', args: {'urls': cssFiles});
    } catch (e) {
      logger.write('Failed to reload CSS stylesheets: $e', tag: Tag.cli, level: Level.warning);
    }
  }

  Future<(File?, List<String>)> _generateRunner({required bool watch}) async {
    final projectName = project.requirePubspecYaml['name'] as String;
    final buildDir = '.dart_tool/build/generated/$projectName/lib';

    if (!Directory(buildDir).absolute.existsSync()) {
      return (null, <String>[]);
    }

    final runnerFiles = await Glob('$buildDir/**.styles.dart').list(root: Directory.current.path).toList();
    final validRunnerFiles = runnerFiles.where((f) {
      return f.path.endsWith('.server.styles.dart') || f.path.endsWith('.client.styles.dart');
    }).toList();

    if (validRunnerFiles.isEmpty) {
      return (null, <String>[]);
    }

    final runnerCode = _getRunnerCode(validRunnerFiles, watch: watch);

    final runnerFile = File('.dart_tool/jaspr/css_runner.dart').absolute;
    runnerFile.createSync(recursive: true);
    runnerFile.writeAsStringSync(runnerCode.toString());

    return (
      runnerFile,
      [
        for (final f in validRunnerFiles)
          p.setExtension(p.withoutExtension(p.withoutExtension(p.relative(f.path, from: buildDir))), '.css'),
      ],
    );
  }

  void _processCssOutput(String line, {void Function()? onDone}) {
    if (!line.trim().startsWith('{')) return;
    try {
      final json = jsonDecode(line);
      if (json case {'event': 'css', 'file': final String file, 'data': {'css': final String cssValue}}) {
        final outputFile = File('.dart_tool/jaspr/generated/$file').absolute..createSync(recursive: true);

        final currentContent = outputFile.readAsStringSync();
        if (currentContent == cssValue) {
          return;
        }

        outputFile.writeAsStringSync(cssValue);
        logger.write(
          'Generated $file',
          tag: Tag.cli,
        );
      } else if (json case {'event': 'done'}) {
        onDone?.call();
      }
    } catch (_) {}
  }

  Future<int> buildCss() async {
    final exitCode = await _buildCss();

    await copyToBuildDir('.dart_tool/jaspr/generated');

    return exitCode;
  }

  Future<int> _buildCss() async {
    final generatedDir = Directory('.dart_tool/jaspr/generated');
    if (generatedDir.existsSync()) {
      generatedDir.deleteSync(recursive: true);
    }
    generatedDir.createSync(recursive: true);

    final (runnerFile, _) = await _generateRunner(watch: false);
    if (runnerFile == null) return 0;

    final result = await ProcessRunner.instance.run(
      dartExecutable,
      ['run', runnerFile.path],
      workingDirectory: Directory.current.path,
    );

    if (result.exitCode != 0) {
      logger.write(
        'Failed to generate css:\n${result.stderr}',
        tag: Tag.cli,
        level: Level.error,
      );
      return result.exitCode;
    }

    final lines = result.stdout.toString().split('\n');
    for (final line in lines) {
      _processCssOutput(line);
    }
    return 0;
  }
}

String _getRunnerCode(List<FileSystemEntity> validRunnerFiles, {bool watch = false}) {
  final runnerCode = StringBuffer();
  runnerCode.writeln(
    "import 'dart:convert';\n"
    "import 'dart:io';\n"
    "import 'dart:isolate';",
  );

  for (int i = 0; i < validRunnerFiles.length; i++) {
    final relative = p.relative(
      validRunnerFiles[i].path,
      from: Directory.current.uri.resolve('.dart_tool/jaspr/').path,
    );
    runnerCode.writeln("import '$relative' as s$i;");
  }

  runnerCode.writeln('\nvoid main() {');

  if (watch) {
    runnerCode.writeln(
      '  stdin.transform(utf8.decoder).transform(LineSplitter()).listen((line) {\n'
      '    try {\n'
      '      final json = jsonDecode(line);\n'
      "      if (json['command'] == 'run') run();\n"
      '    } catch (_) {}\n'
      '  });',
    );
  }

  runnerCode.writeln(
    '  run();\n'
    '}\n\n'
    'Future<void> run() async {\n'
    '  await Isolate.run(() {\n'
    '${validRunnerFiles.indexed.map((i) => '    s${i.$1}.run();\n').join()}'
    '  });\n'
    '  stdout.writeln(jsonEncode({"event": "done"}));\n'
    '}',
  );
  return runnerCode.toString();
}
