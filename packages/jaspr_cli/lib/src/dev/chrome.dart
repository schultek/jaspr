// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:browser_launcher/browser_launcher.dart' as browser_launcher;
import 'package:path/path.dart' as path;
import '../helpers/settings_helper.dart';
import '../logging.dart';

Future<Chrome?> startChrome(int port, Logger logger) async {
  final uri = Uri(scheme: 'http', host: 'localhost', port: port).toString();
  try {
    return await Chrome.start([uri], port: 0, chromeUserDir: chromeUserDir);
  } on StateError catch (_) {
    logger.write(
      'Could not attach debugger to Chrome, since it is already running in a different session. Close Chrome and try again, or continue without debugging.',
      tag: Tag.cli,
      level: Level.error,
    );
    return null;
  } catch (e) {
    logger.write('Unexpected error starting Chrome: $e', tag: Tag.cli, level: Level.error);
    return null;
  }
}

final Directory? chromeUserDir = () {
  final settingsDir = getSettingsDirectory();
  if (settingsDir == null) {
    // Some systems don't support user home directories.
    return null;
  }

  if (!settingsDir.existsSync()) {
    try {
      settingsDir.createSync();
    } catch (e) {
      // If we can't create the directory for the analytics settings, fail
      // gracefully by returning null.
      return null;
    }
  }

  final chromeUserDir = Directory('${settingsDir.path}${path.separator}chrome_user_data').absolute;
  if (!chromeUserDir.existsSync()) {
    chromeUserDir.createSync();
  }

  return chromeUserDir;
}();

var _currentCompleter = Completer<Chrome>();

/// A class for managing an instance of Chrome.
class Chrome {
  final int debugPort;
  final browser_launcher.Chrome chrome;

  Chrome._(this.debugPort, this.chrome);

  Future<void> close() async {
    if (_currentCompleter.isCompleted) _currentCompleter = Completer<Chrome>();
    await chrome.close();
  }

  static Future<Chrome> start(List<String> urls, {required int port, required Directory? chromeUserDir}) async {
    final browser = await browser_launcher.Chrome.startWithDebugPort(
      urls,
      debugPort: port,
      userDataDir: chromeUserDir?.path,
      signIn: true,
    );
    return _connect(Chrome._(port, browser));
  }

  static Future<Chrome> fromExisting(int port) async {
    final browser = await browser_launcher.Chrome.fromExisting(port);
    return _connect(Chrome._(port, browser));
  }

  static Future<Chrome> get connectedInstance => _currentCompleter.future;

  static Future<Chrome> _connect(Chrome chrome) async {
    if (_currentCompleter.isCompleted) {
      throw ChromeError('Only one instance of chrome can be started.');
    }
    // The connection is lazy. Try a simple call to make sure the provided
    // connection is valid.
    try {
      await chrome.chrome.chromeConnection.getTabs();
    } catch (e) {
      await chrome.close();
      throw ChromeError('Unable to connect to Chrome debug port: ${chrome.debugPort}\n $e');
    }
    _currentCompleter.complete(chrome);
    return chrome;
  }
}

class ChromeError extends Error {
  final String details;
  ChromeError(this.details);

  @override
  String toString() {
    return 'ChromeError: $details';
  }
}
