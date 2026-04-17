import 'dart:async';

import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../devtools/dev_toolbar.dart';
import '../devtools/dev_tools_service.dart';
import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../foundation/constants.dart';
import '../framework/framework.dart';
import 'dom_render_object.dart';
import 'options.dart';

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

  @override
  void attachRootComponent(Component app, {String attachTo = 'body'}) {
    _attachTarget = attachTo;
    if (kDebugMode) {
      DevToolsService.instance.attachDebugDataToDocument();
      app = Component.fragment([app, JasprDevToolbar()]);
    }
    super.attachRootComponent(app);
  }

  @override
  RenderObject createRootRenderObject() {
    return RootDomRenderObject(web.document.querySelector(_attachTarget)!);
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

    if (kDebugMode) {
      _sendClientTree();
    }
  }

  Future<void> _sendClientTree() async {
    if (Jaspr.options.clients.isNotEmpty) {
      await Future.wait<void>([
        for (final client in Jaspr.options.clients.values)
          if (client.loadedBuilder case final Future<Object?> loader) loader,
      ]);
      // Wait for the next frame.
      await Future(() {});
    }

    DevToolsService.instance.sendClientTree(currentUrl, _attachTarget, rootElement!);
  }

  @override
  void reportBuildError(Element element, Object error, StackTrace stackTrace) {
    web.console.error('Error while building ${element.component.runtimeType}:\n$error\n\n$stackTrace'.toJS);
  }
}
