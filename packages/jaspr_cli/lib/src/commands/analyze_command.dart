import 'dart:io';

import '../logging.dart';
import 'base_command.dart';

class AnalyzeCommand extends BaseCommand {
  AnalyzeCommand({super.logger}) {
    argParser.addFlag(
      'fatal-infos',
      help: 'Treat info level issues as fatal',
      defaultsTo: true,
    );
    argParser.addFlag(
      'fatal-warnings',
      help: 'Treat warning level issues as fatal',
      defaultsTo: true,
    );
    argParser.addFlag(
      'fix',
      help: 'Apply all possible fixes to the lint issues found.',
      negatable: false,
    );
  }

  @override
  String get description => 'Report Jaspr specific lint warnings.';

  @override
  String get name => 'analyze';

  @override
  String get category => 'Tooling';

  @override
  Future<CommandResult?> run() async {
    await super.run();

    var process = await Process.start('dart', ['run', 'custom_lint', ...?argResults?.arguments]);

    return CommandResult.running(watchProcess('custom_lint', process, tag: Tag.none), stop);
  }
}
