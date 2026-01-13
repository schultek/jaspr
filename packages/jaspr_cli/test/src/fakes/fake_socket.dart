import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';

import 'fake_io.dart';

extension FakeSocketIO on FakeIO {
  Future<WebSocket> upgradeToReverseWebSocket(FakeSocket socket) async {
    final serverSocket = FakeServerSocket(InternetAddress.anyIPv4, 0, this)..addSocket(socket.reverse);
    final server = HttpServer.listenOn(serverSocket);
    final webSocket = await server.transform(WebSocketTransformer()).first;
    serverSocket.close();
    return webSocket;
  }
}

class FakeServerSocket extends Stream<io.Socket> implements io.ServerSocket {
  FakeServerSocket(this.address, this.port, this.fakeIO);
  @override
  final io.InternetAddress address;

  @override
  final int port;

  final FakeIO fakeIO;

  final _controller = StreamController<io.Socket>();

  void addSocket(io.Socket socket) => _controller.add(socket);

  @override
  StreamSubscription<io.Socket> listen(
    void Function(io.Socket event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Future<io.ServerSocket> close() async {
    _controller.close();
    return this;
  }
}

class FakeSocket extends Stream<Uint8List> implements io.Socket {
  FakeSocket(this.address, this.port);

  @override
  final io.InternetAddress address;
  @override
  final int port;

  final _controller = StreamController<Uint8List>();
  final _sink = FakeIOSink();

  void send(String message) => _controller.add(utf8.encode(message));

  StreamQueue<String> get messages => _sink.queue;

  io.Socket get reverse => _ReverseFakeSocket(this);

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Encoding get encoding => _sink.sink.encoding;
  @override
  set encoding(Encoding encoding) => _sink.sink.encoding = encoding;

  @override
  void add(List<int> data) => _sink.sink.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) => _sink.sink.addError(error, stackTrace);

  @override
  Future<dynamic> addStream(Stream<List<int>> stream) => _sink.sink.addStream(stream);

  @override
  Future<dynamic> close() => _sink.sink.close();

  @override
  Future<dynamic> get done => _sink.sink.done;

  @override
  Future<dynamic> flush() => _sink.sink.flush();

  @override
  void write(Object? object) => _sink.sink.write(object);

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) => _sink.sink.writeAll(objects, separator);

  @override
  void writeCharCode(int charCode) => _sink.sink.writeCharCode(charCode);

  @override
  void writeln([Object? object = '']) => _sink.sink.writeln(object);

  @override
  io.InternetAddress get remoteAddress => address;

  @override
  int get remotePort => port;

  @override
  bool setOption(io.SocketOption option, bool enabled) {
    return true;
  }

  @override
  Uint8List getRawOption(io.RawSocketOption option) {
    return option.value;
  }

  @override
  void setRawOption(io.RawSocketOption option) {}

  @override
  void destroy() {}
}

class _ReverseFakeSocket extends Stream<Uint8List> implements io.Socket {
  _ReverseFakeSocket(this._socket);

  final FakeSocket _socket;

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _socket._sink.reverse
        .map(Uint8List.fromList)
        .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Encoding get encoding => _socket.encoding;

  @override
  set encoding(Encoding encoding) => _socket.encoding = encoding;

  @override
  void add(List<int> data) => _socket._controller.add(Uint8List.fromList(data));

  @override
  void addError(Object error, [StackTrace? stackTrace]) => _socket._controller.addError(error, stackTrace);

  @override
  Future<dynamic> addStream(Stream<List<int>> stream) => _socket._controller.addStream(stream.map(Uint8List.fromList));

  @override
  Future<dynamic> close() => _socket._controller.close();

  @override
  Future<dynamic> get done => _socket._controller.done;

  @override
  Future<dynamic> flush() async {}

  @override
  void write(Object? object) => _socket._controller.add(utf8.encode(object.toString()));

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) =>
      _socket._controller.add(utf8.encode(objects.join(separator)));

  @override
  void writeCharCode(int charCode) => _socket._controller.add(utf8.encode(String.fromCharCode(charCode)));

  @override
  void writeln([Object? object = '']) => _socket._controller.add(utf8.encode('$object\n'));

  @override
  io.InternetAddress get address => _socket.address;

  @override
  void destroy() {}

  @override
  Uint8List getRawOption(io.RawSocketOption option) {
    return option.value;
  }

  @override
  int get port => _socket.port;

  @override
  io.InternetAddress get remoteAddress => _socket.remoteAddress;

  @override
  int get remotePort => _socket.remotePort;

  @override
  bool setOption(io.SocketOption option, bool enabled) {
    return true;
  }

  @override
  void setRawOption(io.RawSocketOption option) {}
}
