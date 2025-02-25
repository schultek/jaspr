import 'package:jaspr/jaspr.dart';
import 'package:lukehog_client/lukehog_client.dart';
import 'package:universal_web/web.dart' as web;

final analytics = LukehogClient(
  "YxfQMMWOWRcKpumc",
  debug: kDebugMode,
  getString: (key) async => web.window.localStorage.getItem(key),
  setString: (key, value) async => web.window.localStorage.setItem(key, value),
);

void captureVisit() {
  if (!kIsWeb) return;
  analytics.capture("page_visit", properties: {
    "path": web.window.location.pathname,
  });
}

void captureEasterEgg() {
  if (!kIsWeb) return;
  analytics.capture("easter_egg");
}
