import 'dart:async';

import 'package:universal_web/web.dart';

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../framework/framework.dart';
import 'dom_render_object.dart';

/// Global component binding for the browser
class BrowserAppBinding extends AppBinding with ComponentsBinding {
  @override
  bool get isClient => true;

  late String attachTarget;
  late (Node, Node)? attachBetween;

  @override
  void attachRootComponent(Component app, {String attachTo = 'body', (Node, Node)? attachBetween}) {
    attachTarget = attachTo;
    this.attachBetween = attachBetween;
    super.attachRootComponent(app);
  }

  @override
  RenderObject createRootRenderObject() {
    if (attachBetween case (var start, var end)) {
      return RootDomRenderObject.between(start, end);
    } else {
      return RootDomRenderObject(document.querySelector(attachTarget)!);
    }
  }

  @override
  void scheduleFrame(VoidCallback frameCallback) {
    // We want the build to trigger asynchronously (to batch updates), but as soon as possible.
    // Microtasks are run before other tasks or events.
    scheduleMicrotask(frameCallback);
  }
}
