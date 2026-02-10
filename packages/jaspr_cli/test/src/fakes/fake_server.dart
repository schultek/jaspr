import 'dart:io';

import 'package:jaspr_cli/src/project.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'fake_io.dart';
import 'fake_socket.dart';

extension FakeProxyIO on FakeIO {
  Future<FakeProxyConnection> connectToProxy([String port = serverProxyPort]) async {
    final proxySocket = await serverSockets.next;
    expect(proxySocket.port, equals(int.parse(port)));

    return FakeProxyConnection(proxySocket, this);
  }

  FakeServer setupFakeServer(int port) {
    final fakeSocket = FakeServerSocket(InternetAddress.anyIPv4, port, this);
    return FakeServer(fakeSocket, this);
  }
}

class FakeProxyConnection {
  FakeProxyConnection(this.socket, this.io) {
    when(() => io.sockets.connect('localhost', socket.port)).thenAnswer((_) async {
      final requestSocket = FakeSocket(socket.address, socket.port);
      socket.addSocket(requestSocket.reverse);
      return requestSocket;
    });
  }

  final FakeServerSocket socket;
  final FakeIO io;

  final HttpClient client = HttpClient();

  Future<void> sendFakeRequest(String path, String body) async {
    final request = await client.openUrl('POST', Uri.http('localhost:${socket.port}', path));
    request.write(body);
    await request.close();
  }
}

class FakeServer {
  FakeServer(this.socket, this.io) {
    HttpServer.listenOn(socket).listen((req) {
      listeners[req.uri.path]!.call(req);
    });

    when(() => io.sockets.connect('localhost', socket.port)).thenAnswer((_) async {
      final routeSocket = FakeSocket(InternetAddress.anyIPv4, socket.port);
      socket.addSocket(routeSocket.reverse);
      return routeSocket;
    });
  }

  final FakeServerSocket socket;
  final FakeIO io;

  final Map<String, void Function(HttpRequest)> listeners = {};

  void onRequest(String path, void Function(HttpRequest) callback) {
    listeners[path] = callback;
  }
}
