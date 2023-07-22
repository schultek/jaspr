import 'dart:typed_data';

import 'foundation.dart';

class MethodChannel {
  const MethodChannel(this.name, [this.codec = const StandardMethodCodec(), BinaryMessenger? binaryMessenger]);

  final String name;

  final MethodCodec codec;

  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    throw UnsupportedError('Method channels are not supported in jaspr.');
  }

  Future<List<T>?> invokeListMethod<T>(String method, [dynamic arguments]) async {
    throw UnsupportedError('Method channels are not supported in jaspr.');
  }

  Future<Map<K, V>?> invokeMapMethod<K, V>(String method, [dynamic arguments]) async {
    throw UnsupportedError('Method channels are not supported in jaspr.');
  }

  void setMethodCallHandler(Future<dynamic> Function(MethodCall call)? handler) {
    throw UnsupportedError('Method channels are not supported in jaspr.');
  }
}

class MethodCall {
  const MethodCall(this.method, [this.arguments]);

  final String method;
  final dynamic arguments;
}

abstract class MessageCodec<T> {
  ByteData? encodeMessage(T message);
  T? decodeMessage(ByteData? message);
}

class StandardMessageCodec implements MessageCodec<Object?> {
  /// Creates a [MessageCodec] using the Flutter standard binary encoding.
  const StandardMessageCodec();

  @override
  Object? decodeMessage(ByteData? message) {
    throw UnsupportedError('Method codecs are not supported in jaspr.');
  }

  @override
  ByteData? encodeMessage(Object? message) {
    throw UnsupportedError('Method codecs are not supported in jaspr.');
  }

  void writeValue(WriteBuffer buffer, Object? value) {
    throw UnsupportedError('Method codecs are not supported in jaspr.');
  }

  Object? readValue(ReadBuffer buffer) {
    throw UnsupportedError('Method codecs are not supported in jaspr.');
  }

  Object? readValueOfType(int type, ReadBuffer buffer) {
    throw UnsupportedError('Method codecs are not supported in jaspr.');
  }
}

typedef MessageHandler = Future<ByteData?>? Function(ByteData? message);

/// A messenger which sends binary data across the Flutter platform barrier.
///
/// This class also registers handlers for incoming messages.
abstract class BinaryMessenger {
  const BinaryMessenger();

  Future<ByteData?>? send(String channel, ByteData? message);

  void setMessageHandler(String channel, MessageHandler? handler);
}

class BasicMessageChannel<T> {
  const BasicMessageChannel(this.name, this.codec, {BinaryMessenger? binaryMessenger});

  final String name;
  final MessageCodec<T> codec;

  Future<T?> send(T message) async {
    throw UnsupportedError('Message channels are not supported in jaspr.');
  }

  void setMessageHandler(Future<T> Function(T? message)? handler) {
    throw UnsupportedError('Message channels are not supported in jaspr.');
  }

  void setMockMessageHandler(Future<T> Function(T? message)? handler) {
    throw UnsupportedError('Message channels are not supported in jaspr.');
  }
}

class PlatformException implements Exception {
  PlatformException({
    required this.code,
    this.message,
    this.details,
    this.stacktrace,
  });

  final String code;
  final String? message;
  final dynamic details;
  final String? stacktrace;
}

class EventChannel {
  const EventChannel(this.name, [this.codec = const StandardMethodCodec(), BinaryMessenger? binaryMessenger]);

  final String name;

  final MethodCodec codec;

  BinaryMessenger get binaryMessenger {
    throw UnsupportedError('Event channels are not supported in jaspr.');
  }

  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    throw UnsupportedError('Event channels are not supported in jaspr.');
  }
}

abstract class MethodCodec {
  ByteData encodeMethodCall(MethodCall methodCall);

  MethodCall decodeMethodCall(ByteData? methodCall);

  dynamic decodeEnvelope(ByteData envelope);

  ByteData encodeSuccessEnvelope(Object? result);

  ByteData encodeErrorEnvelope({required String code, String? message, Object? details});
}

class StandardMethodCodec implements MethodCodec {
  const StandardMethodCodec([this.messageCodec = const StandardMessageCodec()]);

  final StandardMessageCodec messageCodec;

  @override
  ByteData encodeMethodCall(MethodCall methodCall) {
    throw UnsupportedError('Method codecs are not supported in jaspr.');
  }

  @override
  MethodCall decodeMethodCall(ByteData? methodCall) {
    throw UnsupportedError('Method codecs are not supported in jaspr.');
  }

  @override
  ByteData encodeSuccessEnvelope(Object? result) {
    throw UnsupportedError('Method codecs are not supported in jaspr.');
  }

  @override
  ByteData encodeErrorEnvelope({required String code, String? message, Object? details}) {
    throw UnsupportedError('Method codecs are not supported in jaspr.');
  }

  @override
  dynamic decodeEnvelope(ByteData envelope) {
    throw UnsupportedError('Method codecs are not supported in jaspr.');
  }
}
