import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart';

import 'helpers/settings_helper.dart';
import 'version.dart';

const _analyticsSetting = 'analytics';

bool get analyticsEnabled => getSetting<bool>(_analyticsSetting) ?? false;

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

Future<void> trackEvent(
  String command, {
  String? projectName,
}) async {
  try {
    if (!analyticsEnabled) {
      return;
    }

    var systemId = hash(join(Platform.localHostname, Platform.operatingSystem, Platform.operatingSystemVersion));

    await post(
      Uri.parse('https://api-eu.mixpanel.com/track'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode([
        {
          'event': 'cli_usage',
          'properties': {
            'token': '4de26246ad502c15ea6b0e5b9137a95c',
            'distinct_id': '$systemId',
            'command': command,
            'cli_version': jasprCliVersion,
            if (projectName != null) 'project_id': '${hash(projectName)}',
            'os': Platform.operatingSystem,
          }
        }
      ]),
    ).timeout(Duration(milliseconds: 300));
  } catch (_) {}
}
