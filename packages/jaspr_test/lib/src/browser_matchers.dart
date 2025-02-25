import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../jaspr_test.dart';

/// A matcher for checking the [outerHTML] of a [HTMLElement].
Matcher hasOuterHtml(String outerHtml) {
  return isA<web.HTMLElement>()
      .having((e) => e.instanceOfString('HTMLElement'), 'instanceOf(HTMLElement)', isTrue)
      .having((e) => e.outerHTML, 'outerHTML', outerHtml);
}
