import 'dart:async';

import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../framework/framework.dart';
import 'dom_render_object.dart';

/// Global component binding for the client.
class ClientAppBinding extends AppBinding with ComponentsBinding {
  @override
  bool get isClient => true;

  static final String _baseOrigin = () {
    final base = web.document.querySelector('head>base') as web.HTMLBaseElement?;
    return base?.href ?? web.window.location.origin;
  }();

  @override
  String get currentUrl {
    if (_baseOrigin.length > web.window.location.href.length) {
      return '/';
    }
    var pathWithoutOrigin = web.window.location.href.substring(_baseOrigin.length);
    if (!pathWithoutOrigin.startsWith('/')) {
      pathWithoutOrigin = '/$pathWithoutOrigin';
    }
    return pathWithoutOrigin;
  }

  late String _attachTarget;
  (web.Node, web.Node)? _attachBetween;

  @override
  void attachRootComponent(Component app, {String attachTo = 'body', (web.Node, web.Node)? attachBetween}) {
    _attachTarget = attachTo;
    _attachBetween = attachBetween;
    super.attachRootComponent(app);
  }

  @override
  RenderObject createRootRenderObject() {
    if (_attachBetween case (final start, final end)) {
      return RootDomRenderObject.between(start, end);
    } else {
      return RootDomRenderObject(web.document.querySelector(_attachTarget)!);
    }
  }

  @override
  void scheduleFrame(VoidCallback frameCallback) {
    // We want the build to trigger asynchronously (to batch updates), but as soon as possible.
    // Microtasks are run before other tasks or events.
    scheduleMicrotask(frameCallback);
  }

  @override
  void completeInitialFrame() {
    (rootElement!.renderObject as DomRenderObject).finalize();
    super.completeInitialFrame();
  }

  @override
  void reportBuildError(Element element, Object error, StackTrace stackTrace) {
    web.console.error('Error while building ${element.component.runtimeType}:\n$error\n\n$stackTrace'.toJS);
  }
}
