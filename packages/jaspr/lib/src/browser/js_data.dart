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

  List<ComponentConfig>? get comp {
    return _config?.comps?.map((c) => ComponentConfig._(c)).toList();
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
external String _jsonStringify(Object obj);

@JS()
class _JasprConfig {
  external dynamic get sync;
  external JsArray<_ComponentConfig>? get comps;
}

@JS()
class _ComponentConfig {
  external String id;
  external String name;
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
