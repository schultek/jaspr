@JS()
library js_data;

import 'dart:convert';
import 'dart:js_interop';

import '../foundation/sync.dart';

@JS('jaspr')
external _JasprConfig? get _config;

JasprConfig get jasprConfig => JasprConfig();

class JasprConfig {
  Map<String, dynamic>? get sync {
    return decodeConfig(_config?.sync);
  }
}

class ComponentConfig {
  final _ComponentConfig _config;
  ComponentConfig._(this._config);

  String get id => _config.id;
  String get name => _config.name;
  Map<String, dynamic> get params => decodeConfig(_config.params) ?? {};
}

@JS('JSON.stringify')
external String _jsonStringify(JSAny obj);

@JS()
@staticInterop
class _JasprConfig {}

extension _JasprConfigExtension on _JasprConfig {
  external JSObject? get sync;
}

@JS()
@staticInterop
class _ComponentConfig {}

extension _ComponentConfigExtension on _ComponentConfig {
  external String get id;
  external String get name;
  external JSObject? get params;
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
