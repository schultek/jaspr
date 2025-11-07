import 'dart:async';
import 'dart:collection';
import 'dart:io';

import '../../jaspr.dart';
import 'adapters/document_adapter.dart';
import 'adapters/global_styles_adapter.dart';
import 'async_build_owner.dart';
import 'components/client_component_registry.dart';
import 'markup_render_object.dart';
import 'render_functions.dart';

typedef FileLoader = Future<String?> Function(String);

/// Global component binding for the server
class ServerAppBinding extends AppBinding with ComponentsBinding {
  ServerAppBinding(this.request, {required FileLoader loadFile}) : _fileLoader = loadFile;

  final RequestLike request;
  final FileLoader _fileLoader;

  @override
  bool get isClient => false;

  @override
  String get currentUrl => request.url;

  late final Map<String, String> cookies = () {
    final Map<String, String> map = {};
    final cookies = request.headers[HttpHeaders.cookieHeader]?.expand((h) => h.split(';')) ?? [];
    for (final cookie in cookies) {
      final c = Cookie.fromSetCookieValue(cookie.trim());
      map[c.name] = c.value;
    }
    return UnmodifiableMapView(map);
  }();

  final Map<String, List<String>> responseHeaders = {
    'Content-Type': ['text/html'],
  };

  int responseStatusCode = 200;
  String? responseBodyOverride;

  @override
  void attachRootComponent(Component app) async {
    super.attachRootComponent(ClientComponentRegistry(child: app));
  }

  Future<String> render({bool standalone = false}) async {
    if (rootElement == null) return '';

    if (rootElement!.owner.isFirstBuild) {
      final completer = Completer.sync();
      rootElement!.binding.addPostFrameCallback(completer.complete);
      await completer.future;
    }

    var root = rootElement!.renderObject as MarkupRenderObject;

    _adapters.insert(0, GlobalStylesAdapter()..binding = this);
    if (!standalone) {
      _adapters.insert(0, DocumentAdapter()..binding = this);
    }

    // Prepare from outer to inner.
    for (var i = 0; i < _adapters.length; i++) {
      var r = _adapters[i].prepare();
      if (r is Future) {
        await r;
      }
    }

    // Apply from inner to outer;
    for (var i = _adapters.length - 1; i >= 0; i--) {
      _adapters[i].apply(root);
    }

    if (responseBodyOverride != null) {
      return responseBodyOverride!;
    }

    if (request.headers.singleValues['X-Jaspr-Reload'] == 'true' && !standalone) {
      final body = (root.children.findWhere<MarkupRenderElement>((c) => c.tag == 'html')?.node as MarkupRenderElement?)
          ?.children
          .findWhere<MarkupRenderElement>((c) => c.tag == 'body')
          ?.node;
      if (body != null) {
        return body.renderToHtml();
      }
    }

    return root.renderToHtml();
  }

  @override
  void scheduleFrame(VoidCallback frameCallback) {
    throw UnsupportedError('Scheduling a frame is not supported on the server, and should never happen.');
  }

  @override
  RenderObject createRootRenderObject() {
    return RootMarkupRenderObject();
  }

  @override
  BuildOwner createRootBuildOwner() {
    return AsyncBuildOwner();
  }

  Future<String?> loadFile(String name) => _fileLoader(name);

  late final List<RenderAdapter> _adapters = [];

  void addRenderAdapter(RenderAdapter adapter) {
    if (_adapters.contains(adapter)) return;
    _adapters.add(adapter..binding = this);
  }

  JasprOptions get options => _options!;
  JasprOptions? _options;

  void initializeOptions(JasprOptions options) {
    _options = options;
  }

  @override
  void reportBuildError(Element element, Object error, StackTrace stackTrace) {
    responseStatusCode = 500;
    stderr.writeln('Error while building ${element.component.runtimeType}:\n$error\n\n$stackTrace');
  }
}

abstract class RenderAdapter {
  late ServerAppBinding binding;
  FutureOr<void> prepare() {}
  void apply(MarkupRenderObject root) {}
}
