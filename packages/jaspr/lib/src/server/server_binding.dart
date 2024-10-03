import 'dart:async';

import '../../jaspr.dart';
import 'adapters/client_component_adapter.dart';
import 'adapters/document_adapter.dart';
import 'adapters/global_styles_adapter.dart';
import 'async_build_owner.dart';
import 'markup_render_object.dart';

/// Global component binding for the server
class ServerAppBinding extends AppBinding with ComponentsBinding {
  @override
  Uri get currentUri => _currentUri!;
  Uri? _currentUri;

  void setCurrentUri(Uri uri) {
    _currentUri = uri;
  }

  @override
  bool get isClient => false;

  @override
  void attachRootComponent(Component app) async {
    super.attachRootComponent(ClientComponentRegistry(child: app));
  }

  Future<String> render() async {
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
      DocumentAdapter(),
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

  late Future<String?> Function(String) _fileHandler;

  void setFileHandler(Future<String?> Function(String) handler) {
    _fileHandler = handler;
  }

  Future<String?> loadFile(String name) => _fileHandler(name);

  late final List<RenderAdapter> _adapters = [];

  void addRenderAdapter(RenderAdapter adapter) {
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
