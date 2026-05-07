import 'dart:async';
import 'dart:convert';
import 'dart:developer';

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

  ClientAppBinding() {
    assert(() {
      registerExtension('ext.jaspr.reassemble', (method, parameters) async {
        // ignore: invalid_use_of_protected_member
        rootElement?.visitChildren((element) => element.reassemble());
        return ServiceExtensionResponse.result('{}');
      });
      registerExtension('ext.jaspr.reload_stylesheets', (method, parameters) async {
        final urls = (jsonDecode(parameters['urls']!) as List).cast<String>();

        void reloadStylesheet(web.Element oldLink, String url, {int retries = 5}) {
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
          });

          errorSub = web.EventStreamProvider<web.Event>('error').forElement(newLink).listen((_) {
            cleanup();
            newLink.remove();
            if (retries > 0) {
              Future.delayed(const Duration(milliseconds: 500), () {
                reloadStylesheet(oldLink, url, retries: retries - 1);
              });
            } else {
              print('Failed to reload stylesheet $url after 5 retries.');
            }
          });

          oldLink.parentNode?.insertBefore(newLink, oldLink.nextSibling);
        }

        // Reload all stylesheet <link> tags.
        for (final url in urls) {
          final link = web.document.querySelector('link[rel="stylesheet"][href^="$url"]');
          if (link != null) {
            reloadStylesheet(link, url);
          }
        }
        return ServiceExtensionResponse.result('{}');
      });
      return true;
    }());
  }

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
