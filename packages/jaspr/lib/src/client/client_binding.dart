import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'dart:js_interop_unsafe';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../foundation/constants.dart';
import '../framework/framework.dart';
import 'component_anchors.dart';
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
        Jaspr.invalidateClients();
        // ignore: invalid_use_of_protected_member
        rootElement?.visitChildren((element) => element.reassemble());
        return ServiceExtensionResponse.result('{}');
      });
      registerExtension('ext.jaspr.reload_html', (method, parameters) async {
        final path = parameters['path'];
        if (path == null || path == web.window.location.pathname) {
          await _reloadPage(path);
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
          await reloadStylesheets(stylesheetUrls);
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
    super.attachRootComponent(app);
  }

  @override
  RenderObject createRootRenderObject() {
    return RootDomRenderObject(web.document.querySelector(_attachTarget)!);
  }

  @override
  @protected
  void scheduleFrame(VoidCallback frameCallback) {
    // We want the build to trigger asynchronously (to batch updates), but as soon as possible.
    // Microtasks are run before other tasks or events.
    scheduleMicrotask(frameCallback);
  }

  @override
  @internal
  void completeInitialFrame() {
    (rootElement!.renderObject as DomRenderObject).finalize();
    super.completeInitialFrame();
  }

  @override
  void reportBuildError(Element element, Object error, StackTrace stackTrace) {
    web.console.error('Error while building ${element.component.runtimeType}:\n$error\n\n$stackTrace'.toJS);
  }

  /// Reloads the linked stylesheets with the given [urls], which are relative to the root.
  @visibleForTesting
  Future<void> reloadStylesheets(List<String> urls) async {
    Future<void> performReload() async {
      final futures = [
        for (final url in urls)
          if (_findStylesheetLink(url) case final link?) _reloadStylesheet(link),
      ];

      if (futures.isEmpty) return;

      await futures.wait;

      if (web.document.has('fonts')) {
        try {
          await web.document.fonts.ready.toDart.timeout(const Duration(seconds: 2));
        } catch (_) {}
      }
    }

    if (web.document.has('startViewTransition')) {
      final transition = web.document.startViewTransition((() => performReload().toJS).toJS);
      await transition.finished.toDart;
    } else {
      await performReload();
    }
  }

  /// Returns the first link to the stylesheet with the given [url], which is relative to the root.
  ///
  /// The server links a stylesheet relative to the base URL if one is set, otherwise from the root.
  /// A stylesheet linked by hand, such as in an HTML file, can also be relative to the page.
  /// The query is ignored, as it holds the version of a reloaded stylesheet.
  web.Element? _findStylesheetLink(String url) {
    final hasBaseUrl = web.document.querySelector('base[href]') != null;
    // Without a base URL, this is the URL of the page.
    final baseUri = Uri.parse(web.document.baseURI);
    final links = web.document.querySelectorAll('link[rel="stylesheet"][href]');

    for (final stylesheetUrl in [if (!hasBaseUrl) baseUri.resolve('/$url'), baseUri.resolve(url)]) {
      for (var i = 0; i < links.length; i++) {
        final link = links.item(i) as web.HTMLLinkElement;
        final linkedUrl = Uri.tryParse(link.href);
        if (linkedUrl != null &&
            linkedUrl.scheme == stylesheetUrl.scheme &&
            linkedUrl.authority == stylesheetUrl.authority &&
            linkedUrl.path == stylesheetUrl.path) {
          return link;
        }
      }
    }
    return null;
  }

  Future<void> _reloadStylesheet(web.Element oldLink, {int retries = 5}) {
    final completer = Completer<void>();
    // Keep the link as it was written and only set its version,
    // so it resolves to the same stylesheet from any page.
    final url = Uri.parse(oldLink.getAttribute('href')!);
    final version = '${DateTime.now().millisecondsSinceEpoch}';
    final newLink = web.document.createElement('link') as web.HTMLLinkElement;
    newLink.rel = 'stylesheet';
    newLink.href = '${url.replace(queryParameters: {...url.queryParametersAll, 'v': version})}';

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
          _reloadStylesheet(oldLink, retries: retries - 1).then((_) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          });
        });
      } else {
        print('Failed to reload stylesheet ${url.path} after 5 retries.');
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    oldLink.parentNode?.insertBefore(newLink, oldLink.nextSibling);
    return completer.future;
  }

  Future<void>? _lastPageReload;

  /// Reloads the page with its current server-rendered content.
  ///
  /// Reloads run one at a time in the order they were requested,
  /// so an earlier reload that is still loading clients can't replace the page after a later one.
  Future<void> _reloadPage([String? path]) {
    // A failed reload already reported its error to its own caller.
    final previousReload = _lastPageReload?.catchError((_) {}) ?? Future.value();
    return _lastPageReload = previousReload.then((_) => _fetchAndReloadPage(path));
  }

  /// The path and query of the current page, which identify its server-rendered content.
  static String get _pageLocation => web.window.location.pathname + web.window.location.search;

  Future<void> _fetchAndReloadPage(String? path) async {
    // The page can navigate to another path while this reload waits for earlier ones.
    if (path != null && path != web.window.location.pathname) return;

    final pageLocation = _pageLocation;
    final response = await http.get(
      Uri.parse(web.window.location.href).replace(path: path),
      headers: {'X-Jaspr-Reload': 'true'},
    );
    // The page can also navigate while its content is fetched, which then belongs to another page.
    if (_pageLocation != pageLocation) return;
    if (response.statusCode != 200) {
      web.console.error('[Jaspr] Failed to reload page: ${response.statusCode} ${response.reasonPhrase}'.toJS);
      return;
    }

    final responseBody = utf8.decode(response.bodyBytes);
    final doc = web.DOMParser().parseFromString(responseBody.toJS, 'text/html');

    final body = doc.body;

    if (body == null) {
      web.console.error('[Jaspr] Failed to reload page: No body found'.toJS);
      return;
    }

    final sw = Stopwatch()..start();

    await reloadBody(body);

    sw.stop();

    if (kVerboseMode) {
      print('Page reloaded in ${sw.elapsedMilliseconds}ms');
    }
  }

  /// Replaces the page with the server-rendered [body] and reloads the app against it.
  ///
  /// Does nothing if the page navigates while the new client components in [body] load,
  /// as [body] is the content of the page it navigated away from.
  @visibleForTesting
  Future<void> reloadBody(web.HTMLElement body) async {
    final newNode = _attachTarget == 'body' ? body : body.querySelector(_attachTarget)!;

    // Load new client components before reloading.
    // An anchor only resolves synchronously once its nested clients do,
    // so an existing client that gained a deferred descendant would
    // otherwise remount and lose its state.
    // Loading errors are reported when the client app loads its slots.
    // Outside debug mode, extracting anchors strips their data from the markers,
    // which the client app still needs to read when it extracts them again.
    if (kDebugMode) {
      final pageLocation = _pageLocation;
      await [
        for (final anchor in extractAnchors(nodes: [newNode]))
          if (!anchor.isResolved) anchor.resolve().catchError((_) {}),
      ].wait;
      if (_pageLocation != pageLocation) return;
    }

    final rootRenderObject = rootElement!.renderObject as RootDomRenderObject;
    rootRenderObject.setRootNode(newNode);
    rootElement!.owner.performReload(rootElement!);

    web.document.body!.replaceWith(body);
    completeInitialFrame();
  }
}
