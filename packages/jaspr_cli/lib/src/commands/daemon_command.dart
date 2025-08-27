import '../dev/client_domain.dart';
import '../dev/client_workflow.dart';
import '../helpers/daemon_helper.dart';
import 'dev_command.dart';

class DaemonCommand extends DevCommand with DaemonHelper {
  DaemonCommand() : super(logger: DaemonLogger());

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
  final bool launchInChrome = true;
  @override
  final bool autoRun = false;

  @override
  Future<int> runCommand() async {
    return runWithDaemon((_) async {
      return super.runCommand();
    });
  }

  @override
  void handleClientWorkflow(ClientWorkflow workflow) {
    daemon.registerDomain(ClientDomain(daemon, workflow.serverManager));
  }
}
