import 'dart:typed_data';

import 'package:flutter/services.dart';

class Registrar extends BinaryMessenger {
  /// Creates a [Registrar].
  ///
  /// The argument is ignored. To create a test [Registrar] with custom behavior,
  /// subclass the [Registrar] class and override methods as appropriate.
  Registrar();

  void registerMessageHandler() {
    throw UnimplementedError();
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    throw UnimplementedError();
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    throw UnimplementedError();
  }
}
