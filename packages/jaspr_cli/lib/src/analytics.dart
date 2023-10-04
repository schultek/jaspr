import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart';

import 'version.dart';

Future<void> trackEvent(
  String command, {
  String? projectName,
}) async {
  try {
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
    );
  } catch (_) {}
}
