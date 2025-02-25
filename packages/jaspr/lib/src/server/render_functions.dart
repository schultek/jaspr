import 'dart:async';
import 'dart:isolate';

import 'package:shelf/shelf.dart';
// ignore: implementation_imports
import 'package:shelf/src/headers.dart';

import '../../jaspr.dart';
import 'run_app.dart';
import 'server_app.dart';
import 'server_binding.dart';

typedef RequestLike = ({String url, Headers headers});

/// Performs the rendering process and provides the created [AppBinding] to [setup].
///
/// If [Jaspr.useIsolates] is true, this spawns an isolate for each render.
Future<ResponseLike> render(SetupFunction setup, Request request, FileLoader loadFile, bool standalone) async {
  var url = request.url.normalizePath().toString();
  if (!url.startsWith('/')) {
    url = '/$url';
  }

  final RequestLike r = (url: url, headers: Headers.from(request.headersAll));

  if (!Jaspr.useIsolates) {
    var binding = ServerAppBinding(r, loadFile: loadFile);
    setup(binding);
    final body = await binding.render(standalone: standalone);
    return (
      statusCode: binding.responseStatusCode,
      body: body,
      headers: binding.responseHeaders,
    );
  }

  var resultCompleter = Completer<ResponseLike>.sync();

  var port = ReceivePort();
  var errorPort = ReceivePort();

  var errorSub = errorPort.listen((message) {
    var [error, stack] = message;
    resultCompleter.completeError(error, StackTrace.fromString(stack));
  });

  var sub = port.listen((message) async {
    if (message is ResponseLike) {
      resultCompleter.complete(message);
    } else if (message is _LoadFileRequest) {
      message.sendPort.send(await loadFile(message.name));
    }
  });

  try {
    var message = _RenderMessage(setup, r, standalone, port.sendPort);
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

  var binding = ServerAppBinding(message.request, loadFile: (name) {
    receivePort ??= ReceivePort();
    message.sendPort.send(_LoadFileRequest(name, receivePort!.sendPort));
    return receivePort!.first.then((value) => value);
  });
  message.setup(binding);

  var body = await binding.render(standalone: message.standalone);
  final ResponseLike response = (
    statusCode: binding.responseStatusCode,
    body: body,
    headers: binding.responseHeaders,
  );
  message.sendPort.send(response);
}

class _RenderMessage {
  final SetupFunction setup;
  final RequestLike request;
  final bool standalone;
  final SendPort sendPort;

  _RenderMessage(this.setup, this.request, this.standalone, this.sendPort);
}

class _LoadFileRequest {
  final String name;
  final SendPort sendPort;

  _LoadFileRequest(this.name, this.sendPort);
}
