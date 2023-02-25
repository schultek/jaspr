import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:mason/mason.dart';

import 'commands/build_command.dart';
import 'commands/create_command.dart';
import 'commands/serve_command.dart';
import 'version.dart';

/// The package name.
const packageName = 'jaspr_cli';

/// The executable name.
const executableName = 'jaspr';

/// A [CommandRunner] for the Jaspr CLI.
class JasprCommandRunner extends CompletionCommandRunner<int> {
  JasprCommandRunner({
    Logger? logger,
  })  : _logger = logger ?? Logger(),
        super(executableName, 'jaspr - A modern web framework for building websites in Dart.') {
    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the current version.',
    );
    addCommand(CreateCommand(logger: _logger));
    addCommand(ServeCommand(logger: _logger));
    addCommand(BuildCommand(logger: _logger));
  }

  final Logger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      return await runCommand(parse(args)) ?? ExitCode.success.code;
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
    } catch (error) {
      _logger.err('$error');
      return ExitCode.software.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.command?.name == 'completion') {
      await super.runCommand(topLevelResults);
      return ExitCode.success.code;
    }

    int? exitCode = ExitCode.unavailable.code;
    if (topLevelResults['version'] == true) {
      _logger.info(jasprCliVersion);
      exitCode = ExitCode.success.code;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }
    //if (topLevelResults.command?.name != 'update') await _checkForUpdates();
    return exitCode;
  }
}
