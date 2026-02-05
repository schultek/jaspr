import 'dart:async';

import '../daemon/logger.dart';
import '../domains/html_domain.dart';
import '../domains/scopes_domain.dart';
import '../helpers/daemon_helper.dart';
import 'base_command.dart';

class ToolingDaemonCommand extends BaseCommand with DaemonHelper {
  ToolingDaemonCommand() : super(logger: DaemonLogger());

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
    return runWithDaemon((daemon) async {
      daemon.registerDomain(ScopesDomain(daemon, logger));
      daemon.registerDomain(HtmlDomain(daemon, logger));
      return 0;
    });
  }
}
