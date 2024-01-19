import 'dart:async';
import 'dart:convert';

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../framework/framework.dart';
import 'document/document.dart';
import 'markup_render_object.dart';

/// Global component binding for the server
class ServerAppBinding extends AppBinding with ComponentsBinding, DocumentBinding {
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

    var renderObject = rootElement!.renderObject as MarkupRenderObject;
    return renderDocument(renderObject);
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
}
