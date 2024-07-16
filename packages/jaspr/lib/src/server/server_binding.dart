import 'dart:async';
import 'dart:convert';

import '../../jaspr.dart';
import 'adapters/client_component_adapter.dart';
import 'adapters/document_adapter.dart';
import 'adapters/sync_script_adapter.dart';
import 'async_build_owner.dart';
import 'markup_render_object.dart';

/// Global component binding for the server
class ServerAppBinding extends AppBinding with ComponentsBinding {
  ServerAppBinding.init({required Uri uri, required Future<String?> Function(String) handler})
      : _currentUri = uri,
        _fileHandler = handler;

  final Uri _currentUri;
  final Future<String?> Function(String) _fileHandler;

  @override
  Uri get currentUri => _currentUri;

  @override
  bool get isClient => false;

  final rootCompleter = Completer.sync();

  @override
  void didAttachRootElement(Element element) {
    rootCompleter.complete();
  }

  Future<String> render() async {
    await rootCompleter.future;

    final root = rootElement!.renderObject as MarkupRenderObject;
    final adapters = [
      ..._adapters.reversed,
      SyncScriptAdapter(getStateData),
      DocumentAdapter(),
    ];

    for (final adapter in adapters.reversed) {
      final r = adapter.prepare();
      if (r is Future) {
        await r;
      }
    }

    for (final adapter in adapters) {
      adapter.apply(root);
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

  Future<String?> loadFile(String name) => _fileHandler(name);

  late final List<RenderAdapter> _adapters = [];

  void addRenderAdapter(RenderAdapter adapter) {
    _adapters.add(adapter);
  }

  JasprOptions? _options;
  JasprOptions get options => _options!;

  // ignore: use_setters_to_change_properties
  void initializeOptions(JasprOptions options) {
    _options = options;
  }

  @override
  Future<void> attachRootComponent(Component app) {
    return super.attachRootComponent(ClientComponentRegistry(child: app));
  }
}

abstract class RenderAdapter {
  FutureOr<void> prepare() {}
  void apply(MarkupRenderObject root) {}
}
