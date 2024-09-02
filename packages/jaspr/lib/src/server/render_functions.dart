import 'dart:async';
import 'dart:isolate';

import '../../jaspr.dart';
import 'server_app.dart';
import 'server_binding.dart';

typedef FileLoader = Future<String?> Function(String);

/// Performs the rendering process and provides the created [AppBinding] to [setup].
///
/// If [Jaspr.useIsolates] is true, this spawns an isolate for each render.
Future<String> render(SetupFunction setup, Uri requestUri, FileLoader loadFile) async {
  if (!Jaspr.useIsolates) {
    var binding = ServerAppBinding()
      ..setCurrentUri(requestUri)
      ..setFileHandler(loadFile);
    setup(binding);
    return binding.render();
  }

  var resultCompleter = Completer<String>.sync();

  var port = ReceivePort();
  var errorPort = ReceivePort();

  var errorSub = errorPort.listen((message) {
    var [error, stack] = message;
    resultCompleter.completeError(error, StackTrace.fromString(stack));
  });

  var sub = port.listen((message) async {
    if (message is String) {
      resultCompleter.complete(message);
    } else if (message is _LoadFileRequest) {
      message.sendPort.send(await loadFile(message.name));
    }
  });

  try {
    var message = _RenderMessage(setup, requestUri, port.sendPort);
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

  var result = await binding.render();
  message.sendPort.send(result);
}

class _RenderMessage {
  final SetupFunction setup;
  final Uri requestUri;
  final SendPort sendPort;

  _RenderMessage(this.setup, this.requestUri, this.sendPort);
}

class _LoadFileRequest {
  final String name;
  final SendPort sendPort;

  _LoadFileRequest(this.name, this.sendPort);
}
