import 'dart:async';
import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';

import '../main.init.dart';

void Function(void Function()) _debounce<T>(Duration duration) {
  Timer? timer;
  return (fn) {
    timer?.cancel();
    timer = Timer(duration, fn);
  };
}

void Function(T) debounce<T>(void Function(T) fn, Duration duration) {
  var d = _debounce(duration);
  return (v) => d(() => fn(v));
}

void Function(T, U) debounce2<T, U>(void Function(T, U) fn, Duration duration) {
  var d = _debounce(duration);
  return (a, b) => d(() => fn(a, b));
}

extension DebounceStream<T> on Stream<T> {
  Stream<T> debounce(Duration duration) {
    return transform(StreamTransformer.fromHandlers(handleData: debounce2((data, sink) => sink.add(data), duration)));
  }
}

class MapperCodec<T> extends Codec<T, dynamic> {
  MapperCodec() {
    initializeMappers();
  }

  @override
  Converter<dynamic, T> get decoder => MapperDecoder();

  @override
  Converter<T, dynamic> get encoder => MapperEncoder();
}

class MapperDecoder<T> extends Converter<dynamic, T> {
  @override
  T convert(input) {
    return MapperContainer.globals.fromJson(input);
  }
}

class MapperEncoder<T> extends Converter<T, dynamic> {
  @override
  dynamic convert(T input) {
    return MapperContainer.globals.toJson(input);
  }
}
