import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sse/client/sse_client.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../framework/framework.dart';
import 'dom_render_object.dart';
import 'utils.dart';

/// Global component binding for the client.
class ClientAppBinding extends AppBinding with ComponentsBinding {
  ClientAppBinding() {
    initializeEvents();
  }

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
  }

  @override
  void reportBuildError(Element element, Object error, StackTrace stackTrace) {
    web.console.error('Error while building ${element.component.runtimeType}:\n$error\n\n$stackTrace'.toJS);
  }

  /// Reloads the current page.
  void reload([String? path]) async {
    final response = await http.get(
      Uri.parse(web.window.location.href).replace(path: path),
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
    if (_attachTarget != 'body') {
      throw Exception('Can only reload page when attached to body');
    }

    final sw = Stopwatch()..start();

    final rootRenderObject = rootElement!.renderObject as RootDomRenderObject;
    final rootNode = rootRenderObject.node;

    rootRenderObject.node = body;
    rootRenderObject.toHydrate = [...body.childNodes.toIterable()];
    rootElement!.owner.performReload(rootElement!);

    rootNode.replaceWith(body);

    sw.stop();
    print('Page reloaded in ${sw.elapsedMilliseconds}ms');
  }

  SseClient? _eventsClient;

  void initializeEvents() {
    if (_eventsClient != null) return;

    _eventsClient = SseClient(r'/$jasprEventsHandler');
    _eventsClient!.stream.listen(
      (event) {
        final data = jsonDecode(event);
        if (data case ['ReloadRequest']) {
          reload();
        }
      },
      onDone: () {
        _eventsClient!.close();
        _eventsClient = null;
      },
    );
    _eventsClient!.sink.add(jsonEncode(['RouteInfo', web.window.location.pathname]));
  }
}
