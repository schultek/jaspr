import 'dart:async';
import 'dart:isolate';


import 'component_registry.dart';
import 'document/document.dart';
import 'server_app.dart';
import 'server_binding.dart';

/// This spawns an isolate for each render, in order to avoid conflicts with static instances and multiple parallel requests
Future<String> renderHtml(SetupFunction setup, Uri requestUri, Future<String> Function(String) loadFile) async {
  var port = ReceivePort();

  var message = _RenderMessage(setup, ComponentRegistry.data, requestUri, port.sendPort);

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

  return result;
}

/// This spawns an isolate for each render, in order to avoid conflicts with static instances and multiple parallel requests
Future<String> renderData(SetupFunction setup, Uri requestUri) async {
  var port = ReceivePort();
  var message = _RenderMessage(setup, ComponentRegistry.data, requestUri, port.sendPort);

  await Isolate.spawn(_renderData, message);
  var result = await port.first;

  return result;
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
