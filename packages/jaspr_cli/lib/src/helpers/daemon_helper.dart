import '../commands/base_command.dart';
import '../daemon/daemon.dart';
import '../daemon/daemon_domain.dart';
import '../daemon/logger.dart';

mixin DaemonHelper on BaseCommand {
  late Daemon daemon;

  Future<int> runWithDaemon(Future<int> Function(Daemon daemon) callback) async {
    daemon = Daemon(DaemonLogger.stdinCommandStream, DaemonLogger.stdoutCommandResponse);
    guardResource(() {
      daemon.shutdown();
    });

    final daemonDomain = DaemonDomain(daemon);
    daemon.registerDomain(daemonDomain);

    final resultFuture = callback(daemon);

    await daemon.onExit;
    await stop();

    return await resultFuture;
  }
}
