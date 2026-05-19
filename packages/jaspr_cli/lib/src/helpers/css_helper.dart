import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:frontend_server_client/frontend_server_client.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:vm_service/vm_service.dart' hide Version;
import 'package:vm_service/vm_service_io.dart';

import '../commands/base_command.dart';
import '../dev/client_workflow.dart';
import '../dev/dev_proxy.dart';
import '../dev/util.dart';
import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';

extension CssHelper on BaseCommand {
  void watchCss(ClientWorkflow workflow) async {
    final runner = CssRunner(workflow, project, logger)..prepare();
    await runner.start();

    workflow.devProxy.registerPostReloadCallback(runner.reload);

    guardResource(() {
      workflow.devProxy.unregisterPostReloadCallback(runner.reload);
      runner.dispose();
    });
  }

  Future<int> buildCss() async {
    final runner = CssRunner(null, project, logger)..prepare();
    final exitCode = await runner.build();

    await copyToBuildDir('.dart_tool/jaspr/generated');
    return exitCode;
  }
}

class CssRunner {
  CssRunner(this.workflow, this.project, this.logger);

  final ClientWorkflow? workflow;
  final Project project;
  final Logger logger;

  final librariesFile = File('.dart_tool/jaspr/css/libraries.json').absolute;
  final wrapperFile = File('.dart_tool/jaspr/css/frontend_server_wrapper.dart').absolute;
  final runnerFile = File('.dart_tool/jaspr/css/css_runner.dart').absolute;
  final packageConfigFile = File('.dart_tool/jaspr/css/package_config.json').absolute;

  FrontendServerClient? client;
  Process? process;

  VmService? vmService;
  String? isolateId;

  bool _disposed = false;

  void prepare() {
    final generatedDir = Directory('.dart_tool/jaspr/generated');
    if (generatedDir.existsSync()) {
      generatedDir.deleteSync(recursive: true);
    }
    generatedDir.createSync(recursive: true);

    String? universalWebPath;

    if (!packageConfigFile.existsSync()) {
      final originalPackageConfigPath = findPackageConfigFilePath() ?? '.dart_tool/package_config.json';
      final originalPackageConfigFile = File(originalPackageConfigPath);
      if (originalPackageConfigFile.existsSync()) {
        final config = jsonDecode(originalPackageConfigFile.readAsStringSync()) as Map<String, dynamic>;
        final packages = (config['packages'] as List<dynamic>?)?.cast<Map<String, dynamic>>();
        if (packages != null) {
          Map<String, dynamic>? universalWebEntry;

          for (final package in packages) {
            if (package case {'name': 'universal_web'}) {
              universalWebEntry = package;
            }
          }

          if (universalWebEntry != null) {
            final universalWebRootUri = Uri.parse(universalWebEntry['rootUri'] as String);
            final absoluteUniversalWebRootUri = universalWebRootUri.isAbsolute
                ? universalWebRootUri
                : Uri.file(p.normalize(p.join(p.dirname(originalPackageConfigFile.path), universalWebRootUri.path)));

            // Save path for libraries.json
            universalWebPath = p.normalize(
              p.join(absoluteUniversalWebRootUri.toFilePath(), universalWebEntry['packageUri'] as String? ?? 'lib/'),
            );

            universalWebEntry['packageUri'] = 'web_override/lib/';
          }
          // Make all relative paths absolute
          for (final package in packages) {
            final rootUri = Uri.parse(package['rootUri'] as String);
            if (!rootUri.isAbsolute) {
              package['rootUri'] = Uri.file(
                p.normalize(p.join(p.dirname(originalPackageConfigFile.path), rootUri.path)),
              ).toString();
            }
          }
        }

        packageConfigFile.createSync(recursive: true);
        packageConfigFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(config));
      }
    } else {
      // If package_config.json exists, just read the universal_web path for libraries.json
      final config = jsonDecode(packageConfigFile.readAsStringSync()) as Map<String, dynamic>;
      final packages = config['packages'] as List<dynamic>?;
      if (packages != null) {
        for (final package in packages) {
          if (package case {'name': 'universal_web'}) {
            final rootUri = Uri.parse(package['rootUri'] as String);
            universalWebPath = p.normalize(p.join(rootUri.toFilePath(), package['packageUri'] as String? ?? 'lib/'));
            break;
          }
        }
      }
    }

