@JS()
library js_data;

import 'dart:convert';

import 'package:js/js.dart';

import '../foundation/sync.dart';

@JS('jaspr')
external _JasprConfig? get _config;

JasprConfig get jasprConfig => JasprConfig();

class JasprConfig {
  Map<String, dynamic>? get sync {
    return decodeConfig(_config?.sync);
  }
}

@JS('JSON.stringify')
external String _jsonStringify(Object obj);

@JS()
class _JasprConfig {
  external dynamic get sync;
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
