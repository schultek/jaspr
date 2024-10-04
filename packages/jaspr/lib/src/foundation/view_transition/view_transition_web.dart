import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart';

Future<void> startViewTransition(void Function() callback) async {
  if (!document.has('startViewTransition')) {
    callback();
    return;
  }

  final transition = document.startViewTransition(callback.toJS);
  await transition.finished.toDart;
}