    if (!librariesFile.existsSync()) {
      if (universalWebPath == null) return;

      final mockJSInteropPath = p.absolute(p.join(universalWebPath, 'src/js_interop.dart'));
      final mockJSInteropUnsafePath = p.absolute(p.join(universalWebPath, 'src/js_interop_unsafe_override.dart'));

      final defaultLibrariesJson = File(p.join(dartSdkDir, 'lib', 'libraries.json'));
      if (!defaultLibrariesJson.existsSync()) return;

      final librariesJsonStr = defaultLibrariesJson.readAsStringSync();
      final libraries = jsonDecode(librariesJsonStr) as Map<String, dynamic>;

      if (libraries['vm_common'] case {'libraries': final Map<String, dynamic> libs}) {
        final versionFile = File(p.join(dartSdkDir, 'version'));
        final dartVersion = Version.parse(versionFile.readAsStringSync().trim().split(' ').first);
        final isDart311OrHigher = dartVersion >= Version(3, 11, 0);
        final supportedFlag = isDart311OrHigher ? 'support_conditional_import' : 'supported';

        if (project.modeOrNull == JasprMode.client) {
          libs['js_interop'] = {'uri': mockJSInteropPath};
          libs['js_interop_unsafe'] = {'uri': mockJSInteropUnsafePath};

          if (libs['io'] case final Map<String, dynamic> io) io[supportedFlag] = false;
          if (libs['ffi'] case final Map<String, dynamic> ffi) ffi[supportedFlag] = false;
          if (libs['isolate'] case final Map<String, dynamic> isolate) isolate[supportedFlag] = false;
        } else {
          libs['js_interop'] = {'uri': mockJSInteropPath, supportedFlag: false};
          libs['js_interop_unsafe'] = {'uri': mockJSInteropUnsafePath, supportedFlag: false};
        }
      }

      librariesFile.createSync(recursive: true);
      librariesFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(libraries));
    }

    wrapperFile.createSync(recursive: true);
    wrapperFile.writeAsStringSync('''
import 'dart:io';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  final sdkDir = r'$dartSdkDir';
  final aotSnapshot = p.join(sdkDir, 'bin', 'snapshots', 'frontend_server_aot.dart.snapshot');
  final newArgs = [...args, '--libraries-spec', '${librariesFile.path}'];
  
  final process = await Process.start(
    p.join(sdkDir, 'bin', 'dartaotruntime'),
    [aotSnapshot, ...newArgs],
  );
  
  stdin.pipe(process.stdin);
  process.stdout.pipe(stdout);
  process.stderr.pipe(stderr);
  
  final exitCode = await process.exitCode;
  exit(exitCode);
}
''');
  }

  Future<void> start() async {
    assert(client == null);
    assert(process == null);

    final cssFiles = await _generateRunner(watch: true);
    if (cssFiles.isEmpty) return;

    final platformKernel = p.join(dartSdkDir, 'lib', '_internal', 'vm_platform_strong.dill');

    client = await FrontendServerClient.start(
      runnerFile.path,
      Directory.current.absolute.uri.resolve('.dart_tool/jaspr/css/css_runner.dill').toFilePath(),
      platformKernel,
      target: 'vm',
      sdkRoot: dartSdkDir,
      frontendServerPath: wrapperFile.path,
      packagesJson: packageConfigFile.path,
      printIncrementalDependencies: false,
    );

    final compilerResult = await client!.compile();
    client!.accept();

    if (compilerResult.errorCount > 0) {
      logger.write('Failed to compile CSS runner', tag: Tag.cli, level: Level.error);
      logger.write(compilerResult.compilerOutputLines.join('\n'), tag: Tag.cli, level: Level.error);
    }

    if (compilerResult.dillOutput != null) {
      await _startProcess(cssFiles);
    }
  }

  Future<void> _startProcess(List<String> cssFiles) async {
    logger.write("Starting frontend server with input '${runnerFile.path} at ${Directory.current.path}", tag: Tag.cli);

    process = await Process.start(
      dartExecutable,
      [
        'run',
        '--enable-vm-service=0',
        '.dart_tool/jaspr/css/css_runner.dill',
      ],
      workingDirectory: Directory.current.absolute.path,
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
            logger.write('Connected to CSS VM service: $wsUri', tag: Tag.cli, level: Level.verbose);
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
          for (final connection in workflow!.devProxy.getClientConnections()) {
            _reloadStylesheets(connection, cssFiles);
          }
        },
      );
    });

    process!.stderr.transform(utf8.decoder).transform(LineSplitter()).listen((line) async {
      logger.write('[CSS Runner] $line', tag: Tag.cli, level: Level.error);
    });

    process!.exitCode.then((value) {
      if (_disposed) return;
      if (value != 0) {
        logger.write('CSS runner exited with code $value', tag: Tag.cli, level: Level.error);
      }
      process = null;
      vmService = null;
      isolateId = null;
    });
  }

  Future<void> reload(BuildResult result) async {
    final cssFiles = await _generateRunner(watch: true);
    if (cssFiles.isEmpty) return;

    logger.write('Regenerating CSS files...', tag: Tag.cli);

    if (client == null) {
      await start();
      return;
    }

    try {
      final compilerResult = await client!.compile([Uri.file(runnerFile.path), ...?result.changedAssets]);
      client!.accept();

      if (compilerResult.errorCount > 0) {
        logger.write('Failed to compile CSS runner', tag: Tag.cli, level: Level.error);
        logger.write(compilerResult.compilerOutputLines.join('\n'), tag: Tag.cli, level: Level.error);
      }

      if (compilerResult.dillOutput != null) {
        if (process == null) {
          await _startProcess(cssFiles);
        } else if (vmService != null && isolateId != null) {
          await vmService!.reloadSources(
            isolateId!,
            rootLibUri: Uri.file(p.absolute(compilerResult.dillOutput!)).toString(),
          );
          process!.stdin.writeln(jsonEncode({'command': 'run'}));
        }
      }
    } catch (e) {
      logger.write('Failed to hot-reload CSS runner: $e', tag: Tag.cli, level: Level.warning);
    }
  }

  Future<int> build() async {
    final cssFiles = await _generateRunner(watch: false);
    if (cssFiles.isEmpty) return 0;

    final platformKernel = p.join(dartSdkDir, 'lib', '_internal', 'vm_platform_strong.dill');

    final client = await FrontendServerClient.start(
      runnerFile.path,
      '.dart_tool/jaspr/css/css_runner.dill',
      platformKernel,
      target: 'vm',
      frontendServerPath: wrapperFile.path,
      packagesJson: packageConfigFile.path,
      printIncrementalDependencies: false,
    );
    final compilerResult = await client.compile();
    client.accept();
    client.kill();

    if (compilerResult.errorCount > 0) {
      logger.write('Failed to compile CSS runner', tag: Tag.cli, level: Level.error);
      logger.write(compilerResult.compilerOutputLines.join('\n'), tag: Tag.cli, level: Level.error);
    }

    if (compilerResult.dillOutput == null) {
      return 1;
    }

    final result = await ProcessRunner.instance.run(
      dartExecutable,
      ['run', '.dart_tool/jaspr/css/css_runner.dill'],
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

  Future<List<String>> _generateRunner({required bool watch}) async {
    final projectName = project.requirePubspecYaml['name'] as String;
    final buildDir = '.dart_tool/build/generated/$projectName/lib';

    if (!Directory(buildDir).absolute.existsSync()) {
      return <String>[];
    }

    final runnerFiles = await Glob('$buildDir/**.styles.dart').list(root: Directory.current.absolute.path).toList();
    final validRunnerFiles = runnerFiles.where((f) {
      return f.path.endsWith('.server.styles.dart') || f.path.endsWith('.client.styles.dart');
    }).toList();

    if (validRunnerFiles.isEmpty) {
      return <String>[];
    }

    final runnerCode = _getRunnerCode(validRunnerFiles, watch: watch);

    runnerFile.createSync(recursive: true);
    runnerFile.writeAsStringSync(runnerCode.toString());

    return [
      for (final f in validRunnerFiles)
        p.setExtension(p.withoutExtension(p.withoutExtension(p.relative(f.path, from: buildDir))), '.css'),
    ];
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
        from: Directory.current.absolute.uri.resolve('.dart_tool/jaspr/css/').path,
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

  Future<void> _reloadStylesheets(ClientConnection connection, List<String> cssFiles) async {
    if (connection.vmService == null) {
      return;
    }
    try {
      logger.write('Hot-reloading CSS stylesheets: $cssFiles', tag: Tag.cli, level: Level.verbose);
      await connection.vmService!.callServiceExtension('ext.jaspr.reload_stylesheets', args: {'urls': cssFiles});
    } catch (e) {
      logger.write('Failed to reload CSS stylesheets: $e', tag: Tag.cli, level: Level.warning);
    }
  }

  void _processCssOutput(String line, {void Function()? onDone}) {
    if (!line.trim().startsWith('{')) {
      // Silently drop any non-json output from the CSS runner.
      return;
    }
    try {
      final json = jsonDecode(line);
      if (json case {'event': 'css', 'file': final String file, 'data': {'css': final String cssValue}}) {
        final outputFile = File('.dart_tool/jaspr/generated/$file').absolute..createSync(recursive: true);

        final currentContent = outputFile.readAsStringSync();
        if (currentContent == cssValue) {
          return;
        }

        outputFile.writeAsStringSync(cssValue);
        logger.write('Generated $file', tag: Tag.cli);
      } else if (json case {'event': 'done'}) {
        onDone?.call();
      }
    } catch (_) {}
  }

  void dispose() {
    _disposed = true;
    client?.kill();
    process?.kill();
    vmService?.dispose();
  }
}
