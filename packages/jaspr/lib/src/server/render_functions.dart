import 'dart:async';
import 'dart:isolate';

import '../../jaspr.dart';
import 'server_app.dart';
import 'server_binding.dart';

enum RenderMode { html, data }

typedef FileLoader = Future<String?> Function(String);

/// Performs the rendering process and provides the created [AppBinding] to [setup].
///
/// If [Jaspr.useIsolates] is true, this spawns an isolate for each render.
Future<String> render(RenderMode mode, SetupFunction setup, Uri requestUri, FileLoader loadFile) async {
  if (!Jaspr.useIsolates) {
    final binding = ServerAppBinding.init(uri: requestUri, handler: loadFile);
    setup(binding);

    return await switch (mode) {
      RenderMode.html => binding.render(),
      RenderMode.data => binding.data(),
    };
  }

  final resultCompleter = Completer<String>.sync();

  final port = ReceivePort();
  final errorPort = ReceivePort();

  final errorSub = errorPort.listen((message) {
    final [error as Object, stack as String] = message as List;
    resultCompleter.completeError(error, StackTrace.fromString(stack));
  });

  final sub = port.listen((message) async {
    if (message is String) {
      resultCompleter.complete(message);
    } else if (message is _LoadFileRequest) {
      message.sendPort.send(await loadFile(message.name));
    }
  });

  try {
    final message = _RenderMessage(mode, setup, requestUri, port.sendPort);
    await Isolate.spawn(_render, message, onError: errorPort.sendPort);

    return await resultCompleter.future;
  } finally {
    sub.cancel();
    errorSub.cancel();
    port.close();
    errorPort.close();
  }
}

Future<void> _render(_RenderMessage message) async {
  ReceivePort? receivePort;

  final binding = ServerAppBinding.init(
    uri: message.requestUri,
    handler: (name) {
      receivePort ??= ReceivePort();
      message.sendPort.send(_LoadFileRequest(name, receivePort!.sendPort));
      return receivePort!.first.then((value) => value as String);
    },
  );
  message.setup(binding);

  final result = await switch (message.mode) {
    RenderMode.html => binding.render(),
    RenderMode.data => binding.data(),
  };
  message.sendPort.send(result);
}

class _RenderMessage {
  _RenderMessage(this.mode, this.setup, this.requestUri, this.sendPort);

  final RenderMode mode;
  final SetupFunction setup;
  final Uri requestUri;
  final SendPort sendPort;
}

class _LoadFileRequest {
  _LoadFileRequest(this.name, this.sendPort);

  final String name;
  final SendPort sendPort;
}
