import 'dart:js_interop';

import 'package:web/web.dart';

Future<void> startViewTransition(void Function() callback) async {
  final transition = document.startViewTransition(callback.toJS);
  await transition.finished.toDart;
}
