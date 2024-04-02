import 'dart:async';
import 'dart:isolate';

import '../../jaspr.dart';
import 'server_app.dart';
import 'server_binding.dart';

/// This spawns an isolate for each render, in order to avoid conflicts with static instances and multiple parallel requests
Future<String> renderHtml(SetupFunction setup, Uri requestUri,
    Future<String> Function(String) loadFile) async {
  if (Jaspr.useIsolates) {
    var port = ReceivePort();
    var errorPort = ReceivePort();
    var resultCompleter = Completer<String>.sync();
    errorPort.listen((message) {
      if (message is List) {
        resultCompleter.completeError(message[0]);
      }
    });

    var message = _RenderMessage(setup, requestUri, port.sendPort);
    await Isolate.spawn(_renderHtml, message, onError: errorPort.sendPort);

    var sub = port.listen((message) async {
      if (message is String) {
        resultCompleter.complete(message);
      } else if (message is LoadFileRequest) {
        message.sendPort.send(await loadFile(message.name));
      }
    });

    try {
      var result = await resultCompleter.future;
      return result;
    } finally {
      sub.cancel();
      port.close();
      errorPort.close();
    }
  } else {
    var binding = ServerAppBinding()
      ..setCurrentUri(requestUri)
      ..setFileHandler(loadFile);
    setup(binding);

    return binding.render();
  }
}

/// This spawns an isolate for each render, in order to avoid conflicts with static instances and multiple parallel requests
Future<String> renderData(SetupFunction setup, Uri requestUri) async {
  if (Jaspr.useIsolates) {
    var port = ReceivePort();
    var message = _RenderMessage(setup, requestUri, port.sendPort);

    await Isolate.spawn(_renderData, message);
    var result = await port.first;

    return result;
  } else {
    var binding = ServerAppBinding()..setCurrentUri(requestUri);
    setup(binding);

    return binding.data();
  }
}

class _RenderMessage {
  SetupFunction setup;
  Uri requestUri;
  SendPort sendPort;

  _RenderMessage(this.setup, this.requestUri, this.sendPort);
}

/// Runs the app and returns the rendered html
void _renderHtml(_RenderMessage message) async {
  ReceivePort? receivePort;

  var binding = ServerAppBinding()
    ..setCurrentUri(message.requestUri)
    ..setFileHandler((name) {
      receivePort ??= ReceivePort();
      message.sendPort.send(LoadFileRequest(name, receivePort!.sendPort));
      return receivePort!.first.then((value) => value);
    });
  message.setup(binding);

  var html = await binding.render();
  message.sendPort.send(html);
}

/// Runs the app and returns the preloaded state data as json
void _renderData(_RenderMessage message) async {
  var binding = ServerAppBinding()..setCurrentUri(message.requestUri);
  message.setup(binding);

  var data = await binding.data();
  message.sendPort.send(data);
}

class LoadFileRequest {
  final String name;
  final SendPort sendPort;

  LoadFileRequest(this.name, this.sendPort);
}
