import '../dev/client_workflow.dart';
import '../logging.dart';
import 'dev_command.dart';

class ServeCommand extends DevCommand {
  ServeCommand({super.logger}) {
    argParser.addFlag(
      'launch-in-chrome',
      help: 'Automatically launches your application in Chrome with the debug port open.',
      negatable: false,
    );
  }

  @override
  String get description => 'Runs a development server that reloads based on file system updates.';

  @override
  String get name => 'serve';

  @override
  late final bool launchInChrome = argResults?.flag('launch-in-chrome') ?? false;

  @override
  void handleClientWorkflow(ClientWorkflow workflow) {
    workflow.devProxy.clientEvents.listen((event) {
      if (launchInChrome && event['method'] == 'client.debugPort') {
        final params = event['params'] as Map<String, Object?>;
        final wsUri = params['wsUri'] as String;
        logger.write(
          'The Dart VM service is listening on http${wsUri.substring(2, wsUri.length - 2)}',
          tag: Tag.client,
        );
      }
      if (event['method'] == 'client.log') {
        final params = event['params'] as Map<String, Object?>;
        logger.write(params['log'] as String, tag: Tag.client);
      }
    });
  }
}
