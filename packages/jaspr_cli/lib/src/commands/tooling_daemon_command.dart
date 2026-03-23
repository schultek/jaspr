import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;

import '../daemon/logger.dart';
import '../domains/html_domain.dart';
import '../domains/scopes_domain.dart';
import '../helpers/daemon_helper.dart';
import 'base_command.dart';

class ToolingDaemonCommand extends BaseCommand with DaemonHelper {
  ToolingDaemonCommand() : super(logger: DaemonLogger()) {
    argParser.addCommand(
      'convert-html',
      ArgParser()
        ..addOption('file')
        ..addOption('url')
        ..addOption('query'),
    );
  }

  @override
  String get description => 'Start the Jaspr tooling daemon.';

  @override
  String get name => 'tooling-daemon';

  @override
  String get category => 'Tooling';

  @override
  bool get hidden => true;

  @override
  bool get verbose => true;

  @override
  Future<int> runCommand() async {
    final command = argResults?.command?.name;

    if (command == 'convert-html') {
      final file = argResults?.command?.option('file');
      final url = argResults?.command?.option('url');
      final query = argResults?.command?.option('query');

      String html;
      if (file != null && url == null) {
        html = File(file).readAsStringSync();
      } else if (file == null && url != null) {
        final response = await http.get(Uri.parse(url));
        html = response.body;
      } else {
        stderr.writeln('Either --file or --url must be provided.');
        return 1;
      }

      final result = await HtmlDomain.convertHtml(html, query);
      stdout.writeln(result);
      return 0;
    }

    return runWithDaemon((daemon) async {
      daemon.registerDomain(ScopesDomain(daemon, logger));
      daemon.registerDomain(HtmlDomain(daemon, logger));
      return 0;
    });
  }
}
