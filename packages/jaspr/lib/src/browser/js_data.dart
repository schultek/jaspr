@JS()
library js_data;

import 'dart:convert';
import 'dart:js';

import 'package:js/js.dart';
import '../foundation/sync.dart';

@JS('jaspr')
external _JasprConfig? get _config;

JasprConfig get jasprConfig => JasprConfig();

class JasprConfig {
  Map<String, dynamic>? get sync {
    return decodeConfig(_config?.sync);
  }

  List<IslandConfig>? get islands {
    return _config?.islands?.map((c) => IslandConfig(c)).toList();
  }

  AppConfig? get app {
    return _config?.app != null ? AppConfig(_config!.app!) : null;
  }
}

class IslandConfig {
  final _IslandConfig _config;
  IslandConfig(this._config);

  String get id => _config.id;
  String get name => _config.name;
  Map<String, dynamic> get params => decodeConfig(_config.params) ?? {};
}

class AppConfig {
  final _AppConfig _config;
  AppConfig(this._config);

  String get id => _config.id;
  Map<String, dynamic> get params => decodeConfig(_config.params) ?? {};
}

@JS('JSON.stringify')
external String _jsonStringify(Object obj);

@JS()
class _JasprConfig {
  external dynamic get sync;
  external JsArray<_IslandConfig>? get islands;
  external _AppConfig? get app;
}

@JS()
class _IslandConfig {
  external String id;
  external String name;
  external dynamic params;
}

@JS()
class _AppConfig {
  external String id;
  external dynamic params;
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