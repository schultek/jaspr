import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import '../../jaspr.dart';
import '../../server.dart';
import 'server_app.dart';
import 'server_binding.dart';

enum RenderMode { html, data }

typedef FileLoader = Future<String?> Function(String);

/// Performs the rendering process and provides the created [AppBinding] to [setup].
///
/// If [Jaspr.useIsolates] is true, this spawns an isolate for each render.
Future<Response> render(RenderMode mode, SetupFunction setup, Uri requestUri, FileLoader loadFile) async {
  if (!Jaspr.useIsolates) {
    var binding = ServerAppBinding()
      ..setCurrentUri(requestUri)
      ..setFileHandler(loadFile);
    setup(binding);

    return await switch (mode) {
      RenderMode.html => binding.render(),
      RenderMode.data => binding.data(),
    };
  }

  var resultCompleter = Completer<Response>.sync();

  var port = ReceivePort();
  var errorPort = ReceivePort();

  var errorSub = errorPort.listen((message) {
    var [error, stack] = message;
    resultCompleter.completeError(error, StackTrace.fromString(stack));
  });

  var sub = port.listen((message) async {
    if (message is Map) {
      resultCompleter.complete(Response(
        message['statusCode'],
        body: message['body'],
        headers: message['headers'],
      ));
    } else if (message is _LoadFileRequest) {
      message.sendPort.send(await loadFile(message.name));
    }
  });

  try {
    var message = _RenderMessage(mode, setup, requestUri, port.sendPort);
    await Isolate.spawn(_render, message, onError: errorPort.sendPort);

    return await resultCompleter.future;
  } finally {
    sub.cancel();
    errorSub.cancel();
    port.close();
    errorPort.close();
  }
}

void _render(_RenderMessage message) async {
  ReceivePort? receivePort;

  var binding = ServerAppBinding()
    ..setCurrentUri(message.requestUri)
    ..setFileHandler((name) {
      receivePort ??= ReceivePort();
      message.sendPort.send(_LoadFileRequest(name, receivePort!.sendPort));
      return receivePort!.first.then((value) => value);
    });
  message.setup(binding);

  Response response = await switch (message.mode) {
    RenderMode.html => binding.render(),
    RenderMode.data => binding.data(),
  };

  message.sendPort.send({
    'statusCode': response.statusCode,
    'body': await response.readAsString(),
    'headers': response.headers,
  });
}

class _RenderMessage {
  final RenderMode mode;
  final SetupFunction setup;
  final Uri requestUri;
  final SendPort sendPort;

  _RenderMessage(this.mode, this.setup, this.requestUri, this.sendPort);
}

class _LoadFileRequest {
  final String name;
  final SendPort sendPort;

  _LoadFileRequest(this.name, this.sendPort);
}
