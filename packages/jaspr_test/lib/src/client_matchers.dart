import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../jaspr_test.dart';

/// A matcher for checking the [outerHTML] of a [HTMLElement].
Matcher hasOuterHtml(String outerHtml) {
  return isA<web.HTMLElement>()
      .having((e) => e.instanceOfString('HTMLElement'), 'instanceOf(HTMLElement)', isTrue)
      // `outerHTML` is typed as `JSAny`, which only equals a Dart `String` when compiled to JS, not to Wasm.
      .having((e) => (e.outerHTML as JSString).toDart, 'outerHTML', outerHtml);
}
