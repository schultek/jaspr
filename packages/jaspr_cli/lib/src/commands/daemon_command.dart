import '../daemon/logger.dart';
import '../dev/client_domain.dart';
import '../dev/client_workflow.dart';
import '../helpers/daemon_helper.dart';
import 'dev_command.dart';

class DaemonCommand extends DevCommand with DaemonHelper {
  DaemonCommand() : super(logger: DaemonLogger()) {
    argParser.addFlag(
      'launch-in-chrome',
      help: 'Automatically launches your application in Chrome with the debug port open.',
      defaultsTo: true,
      negatable: true,
    );
  }

  @override
  String get description => 'Runs a daemon server.';

  @override
  String get name => 'daemon';

  @override
  bool get hidden => true;

  @override
  // ignore: overridden_fields
  final bool verbose = true;

  @override
  late final bool launchInChrome = argResults?.flag('launch-in-chrome') ?? true;

  @override
  Future<int> runCommand() async {
    return runWithDaemon((_) async {
      return super.runCommand();
    });
  }

  @override
  void handleClientWorkflow(ClientWorkflow workflow) {
    daemon.registerDomain(ClientDomain(daemon, workflow.devProxy));
  }
}
