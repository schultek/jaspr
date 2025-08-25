import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:mason/mason.dart';
import 'package:pub_updater/pub_updater.dart';

import 'commands/analyze_command.dart';
import 'commands/build_command.dart';
import 'commands/clean_command.dart';
import 'commands/create_command.dart';
import 'commands/daemon_command.dart';
import 'commands/doctor_command.dart';
import 'commands/migrate_command.dart';
import 'commands/serve_command.dart';
import 'commands/tooling_daemon_command.dart';
import 'commands/update_command.dart';
import 'helpers/analytics.dart';
import 'version.dart';

/// The package name.
const packageName = 'jaspr_cli';

/// The executable name.
const executableName = 'jaspr';

/// A [CommandRunner] for the Jaspr CLI.
class JasprCommandRunner extends CompletionCommandRunner<int> {
  JasprCommandRunner() : super(executableName, 'jaspr - A modern web framework for building websites in Dart.') {
    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the current version info.',
    );
    argParser.addFlag('enable-analytics', negatable: false, help: 'Enable anonymous analytics.');
    argParser.addFlag('disable-analytics', negatable: false, help: 'Disable anonymous analytics.');
    addCommand(CreateCommand());
    addCommand(ServeCommand());
    addCommand(BuildCommand());
    addCommand(AnalyzeCommand());
    addCommand(CleanCommand());
    addCommand(UpdateCommand());
    addCommand(DoctorCommand());
    addCommand(MigrateCommand());
    addCommand(DaemonCommand());
    addCommand(ToolingDaemonCommand());
  }

  final Logger _logger = Logger();
  final PubUpdater _updater = PubUpdater();

  @override
  Future<int?> run(Iterable<String> args) async {
    try {
      return await runCommand(parse(args));
    } on FormatException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    } on ProcessException catch (error) {
      _logger.err(error.message);
      return ExitCode.unavailable.code;
    } /*catch (error, stackTrace) {
      _logger.err('$error');
      _logger.err('$stackTrace');
      return ExitCode.software.code;
    }*/
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.command?.name == 'completion') {
      return await super.runCommand(topLevelResults);
    }

    int? exitCode = ExitCode.unavailable.code;
    var isVersionCommand = topLevelResults['version'] == true;
    if (isVersionCommand) {
      _logger.info(jasprCliVersion);
      exitCode = ExitCode.success.code;
    }
    if (topLevelResults.command?.name != 'update') {
      await _checkForUpdates();
    }
    if (!isVersionCommand) {
      if (topLevelResults['disable-analytics']) {
        disableAnalytics(_logger);
        exitCode = ExitCode.success.code;
      } else if (topLevelResults['enable-analytics']) {
        enableAnalytics(_logger);
        exitCode = ExitCode.success.code;
      } else {
        return await super.runCommand(topLevelResults);
      }
    }
    return exitCode;
  }

  Future<void> _checkForUpdates() async {
    try {
      final latestVersion = await _updater.getLatestVersion(packageName);
      final isUpToDate = jasprCliVersion == latestVersion;
      if (!isUpToDate) {
        _logger.info(wrapBox(
            '${lightYellow.wrap('Update available!')} ${lightCyan.wrap(jasprCliVersion)} \u2192 ${lightCyan.wrap(latestVersion)}\n'
            'Run ${cyan.wrap('$executableName update')} to update'));
      }
    } catch (_) {}
  }
}

String wrapBox(String message) {
  var lines = message.split('\n');
  var lengths = lines.map((l) => l.replaceAll(RegExp('\x1B\\[\\d+m'), '').length).toList();
  var maxLength = lengths.reduce(max);
  var buffer = StringBuffer();
  var hborder = ''.padLeft(maxLength + 8, '═');
  buffer.write('╔$hborder╗\n');
  for (var (i, l) in lines.indexed) {
    var pad = (maxLength + 8 - lengths[i]) / 2;
    var padL = ''.padLeft(pad.floor());
    var padR = ''.padLeft(pad.ceil());
    buffer.write('║$padL$l$padR║\n');
  }
  buffer.write('╚$hborder╝');
  return buffer.toString();
}
