import 'dart:async';
import 'dart:convert';

import '../../jaspr.dart';
import 'adapters/document_adapter.dart';
import 'adapters/sync_script_adapter.dart';
import 'async_build_owner.dart';
import 'components/client_component_registry.dart';
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

  final rootCompleter = Completer.sync();

  @override
  void didAttachRootElement(Element element) {
    rootCompleter.complete();
  }

  Future<String> render() async {
    await rootCompleter.future;

    var root = rootElement!.renderObject as MarkupRenderObject;

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

    return root.renderToHtml();
  }

  Future<String> data() async {
    await rootCompleter.future;
    return jsonEncode(getStateData());
  }

  @override
  dynamic getRawState(String id) => null;

  @override
  Future<Map<String, String>> fetchState(String url) {
    throw 'Cannot fetch state on the server';
  }

  @override
  void updateRawState(String id, dynamic state) {}

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

  late final List<RenderAdapter> _adapters = [
    DocumentAdapter(),
    SyncScriptAdapter(getStateData),
  ];

  void addRenderAdapter(RenderAdapter adapter) {
    _adapters.add(adapter..binding = this);
  }

  JasprOptions get options => _options!;
  JasprOptions? _options;

  void initializeOptions(JasprOptions options) {
    _options = options;
  }

  @override
  Future<void> attachRootComponent(Component app) {
    return super.attachRootComponent(ClientComponentRegistry(child: app));
  }
}

abstract class RenderAdapter {
  late ServerAppBinding binding;
  FutureOr<void> prepare() {}
  void apply(MarkupRenderObject root) {}
}
