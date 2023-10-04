import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart';

import 'version.dart';

Future<void> trackEvent(
  String command, {
  String? projectName,
}) async {
  var projectId = projectName != null ? hash(projectName) : null;

  var userId = hash(join(Platform.localHostname, Platform.operatingSystem, Platform.operatingSystemVersion));

  var cliVersion = jasprCliVersion;

  await get(Uri.parse('https://www.woopra.com/track/ce?'
      'project=jasprpad.schultek.de'
      '&event=cli_usage'
      '&ce_command=$command'
      '&ce_cli_version=$cliVersion'
      '${projectId != null ? '&ce_project_id=$projectId' : ''}'
      '&cv_id=$userId'));
}
