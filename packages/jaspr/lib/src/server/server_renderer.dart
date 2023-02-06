import 'dart:async';
import 'dart:isolate';

import 'document/document.dart';
import 'server_app.dart';
import 'server_binding.dart';

/// This spawns an isolate for each render, in order to avoid conflicts with static instances and multiple parallel requests
Future<String> renderHtml(SetupFunction setup, Uri requestUri, Future<String> Function(String) loadFile, {bool useIsolates = true}) async {
  if (!useIsolates) {
    return _renderHtml(setup, requestUri, null);
  }

  var port = ReceivePort();

  var message = _RenderIsolateMessage(setup, requestUri, port.sendPort);

  await Isolate.spawn(_renderHtmlInIsolate, message);

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

  return result;
}

/// This spawns an isolate for each render, in order to avoid conflicts with static instances and multiple parallel requests
Future<String> renderData(SetupFunction setup, Uri requestUri) async {
  var port = ReceivePort();
  var message = _RenderIsolateMessage(setup, requestUri, port.sendPort);

  await Isolate.spawn(_renderData, message);
  var result = await port.first;

  return result;
}

class _RenderIsolateMessage {
  SetupFunction setup;
  Uri requestUri;
  SendPort sendPort;

  _RenderIsolateMessage(this.setup, this.requestUri, this.sendPort);
}

void _renderHtmlInIsolate(_RenderIsolateMessage message) async {
  var html = await _renderHtml(message.setup, message.requestUri, message.sendPort);
  message.sendPort.send(html);
}

/// Runs the app and returns the rendered html
Future<String> _renderHtml(SetupFunction setup, Uri requestUri, SendPort? sendPort) async {
  AppBinding.ensureInitialized()
    .setCurrentUri(requestUri);
  if (sendPort != null) {
    AppBinding.ensureInitialized().setSendPort(sendPort);
  }
  setup();

  return AppBinding.ensureInitialized().render();
}

/// Runs the app and returns the preloaded state data as json
void _renderData(_RenderIsolateMessage message) async {
  AppBinding.ensureInitialized().setCurrentUri(message.requestUri);
  message.setup();

  var data = await AppBinding.ensureInitialized().data();
  message.sendPort.send(data);
}
