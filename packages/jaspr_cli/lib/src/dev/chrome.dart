// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:browser_launcher/browser_launcher.dart' as browser_launcher;
import 'package:path/path.dart' as path;
// ignore: implementation_imports
import 'package:webdev/src/serve/chrome.dart' as webdev;
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

/// A class for managing an instance of Chrome.
class Chrome {
  final webdev.Chrome wChrome;
  final browser_launcher.Chrome? bChrome;

  Chrome._(this.wChrome, this.bChrome);

  Future<void> close() async {
    wChrome.close();
    bChrome?.close();
  }

  static Future<Chrome> start(List<String> urls, {required int port, required Directory? chromeUserDir}) async {
    final browser = await browser_launcher.Chrome.startWithDebugPort(
      urls,
      debugPort: port,
      userDataDir: chromeUserDir?.path,
      signIn: true,
    );
    return Chrome._(await webdev.Chrome.fromExisting(browser.debugPort), browser);
  }

  static Future<Chrome> fromExisting(int port) async {
    final browser = await browser_launcher.Chrome.fromExisting(port);
    return Chrome._(await webdev.Chrome.fromExisting(browser.debugPort), browser);
  }
}
