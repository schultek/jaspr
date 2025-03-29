// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:browser_launcher/browser_launcher.dart' as browser_launcher;
// ignore: implementation_imports
import 'package:webdev/src/serve/chrome.dart' as webdev;
import '../logging.dart';

Future<Chrome?> startChrome(int port, Logger logger) async {
  final uri = Uri(scheme: 'http', host: 'localhost', port: port).toString();
  try {
    return await Chrome.start([uri], port: 0);
  } on ChromeError catch (e) {
    logger.write('Error starting Chrome: ${e.details}', level: Level.error);
    return null; 
  }
}

/// A class for managing an instance of Chrome.
class Chrome {
  final webdev.Chrome wChrome;
  final browser_launcher.Chrome bChrome;

  Chrome._(
    this.wChrome,
    this.bChrome,
  );

  Future<void> close() async {
    wChrome.close();
    bChrome.close();
  }

  static Future<Chrome> start(List<String> urls, {required int port}) async {
    final browser = await browser_launcher.Chrome.startWithDebugPort(urls, debugPort: port);

    return Chrome._(await webdev.Chrome.fromExisting(browser.debugPort), browser);
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
