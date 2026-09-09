import 'dart:io';

/// Checks if a given TCP port is available on [InternetAddress.anyIPv4].
Future<bool> isPortAvailable(int port) async {
  try {
    final socket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    await socket.close();
    return true;
  } catch (_) {
    return false;
  }
}

/// Finds an available TCP port starting from [defaultPort].
///
/// Increments from [defaultPort] until an available port not in [exclude] is found.
Future<int> findAvailablePort(int defaultPort, {Iterable<int> exclude = const []}) async {
  final excludeSet = exclude.toSet();
  var port = defaultPort;
  while (port <= 65535) {
    if (!excludeSet.contains(port) && await isPortAvailable(port)) {
      return port;
    }
    port++;
  }
  throw SocketException('No available ports found starting from $defaultPort');
}
