import 'package:jaspr/jaspr.dart';

enum TreeMode {
  client,
  server,
  combined,
}

class TreeState {
  final String url;
  String id;
  int timestamp;
  ClientTree? clientTree;
  ServerTree? serverTree;

  TreeState({
    required this.url,
    required this.id,
    required this.timestamp,
    this.clientTree,
    this.serverTree,
  });
}

class ServerTree {
  final DiagnosticsNode tree;

  ServerTree({required this.tree});
}

class ClientTree {
  final String attachTarget;
  final DiagnosticsNode tree;

  ClientTree({required this.attachTarget, required this.tree});
}

extension PropMap on List<DiagnosticsProperty> {
  DiagnosticsProperty? get(String key) {
    return where((p) => p.name == key).firstOrNull;
  }
}
