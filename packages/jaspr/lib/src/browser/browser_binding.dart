import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../framework/framework.dart';
import 'clients.dart';
import 'dom_render_object.dart';

/// Global component binding for the browser
class BrowserAppBinding extends AppBinding with ComponentsBinding {
  @override
  bool get isClient => true;

  static final String _baseOrigin = () {
    var base = web.document.querySelector('head>base') as web.HTMLBaseElement?;
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

  late String attachTarget;
  late (web.Node, web.Node)? attachBetween;

  @override
  void attachRootComponent(Component app, {String attachTo = 'body', (web.Node, web.Node)? attachBetween}) {
    attachTarget = attachTo;
    this.attachBetween = attachBetween;
    super.attachRootComponent(app);
  }

  @override
  RenderObject createRootRenderObject() {
    if (attachBetween case (var start, var end)) {
      return RootDomRenderObject.between(start, end);
    } else {
      return RootDomRenderObject(web.document.querySelector(attachTarget)!);
    }
  }

  @override
  void scheduleFrame(VoidCallback frameCallback) {
    // We want the build to trigger asynchronously (to batch updates), but as soon as possible.
    // Microtasks are run before other tasks or events.
    scheduleMicrotask(frameCallback);
  }

  @override
  void reportBuildError(Element element, Object error, StackTrace stackTrace) {
    web.console.error('Error while building ${element.component.runtimeType}:\n$error\n\n$stackTrace'.toJS);
  }

  /// Reloads the current page.
  void reload() async {
    final response = await http.get(
      Uri.parse(web.window.location.href),
      headers: {'X-Jaspr-Reload': 'true'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reload page: ${response.statusCode} ${response.reasonPhrase}');
    }

    final doc = web.Document.parseHTMLUnsafe(response.body.toJS);
    final body = doc.body;

    if (body == null) {
      throw Exception('Failed to reload page: No body found');
    }

    final sw = Stopwatch()..start();
    updatePage(body);
    sw.stop();
    print("Page reloaded in ${sw.elapsedMilliseconds}ms");
  }
}
