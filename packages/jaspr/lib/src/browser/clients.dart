import 'dart:async';

import '../framework/framework.dart';
import 'js_data.dart';
import 'run_app.dart';

typedef ClientLoader = FutureOr<ClientBuilder> Function();
typedef ClientBuilder = Component Function(ConfigParams);

class ConfigParams {
  final Map<String, dynamic> _params;

  ConfigParams(this._params);

  T get<T>(String key) {
    if (_params[key] is! T) {
      print("$key is not $T: ${_params[key]}");
    }
    return _params[key];
  }
}

void registerClientsSync(Map<String, ClientBuilder> clients) {
  _applyClients((name) => clients[name]!);
}

void registerClients(Map<String, ClientLoader> clients) {
  final Map<String, ClientBuilder> builders = {};
  _applyClients((name) {
    var client = (builders[name] ?? clients[name]!()) as FutureOr<ClientBuilder>;
    if (client is ClientBuilder) {
      return builders[name] = client;
    } else {
      return client.then((b) => builders[name] = b);
    }
  });
}

ClientLoader loadClient(Future<void> Function() loader, ClientBuilder builder) {
  return () => loader().then((_) => builder);
}

void _runClient(ClientBuilder builder, ConfigParams params, String id) {
  runApp(builder(params), attachTo: id);
}

void _applyClients(FutureOr<ClientBuilder> Function(String) fn) {
  var comps = jasprConfig.comp;
  if (comps == null) return;

  for (var comp in comps) {
    var builder = fn(comp.name);
    if (builder is ClientBuilder) {
      _runClient(builder, ConfigParams(comp.params), comp.id);
    } else {
      builder.then((b) => _runClient(b, ConfigParams(comp.params), comp.id));
    }
  }
}

void runAppWithParams(ClientBuilder appBuilder) {
  var appConfig = jasprConfig.comp?.firstOrNull;
  _runClient(appBuilder, ConfigParams(appConfig?.params ?? {}), appConfig?.id ?? 'body');
}
