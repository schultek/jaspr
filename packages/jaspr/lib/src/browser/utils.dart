import 'package:universal_web/web.dart' as web;

extension NodeListIterable on web.NodeList {
  Iterable<web.Node> toIterable() sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)!;
    }
  }
}

extension NamedNodeMapMap on web.NamedNodeMap {
  Map<String, String> toMap() {
    final map = <String, String>{};
    for (var i = 0; i < length; i++) {
      final item = this.item(i)!;
      map[item.name] = item.value;
    }
    return map;
  }
}
