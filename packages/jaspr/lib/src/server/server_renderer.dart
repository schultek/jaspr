import 'dart:async';
import 'dart:isolate';

import 'package:shelf/shelf.dart';

import '../foundation/constants.dart';
import '../foundation/sync.dart';
import '../framework/framework.dart';
import 'component_registry.dart';
import 'document/document.dart';
import 'server_app.dart';
import 'server_binding.dart';


/// This spawns an isolate for each render, in order to avoid conflicts with static instances and multiple parallel requests
Future<Response> renderApp(SetupFunction setup, Request request, Future<String> Function(String) loadFile) async {
  var port = ReceivePort();

  /// We support two modes here, rendered-html and data-only
  /// rendered-html does normal ssr, but data-only only returns the preloaded state data as json
  if (request.headers['jaspr-mode'] == 'data-only') {
    var message = _RenderMessage(setup, ComponentRegistry.data, request.url, port.sendPort);

    await Isolate.spawn(_renderData, message);
    var result = await port.first;

    return Response.ok(result, headers: {'Content-Type': 'application/json'});
  } else {
    var message = _RenderMessage(setup, ComponentRegistry.data, request.url, port.sendPort);

    await Isolate.spawn(_renderHtml, message);

    var resultCompleter = Completer<String>.sync();

    var sub = port.listen((message) async {
      if (message is String) {
        resultCompleter.complete(message);
      } else if (message is LoadFileRequest) {
        message.sendPort.send(await loadFile(message.name));
      }
    });

    var result = await resultCompleter.future;
    sub.cancel();

    return Response.ok(result, headers: {'Content-Type': 'text/html'});
  }
}

class _RenderMessage {
  SetupFunction setup;
  ComponentRegistryData? registryData;
  Uri requestUri;
  SendPort sendPort;

  _RenderMessage(this.setup, this.registryData, this.requestUri, this.sendPort);
}

/// Runs the app and returns the rendered html
void _renderHtml(_RenderMessage message) async {
  AppBinding.ensureInitialized()
    ..setRegistryData(message.registryData)
    ..setCurrentUri(message.requestUri)
    ..setSendPort(message.sendPort);
  message.setup();

  var html = await AppBinding.ensureInitialized().render();
  message.sendPort.send(html);
}

/// Runs the app and returns the preloaded state data as json
void _renderData(_RenderMessage message) async {
  AppBinding.ensureInitialized()
    ..setRegistryData(message.registryData)
    ..setCurrentUri(message.requestUri);
  message.setup();

  var data = await AppBinding.ensureInitialized().data();
  message.sendPort.send(data);
}
