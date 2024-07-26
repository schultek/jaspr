import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/src/headers.dart';

import '../../jaspr.dart';
import '../../server.dart';
import 'adapters/client_component_adapter.dart';
import 'adapters/document_adapter.dart';
import 'adapters/global_styles_adapter.dart';
import 'adapters/sync_script_adapter.dart';
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

  final Map<String, Object> _responseHeaders = {};
  Map<String, Object> get responseHeaders => _responseHeaders;

  @override
  bool get isClient => false;

  final rootCompleter = Completer.sync();

  @override
  void didAttachRootElement(Element element) {
    rootCompleter.complete();
  }

  Future<Response> render() async {
    await rootCompleter.future;

    var root = rootElement!.renderObject as MarkupRenderObject;
    var adapters = [
      ..._adapters.reversed,
      GlobalStylesAdapter(this),
      SyncScriptAdapter(getStateData),
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

    return Response.ok(
      root.renderToHtml(),
      headers: responseHeaders..putIfAbsent('Content-Type', () => 'text/html'),
    );
  }

  Future<Response> data() async {
    await rootCompleter.future;

    return Response.ok(
      jsonEncode(getStateData()),
      headers: responseHeaders..putIfAbsent('Content-Type', () => 'application/json'),
    );
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

  late final List<RenderAdapter> _adapters = [];

  void addRenderAdapter(RenderAdapter adapter) {
    _adapters.add(adapter);
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
  FutureOr<void> prepare() {}
  void apply(MarkupRenderObject root) {}
}
