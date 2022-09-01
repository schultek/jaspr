@JS()
library js_data;

import 'dart:convert';
import 'dart:html_common';
import 'dart:js';

import 'package:js/js.dart';
import '../foundation/sync.dart';

@JS('jaspr')
external JasprConfig? get jasprConfig;

@JS('JSON.stringify')
external String _jsonStringify(Object obj);

@JS()
class JasprConfig {
  external dynamic get sync;
  external JsArray<IslandConfig>? get islands;
  external AppConfig? get app;
}

@JS()
class IslandConfig {
  external String id;
  external String name;
  external dynamic params;
}

@JS()
class AppConfig {
  external String id;
  external dynamic params;
}

extension IslandConfigParams on IslandConfig? {
  ConfigParams get config => ConfigParams.from(this?.params);
}

extension AppConfigParams on AppConfig? {
  ConfigParams get config => ConfigParams.from(this?.params);
}

Map<String, dynamic>? decodeConfig(dynamic config) {
  if (config == null) {
    return null;
  } else if (config is String) {
    return stateCodec.decode(config).cast<String, dynamic>();
  } else {
    return jsonDecode(_jsonStringify(config));
  }
}

class ConfigParams {
  final Map<String, dynamic> _params;

  ConfigParams(this._params);

  factory ConfigParams.from(dynamic params) {
    return ConfigParams(decodeConfig(params) ?? {});
  }

  T get<T>(String key) {
    if (_params[key] is! T) {
      print("$key is not $T: ${_params[key]}");
    }
    return _params[key];
  }
}