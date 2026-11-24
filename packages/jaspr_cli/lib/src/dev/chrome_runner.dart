import 'dart:async';

import '../logging.dart';
import 'chrome.dart';
import 'dev_workflow.dart';

class ChromeRunner {
  ChromeRunner(this.workflow, this.logger);

  final DevWorkflow workflow;
  final Logger logger;

  Chrome? _instance;

  bool get isRunning => _instance != null;
  Chrome? get instance => _instance;

  Future<bool> launch(int port) async {
    if (_instance case final chrome?) {
      final focused = await chrome.focus();
      if (focused) {
        logger.write('Chrome is already running.', tag: Tag.cli);
        return true;
      } else {
        await chrome.close();
        _instance = null;
      }
    }

    await workflow.ensureCdpMode();

    logger.write('Launching Chrome...', tag: Tag.cli, progress: ProgressState.running);
    final chrome = await startChrome(port, logger);
    if (chrome == null) {
      return false;
    }

    _instance = chrome;
    logger.write('Chrome started.', tag: Tag.cli, progress: ProgressState.completed);
    return true;
  }

  Future<void> reset() async {
    await _instance?.close();
    _instance = null;
  }

  Future<void> close() async {
    if (_instance != null) {
      logger.write('Closing Chrome...', level: Level.debug);
      await _instance?.close();
      _instance = null;
    }
  }
}
