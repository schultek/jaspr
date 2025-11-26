import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:universal_web/web.dart';

FutureOr<void> startViewTransition(void Function() callback) {
  if (!document.has('startViewTransition')) {
    callback();
    return null;
  }

  final transition = document.startViewTransition(callback.toJS);
  return transition.finished.toDart as Future<void>;
}
