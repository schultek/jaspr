import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'dart:js_interop_unsafe';

import 'package:http/http.dart' as http;
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
  static final ClientAppBinding _instance = ClientAppBinding._();

  static ClientAppBinding ensureInitialized() {
    return _instance;
  }

  ClientAppBinding._() {
    assert(() {
      registerExtension('ext.jaspr.reassemble', (method, parameters) async {
        // ignore: invalid_use_of_protected_member
        rootElement?.visitChildren((element) => element.reassemble());
        return ServiceExtensionResponse.result('{}');
      });
      registerExtension('ext.jaspr.reload', (method, parameters) async {
        final path = parameters['path'];
        if (path == null || path == web.window.location.pathname) {
          _reloadPage();
        }
        return ServiceExtensionResponse.result('{}');
      });
      registerExtension('ext.jaspr.reload_stylesheets', (method, parameters) async {
        List<String>? stylesheetUrls;
        if (parameters['urls'] case final urlsParameter?) {
          try {
            final decoded = jsonDecode(urlsParameter);
            if (decoded is List<Object?>) {
              stylesheetUrls = decoded.cast<String>();
            }
          } catch (_) {
            stylesheetUrls = urlsParameter
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(growable: false);
          }
        }
        if (stylesheetUrls != null) {
          _reloadStylesheets(stylesheetUrls);
        }
        return ServiceExtensionResponse.result('{}');
      });
      return true;
    }());
  }

  @override
  bool get isClient => true;

  static final String _baseOrigin = () {
    final hasBase = web.document.querySelector('head>base') != null;
    return hasBase ? web.document.baseURI : web.window.location.origin;
  }();

  @override
  String get basePath {
    final path = Uri.parse(_baseOrigin).path;
    return path.isEmpty ? '/' : path;
  }

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

  Timer? _clientTreeThrottleTimer;

  @override
  void didBuildFrame() {
    super.didBuildFrame();
    if (kDebugMode && rootElement != null) {
      if (_clientTreeThrottleTimer?.isActive ?? false) return;
      _clientTreeThrottleTimer = Timer(const Duration(milliseconds: 1000), () {
        if (rootElement != null) {
          DevToolsService.instance.sendClientTree(currentUrl, _attachTarget, rootElement!);
        }
      });
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

  void _reloadStylesheets(List<String> urls) {
    Future<void> performReload() async {
      final futures = <Future<void>>[];

      for (final url in urls) {
        final link = web.document.querySelector('link[rel="stylesheet"][href^="$url"]');
        if (link != null) {
          futures.add(_reloadStylesheet(link, url));
        }
      }

      if (futures.isEmpty) return;

      await Future.wait(futures);

      if (web.document.has('fonts')) {
        try {
          await web.document.fonts.ready.toDart.timeout(const Duration(seconds: 2));
        } catch (_) {}
      }
    }

    if (web.document.has('startViewTransition')) {
      web.document.startViewTransition((() => performReload().toJS).toJS);
    } else {
      performReload();
    }
  }

  Future<void> _reloadStylesheet(web.Element oldLink, String url, {int retries = 5}) {
    final completer = Completer<void>();
    final newLink = web.document.createElement('link') as web.HTMLLinkElement;
    newLink.rel = 'stylesheet';
    newLink.href = '$url?v=${DateTime.now().millisecondsSinceEpoch}';

    StreamSubscription<void>? loadSub;
    StreamSubscription<void>? errorSub;

    void cleanup() {
      loadSub?.cancel();
      errorSub?.cancel();
    }

    loadSub = web.EventStreamProvider<web.Event>('load').forElement(newLink).listen((_) {
      cleanup();
      oldLink.remove();
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    errorSub = web.EventStreamProvider<web.Event>('error').forElement(newLink).listen((_) {
      cleanup();
      newLink.remove();
      if (retries > 0) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _reloadStylesheet(oldLink, url, retries: retries - 1).then((_) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          });
        });
      } else {
        print('Failed to reload stylesheet $url after 5 retries.');
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    oldLink.parentNode?.insertBefore(newLink, oldLink.nextSibling);
    return completer.future;
  }

  void _reloadPage([String? path]) async {
    final response = await http.get(
      Uri.parse(web.window.location.href).replace(path: path),
      headers: {'X-Jaspr-Reload': 'true'},
    );
    if (response.statusCode != 200) {
      web.console.error('[Jaspr] Failed to reload page: ${response.statusCode} ${response.reasonPhrase}'.toJS);
      return;
    }

    final responseBody = utf8.decode(response.bodyBytes);
    final doc = web.DOMParser().parseFromString(responseBody.toJS, "text/html");

    final body = doc.body;

    if (body == null) {
      web.console.error('[Jaspr] Failed to reload page: No body found'.toJS);
      return;
    }

    final sw = Stopwatch()..start();

    final newNode = _attachTarget == 'body' ? body : body.querySelector(_attachTarget)!;

    final rootRenderObject = rootElement!.renderObject as RootDomRenderObject;
    rootRenderObject.setRootNode(newNode);
    rootElement!.owner.performReload(rootElement!);

    web.document.body!.replaceWith(body);

    sw.stop();

    if (DevToolsService.instance.debugVerboseLoggingActive) {
      print('Page reloaded in ${sw.elapsedMilliseconds}ms');
    }
  }
}
