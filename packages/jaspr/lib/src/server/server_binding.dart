import 'dart:async';
import 'dart:collection';
import 'dart:io';

import '../../jaspr.dart';
import 'adapters/client_component_adapter.dart';
import 'adapters/document_adapter.dart';
import 'adapters/global_styles_adapter.dart';
import 'async_build_owner.dart';
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
  String? responseErrorBody;

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
    var adapters = [
      ..._adapters.reversed,
      GlobalStylesAdapter(this),
      if (!standalone) DocumentAdapter(),
    ];

    for (var adapter in adapters.reversed) {
      var r = adapter.prepare();
      if (r is Future) {
        await r;
      }
    }

    for (var adapter in adapters) {
      adapter.apply(root);
    }

    if (responseErrorBody != null) {
      return responseErrorBody!;
    }

    return root.renderToHtml();
  }

  @override
  void scheduleFrame(VoidCallback frameCallback) {
    throw UnsupportedError('Scheduling a frame is not supported on the server, and should never happen.');
  }

  @override
  RenderObject createRootRenderObject() {
    return MarkupRenderObject();
  }

  @override
  BuildOwner createRootBuildOwner() {
    return AsyncBuildOwner();
  }

  Future<String?> loadFile(String name) => _fileLoader(name);

  late final List<RenderAdapter> _adapters = [];

  void addRenderAdapter(RenderAdapter adapter) {
    if (_adapters.contains(adapter)) return;
    _adapters.add(adapter);
  }

  JasprOptions get options => _options!;
  JasprOptions? _options;

  void initializeOptions(JasprOptions options) {
    _options = options;
  }
}

abstract class RenderAdapter {
  FutureOr<void> prepare() {}
  void apply(MarkupRenderObject root) {}
}
