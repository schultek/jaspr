import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart';

import '../version.dart';
import 'settings_helper.dart';

const _analyticsSetting = 'analytics';
const _analyticsIdSetting = 'analyticsId';

bool get analyticsEnabled => getSetting<bool>(_analyticsSetting) ?? false;
String? get analyticsId => getSetting<String>(_analyticsIdSetting);

void enableAnalytics(Logger logger) {
  if (analyticsEnabled) {
    logger.write('Analytics already enabled.');
    return;
  }

  updateSetting(_analyticsSetting, true);

  if (analyticsEnabled) {
    logger.info('Analytics enabled successfully.');
  } else {
    logger.warn('Could not enable analytics. Persistent settings may not be available on your system.');
  }
}

void disableAnalytics(Logger logger) {
  if (!analyticsEnabled) {
    logger.write('Analytics already disabled.');
    return;
  }

  updateSetting(_analyticsSetting, false);

  if (!analyticsEnabled) {
    logger.info('Analytics disabled successfully.');
  } else {
    logger.err('Could not disable analytics. This should not happen, please open an issue on github.');
  }
}

Future<void> trackEvent(String command, {String? projectName, String? projectMode}) async {
  try {
    if (!analyticsEnabled) {
      return;
    }

    var distinctId = analyticsId;
    if (distinctId == null) {
      updateSetting(_analyticsIdSetting, distinctId = randomId());
    }
    final projectHash = projectName != null ? hash(join(distinctId, projectName)).toString() : null;
    final isCI = Platform.environment.containsKey('CI');

    await post(
      Uri.parse('https://api-eu.mixpanel.com/track'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode([
        {
          'event': 'cli_usage',
          'properties': {
            'token': '4de26246ad502c15ea6b0e5b9137a95c',
            'distinct_id': distinctId,
            'command': command,
            'mode': projectMode,
            'cli_version': jasprCliVersion,
            'project_id': ?projectHash,
            'os': Platform.operatingSystem,
            'ci': isCI,
          },
        },
      ]),
    ).timeout(Duration(milliseconds: 300));
  } catch (_) {}
}

String randomId() {
  final random = Random();
  final chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(16, (index) => chars[random.nextInt(chars.length)]).join();
}
